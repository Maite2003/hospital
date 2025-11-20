import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const body = await request.json();

    // Validación simple
    if (!body.name || !body.price) {
      return NextResponse.json(
        { error: "Faltan campos obligatorios: name y price" },
        { status: 400 }
      );
    }

    if (typeof body.price !== "number" || body.price <= 0) {
      return NextResponse.json(
        { error: "price debe ser un número mayor a 0" },
        { status: 400 }
      );
    }

    // Si todo está bien, procesamos
    // ... lógica para guardar

    return NextResponse.json(
      { message: "Producto creado exitosamente", data: body },
      { status: 201 }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Error al procesar la solicitud" },
      { status: 500 }
    );
  }
}