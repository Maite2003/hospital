import {prisma} from "@/lib/prisma";

// Crear

export async function crearInternacion(data: {
  dniPaciente: number;
  matriculaMedico: number;
  camaId: number;
  habitacionId: number;
  fechaIngreso: string;
}) {
  try {
    // 1. Buscar paciente
    const paciente = await prisma.paciente.findUnique({
      where: { nroDni: data.dniPaciente }
    });

    if (!paciente) {
      return { success: false, message: 'Paciente no encontrado. Debe darlo de alta primero.' };
    }

    const medico = await prisma.medico.findUnique({
      where: { nroMatricula: data.matriculaMedico }
    });

    if (!medico) {
      return { success: false, message: 'Médico no encontrado.' };
    }

    const cama = await prisma.cama.findUnique({
      where: {
        id_idHabitacion: {
          id: data.camaId,
          idHabitacion: data.habitacionId
        }
      }
    });

    if (!cama) {
      return {success: false, message: "Cama no encontrada."}
    }

    // 2. Crear internación y Ocupar cama (Transacción)
    return prisma.$transaction(async (tx) => {
      // TODO: CAMBIAR ESTO A UNA TRANSACCION EN LA BASE DE DATOS
      // 1. CREAR INTERNACIÓN Y GUARDAR ID
      const nuevaInternacion = await tx.internacion.create({
        data: {
          fechaHoraInicio: new Date(data.fechaIngreso),
          paciente: {
            connect: {
              nroDni: paciente.nroDni,
            }
          },
          medico: {
            connect: {
              nroMatricula: medico.nroMatricula,
            }
          }
        },
        select: {
          id: true
        }
      });

      // 2. CREAR ASIGNACIÓN DE CAMA (USAMOS EL ID CREADO EN EL PASO 1)
      const asignacionCama = await tx.internacionCama.create({
        data: {
          fechaHoraAsignacion: new Date(),
          internacion: {
            connect: {
              id: nuevaInternacion.id
            }
          },
          cama: {
            connect: {
              id_idHabitacion: {
                id: cama.id,
                idHabitacion: cama.idHabitacion
              }
            }
          }
        }
      });
  });
    return { success: true, message: 'Internación creada exitosamente' };

  } catch (error) {
    console.error(error);
    return { success: false, message: 'Error de base de datos' };
  }
}