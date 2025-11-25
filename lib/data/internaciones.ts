import { prisma } from "@/lib/prisma";
import { crearInternacion as crearInternacionProps, Internacion } from '@/types/types';

export async function crearInternacion(data: crearInternacionProps) {
  const internacion = await prisma.$queryRaw`
      BEGIN;

      -- 1. Crear internación
      INSERT INTO INTERNACION (fecha_hora_inicio, nro_matricula, nro_dni)
      VALUES (NOW(), :matricula, :dni)
      RETURNING id_internacion;

      -- 2. Asignar cama inicial
      INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
      VALUES (
          NOW(),
          currval('internacion_id_internacion_seq'),  -- Última internación creada
          :id_habitacion,
          :id_cama
      );

      COMMIT;
    `;

  return internacion;
}

export async function getTodasLasInternaciones() {
  const internaciones: Internacion[] = await prisma.internacion.findMany({
    select: {
      id: true,
      fechaHoraFin: true,
      fechaHoraInicio:true,
      nroMatricula: true,
      nroDni: true,
    }
  });

  return internaciones;
}

export async function getInternacion(id: number) {
  const internacion = await prisma.internacion.findFirst({
    where: {
      id: id
    },
    select: {
      id: true,
      fechaHoraFin: true,
      fechaHoraInicio:true,
      nroMatricula: true,
      nroDni: true,
    }
  });
  return internacion;
}

export async function eliminarInternacion(id: number) {
  const internacion = await prisma.$queryRaw`
      BEGIN;

      UPDATE INTERNACION
      SET fecha_hora_fin = NOW()
      WHERE id_internacion = :id_internacion;

      -- El trigger: libera la última cama usada

      COMMIT; 
    `;
  return internacion;
}