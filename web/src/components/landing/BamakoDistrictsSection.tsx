"use client";

import React, { useState } from "react";
import Link from "next/link";
import { BAMAKO_COMMUNES } from "@/lib/constants/bamako";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { MapPin, Navigation, Clock, ShieldCheck, ArrowRight } from "lucide-react";

export const BamakoDistrictsSection: React.FC = () => {
  const [selectedCommune, setSelectedCommune] = useState(BAMAKO_COMMUNES[3].id); // Default Commune IV (ACI 2000)

  const activeCommune = BAMAKO_COMMUNES.find((c) => c.id === selectedCommune) || BAMAKO_COMMUNES[0];

  return (
    <section className="py-20 bg-brand-surface border-b border-brand-border" id="quartiers">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto space-y-4 mb-12">
          <div className="text-xs font-bold text-brand-accent tracking-widest uppercase">
            Couverture Géographique
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            Des réparateurs qualifiés dans chaque quartier de Bamako
          </h2>
          <p className="text-slate-600 text-base">
            Évitez les trajets et les ponts encombrés : trouvez un atelier partenaire directement dans votre commune.
          </p>
        </div>

        {/* Commune selector tabs */}
        <div className="flex flex-wrap items-center justify-center gap-2 mb-10">
          {BAMAKO_COMMUNES.map((commune) => (
            <button
              key={commune.id}
              onClick={() => setSelectedCommune(commune.id)}
              className={`px-4 py-2.5 rounded-xl text-xs sm:text-sm font-bold transition-all ${
                selectedCommune === commune.id
                  ? "bg-brand-primary text-white shadow-sm"
                  : "bg-white text-slate-600 hover:bg-slate-100 border border-slate-200"
              }`}
            >
              {commune.name}
            </button>
          ))}
        </div>

        {/* Selected Commune Card details */}
        <Card className="max-w-4xl mx-auto p-8 shadow-hover border-slate-200">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6 pb-6 border-b border-slate-100">
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-brand-accent font-bold text-sm">
                <MapPin className="w-4 h-4" />
                <span>Zone d'intervention prioritaire</span>
              </div>
              <h3 className="text-2xl font-black text-slate-900">
                {activeCommune.name} · District de Bamako
              </h3>
            </div>
            <div className="flex items-center gap-3">
              <span className="px-3 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-1.5">
                <Clock className="w-3.5 h-3.5 text-emerald-600" />
                Délai moyen : 15 à 30 min
              </span>
            </div>
          </div>

          <div className="py-6 space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-500">
              Quartiers desservis par nos techniciens partenaires :
            </h4>
            <div className="flex flex-wrap gap-2.5">
              {activeCommune.neighborhoods.map((neighborhood, i) => (
                <span
                  key={i}
                  className="px-3.5 py-2 rounded-xl bg-slate-50 border border-slate-200 text-xs sm:text-sm font-semibold text-slate-800 hover:border-brand-primary/40 transition-colors flex items-center gap-2"
                >
                  <Navigation className="w-3.5 h-3.5 text-brand-accent" />
                  <span>{neighborhood}</span>
                </span>
              ))}
            </div>
          </div>

          <div className="pt-6 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2 text-xs text-slate-500">
              <ShieldCheck className="w-4 h-4 text-brand-accent" />
              <span>Chaque atelier fait l'objet d'un contrôle physique de conformité</span>
            </div>
            <Link href="/sos-panne">
              <Button variant="accent" size="sm" rightIcon={<ArrowRight className="w-4 h-4" />}>
                Trouver un atelier à {activeCommune.name}
              </Button>
            </Link>
          </div>
        </Card>
      </div>
    </section>
  );
};
