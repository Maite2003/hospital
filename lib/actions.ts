'use server';

import { prisma } from './prisma';
import { revalidatePath } from 'next/cache';
import { TipoListadoCamas, TipoListadoComentarios, TipoListadoModificaciones } from '@/types';

// Utilería para serializar BigInt (Prisma devuelve BigInt, JSON no lo soporta)
function serializeBigInt(obj: any): any {
  return JSON.parse(JSON.stringify(obj, (key, value) =>
    typeof value === 'bigint' ? Number(value) : value
  ));
}

// --- INTERNACIONES ---

export async function crearInternacion(data: {
  dniPaciente: number;
  matriculaMedico: number;
  habitacionId: number;
  camaId: number;
  fechaIngreso: string;
}) {
  try {
    // Usamos una transacción de Prisma
    // Nota: Tu trigger 'trg_ocupar_cama' en SQL se encargará de verificar disponibilidad
    // y actualizar el estado de la cama. Nosotros solo insertamos.
    
    await prisma.$transaction(async (tx) => {
      // 1. Crear la internación
      const nuevaInternacion = await tx.internacion.create({
        data: {
          fechaHoraInicio: new Date(data.fechaIngreso),
          nroDni: BigInt(data.dniPaciente),
          nroMatricula: BigInt(data.matriculaMedico),
        }
      });

      // 2. Asignar la cama (Esto dispara tu trigger SQL)
      await tx.internacionCama.create({
        data: {
          fechaHoraAsignacion: new Date(),
          idInternacion: nuevaInternacion.id,
          idHabitacion: data.habitacionId,
          idCama: data.camaId
        }
      });
    });

    revalidatePath('/reportes/camas');
    return { success: true, message: 'Internación creada exitosamente' };

  } catch (error: any) {
    console.error("Error DB:", error);
    // Capturamos errores de tus triggers SQL (ej: "La cama ya está ocupada")
    return { success: false, message: error.message || 'Error al crear internación' };
  }
}

// --- REPORTES (Usando tus funciones SQL) ---

export async function getListadoCamas() {
  // Llamamos a tu función SQL: listar_camas_libres()
  const result = await prisma.$queryRaw<TipoListadoCamas[]>`
    SELECT * FROM listar_camas_libres()
  `;
  return result;
}

export async function buscarHistorialPorDNI(term: string) {
  const dni = parseInt(term);
  if (isNaN(dni)) return [];

  // 1. Primero necesitamos encontrar las internaciones de ese DNI
  //    Podríamos hacer un JOIN, pero para reutilizar tu función listar_comentarios_internacion(id)
  //    iteraremos sobre las internaciones del paciente.
  
  const internaciones = await prisma.internacion.findMany({
    where: { nroDni: BigInt(dni) },
    select: { id: true }
  });

  if (internaciones.length === 0) return [];

  let todosLosComentarios: TipoListadoComentarios[] = [];

  for (const int of internaciones) {
    // Llamada a tu función SQL por cada internación
    const comentarios = await prisma.$queryRaw<TipoListadoComentarios[]>`
      SELECT * FROM listar_comentarios_internacion(${int.id})
    `;
    todosLosComentarios = [...todosLosComentarios, ...comentarios];
  }

  return serializeBigInt(todosLosComentarios);
}

export async function getAuditoriaGuardias() {
  // Llamamos a tu función SQL: listar_modificaciones_guardia()
  const result = await prisma.$queryRaw<TipoListadoModificaciones[]>`
    SELECT * FROM listar_modificaciones_guardia()
  `;
  
  return serializeBigInt(result);
}