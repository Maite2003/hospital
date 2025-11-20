import { NextResponse } from "next/server";
import { prisma } from '@/lib/prisma';
import { getReporteComentariosInternacion } from '@/lib/data/comentarios'

export async function GET(
    req: Request,
    { params }: { params: Promise<{ id: string }> }) {
  try {
    const id = (await params).id;
    const id_parsed = parseInt(id, 10);

    const internacion = await getReporteComentariosInternacion(id_parsed);
    return NextResponse.json({ internacion, status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: `Error al obtener los comentario de la internacion, error es ${error}`, status: 500 }
    );
  }
}
