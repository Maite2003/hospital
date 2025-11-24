
export interface Persona {
    nroDni: string,
    nombre: string,
    apellido: string
}

export interface Paciente {
    nroDni: string,
    sexo: string,
    fechaNac: Date | string,
}

export interface Medico {
    nroMatricula: string,
    fechaIngreso: Date | string,
    foto: string,
    cuil: string,
    cuit: string,
    nroDni: string
}

export interface Comentario {
    idInternacion: number,
    idComentario: number,
    fechaHora: Date | string,
    descripcion: string,
    id_recorrido: number,
}

export interface Recorrido {
    id_recorrido: number,
    fecha: Date | string,
    id_ronda: number,
    nro_matricula: string,
}

export interface Internacion {
    id: number,
    fechaHoraInicio: Date | string,
    fechaHoraFin: Date | string,
    nroMatricula: string,
    nroDni: string,
}

export interface Cama {
    id: number,
    idHabitacion: number,
    estaLibre: boolean,
}

export interface Habitacion {
    id: number,
    piso: number,
    orientacion: string,
    idSector: number,
}

export interface Sector {
    id: number,
    nombreSector: string,
}

export interface Especialidad {
    id_especialidad: number,
    nombre: string,
}

export interface Usuario {
    username: string,
    password: string,
    puedeModGuardia: boolean,
    nroDni: string,
}

export interface UsuarioModificaGuardia {
    username: string,
    id_guardia: number,
    fecha_hora: Date | string,
    descripcion: string,
}

export interface Guardia {
    id_guardia: number,
    fecha: Date | string,
    id_especialidad: number,
    nro_matricula: string,
}

export interface RelacionGuardiaYTurno {
    id_guardia: number,
    id_turno_guardia: number,
}

export interface TurnoGuardia {
  id_turno_guardia: number;
  hora_inicio: string;
  hora_fin: string;
}

// REPORTES

export interface TipoListadoModificaciones {
  username: string;
  id_guardia: number;
  fecha_hora_mod: Date | string;
  descripcion: string;
  fecha_guardia: Date | string;
  especialidad: string;
  nro_matricula: string; 
  nombre_medico: string;
  turnos: TurnoGuardia[]; 
}

export interface TipoListadoCamas {
  id_habitacion: number;
  piso: number;
  orientacion: string;
  nombre_sector: string;
  id_cama: number;
  esta_libre: boolean;
}

export interface TipoCamaConDetalle {
    id: number,
    idHabitacion: number,
    habitacion: {
        piso: number,
        orientacion: string,
        sector: {
            nombreSector: string,
        }
    }
    estaLibre: boolean,
}

export interface TipoFilasComentariosPorInternacion {
    id_internacion: number;
    fecha_hora_inicio_int: Date | string;
    fecha_hora_fin_int: Date | string | null;
    nro_dni: string;
    nombre: string;
    apellido: string;
    id_comentario: number;
    fecha_hora_comentario: Date | string;
    descripcion: string;
    nro_matricula: string;
    nombre_doctor: string;
}

export interface TipoComentario {
    idComentario: number;
    fechaHora: Date | string;
    descripcion: string;
    nroMatricula: string;
    nombre_doctor: string;
}

export interface TipoListadoComentarios {
  idInternacion: number;
  fechaHoraInicio: Date | string;
  fechaHoraFin: Date | string | null;
  nroDni: string; 
  nombre: string;
  apellido: string;
  comentarios: TipoComentario[]
}

// INTERNACIONES TRANSACCIONES
 export interface crearInternacion {
    dniPaciente: string;
    matriculaMedico: string;
    camaId: number;
    habitacionId: number;
    fechaIngreso: Date | string;
}

export interface editarInternacion {
    idInternacion: number,
    matriculaMedico?: string;
    camaId?: number;
    habitacionId?: number;
    fechaSalida?: Date | string;
}
