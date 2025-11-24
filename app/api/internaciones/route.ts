import { NextResponse } from "next/server";
import { crearInternacion, getTodasLasInternaciones, eliminarInternacion } from "@/lib/data/internaciones";
import { crearInternacion as crearInternacionProps, Internacion } from '@/types/types';

export async function POST(request: Request) {
  try {
    const body: crearInternacionProps = await request.json();

    const internacion = crearInternacion(body);
    
    return NextResponse.json(
      { internacion },
      { status: 201 }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Error al procesar la solicitud" },
      { status: 500 }
    );
  }
}

export async function GET() {
  try {
    const internaciones: Internacion[] = await getTodasLasInternaciones();

    return NextResponse.json({ internaciones }, {status: 200});
  } catch (error) {
    return NextResponse.json(
      { error: "Error al obtener las internaciones" }, { status: 500 }
    );
  }
}


export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const id = parseInt(await params.id);
    const deleted = await eliminarInternacion(id);

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
