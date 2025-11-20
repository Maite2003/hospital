'use client';

import { useEffect, useState } from 'react';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { UserPlus, Activity } from 'lucide-react';
import { TipoListadoCamas, crearInternacion } from '@/types/types';
import { getReporteCamasLibres } from '@/lib/data/camas';

export default function GestionInternacionesPage() {
  const [camasDisponibles, setCamasDisponibles] = useState<TipoListadoCamas[]>([]);

  // Conseguir camas libres
  async function loadCamas() {
    const res = await fetch("/api/reportes/camas_libres");
    if (!res.ok) throw new Error("Error al obtener camas libres");
    const camitas: TipoListadoCamas[] = (await res.json()).camas;
    setCamasDisponibles(camitas);
  }

  // Cargar camas al inicio
  useEffect(() => {
    loadCamas();
  }, []);

  const validationSchema = Yup.object({
    dniPaciente: Yup.number().required('Requerido'),
    medicoMatricula: Yup.number().required('Requerido'),
    camaSeleccionada: Yup.string().required('Seleccione una cama'), // Guardamos "habID-camaID"
    fechaIngreso: Yup.date().required('Requerido')
  });

  const formik = useFormik({
    initialValues: {
      dniPaciente: '',
      medicoMatricula: '',
      camaSeleccionada: '', 
      fechaIngreso: new Date().toISOString().split('T')[0],
    },
    validationSchema,
    onSubmit: async (values, { resetForm }) => {
      const [habitacionId, camaId] = values.camaSeleccionada.split('-');

      const infoInternacion: crearInternacion = {
        dniPaciente: Number(values.dniPaciente),
        matriculaMedico: Number(values.medicoMatricula),
        habitacionId: Number(habitacionId),
        camaId: Number(camaId),
        fechaIngreso: values.fechaIngreso
      };

      try {
        const res = await fetch("/api/internaciones", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(infoInternacion),
        });
        if (!res.ok) {
          const error = await res.json();
          alert("❌ Error: " + error);
        } else {
          alert("✅ Internación guardada. Trigger de ocupación ejecutado.");
          resetForm();
          // Recargar camas
          loadCamas();
        }
      } catch (error) {
        alert("❌ Error: " + error);
      }
    }
  });

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
                type="number"
                {...formik.getFieldProps('dniPaciente')}
                className="w-full p-2 border border-slate-300 rounded-md outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="Ej: 12345678"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Matrícula Médico</label>
              <input
                type="number"
                {...formik.getFieldProps('medicoMatricula')}
                className="w-full p-2 border border-slate-300 rounded-md outline-none focus:ring-2 focus:ring-indigo-500"
                placeholder="Ej: 9988"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Seleccione Cama (Solo Libres)</label>
            <select
              {...formik.getFieldProps('camaSeleccionada')}
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
              {...formik.getFieldProps('fechaIngreso')}
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
    </div>
  );
}