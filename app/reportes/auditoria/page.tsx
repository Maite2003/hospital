'use client';

import { useEffect, useState } from 'react';
import { TipoListadoModificaciones } from '@/types/types';

export default function AuditoriaPage() {
  const [modificaciones_guardias, setModificacionesGuardias] = useState<TipoListadoModificaciones[]>([]);
  
  // Conseguir modificaciones a guardias
  async function loadAudutorias() {
    const res = await fetch("/api/reportes/modificaciones_guardias");
    if (!res.ok) throw new Error("Error al obtener modificaciones de guardias");
    const modificaciones: TipoListadoModificaciones[] = (await res.json()).modificaciones_guardias;
    setModificacionesGuardias(modificaciones);
  }

  useEffect(() => {
    loadAudutorias();
  }, []);

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-800">Reportes: Auditoría Guardias</h1>
        <p className="text-slate-500">Registro de cambios en asignación de guardias.</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm overflow-hidden border border-slate-200">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-800 text-white uppercase text-xs font-semibold">
            <tr>
              <th className="p-4">Fecha Modificación</th>
              <th className="p-4">Usuario</th>
              <th className="p-4">Médico</th>
              <th className="p-4">Guardia ID</th>
              <th className="p-4">Descripción</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {modificaciones_guardias 
              ? modificaciones_guardias.map((modificaciones, idx) => (
                <tr key={idx} className="hover:bg-slate-50">
                  <td className="p-4 font-mono text-xs text-slate-500">
                    {new Date(modificaciones.fecha_hora_mod).toLocaleString()}
                  </td>
                  <td className="p-4 font-medium">@{modificaciones.username}</td>
                  <td className="p-4">
                    <div className="flex flex-col">
                      <span>{modificaciones.nombre_medico}</span>
                      <span className="text-xs text-slate-500">{modificaciones.especialidad}</span>
                    </div>
                  </td>
                  <td className="p-4">#{modificaciones.id_guardia}</td>
                  <td className="p-4 italic">"{modificaciones.descripcion}"</td>
                </tr>
              ))
            : <tr><td colSpan={5} className="p-8 text-center text-slate-400">No hay registros de auditoría.</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}