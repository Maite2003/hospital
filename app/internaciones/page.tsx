"use client"

import { useEffect, useState } from "react"
import { useFormik } from "formik"
import * as Yup from "yup"
import { UserPlus, Activity, BedDouble, RefreshCw, XCircle, Calendar, Stethoscope, User, MapPin } from "lucide-react"
import type { TipoListadoCamas, crearInternacion, Internacion, InternacionActiva } from "@/types/types"
import axios from "axios"

interface InternacionConDetalles extends Internacion {
  pacienteNombre?: string
  pacienteApellido?: string
  medicoNombre?: string
  medicoApellido?: string
  camaActual?: TipoListadoCamas
}

export default function GestionInternacionesPage() {
  const [camasDisponibles, setCamasDisponibles] = useState<TipoListadoCamas[]>([])
  const [internacionesActivas, setInternacionesActivas] = useState<InternacionActiva[]>([])
  const [editandoInternacion, setEditandoInternacion] = useState<number | null>(null)
  const [nuevaCamaSeleccionada, setNuevaCamaSeleccionada] = useState<string>("")

  async function loadTodasLasCamas() {
    try {
      const res = await axios.get("/api/reportes/camas_libres")
      if (res.status === 200) {
        return res.data.camas as TipoListadoCamas[]
      }
      return []
    } catch {
      return []
    }
  }

  // Conseguir camas libres
  async function loadCamas() {
    const camitas = await loadTodasLasCamas()
    const soloLibres = camitas.filter((cama) => cama.esta_libre)
    setCamasDisponibles(soloLibres)
  }

  async function loadInternacionesActivas() {
    try {
      const res = await axios.get("/api/internaciones")

      if (res.status === 200) {
        const activas = res.data.internaciones;

        const todasLasCamas = await loadTodasLasCamas()

        // Get patient and doctor names
        const internacionesConDetalles = await Promise.all(
          activas.map(async (int: InternacionActiva) => {
            try {
              const [pacienteRes, medicoRes] = await Promise.all([
                axios.get(`/api/personas/${int.nro_dni}`),
                axios.get(`/api/personas/${int.nro_matricula}`),
              ])

              const camaActual = todasLasCamas.find(
                (c) => c.id_habitacion === int.id_habitacion && c.id_cama === int.id_cama,
              )

              return {
                ...int,
                pacienteNombre: pacienteRes.data.persona?.nombre || "",
                pacienteApellido: pacienteRes.data.persona?.apellido || "",
                medicoNombre: medicoRes.data.persona?.nombre || "",
                medicoApellido: medicoRes.data.persona?.apellido || "",
                camaActual: camaActual,
              }
            } catch {
              return int
            }
          }),
        )

        setInternacionesActivas(internacionesConDetalles)
      }
    } catch (error) {
      console.error("Error al cargar internaciones activas:", error)
    }
  }

  // Cargar camas al inicio
  useEffect(() => {
    loadCamas()
    loadInternacionesActivas()
  }, [])

  async function handleCambiarCama(idInternacion: number) {
    if (!nuevaCamaSeleccionada) {
      alert("Por favor seleccione una cama")
      return
    }

    const [habitacionId, camaId] = nuevaCamaSeleccionada.split("-")

    try {
      const res = await axios.post(`/api/internaciones/${idInternacion}`, {
        id_habitacion: Number(habitacionId),
        id_cama: Number(camaId),
      })

      if (res.status === 200) {
        alert("Cama modificada exitosamente")
        setEditandoInternacion(null)
        setNuevaCamaSeleccionada("")
        loadCamas()
        loadInternacionesActivas()
      }
    } catch (error) {
      let errorMessage = "Error al modificar la cama"
      if (axios.isAxiosError(error) && error.response) {
        errorMessage = error.response.data.error || errorMessage
      }
      alert(`❌ Error: ${errorMessage}`)
    }
  }

  async function handleTerminarInternacion(idInternacion: number) {
    if (!confirm("¿Está seguro que desea terminar esta internación?")) {
      return
    }

    try {
      const fechaFin = new Date().toISOString()
      const res = await axios.put(`/api/internaciones/${idInternacion}`, {
        fechaHoraFin: fechaFin,
      })

      if (res.status === 200) {
        alert("Internación terminada exitosamente")
        loadCamas()
        loadInternacionesActivas()
      }
    } catch (error) {
      let errorMessage = "Error al terminar la internación"
      if (axios.isAxiosError(error) && error.response) {
        errorMessage = error.response.data.error || errorMessage
      }
      alert(`❌ Error: ${errorMessage}`)
    }
  }

  function calcularDiasInternacion(fechaInicio: Date | string): number {
    const inicio = new Date(fechaInicio)
    const ahora = new Date()
    const diferencia = ahora.getTime() - inicio.getTime()
    return Math.floor(diferencia / (1000 * 60 * 60 * 24))
  }

  function formatearFechaHora(fecha: Date | string): string {
    const d = new Date(fecha)
    return d.toLocaleString("es-AR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const validationSchema = Yup.object({
    dniPaciente: Yup.string()
      .required("Requerido")
      .matches(/^[0-9]{7,8}$/, "El DNI debe contener 8 dígitos numéricos, sin puntos ni espacios."),
    medicoMatricula: Yup.string()
      .required("Requerido")
      .length(4, "La matrícula debe tener exactamente 4 dígitos.")
      .matches(/^[0-9]+$/, "La matrícula debe contener solo dígitos numéricos."),
    camaSeleccionada: Yup.string().required("Seleccione una cama"),
    fechaIngreso: Yup.date().required("Requerido"),
  })

  const formik = useFormik({
    initialValues: {
      dniPaciente: "",
      medicoMatricula: "",
      camaSeleccionada: "",
      fechaIngreso: new Date().toISOString().split("T")[0],
    },
    validationSchema,
    onSubmit: async (values, { resetForm }) => {
      const [habitacionId, camaId] = values.camaSeleccionada.split("-")

      const infoInternacion: crearInternacion = {
        dni_paciente: values.dniPaciente,
        matricula_medico: values.medicoMatricula,
        habitacion_id: Number(habitacionId),
        cama_id: Number(camaId),
        fecha_ingreso: values.fechaIngreso
      };

      try {
        const res = await axios.post("/api/internaciones", infoInternacion)
        console.log(`No tiro error, la respuesta es ${res}`)
        if (res.status == 201) {
          resetForm()
          loadCamas()
          loadInternacionesActivas()
          alert(`Internacion creada con exito`)
        } else {
          resetForm()
          alert(`${res.data.error}`)
        }
      } catch (error) {
        console.log(`Tiro error, el error es ${error}`)
        let errorMessage = "Error de base de datos o conexión desconocido"

        if (axios.isAxiosError(error) && error.response) {
          errorMessage = error.response.data.error || error.response.data.message || JSON.stringify(error.response.data)
        } else if (error instanceof Error) {
          errorMessage = error.message
        }
        alert(`❌ Error: ${errorMessage}`)
      }
    },
  })

  return (
    <div className="animate-in slide-in-from-bottom-4 duration-500">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-800">Gestión de Internaciones</h1>
      </div>

      <div className="max-w-2xl mx-auto bg-white p-8 rounded-xl shadow-sm border border-slate-200">
        <h2 className="text-xl font-semibold text-slate-800 mb-6 flex items-center gap-2">
          <UserPlus className="text-indigo-600" /> Registrar Nueva Internación
        </h2>

        <form onSubmit={formik.handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">DNI Paciente</label>
              <input
                type="text"
                {...formik.getFieldProps("dniPaciente")}
                className="w-full p-2 border border-slate-300 rounded-md outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="Ej: 12345678"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Matrícula Médico</label>
              <input
                type="text"
                {...formik.getFieldProps("medicoMatricula")}
                className="w-full p-2 border border-slate-300 rounded-md outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="Ej: 9988"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Seleccione Cama (Solo Libres)</label>
            <select
              {...formik.getFieldProps("camaSeleccionada")}
              className="w-full p-2 border border-slate-300 rounded-md outline-none focus:ring-2 focus:ring-indigo-500 bg-white"
            >
              <option value="">-- Seleccionar --</option>
              {camasDisponibles.map((c, idx) => (
                <option key={`${c.id_habitacion}-${c.id_cama}-${idx}`} value={`${c.id_habitacion}-${c.id_cama}`}>
                  {c.nombre_sector} | Hab: {c.id_habitacion} | Cama: {c.id_cama} ({c.orientacion})
                </option>
              ))}
            </select>
            {formik.touched.camaSeleccionada && formik.errors.camaSeleccionada && (
              <div className="text-red-500 text-xs mt-1">{formik.errors.camaSeleccionada}</div>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Fecha de Ingreso</label>
            <input
              type="date"
              {...formik.getFieldProps("fechaIngreso")}
              className="w-full p-2 border border-slate-300 rounded-md outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <div className="flex justify-end pt-4">
            <button
              type="submit"
              className="bg-indigo-600 text-white px-6 py-2 rounded-md hover:bg-indigo-700 transition font-medium shadow-sm flex items-center gap-2"
            >
              <Activity className="w-4 h-4" />
              Confirmar Internación
            </button>
          </div>
        </form>
      </div>

      <div className="max-w-6xl mx-auto mt-8 bg-white p-8 rounded-xl shadow-sm border border-slate-200">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-slate-800 flex items-center gap-2">
            <BedDouble className="text-indigo-600" /> Internaciones Activas
          </h2>
          <span className="bg-indigo-100 text-indigo-700 px-3 py-1 rounded-full text-sm font-medium">
            {internacionesActivas.length} {internacionesActivas.length === 1 ? "Activa" : "Activas"}
          </span>
        </div>

        {internacionesActivas.length === 0 ? (
          <div className="text-center py-12">
            <BedDouble className="w-16 h-16 mx-auto text-slate-300 mb-4" />
            <p className="text-slate-500 text-lg">No hay internaciones activas</p>
          </div>
        ) : (
          <div className="grid gap-6">
            {internacionesActivas.map((internacion) => {
              const diasInternado = calcularDiasInternacion(internacion.fecha_hora_inicio)

              return (
                <div
                  key={internacion.id_internacion}
                  className="border-2 border-slate-200 rounded-xl p-6 hover:border-indigo-300 transition-all hover:shadow-md"
                >
                  {/* Header */}
                  <div className="flex items-start justify-between mb-4 pb-4 border-b border-slate-100">
                    <div>
                      <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                        Internación #{internacion.id_internacion}
                        <span className="text-xs font-normal bg-green-100 text-green-700 px-2 py-1 rounded-full">
                          Activa
                        </span>
                      </h3>
                      <p className="text-sm text-slate-500 mt-1 flex items-center gap-1">
                        <Calendar className="w-3.5 h-3.5" />
                        {diasInternado} {diasInternado === 1 ? "día" : "días"} internado
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-slate-500">Ingresó el</p>
                      <p className="text-sm font-semibold text-slate-800">
                        {formatearFechaHora(internacion.fecha_hora_inicio)}
                      </p>
                    </div>
                  </div>

                  {/* Main Info Grid */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-4">
                    {/* Patient Info */}
                    <div className="bg-blue-50 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-2">
                        <User className="w-4 h-4 text-blue-600" />
                        <p className="text-xs font-semibold text-blue-900 uppercase tracking-wide">Paciente</p>
                      </div>
                      <p className="font-bold text-slate-900 text-lg">
                        {internacion.nombre_paciente} {internacion.apellido_paciente}
                      </p>
                      <p className="text-sm text-slate-600 mt-1">DNI: {internacion.nro_dni}</p>
                    </div>

                    {/* Doctor Info */}
                    <div className="bg-purple-50 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-2">
                        <Stethoscope className="w-4 h-4 text-purple-600" />
                        <p className="text-xs font-semibold text-purple-900 uppercase tracking-wide">Médico a Cargo</p>
                      </div>
                      <p className="font-bold text-slate-900 text-lg">
                        Dr. {internacion.nombre_medico} {internacion.apellido_medico}
                      </p>
                      <p className="text-sm text-slate-600 mt-1">Mat: {internacion.nro_matricula}</p>
                    </div>

                    {/* Bed/Room Info */}
                    <div className="bg-green-50 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-2">
                        <MapPin className="w-4 h-4 text-green-600" />
                        <p className="text-xs font-semibold text-green-900 uppercase tracking-wide">Ubicación</p>
                      </div>
                      {internacion.id_cama ? (
                        <>
                          <p className="font-bold text-slate-900 text-lg">{internacion.nombre_sector}</p>
                          <p className="text-sm text-slate-600 mt-1">
                            Piso {internacion.piso} • Hab {internacion.id_habitacion} • Cama{" "}
                            {internacion.id_cama}
                          </p>
                          <p className="text-xs text-slate-500 mt-1">
                            Orientación: {internacion.orientacion}
                          </p>
                        </>
                      ) : (
                        <>
                          <p className="font-bold text-slate-900 text-lg">Hab {internacion.id_habitacion}</p>
                          <p className="text-sm text-slate-600 mt-1">Cama {internacion.id_cama}</p>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Actions or Edit Section */}
                  {editandoInternacion === internacion.id_internacion ? (
                    <div className="mt-4 pt-4 border-t-2 border-slate-200 bg-slate-50 -mx-6 -mb-6 px-6 py-4 rounded-b-xl">
                      <label className="block text-sm font-semibold text-slate-700 mb-3">
                        Seleccionar Nueva Cama Disponible
                      </label>
                      <div className="flex gap-3">
                        <select
                          value={nuevaCamaSeleccionada}
                          onChange={(e) => setNuevaCamaSeleccionada(e.target.value)}
                          className="flex-1 p-3 border-2 border-slate-300 rounded-lg outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 bg-white"
                        >
                          <option value="">-- Seleccionar Cama Disponible --</option>
                          {camasDisponibles.map((c, idx) => (
                            <option
                              key={`edit-${c.id_habitacion}-${c.id_cama}-${idx}`}
                              value={`${c.id_habitacion}-${c.id_cama}`}
                            >
                              {c.nombre_sector} | Piso {c.piso} | Hab {c.id_habitacion} | Cama {c.id_cama} (
                              {c.orientacion})
                            </option>
                          ))}
                        </select>
                        <button
                          onClick={() => handleCambiarCama(internacion.id_internacion)}
                          className="bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 transition-all font-semibold flex items-center gap-2 shadow-sm"
                        >
                          <RefreshCw className="w-4 h-4" />
                          Confirmar
                        </button>
                        <button
                          onClick={() => {
                            setEditandoInternacion(null)
                            setNuevaCamaSeleccionada("")
                          }}
                          className="bg-slate-500 text-white px-6 py-3 rounded-lg hover:bg-slate-600 transition-all font-semibold"
                        >
                          Cancelar
                        </button>
                      </div>
                    </div>
                  ) : (
                    <div className="mt-4 pt-4 border-t border-slate-200 flex justify-end gap-3">
                      <button
                        onClick={() => setEditandoInternacion(internacion.id_internacion)}
                        className="bg-indigo-600 text-white px-5 py-2.5 rounded-lg hover:bg-indigo-700 transition-all flex items-center gap-2 text-sm font-semibold shadow-sm"
                      >
                        <BedDouble className="w-4 h-4" />
                        Cambiar Cama
                      </button>
                      <button
                        onClick={() => handleTerminarInternacion(internacion.id_internacion)}
                        className="bg-red-600 text-white px-5 py-2.5 rounded-lg hover:bg-red-700 transition-all flex items-center gap-2 text-sm font-semibold shadow-sm"
                      >
                        <XCircle className="w-4 h-4" />
                        Terminar Internación
                      </button>
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
