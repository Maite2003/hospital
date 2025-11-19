import { NextResponse } from "next/server";
import {prisma} from '@/lib/prisma';

export async function GET() {
  try {
    const products = await prisma.getAll();
    return NextResponse.json(products, { status: 200 });
  } catch (error) {
    return NextResponse.json(
      { error: "Error al obtener productos" },
      { status: 500 }
    );
  }
}
