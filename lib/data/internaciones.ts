import { prisma } from "@/lib/prisma";
import { crearInternacion as crearInternacionProps, Internacion } from '@/types/types';

export async function crearInternacion(data: crearInternacionProps) {
  const internacion = await prisma.$queryRaw`
      SELECT * FROM crear_internacion(${data.camaId}, ${data.dniPaciente}, ${data.fechaIngreso}, ${data.habitacionId}, ${data.matriculaMedico});
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
      SELECT * FROM eliminar_internacion(${id});
    `;
  return internacion;
}