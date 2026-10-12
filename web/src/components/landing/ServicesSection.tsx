import React from "react";
import Link from "next/link";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import {
  Smartphone,
  Laptop,
  Printer,
  Tv,
  ArrowRight,
  CheckCircle2,
} from "lucide-react";

export const ServicesSection: React.FC = () => {
  const services = [
    {
      icon: <Smartphone className="w-7 h-7 text-brand-accent" />,
      title: "Smartphones & Téléphones",
      tagline: "iPhone, Samsung, Tecno, Infinix, Xiaomi",
      issues: [
        "Écran cassé ou tactile figé",
        "Batterie qui se vide trop vite",
        "Connecteur de charge endommagé",
        "Micro ou haut-parleur silencieux",
      ],
      priceEst: "Dès 5 000 FCFA",
      categorySlug: "smartphones",
    },
    {
      icon: <Laptop className="w-7 h-7 text-brand-primary" />,
      title: "Ordinateurs & PC Portables",
      tagline: "HP, Dell, Lenovo, Apple MacBook, Asus",
      issues: [
        "Écran noir / Ne démarre plus",
        "Surchauffe / Ventilateur bruyant",
        "Réinstallation système & récupération données",
        "Clavier défaillant ou liquide renversé",
      ],
      priceEst: "Dès 10 000 FCFA",
      categorySlug: "ordinateurs",
    },
    {
      icon: <Printer className="w-7 h-7 text-emerald-600" />,
      title: "Imprimantes & Bureautique",
      tagline: "HP LaserJet, Canon, Epson EcoTank",
      issues: [
        "Bourrage papier permanent",
        "Tête d'impression bouchée",
        "Erreurs réseau / Non reconnue en Wi-Fi",
        "Maintenance préventive bureau",
      ],
      priceEst: "Dès 15 000 FCFA",
      categorySlug: "imprimantes",
    },
    {
      icon: <Tv className="w-7 h-7 text-amber-500" />,
      title: "Électronique & Écrans TV",
      tagline: "Smart TV, Onduleurs, Cartes mères",
      issues: [
        "Son sans image (rétroéclairage)",
        "Onduleur qui ne tient plus la charge",
        "Court-circuit suite à coupure d'EDM",
        "Soudure de composants CMS",
      ],
      priceEst: "Dès 10 000 FCFA",
      categorySlug: "electronique",
    },
  ];

  return (
    <section className="py-20 bg-brand-surface border-b border-brand-border" id="services">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto space-y-4 mb-14">
          <div className="text-xs font-bold text-brand-accent tracking-widest uppercase">
            Spécialités Techniques Agréées
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            Quel équipement souhaitez-vous réparer ?
          </h2>
          <p className="text-slate-600 text-base">
            Nos ateliers partenaires disposent des pièces d'origine et du matériel de diagnostic électronique de pointe pour chaque catégorie.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {services.map((item, index) => (
            <Card
              key={index}
              hover
              className="flex flex-col justify-between border-slate-200 hover:border-brand-primary/30"
            >
              <div className="space-y-4">
                <div className="w-14 h-14 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-center shadow-sm">
                  {item.icon}
                </div>
                <div>
                  <h3 className="text-lg font-bold text-slate-900">{item.title}</h3>
                  <p className="text-xs font-medium text-slate-500 mt-0.5">{item.tagline}</p>
                </div>

                <ul className="space-y-2 pt-2 border-t border-slate-100 text-xs text-slate-600">
                  {item.issues.map((issue, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 shrink-0 mt-0.5" />
                      <span>{issue}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="pt-6 mt-6 border-t border-slate-100 flex items-center justify-between">
                <div>
                  <span className="text-[11px] text-slate-400 block uppercase font-bold tracking-wider">
                    Tarif indicatif
                  </span>
                  <span className="text-sm font-extrabold text-brand-primary">
                    {item.priceEst}
                  </span>
                </div>
                <Link href="/sos-panne">
                  <Button variant="outline" size="sm" rightIcon={<ArrowRight className="w-3.5 h-3.5" />}>
                    SOS
                  </Button>
                </Link>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
};
