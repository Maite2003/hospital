import { NextResponse } from "next/server";
import { crearInternacion, getTodasLasInternaciones } from "@/lib/data/internaciones";
import { crearInternacion as crearInternacionProps, InternacionFront } from '@/types/types';

export async function POST(request: Request) {
  try {
    const body: crearInternacionProps = await request.json();
    crearInternacion(body);
    return NextResponse.json(
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
    const internaciones: InternacionFront[] | null = await getTodasLasInternaciones();
    return NextResponse.json({ internaciones }, {status: 200});
  } catch (error) {
    return NextResponse.json(
      { error: "Error al obtener las internaciones" }, { status: 500 }
    );
  }
}