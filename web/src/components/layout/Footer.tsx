import React from "react";
import Link from "next/link";
import { Logo } from "../ui/Logo";
import { Phone, Mail, MapPin, Shield, Clock, Heart } from "lucide-react";

export const Footer: React.FC = () => {
  return (
    <footer className="bg-brand-primary-dark text-slate-300 border-t border-slate-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10">
          {/* Col 1: Brand & mission */}
          <div className="space-y-4">
            <Logo variant="light" size="lg" />
            <p className="text-sm text-slate-400 leading-relaxed">
              La 1ère plateforme de dépannage électronique et informatique d'urgence à Bamako. Mise en relation instantanée avec des techniciens vérifiés par quartier.
            </p>
            <div className="flex items-center gap-3 text-xs text-slate-400">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-slate-800 text-slate-300 border border-slate-700">
                <Shield className="w-3.5 h-3.5 text-emerald-400" /> Réparations garanties
              </span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-slate-800 text-slate-300 border border-slate-700">
                <Clock className="w-3.5 h-3.5 text-brand-accent" /> Devis &lt; 15 min
              </span>
            </div>
          </div>

          {/* Col 2: Pour les clients */}
          <div className="space-y-3">
            <h4 className="text-sm font-bold text-white uppercase tracking-wider">
              Pour les Clients
            </h4>
            <ul className="space-y-2 text-sm text-slate-400">
              <li>
                <Link href="/sos-panne" className="hover:text-white transition-colors">
                  Déclarer une panne d'urgence
                </Link>
              </li>
              <li>
                <Link href="/#comment-ca-marche" className="hover:text-white transition-colors">
                  Comment ça marche
                </Link>
              </li>
              <li>
                <Link href="/#tarifs" className="hover:text-white transition-colors">
                  Tarifs indicatifs en FCFA
                </Link>
              </li>
              <li>
                <Link href="/mes-demandes" className="hover:text-white transition-colors">
                  Suivi de mes réparations
                </Link>
              </li>
              <li>
                <Link href="/connexion" className="hover:text-white transition-colors">
                  Connexion espace usager
                </Link>
              </li>
            </ul>
          </div>

          {/* Col 3: Pour les Ateliers & Réparateurs */}
          <div className="space-y-3">
            <h4 className="text-sm font-bold text-white uppercase tracking-wider">
              Espace Professionnels
            </h4>
            <ul className="space-y-2 text-sm text-slate-400">
              <li>
                <Link href="/atelier/dashboard" className="hover:text-white transition-colors">
                  Dashboard Atelier Pro
                </Link>
              </li>
              <li>
                <Link href="/atelier/fil-urgences" className="hover:text-white transition-colors">
                  Fil des pannes en direct
                </Link>
              </li>
              <li>
                <Link href="/atelier/journal" className="hover:text-white transition-colors">
                  Journal de comptoir & WhatsApp
                </Link>
              </li>
              <li>
                <Link href="/atelier/abonnement" className="hover:text-white transition-colors">
                  Abonnement Pro (5 000 FCFA)
                </Link>
              </li>
              <li>
                <Link href="/inscription" className="hover:text-white transition-colors">
                  Référencer mon atelier
                </Link>
              </li>
            </ul>
          </div>

          {/* Col 4: Contact & Localisation */}
          <div className="space-y-3">
            <h4 className="text-sm font-bold text-white uppercase tracking-wider">
              Contact & Quartiers
            </h4>
            <div className="space-y-2.5 text-sm text-slate-400">
              <div className="flex items-start gap-2.5">
                <MapPin className="w-4 h-4 text-brand-accent shrink-0 mt-0.5" />
                <span>Hamdallaye ACI 2000, Bamako, République du Mali</span>
              </div>
              <div className="flex items-center gap-2.5">
                <Phone className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>+223 70 00 00 00 / +223 60 00 00 00</span>
              </div>
              <div className="flex items-center gap-2.5">
                <Mail className="w-4 h-4 text-brand-accent shrink-0" />
                <span>contact@techsos.ml</span>
              </div>
            </div>
            <div className="pt-2 text-xs text-slate-500">
              Couverture : Communes I, II, III, IV, V et VI du District de Bamako.
            </div>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-slate-800/80 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-400">
          <p>
            © {new Date().getFullYear()} TechSOS · Développé par <span className="text-slate-200 font-semibold">Golden Innovation Tech</span> à Bamako, Mali.
          </p>
          <div className="flex items-center gap-4">
            <span className="flex items-center gap-1">
              Fait avec <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500" /> pour le Mali
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
};
