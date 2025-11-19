import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoCamas } from "@/types/types"


export async function getReporteCamasLibres() {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_camas_libres()`; // Funcion que definimos con SQL a manito
  try {
    const result = await prisma.$queryRaw<TipoListadoCamas[]>(sqlQuery);
    return result;
  } catch {
    return null;
  }
}