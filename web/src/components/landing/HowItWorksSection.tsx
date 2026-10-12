import React from "react";
import Link from "next/link";
import { Mic, ArrowRight, CheckCircle, Shield, Award } from "lucide-react";
import { Button } from "../ui/Button";

export const HowItWorksSection: React.FC = () => {
  const steps = [
    {
      number: "01",
      title: "Expliquez la panne en 1 clic",
      description:
        "Pas besoin de termes techniques compliqués : enregistrez une simple note vocale (comme sur WhatsApp) ou décrivez le souci et ajoutez des photos.",
      icon: <Mic className="w-6 h-6 text-brand-accent" />,
      badge: "Note vocale Web",
    },
    {
      number: "02",
      title: "Recevez des devis en FCFA",
      description:
        "Les réparateurs certifiés de votre quartier examinent votre panne et vous envoient leur prix ferme en FCFA et leur délai d'intervention.",
      icon: <Award className="w-6 h-6 text-brand-primary" />,
      badge: "Comparateur transparent",
    },
    {
      number: "03",
      title: "Validez et récupérez votre appareil",
      description:
        "Choisissez la meilleure offre, déposez l'appareil ou convenez d'un rendez-vous. Vous ne validez la clôture qu'après test de bon fonctionnement.",
      icon: <Shield className="w-6 h-6 text-emerald-600" />,
      badge: "Garantie réparation",
    },
  ];

  return (
    <section className="py-20 bg-white border-b border-brand-border" id="comment-ca-marche">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto space-y-4 mb-16">
          <div className="text-xs font-bold text-brand-accent tracking-widest uppercase">
            Simple · Rapide · Transparent
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            Comment fonctionne TechSOS ?
          </h2>
          <p className="text-slate-600 text-base">
            En moins de 15 minutes, votre panne trouve un technicien qualifié sans vous déplacer dans les embouteillages de Bamako.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
          {steps.map((step, index) => (
            <div
              key={index}
              className="relative rounded-2xl p-8 bg-slate-50 border border-slate-200/80 hover:border-brand-primary/20 transition-all flex flex-col justify-between"
            >
              <div className="space-y-5">
                <div className="flex items-center justify-between">
                  <div className="w-12 h-12 rounded-xl bg-white shadow-sm border border-slate-200 flex items-center justify-center">
                    {step.icon}
                  </div>
                  <span className="text-2xl font-black text-slate-300">
                    {step.number}
                  </span>
                </div>

                <div className="space-y-2">
                  <span className="inline-block text-[11px] font-bold uppercase tracking-wider text-brand-accent bg-orange-50 px-2.5 py-0.5 rounded-full border border-orange-200/60">
                    {step.badge}
                  </span>
                  <h3 className="text-lg font-bold text-slate-900 leading-snug">
                    {step.title}
                  </h3>
                  <p className="text-sm text-slate-600 leading-relaxed">
                    {step.description}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-14 text-center">
          <Link href="/sos-panne">
            <Button variant="accent" size="lg" rightIcon={<ArrowRight className="w-4 h-4" />}>
              Lancer un dépannage maintenant
            </Button>
          </Link>
        </div>
      </div>
    </section>
  );
};
