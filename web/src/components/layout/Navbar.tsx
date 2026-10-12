"use client";

import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Logo } from "../ui/Logo";
import { Button } from "../ui/Button";
import {
  Wrench,
  AlertCircle,
  Menu,
  X,
  User,
  LayoutDashboard,
  LogOut,
  PhoneCall,
  ShieldCheck,
} from "lucide-react";
import { useAuth } from "@/lib/context/AuthContext";

export const Navbar: React.FC = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const pathname = usePathname();
  const { user, logout } = useAuth();

  const isAtelierRoute = pathname?.startsWith("/atelier");

  return (
    <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-brand-border">
      {/* Top micro emergency ticker */}
      <div className="bg-brand-primary text-white text-xs py-1.5 px-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="font-medium">
              Disponibilité immédiate · Réparateurs en ligne à Bamako (ACI 2000, Badalabougou, Lafiabougou)
            </span>
          </div>
          <div className="hidden sm:flex items-center gap-4 text-slate-300">
            <span className="flex items-center gap-1">
              <ShieldCheck className="w-3.5 h-3.5 text-brand-accent" /> Devis garanti en FCFA
            </span>
            <span className="flex items-center gap-1">
              <PhoneCall className="w-3.5 h-3.5 text-emerald-400" /> Assistance : +223 70 00 00 00
            </span>
          </div>
        </div>
      </div>

      {/* Main bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
        <Logo size="md" />

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center gap-8">
          <Link
            href="/"
            className={`text-sm font-semibold transition-colors hover:text-brand-accent ${
              pathname === "/" ? "text-brand-accent" : "text-slate-700"
            }`}
          >
            Accueil
          </Link>
          <Link
            href="/#comment-ca-marche"
            className="text-sm font-semibold text-slate-700 hover:text-brand-accent transition-colors"
          >
            Comment ça marche
          </Link>
          <Link
            href="/#quartiers"
            className="text-sm font-semibold text-slate-700 hover:text-brand-accent transition-colors"
          >
            Ateliers à Bamako
          </Link>
          <Link
            href="/#tarifs"
            className="text-sm font-semibold text-slate-700 hover:text-brand-accent transition-colors"
          >
            Tarifs & Garanties
          </Link>
        </nav>

        {/* Desktop Actions */}
        <div className="hidden md:flex items-center gap-3">
          {user ? (
            <div className="flex items-center gap-3">
              {user.role === "PROVIDER" ? (
                <Link href="/atelier/dashboard">
                  <Button variant="outline" size="sm" leftIcon={<LayoutDashboard className="w-4 h-4" />}>
                    Dashboard Atelier
                  </Button>
                </Link>
              ) : (
                <Link href="/mes-demandes">
                  <Button variant="outline" size="sm" leftIcon={<User className="w-4 h-4" />}>
                    Mes Demandes
                  </Button>
                </Link>
              )}
              <Link href="/sos-panne">
                <Button variant="accent" size="sm" leftIcon={<AlertCircle className="w-4 h-4" />}>
                  SOS Panne
                </Button>
              </Link>
              <button
                onClick={logout}
                title="Déconnexion"
                className="p-2 text-slate-400 hover:text-rose-600 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-2.5">
              <Link href="/atelier/dashboard">
                <Button
                  variant="outline"
                  size="sm"
                  leftIcon={<Wrench className="w-3.5 h-3.5 text-brand-primary" />}
                >
                  Espace Atelier
                </Button>
              </Link>
              <Link href="/connexion">
                <Button variant="ghost" size="sm">
                  Connexion
                </Button>
              </Link>
              <Link href="/sos-panne">
                <Button
                  variant="accent"
                  size="sm"
                  leftIcon={<AlertCircle className="w-4 h-4" />}
                >
                  SOS Panne
                </Button>
              </Link>
            </div>
          )}
        </div>

        {/* Mobile menu button */}
        <div className="flex md:hidden items-center gap-2">
          <Link href="/sos-panne">
            <Button variant="accent" size="sm" className="px-2.5 py-1.5 text-xs">
              SOS
            </Button>
          </Link>
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="p-2 text-slate-700 hover:text-brand-primary rounded-lg focus:outline-none"
            aria-label="Menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </div>

      {/* Mobile drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden border-t border-brand-border bg-white px-4 pt-3 pb-6 space-y-3 shadow-lg">
          <Link
            href="/"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-slate-800 hover:text-brand-accent"
          >
            Accueil
          </Link>
          <Link
            href="/#comment-ca-marche"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-slate-800 hover:text-brand-accent"
          >
            Comment ça marche
          </Link>
          <Link
            href="/#quartiers"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-slate-800 hover:text-brand-accent"
          >
            Ateliers vérifiés à Bamako
          </Link>
          <Link
            href="/#tarifs"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-slate-800 hover:text-brand-accent"
          >
            Tarifs & Garanties
          </Link>

          <div className="pt-3 border-t border-slate-200 flex flex-col gap-2.5">
            {user ? (
              <>
                <div className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1">
                  Connecté : {user.fullName} ({user.role})
                </div>
                {user.role === "PROVIDER" ? (
                  <Link href="/atelier/dashboard" onClick={() => setMobileMenuOpen(false)}>
                    <Button variant="outline" className="w-full">Dashboard Atelier</Button>
                  </Link>
                ) : (
                  <Link href="/mes-demandes" onClick={() => setMobileMenuOpen(false)}>
                    <Button variant="outline" className="w-full">Mes Demandes</Button>
                  </Link>
                )}
                <Button variant="ghost" onClick={() => { logout(); setMobileMenuOpen(false); }} className="w-full text-rose-600">
                  Se déconnecter
                </Button>
              </>
            ) : (
              <>
                <Link href="/connexion" onClick={() => setMobileMenuOpen(false)}>
                  <Button variant="outline" className="w-full">Connexion / Inscription</Button>
                </Link>
                <Link href="/atelier/dashboard" onClick={() => setMobileMenuOpen(false)}>
                  <Button variant="ghost" className="w-full" leftIcon={<Wrench className="w-4 h-4" />}>
                    Espace Réparateur & Atelier
                  </Button>
                </Link>
              </>
            )}
            <Link href="/sos-panne" onClick={() => setMobileMenuOpen(false)}>
              <Button variant="accent" className="w-full" leftIcon={<AlertCircle className="w-4 h-4" />}>
                Déclarer un SOS Panne Express
              </Button>
            </Link>
          </div>
        </div>
      )}
    </header>
  );
};
