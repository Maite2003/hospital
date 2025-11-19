import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoModificaciones } from "@/types/types"


export async function getReporteAudutoriasGuardias() {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_modificaciones_guardia()`; // Funcion que definimos con SQL a manito
  try {
    const result = await prisma.$queryRaw<TipoListadoModificaciones[]>(sqlQuery);
    return result;
  } catch {
    return null;
  }
}