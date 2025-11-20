import { prisma } from "@/lib/prisma";
import { Prisma } from '@prisma/client';
import { TipoListadoCamas, TipoCamaConDetalle } from "@/types/types"

export async function getReporteCamasLibres() {
  const sqlQuery = Prisma.sql`SELECT * FROM listar_camas_libres()`; // Funcion que definimos con SQL a manito
  try {
    const result = await prisma.$queryRaw<TipoListadoCamas[]>(sqlQuery);
    return result;
  } catch {
    return null;
  }
}

export async function getTodasLasCamas() {
  const camasConDetalles: TipoCamaConDetalle[] = await prisma.cama.findMany({
    // Opcional: Puedes agregar aquí condiciones de filtro (where) si es necesario.
    // where: { esta_libre: true }, 

    select: {
      id: true,
      estaLibre: true,
      idHabitacion: true, // Se incluye el id_habitacion según lo solicitado

      // 2. Traer la relación Habitacion (para acceder a Sector):
      habitacion: {
        select: {
          // 3. Traer la relación Sector (para acceder al nombre):
          piso: true,
          orientacion: true,
          sector: {
            select: {
              nombreSector: true, // Campo solicitado: nombre_sector
            },
          },
        },
      },
    },
  });
  return camasConDetalles;
}