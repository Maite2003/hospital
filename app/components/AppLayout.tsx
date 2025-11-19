'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  BedDouble, 
  FileText, 
  ShieldAlert, 
  Activity,
  ChevronRight,
  LogOut,
  Menu
} from 'lucide-react';

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const pathname = usePathname();

  const NavItem = ({ href, label, icon: Icon }: { href: string, label: string, icon: any }) => {
    const isActive = pathname === href;
    return (
      <Link
        href={href}
        onClick={() => setIsMobileMenuOpen(false)}
        className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 group ${
          isActive 
            ? 'bg-indigo-50 text-indigo-700 font-medium shadow-sm' 
            : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'
        }`}
      >
        <Icon className={`w-5 h-5 ${isActive ? 'text-indigo-600' : 'text-slate-400 group-hover:text-slate-600'}`} />
        <span>{label}</span>
        {isActive && <ChevronRight className="w-4 h-4 ml-auto text-indigo-400" />}
      </Link>
    );
  };

  return (
    <div className="min-h-screen bg-slate-50 flex font-sans text-slate-900">
      
      {/* Mobile Overlay */}
      {isMobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-black/20 z-20 lg:hidden"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed lg:static inset-y-0 left-0 z-30 w-72 bg-white border-r border-slate-200 transform transition-transform duration-200 ease-in-out
        ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        <div className="h-full flex flex-col">
          <div className="p-6 border-b border-slate-100">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 bg-indigo-600 rounded-lg flex items-center justify-center">
                <Activity className="text-white w-5 h-5" />
              </div>
              <div>
                <h1 className="font-bold text-lg text-slate-800 tracking-tight">MediGest</h1>
                <p className="text-xs text-slate-500 font-medium uppercase tracking-wider">Hospital Central</p>
              </div>
            </div>
          </div>

          <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
            <div className="text-xs font-semibold text-slate-400 uppercase tracking-wider px-4 mb-2 mt-2">Operaciones</div>
            <NavItem 
              href="/internaciones" 
              label="Gestión Internaciones" 
              icon={LayoutDashboard} 
            />

            <div className="text-xs font-semibold text-slate-400 uppercase tracking-wider px-4 mb-2 mt-8">Reportes y Control</div>
            <NavItem 
              href="/reportes/camas" 
              label="Disponibilidad Camas" 
              icon={BedDouble} 
            />
            <NavItem 
              href="/reportes/historial" 
              label="Historial Pacientes" 
              icon={FileText} 
            />
            <NavItem 
              href="/reportes/auditoria" 
              label="Auditoría Guardias" 
              icon={ShieldAlert} 
            />
          </nav>

          <div className="p-4 border-t border-slate-100">
            <button className="flex items-center gap-3 px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg w-full transition-colors">
              <LogOut className="w-4 h-4" />
              Cerrar Sesión
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col h-screen overflow-hidden">
        {/* Top Header */}
        <header className="bg-white border-b border-slate-200 h-16 flex items-center justify-between px-4 lg:px-8 shadow-sm z-10">
          <button 
            onClick={() => setIsMobileMenuOpen(true)}
            className="lg:hidden p-2 text-slate-600 hover:bg-slate-100 rounded-md"
          >
            <Menu className="w-6 h-6" />
          </button>
          
          <div className="flex items-center gap-4 ml-auto">
            <div className="text-right hidden sm:block">
              <p className="text-sm font-medium text-slate-700">Dr. Admin</p>
              <p className="text-xs text-slate-400">Administración Central</p>
            </div>
            <div className="h-9 w-9 rounded-full bg-indigo-100 border border-indigo-200 flex items-center justify-center text-indigo-700 font-bold text-sm">
              DA
            </div>
          </div>
        </header>

        {/* Content Area */}
        <main className="flex-1 overflow-auto bg-slate-50 p-4 lg:p-8">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}