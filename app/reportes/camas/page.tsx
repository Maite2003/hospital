'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { BedDouble, Filter, Search } from 'lucide-react';
import { getListadoCamas } from '@/lib/actions';
import { TipoListadoCamas } from '@/types';

export default function ReporteCamasPage() {
  const [camas, setCamas] = useState<TipoListadoCamas[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Estados para filtros
  const [filterSector, setFilterSector] = useState('Todos');
  const [searchTerm, setSearchTerm] = useState('');

  // Carga inicial de datos
  useEffect(() => {
    getListadoCamas()
      .then(setCamas)
      .finally(() => setLoading(false));
  }, []);

  // 1. Obtener lista única de sectores para el dropdown
  const sectors = useMemo(() => {
    const unique = Array.from(new Set(camas.map(c => c.nombre_sector)));
    return ['Todos', ...unique.sort()]; // Ordenamos los sectores alfabéticamente
  }, [camas]);

  // 2. Lógica de Filtrado y Ordenamiento
  const filteredAndSortedCamas = useMemo(() => {
    let result = [...camas];

    // A. Filtro por Dropdown de Sector
    if (filterSector !== 'Todos') {
      result = result.filter(c => c.nombre_sector === filterSector);
    }

    // B. Filtro por búsqueda de texto (opcional, por si quieren buscar Nro Habitación)
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      result = result.filter(c => 
        c.id_habitacion.toString().includes(term) || 
        c.nombre_sector.toLowerCase().includes(term)
      );
    }

    // C. Ordenamiento por defecto: Sector -> Habitación -> Cama
    result.sort((a, b) => {
      // Criterio 1: Sector (A-Z)
      if (a.nombre_sector < b.nombre_sector) return -1;
      if (a.nombre_sector > b.nombre_sector) return 1;
      
      // Criterio 2: Número de Habitación (Ascendente)
      if (a.id_habitacion !== b.id_habitacion) {
        return a.id_habitacion - b.id_habitacion;
      }

      // Criterio 3: Nro de Cama
      return a.id_cama - b.id_cama;
    });

    return result;
  }, [camas, filterSector, searchTerm]);

  // 3. Calcular resumen basado en la vista filtrada
  const summary = useMemo(() => {
    return filteredAndSortedCamas.reduce((acc, curr) => {
      const sector = curr.nombre_sector;
      if (!acc[sector]) acc[sector] = { total: 0, libres: 0 };
      acc[sector].total += 1;
      if (curr.esta_libre) acc[sector].libres += 1;
      return acc;
    }, {} as Record<string, { total: number; libres: number }>);
  }, [filteredAndSortedCamas]);

  if (loading) return <div className="p-10 text-center text-slate-500">Cargando disponibilidad hospitalaria...</div>;

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      
      {/* Encabezado */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Disponibilidad de Camas</h1>
          <p className="text-slate-500 text-sm">Vista en tiempo real ordenada por sector.</p>
        </div>

        {/* Barra de Herramientas de Filtros */}
        <div className="flex flex-col sm:flex-row gap-3 w-full md:w-auto">
          {/* Buscador Rápido */}
          <div className="relative">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <input 
              type="text"
              placeholder="Buscar hab..."
              className="pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-teal-500 w-full"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {/* Selector de Sector */}
          <div className="relative">
            <Filter className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <select 
              className="pl-9 pr-8 py-2 border border-slate-300 rounded-lg bg-white text-sm outline-none focus:ring-2 focus:ring-teal-500 w-full cursor-pointer appearance-none"
              value={filterSector}
              onChange={(e) => setFilterSector(e.target.value)}
            >
              {sectors.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
        </div>
      </div>

      {/* Tarjetas de Resumen (Se actualizan según el filtro) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {Object.entries(summary).map(([sector, data]) => (
          <div key={sector} className="bg-white p-4 rounded-lg shadow-sm border-l-4 border-teal-500">
            <h3 className="font-semibold text-slate-600 text-sm uppercase tracking-wide">{sector}</h3>
            <div className="mt-2 flex justify-between items-end">
              <span className="text-3xl font-bold text-teal-700">{data.libres}</span>
              <span className="text-sm text-slate-400 font-medium">de {data.total} camas libres</span>
            </div>
          </div>
        ))}
      </div>

      {/* Tabla Detalle */}
      <div className="bg-white rounded-lg shadow-sm overflow-hidden border border-slate-200">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-50 text-slate-700 uppercase text-xs font-semibold border-b border-slate-200">
            <tr>
              <th className="p-4">Sector</th>
              <th className="p-4">Habitación</th>
              <th className="p-4">Detalles</th>
              <th className="p-4">Cama</th>
              <th className="p-4">Estado</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filteredAndSortedCamas.map((cama, idx) => (
              <tr key={`${cama.id_habitacion}-${cama.id_cama}-${idx}`} className="hover:bg-slate-50 transition-colors">
                <td className="p-4">
                  <span className="px-2 py-1 bg-slate-100 rounded text-xs font-medium text-slate-600">
                    {cama.nombre_sector}
                  </span>
                </td>
                <td className="p-4 font-bold text-slate-700">
                  Hab. {cama.id_habitacion}
                </td>
                <td className="p-4 text-slate-500 text-xs">
                  Piso {cama.piso} • {cama.orientacion === 'N' ? 'Norte' : cama.orientacion === 'S' ? 'Sur' : cama.orientacion === 'E' ? 'Este' : 'Oeste'}
                </td>
                <td className="p-4">
                  Cama {cama.id_cama}
                </td>
                <td className="p-4">
                  {cama.esta_libre ? (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 border border-green-200">
                      Libre
                    </span>
                  ) : (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 border border-red-200">
                      Ocupada
                    </span>
                  )}
                </td>
              </tr>
            ))}
            {filteredAndSortedCamas.length === 0 && (
              <tr>
                <td colSpan={5} className="p-8 text-center text-slate-400 italic">
                  No se encontraron camas con los filtros seleccionados.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}