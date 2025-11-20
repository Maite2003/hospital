import { NextResponse } from "next/server";
import { prisma } from '@/lib/prisma';
import { getReporteAudutoriasGuardias } from '@/lib/data/audutorias'

export async function GET() {
  try {
    const modificaciones_guardias = await getReporteAudutoriasGuardias();
    return NextResponse.json({ modificaciones_guardias, status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: `Error al obtener las modificaciones de guardias. El error es ${error}`, status: 500 }
    );
  }
}
