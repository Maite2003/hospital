import { Prisma } from '@prisma/client';
import { crearInternacion as crearInternacionProps, InternacionFront } from '@/types/types';
import { prisma } from '@/lib/prisma';

interface InternacionResult {
    id_internacion: number;
}

export async function crearInternacion(data: crearInternacionProps) {
  
  try {
    const resultadoTransaccion = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      
      const internacionCreada: InternacionResult[] = await tx.$queryRaw<InternacionResult[]>`
        INSERT INTO INTERNACION (fecha_hora_inicio, nro_matricula, nro_dni)
        VALUES (
            NOW(), 
            ${data.matricula_medico},
            ${data.dni_paciente} 
        )
        RETURNING id_internacion;
      `;

      if (internacionCreada.length === 0 || !internacionCreada[0].id_internacion) {
        throw new Error("No se pudo obtener el ID de la internación recién creada.");
      }
      
      const newInternacionId = internacionCreada[0].id_internacion;
      await tx.$executeRaw`
        INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
        VALUES (
            NOW(),
            ${newInternacionId},
            ${data.habitacion_id},
            ${data.cama_id}
        );
      `;
      
      return newInternacionId;
      
    }, {});

    return resultadoTransaccion;
    
  } catch (error) {
    throw error;
  }
}

// export async function getTodasLasInternaciones() {
//  const internaciones: Internacion[] = await prisma.internacion.findMany({
//    select: {
//      id: true,
//      fechaHoraFin: true,
//      fechaHoraInicio:true,
//      nroMatricula: true,
//      nroDni: true,
//    }
//  });
//  return internaciones;
//}

export async function getTodasLasInternaciones() {
    const sqlQuery = Prisma.sql`SELECT * FROM listar_internaciones()`;
    try {
      const result = await prisma.$queryRaw<InternacionFront[]>(sqlQuery);
      return result;
    } catch {
      return [];
    }
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
  if (!internacion) return {}
  const internacionFormateada = {
    id: internacion.id,
    fecha_hora_fin: internacion.fechaHoraFin,
    fecha_hora_inicio: internacion.fechaHoraInicio,
    nro_matricula: internacion.nroMatricula,
    nro_dni: internacion.nroDni
  }

  return internacionFormateada;
}

export async function eliminarInternacion(id: number) {
  try {
    const resultadoTransaccion = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const filasAfectadas = await tx.$executeRaw`
        UPDATE INTERNACION
        SET fecha_hora_fin = NOW()
        WHERE id_internacion = ${id};
      `;
      
      return filasAfectadas;
    }, {});
    return resultadoTransaccion > 0;
    
  } catch (error) {
    throw error;
  }
}

export async function editarInternacion(id: number, id_cama: number, id_habitacion: number) {
  try {
    await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      
      await tx.$executeRaw`
        INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
        VALUES (
            NOW(),
            ${id},          
            ${id_habitacion}, 
            ${id_cama}      
        );
      `;
    });

  } catch (error) {
    console.error("Error al ejecutar la transacción de internación:", error);
    throw error;
  }
}