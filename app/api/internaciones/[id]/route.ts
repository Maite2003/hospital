import { NextResponse } from "next/server";
import { getInternacion } from '@/lib/data/internaciones';
import { editarInternacion, eliminarInternacion } from "@/lib/data/internaciones";

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

interface modificarInternacionProps {
  id_cama: number,
  id_habitacion: number,
}

export async function POST(
    request: Request,
    { params }: { params: Promise<{ id: string }> }) {
  try {
    const id = (await params).id;
    const id_parsed = parseInt(id);

    const body: modificarInternacionProps = await request.json();

    await editarInternacion(id_parsed, body.id_cama, body.id_habitacion);
    return NextResponse.json({ status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: `Error al intentar modificar la cama, error es ${error}`} , { status: 500 }
    );
  }
}




export async function DELETE(
  request: Request,
  context: { params: Promise<{ id: string }> }) {
  try {
    const {id} = await context.params;
    const parsedId = parseInt(id)
    eliminarInternacion(parsedId);

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
