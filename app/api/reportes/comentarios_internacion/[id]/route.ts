import { NextResponse } from "next/server";
import { getReporteComentariosInternacion } from '@/lib/data/comentarios'

export async function GET(
    req: Request,
    { params }: { params: Promise<{ id: string }> }) {
  try {
    const id = (await params).id;
    const id_parsed = parseInt(id);

    const internacion = await getReporteComentariosInternacion(id_parsed);
    if (!internacion) return NextResponse.json({ msg: "No hay comentarios para esa internacion" }, { status: 404 });
    return NextResponse.json({ internacion }, { status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: `Error al obtener los comentario de la internacion, error es ${error}`} , { status: 500 }
    );
  }
}
