import React from "react";
import Link from "next/link";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { Check, ShieldCheck, Banknote, Sparkles, AlertCircle } from "lucide-react";

export const TarifsSection: React.FC = () => {
  const priceGuides = [
    {
      device: "Smartphones",
      items: [
        { label: "Connecteur de charge", price: "5 000 - 10 000 FCFA" },
        { label: "Remplacement écran (LCD / OLED)", price: "12 000 - 35 000 FCFA" },
        { label: "Remplacement batterie neuve", price: "7 000 - 15 000 FCFA" },
        { label: "Désoxydation liquide / court-circuit", price: "10 000 - 20 000 FCFA" },
      ],
    },
    {
      device: "Ordinateurs Portables",
      items: [
        { label: "Réinstallation système & pilotes", price: "10 000 - 15 000 FCFA" },
        { label: "Changement disque SSD / Ram", price: "15 000 - 30 000 FCFA" },
        { label: "Remplacement dalle d'écran", price: "25 000 - 50 000 FCFA" },
        { label: "Nettoyage thermique & pâte", price: "8 000 - 12 000 FCFA" },
      ],
    },
    {
      device: "Bureautique & Imprimantes",
      items: [
        { label: "Déblocage bourrage & galets", price: "10 000 - 20 000 FCFA" },
        { label: "Nettoyage tête d'impression", price: "15 000 - 25 000 FCFA" },
        { label: "Changement carte d'alimentation", price: "20 000 - 45 000 FCFA" },
        { label: "Configuration réseau & Wi-Fi", price: "10 000 - 15 000 FCFA" },
      ],
    },
  ];

  return (
    <section className="py-20 bg-white border-b border-brand-border" id="tarifs">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto space-y-4 mb-14">
          <div className="text-xs font-bold text-brand-accent tracking-widest uppercase">
            Transparence Tarifaire
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            Tarifs indicatifs moyens à Bamako
          </h2>
          <p className="text-slate-600 text-base">
            Aucun frais caché. Les réparateurs s'engagent sur des devis fermes en FCFA avant toute intervention technique sur votre matériel.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {priceGuides.map((guide, idx) => (
            <Card key={idx} className="border-slate-200 p-7 space-y-6">
              <div className="flex items-center justify-between pb-4 border-b border-slate-100">
                <h3 className="text-lg font-bold text-brand-primary">{guide.device}</h3>
                <span className="text-xs px-2.5 py-1 rounded-full bg-slate-100 font-semibold text-slate-600">
                  Moyenne Bamako
                </span>
              </div>

              <ul className="space-y-4">
                {guide.items.map((item, i) => (
                  <li key={i} className="flex flex-col space-y-1">
                    <span className="text-xs font-semibold text-slate-700">
                      {item.label}
                    </span>
                    <span className="text-sm font-extrabold text-brand-accent">
                      {item.price}
                    </span>
                  </li>
                ))}
              </ul>

              <div className="pt-4 border-t border-slate-100">
                <Link href="/sos-panne">
                  <Button variant="outline" size="sm" className="w-full">
                    Demander un devis
                  </Button>
                </Link>
              </div>
            </Card>
          ))}
        </div>

        {/* Guarantees Box */}
        <div className="mt-12 bg-slate-50 border border-slate-200 rounded-2xl p-6 sm:p-8 flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center shrink-0">
              <ShieldCheck className="w-6 h-6" />
            </div>
            <div className="space-y-1">
              <h4 className="text-base font-bold text-slate-900">
                La Charte Qualité TechSOS Mali
              </h4>
              <p className="text-sm text-slate-600 max-w-2xl">
                Toutes les réparations validées via TechSOS bénéficient d'une période de garantie minimale de 15 jours sur les pièces remplacées et la main d'œuvre.
              </p>
            </div>
          </div>
          <Link href="/sos-panne" className="shrink-0">
            <Button variant="accent">
              SOS Panne Immédiat
            </Button>
          </Link>
        </div>
      </div>
    </section>
  );
};
