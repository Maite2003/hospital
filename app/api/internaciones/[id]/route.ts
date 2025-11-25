import { NextResponse } from "next/server";
import { getInternacion } from '@/lib/data/internaciones';
import { eliminarInternacion } from "@/lib/data/internaciones";

export async function GET(
    req: Request,
    { params }: { params: Promise<{ id: string }> }) {
  try {
    const id = (await params).id;
    const id_parsed = parseInt(id);

    const internacion = await getInternacion(id_parsed);
    return NextResponse.json({ internacion }, { status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: `Error al obtener la internacion, error es ${error}`} , { status: 500 }
    );
  }
}




export async function DELETE(
  request: Request,
  context: { params: Promise<{ id: string }> }) {
  try {
    const {id} = await context.params;
    const parsedId = parseInt(id)
    const deleted = await eliminarInternacion(parsedId);

    if (!deleted) {
      return NextResponse.json(
        { error: "Internacion no encontrado" },
        { status: 404 }
      );
    }

    return NextResponse.json(
      { message: "Internaciones eliminada correctamente" },
      { status: 200 }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Error al eliminar internacion" },
      { status: 500 }
    );
  }
}
