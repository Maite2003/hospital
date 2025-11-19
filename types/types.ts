
export interface Persona {
    dni: number,
    nombre: string,
    apellido: string
}

export interface Paciente {
    nro_dni: number,
    sexo: string,
    fecha_nac: Date
}

export interface Medico {
    nro_matricula: number,
    fecha_ingreso: Date,
    foto: string,
    cuil: number,
    cuit: number,
    nro_dni: number
}

export interface Comentario {
    id_internacion: number,
    id_comentario: number,
    fecha_hora: Date,
    descripcion: string,
    id_recorrido: number,
}

export interface Recorrido {
    id_recorrido: number,
    fecha: Date,
    id_ronda: number,
    nro_matricula: number,
}

export interface Internacion {
    id_internacion: number,
    fecha_hora_inicio: Date,
    fecha_hora_fin: Date,
    nro_matricula: number,
    nro_dni: number,
}

export interface Cama {
    id_cama: number,
    id_habitacion: number,
    esta_libre: boolean,
}

export interface Habitacion {
    id_habitacion: number,
    piso: number,
    orientacion: string,
    id_sector: number,
}

export interface Sector {
    id_sector: number,
    nombre_sector: string,
}

export interface Especialidad {
    id_especialidad: number,
    nombre_especialidad: string,
}

export interface Usuario {
    username: string,
    password: string,
    puede_mod_guardia: boolean,
    nro_dni: number,
}

export interface UsuarioModificaGuardia {
    username: string,
    id_guardia: number,
    fecha_hora: Date,
    descripcion: string,
}

export interface Guardia {
    id_guardia: number,
    fecha: Date,
    id_especialidad: number,
    nro_matricula: number,
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

export interface TipoListadoModificaciones {
  username: string;
  id_guardia: number;
  fecha_hora_mod: Date | string;
  descripcion: string;
  fecha_guardia: Date | string;
  especialidad: string;
  nro_matricula: number; 
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

export interface TipoListadoComentarios {
  id_internacion: number;
  fecha_hora_inicio_int: Date | string;
  fecha_hora_fin_int: Date | string | null;
  nro_dni: number; 
  nombre: string;
  apellido: string;
  id_comentario: number;
  fecha_hora_comentario: Date | string;
  descripcion: string;
  nro_matricula: number; 
  nombre_doctor: string;
}