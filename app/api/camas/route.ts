import { NextResponse } from "next/server";
import { prisma } from '@/lib/prisma';
import { getTodasLasCamas } from '@/lib/data/camas'

export async function GET() {
  try {
    const camas = await getTodasLasCamas();

    return NextResponse.json({ camas, status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: "Error al obtener las camas libres", status: 500 }
    );
  }
}
