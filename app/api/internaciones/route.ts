import { NextResponse } from "next/server";
import { crearInternacion, getTodasLasInternaciones } from "@/lib/data/internaciones";
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