import { NextResponse } from "next/server";
import { getInternacion } from '@/lib/data/internaciones'

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