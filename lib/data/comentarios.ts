import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoComentarios, TipoComentario, TipoFilasComentariosPorInternacion } from "@/types/types"


export async function getReporteComentariosInternacion(id_internacion: number) {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_comentarios_internacion(${id_internacion}::integer)`; // Funcion que definimos con SQL a manito
  try {
    const filas = await prisma.$queryRaw<TipoFilasComentariosPorInternacion[]>(sqlQuery);
    
    // Aca se supone que tengo elementos de este tipo:
    // export interface TipoListadoComentarios {
    //   id_internacion: number;
    //   fecha_hora_inicio_int: Date | string;
    //   fecha_hora_fin_int: Date | string | null;
    //   nro_dni: number;
    //   nombre: string;
    //   apellido: string;
    //   id_comentario: number;
      // fecha_hora_comentario: Date | string;
      // descripcion: string;
      // nro_matricula: number;
      // nombre_doctor: string;
    // }
    // La idea es devolver los campos comunes una vez y despues la lista de comentarios

    const result: TipoListadoComentarios = {
      idInternacion: filas[0].id_internacion,
      fechaHoraInicio: filas[0].fecha_hora_inicio_int,
      fechaHoraFin: filas[0].fecha_hora_fin_int,
      nroDni: filas[0].nro_dni,
      nombre: filas[0].nombre,
      apellido: filas[0].apellido,
      comentarios: filas.map((fila) => {
        const comentario: TipoComentario = {
          idComentario: fila.id_comentario,
          fechaHora: fila.fecha_hora_comentario,
          descripcion: fila.descripcion,
          nroMatricula: fila.nro_matricula,
          nombre_doctor: fila.nombre_doctor
        }
        return comentario;
      })
    }


    return result;
  } catch (error){
    console.log(error)
    return null;
  }
}