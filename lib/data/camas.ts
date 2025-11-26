import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoCamas, TipoCamaConDetalle } from "@/types/types"

export async function getReporteCamasLibres() {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_camas_libres()`; // Funcion que definimos con SQL a manito
  const result = await prisma.$queryRaw<TipoListadoCamas[]>(sqlQuery);
  return result;
}

export async function getTodasLasCamas() {
  const camasConDetalles = await prisma.cama.findMany({
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

  const camasResultado: TipoCamaConDetalle[] = camasConDetalles.map((cama: { id: any; estaLibre: any; idHabitacion: any; habitacion: { piso: any; orientacion: any; sector: { nombreSector: any; }; }; }) => {
    return {
      id: cama.id,
      esta_libre: cama.estaLibre,
      id_habitacion: cama.idHabitacion,
      habitacion: {
        piso: cama.habitacion.piso,
        orientacion: cama.habitacion.orientacion,
        sector: {nombre_sector: cama.habitacion.sector.nombreSector} 
      }
    }
  })

  return camasResultado;
}