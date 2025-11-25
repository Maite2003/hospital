'use client';

import React, { useState } from 'react';
import { Search, FileText } from 'lucide-react';
import { TipoListadoComentarios, TipoComentario } from '@/types/types';
import axios from 'axios';

export default function HistorialPacientesPage() {
  const [idInternacion, setIdInternacion] = useState('');
  const [internacion, setInternacion] = useState<TipoListadoComentarios>();
  const [loading, setLoading] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);
  const [error, setError] = useState<string | undefined>(undefined);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!idInternacion) return;
    
    setLoading(true);
    try {
      // Llama a la acción del servidor que ejecuta tus funciones SQL
      const res = await axios.get(`/api/reportes/comentarios_internacion/${idInternacion}`);

      if (res.status == 200) {
        const i = res.data.internacion
        if (!i) {
          setInternacion(undefined);
        } else {
          const internacion: TipoListadoComentarios = i
          setInternacion(internacion)
        }
        setHasSearched(true);
      }
      else {
        setInternacion(undefined);
        setHasSearched(true);
        setError('Hubo un problema consiguiendo los comentarios, intenta nuevamente mas tarde');
      }
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-800">Reportes: Comentarios por Internacion</h1>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-sm border border-slate-200">
        <form onSubmit={handleSearch} className="flex gap-2 max-w-md">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-3 h-4 w-4 text-slate-400" />
            <input 
              type="text"
              placeholder="Buscar por ID de internacion..."
              className="w-full pl-10 p-2.5 border border-slate-300 rounded-md focus:ring-2 focus:ring-blue-500 outline-none"
              value={idInternacion}
              onChange={(e) => setIdInternacion(e.target.value)}
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition disabled:bg-blue-400"
          >
            {loading ? '...' : 'Buscar'}
          </button>
        </form>
      </div>

      { !internacion && error && (
        <div className="p-8 text-center text-slate-500 bg-slate-50 rounded-lg border border-dashed border-slate-300">
          {error}
        </div>
      )}

      {hasSearched && !internacion && !loading && (
        <div className="p-8 text-center text-slate-500 bg-slate-50 rounded-lg border border-dashed border-slate-300">
          No hay comentarios para esa internacion.
        </div>
      )}

      {internacion && internacion.comentarios.length > 0 && (
        <div className="space-y-4">
          <div>
            <h3 className="font-bold text-blue-900">{internacion.apellido}, {internacion.nombre}</h3>
            <p className="text-xs text-slate-500">DNI: {internacion.nroDni} | Int. #{internacion.idInternacion}</p>
          </div>
          {internacion.comentarios.map((comentario, index) => (
             <div key={index} className="bg-white p-4 rounded-lg shadow-sm border border-slate-200">
               <div className="flex justify-between items-start">
                 <span className="text-xs font-mono text-slate-400">
                   {new Date(comentario.fechaHora).toLocaleString()}
                 </span>
               </div>
               <div className="mt-3 p-3 bg-slate-50 rounded border border-slate-100">
                 <p className="text-slate-800 italic">"{comentario.descripcion}"</p>
               </div>
               <p className="text-xs text-slate-400 mt-2 font-medium text-right">Dr/a. {comentario.nombre_doctor} ({comentario.nroMatricula})</p>
             </div>
          ))}
        </div>
      )}
    </div>
  );
}