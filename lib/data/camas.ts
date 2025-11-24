import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoCamas, TipoCamaConDetalle } from "@/types/types"

export async function getReporteCamasLibres() {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_camas_libres()`; // Funcion que definimos con SQL a manito
  const result = await prisma.$queryRaw<TipoListadoCamas[]>(sqlQuery);
  return result;
}

export async function getTodasLasCamas() {
  const camasConDetalles: TipoCamaConDetalle[] = await prisma.cama.findMany({
    select: {
      id: true,
      estaLibre: true,
      idHabitacion: true,
      habitacion: {
        select: {
          piso: true,
          orientacion: true,
          sector: {
            select: {
              nombreSector: true,
            },
          },
        },
      },
    },
  });
  return camasConDetalles;
}