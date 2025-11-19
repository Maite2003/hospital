import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoComentarios } from "@/types/types"


export async function getReporteComentariosInternacion(id_internacion: number) {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_comentarios_internacion(${id_internacion})`; // Funcion que definimos con SQL a manito
  try {
    const result = await prisma.$queryRaw<TipoListadoComentarios[]>(sqlQuery);
    return result;
  } catch {
    return null;
  }
}