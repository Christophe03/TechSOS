"use client";

import React from "react";
import Link from "next/link";
import { useAuth } from "@/lib/context/AuthContext";
import { Button } from "../ui/Button";
import {
  AlertTriangle,
  ShieldCheck,
  Clock,
  Sparkles,
  MapPin,
  CheckCircle,
  Wrench,
  ChevronRight,
} from "lucide-react";

export const HeroSection: React.FC = () => {
  const { user } = useAuth();
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-brand-primary via-brand-primary-dark to-slate-900 text-white pt-12 pb-20 lg:pt-20 lg:pb-28">
      {/* Background technical grid pattern */}
      <div className="absolute inset-0 opacity-10 bg-[radial-gradient(#E8641C_1px,transparent_1px)] [background-size:24px_24px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          {/* Left Column: Headlines & Call to Actions */}
          <div className="lg:col-span-7 space-y-6 text-center lg:text-left">
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/10 border border-white/15 text-xs sm:text-sm font-semibold backdrop-blur-md">
              <span className="flex h-2 w-2 rounded-full bg-brand-accent animate-ping" />
              <span className="text-brand-accent font-bold">URGENCE DÉPANNAGE</span>
              <span className="text-slate-300">· District de Bamako</span>
            </div>

            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight leading-[1.15]">
              Votre appareil est en panne ? Les meilleurs réparateurs de{" "}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-orange-400 via-amber-300 to-orange-500">
                Bamako
              </span>{" "}
              vous dépannent.
            </h1>

            <p className="text-base sm:text-lg text-slate-300 max-w-2xl mx-auto lg:mx-0 font-normal leading-relaxed">
              Smartphones, ordinateurs portables, imprimantes ou cartes électroniques. Décrivez votre panne par <strong className="text-white">note vocale</strong>, recevez des devis chiffrés en <strong className="text-white">FCFA</strong> et choisissez le réparateur le plus proche.
            </p>

            {/* CTAs */}
            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
              <Link href="/sos-panne" className="w-full sm:w-auto">
                <Button
                  variant="accent"
                  size="lg"
                  className="w-full sm:w-auto shadow-lg shadow-orange-500/25"
                  leftIcon={<AlertTriangle className="w-5 h-5 text-white animate-bounce" />}
                  rightIcon={<ChevronRight className="w-4 h-4" />}
                >
                  Déclarer un SOS Panne Express
                </Button>
              </Link>
              {user && user.role === "PROVIDER" ? (
                <Link href="/atelier/dashboard" className="w-full sm:w-auto">
                  <Button
                    variant="outline"
                    size="lg"
                    className="w-full sm:w-auto bg-white/5 border-white/20 text-white hover:bg-white/10 hover:border-white/40"
                    leftIcon={<Wrench className="w-4 h-4 text-brand-accent" />}
                  >
                    Mon Dashboard Atelier
                  </Button>
                </Link>
              ) : (
                <Link href="/ateliers" className="w-full sm:w-auto">
                  <Button
                    variant="outline"
                    size="lg"
                    className="w-full sm:w-auto bg-white/5 border-white/20 text-white hover:bg-white/10 hover:border-white/40"
                    leftIcon={<MapPin className="w-4 h-4 text-brand-accent" />}
                  >
                    Trouver un Atelier Agréé
                  </Button>
                </Link>
              )}
            </div>

            {/* Trust points */}
            <div className="pt-6 border-t border-white/10 grid grid-cols-2 sm:grid-cols-3 gap-4 text-left">
              <div className="flex items-start gap-2.5">
                <Clock className="w-4 h-4 text-brand-accent shrink-0 mt-0.5" />
                <div>
                  <div className="text-xs font-bold text-white">Devis en &lt; 15 min</div>
                  <div className="text-[11px] text-slate-400">Réponse quasi-immédiate</div>
                </div>
              </div>
              <div className="flex items-start gap-2.5">
                <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="text-xs font-bold text-white">Ateliers Certifiés</div>
                  <div className="text-[11px] text-slate-400">Compétence vérifiée</div>
                </div>
              </div>
              <div className="flex items-start gap-2.5 col-span-2 sm:col-span-1">
                <MapPin className="w-4 h-4 text-amber-400 shrink-0 mt-0.5" />
                <div>
                  <div className="text-xs font-bold text-white">Par Quartier</div>
                  <div className="text-[11px] text-slate-400">ACI 2000, Badala, etc.</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Interactive Emergency Card Mockup */}
          <div className="lg:col-span-5">
            <div className="relative mx-auto max-w-md">
              {/* Decorative glow */}
              <div className="absolute -inset-1 rounded-3xl bg-gradient-to-r from-orange-500 to-amber-500 opacity-30 blur-xl" />

              <div className="relative bg-white text-slate-900 rounded-3xl p-6 sm:p-7 shadow-2xl border border-white/20 space-y-5">
                <div className="flex items-center justify-between pb-4 border-b border-slate-100">
                  <div className="flex items-center gap-3">
                    <span className="flex h-3 w-3 rounded-full bg-emerald-500" />
                    <div>
                      <div className="text-xs font-bold text-slate-900 uppercase tracking-wider">
                        Atelier de Garde Bamako
                      </div>
                      <div className="text-[11px] text-slate-500">
                        14 réparateurs actifs en ce moment
                      </div>
                    </div>
                  </div>
                  <span className="text-xs px-2.5 py-1 font-bold rounded-full bg-orange-100 text-brand-accent">
                    SOS ACTIF
                  </span>
                </div>

                {/* Simulated live ticket */}
                <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-brand-primary">
                      📱 iPhone 13 Pro · Écran fissuré
                    </span>
                    <span className="text-[11px] text-slate-500">Hamdallaye ACI</span>
                  </div>
                  <div className="flex items-center gap-2 text-xs text-slate-600 bg-white p-2.5 rounded-xl border border-slate-200">
                    <span className="w-2.5 h-2.5 rounded-full bg-rose-500 animate-pulse" />
                    <span className="italic font-medium">Note vocale reçue (0:18s)</span>
                    <span className="ml-auto text-[11px] font-semibold text-brand-accent">Écouter</span>
                  </div>
                  <div className="flex items-center justify-between pt-1">
                    <span className="text-xs font-bold text-slate-800">
                      3 devis reçus : <span className="text-emerald-700">dès 25 000 FCFA</span>
                    </span>
                    <span className="text-[11px] font-semibold text-slate-500">Délai : 45 min</span>
                  </div>
                </div>

                <div className="space-y-2.5">
                  <div className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                    Un problème avec votre matériel ?
                  </div>
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <div className="p-2.5 rounded-xl border border-slate-200 flex items-center gap-2 font-medium hover:border-brand-accent transition-colors">
                      <span>💻</span> Ordinateur bloqué
                    </div>
                    <div className="p-2.5 rounded-xl border border-slate-200 flex items-center gap-2 font-medium hover:border-brand-accent transition-colors">
                      <span>🔋</span> Batterie hors service
                    </div>
                    <div className="p-2.5 rounded-xl border border-slate-200 flex items-center gap-2 font-medium hover:border-brand-accent transition-colors">
                      <span>🖨️</span> Imprimante en panne
                    </div>
                    <div className="p-2.5 rounded-xl border border-slate-200 flex items-center gap-2 font-medium hover:border-brand-accent transition-colors">
                      <span>🔌</span> Court-circuit / Charge
                    </div>
                  </div>
                </div>

                <Link href="/sos-panne" className="block">
                  <Button variant="accent" className="w-full">
                    Obtenir mes devis gratuitement
                  </Button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
