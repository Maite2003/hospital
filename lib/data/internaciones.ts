import { prisma } from "@/lib/prisma";
import { crearInternacion as crearInternacionProps, Internacion } from '@/types/types';

export async function crearInternacion(data: crearInternacionProps) {
  await prisma.$queryRaw`
      BEGIN;

      -- 1. Crear internación
      INSERT INTO INTERNACION (fecha_hora_inicio, nro_matricula, nro_dni)
      VALUES (NOW(), :${data.matriculaMedico}, :${data.dniPaciente})
      RETURNING id_internacion;

      -- 2. Asignar cama inicial
      INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
      VALUES (
          NOW(),
          currval('internacion_id_internacion_seq'),  -- Última internación creada
          ${data.habitacionId},
          ${data.camaId}
      );

      COMMIT;
    `;
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
      WHERE id_internacion = ${id};

      -- El trigger: libera la última cama usada

      COMMIT; 
    `;
  return internacion;
}


export async function editarInternacion(id: number, id_cama: number, id_habitacion: number) {
  await prisma.$queryRaw`
      BEGIN;

      INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
      VALUES (
          NOW(),
          ${id},
          ${id_habitacion},
          ${id_cama}
      );

      COMMIT;
    `;
}