'use client';

import React, { useEffect, useState } from 'react';
import { ShieldAlert } from 'lucide-react';
import { getAuditoriaGuardias } from '@/lib/actions';
import { TipoListadoModificaciones } from '@/types';

export default function AuditoriaPage() {
  const [auditoria, setAuditoria] = useState<TipoListadoModificaciones[]>([]);
  
  useEffect(() => {
    getAuditoriaGuardias().then(setAuditoria);
  }, []);

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-800">Reportes: Auditoría Guardias</h1>
        <p className="text-slate-500">Registro de cambios en asignación de guardias sensibles.</p>
      </div>
      
      <div className="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-md">
        <div className="flex">
          <div className="flex-shrink-0">
            <ShieldAlert className="h-5 w-5 text-red-500" />
          </div>
          <div className="ml-3">
            <p className="text-sm text-red-700 font-medium">
              Esta información es confidencial. Todas las consultas a esta pantalla quedan registradas por seguridad.
            </p>
          </div>
        </div>
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
            {auditoria.map((audit, idx) => (
              <tr key={idx} className="hover:bg-slate-50">
                <td className="p-4 font-mono text-xs text-slate-500">
                  {new Date(audit.fecha_hora_mod).toLocaleString()}
                </td>
                <td className="p-4 font-medium">@{audit.username}</td>
                <td className="p-4">
                  <div className="flex flex-col">
                    <span>{audit.nombre_medico}</span>
                    <span className="text-xs text-slate-500">{audit.especialidad}</span>
                  </div>
                </td>
                <td className="p-4">#{audit.id_guardia}</td>
                <td className="p-4 italic">"{audit.descripcion}"</td>
              </tr>
            ))}
            {auditoria.length === 0 && (
                <tr><td colSpan={5} className="p-8 text-center text-slate-400">No hay registros de auditoría.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}