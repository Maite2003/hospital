import { NextResponse } from "next/server";
import { getReporteCamasLibres } from '@/lib/data/camas'

export async function GET() {
  try {
    const camas = await getReporteCamasLibres();
    return NextResponse.json({ camas }, { status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: "Error al obtener las camas libres" }, { status: 500 }
    );
  }
}
