
export interface Persona {
    nro_dni: string,
    nombre: string,
    apellido: string
}

export interface Paciente {
    nro_dni: string,
    sexo: string,
    fecha_nac: Date | string,
}

export interface Medico {
    nro_matricula: string,
    fecha_ingreso: Date | string,
    foto: string,
    cuil: string,
    cuit: string,
    nro_dni: string
}

export interface Comentario {
    id_dnternacion: number,
    id_comentario: number,
    fecha_hora: Date | string,
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
    fecha_hora_inicio: Date | string,
    fecha_hora_fin: Date | string | null,
    nro_matricula: string,
    nro_dni: string,
}

export interface InternacionActiva {
    id_internacion: number,
    fecha_hora_inicio: Date | string,

    nro_dni: string,
    nombre_paciente: string,
    apellido_paciente: string,
    sexo: string,
    fecha_nac: Date,

    nro_matricula: string,
    nombre_medico: string,
    apellido_medico: string,

    id_cama:number,
    id_habitacion:number,
    piso: number,
    orientacion: string,
    nombre_sector: string,

    fecha_hora_asignacion: Date,
}

export interface Cama {
    id: number,
    id_habitacion: number,
    esta_libre: boolean,
}

export interface Habitacion {
    id: number,
    piso: number,
    orientacion: string,
    id_sector: number,
}

export interface Sector {
    id: number,
    nombre_sector: string,
}

export interface Especialidad {
    id_especialidad: number,
    nombre: string,
}

export interface Usuario {
    username: string,
    password: string,
    puede_mod_guardia: boolean,
    nro_dni: string,
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
    id_habitacion: number,
    habitacion: {
        piso: number,
        orientacion: string,
        sector: {
            nombre_sector: string,
        }
    }
    esta_libre: boolean,
}

export interface TipoFilasComentariosPorInternacion {
    id_internacion: number;
    fecha_hora_inicio_int: Date | string;
    fecha_hora_fin_int?: Date | string | null;
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
    id_comentario: number;
    fecha_hora: Date | string;
    descripcion: string;
    nro_matricula: string;
    nombre_doctor: string;
}

export interface TipoListadoComentarios {
  id_internacion: number;
  fecha_hora_inicio: Date | string;
  fecha_hora_fin?: Date | string | null;
  nro_dni: string; 
  nombre: string;
  apellido: string;
  comentarios: TipoComentario[]
}

// INTERNACIONES TRANSACCIONES
 export interface crearInternacion {
    dni_paciente: string;
    matricula_medico: string;
    cama_id: number;
    habitacion_id: number;
    fecha_ingreso: Date | string;
}

export interface editarInternacion {
    id_internacion: number,
    matricula_medico?: string;
    cama_id?: number;
    habitacion_id?: number;
    fecha_salida?: Date | string;
}
