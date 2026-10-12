"use client";

import React from "react";
import { ProviderItem } from "@/lib/api/users";
import { Modal } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";
import Link from "next/link";
import {
  MapPin,
  Star,
  ShieldCheck,
  Phone,
  MessageSquare,
  Wrench,
  CheckCircle2,
  Clock,
  Sparkles,
  ArrowRight,
} from "lucide-react";

interface WorkshopDetailModalProps {
  workshop: ProviderItem | null;
  isOpen: boolean;
  onClose: () => void;
  specialties: string[];
}

export const WorkshopDetailModal: React.FC<WorkshopDetailModalProps> = ({
  workshop,
  isOpen,
  onClose,
  specialties,
}) => {
  if (!workshop) return null;

  const getCleanPhone = (phone: string) => {
    let clean = phone.replace(/[\s\-\+\(\)]/g, "");
    if (!clean.startsWith("223") && clean.length === 8) {
      clean = "223" + clean;
    }
    return clean;
  };

  const cleanPhone = getCleanPhone(workshop.user.phone);
  const waMessage = encodeURIComponent(
    `Bonjour ${workshop.workshopName}, je vous contacte via la fiche officielle TechSOS Bamako pour une réparation.`
  );

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Fiche de l'Atelier Agréé" size="lg">
      <div className="space-y-6">
        {/* Header with badge */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-100">
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
                {workshop.workshopName}
              </h2>
              <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-200">
                Agréé TechSOS
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-1">
              Responsable technique : <strong className="text-slate-800">{workshop.user.fullName}</strong>
            </p>
          </div>

          <div className="flex items-center gap-3">
            <span className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl bg-amber-50 text-amber-900 text-sm font-black border border-amber-200">
              <Star className="w-4 h-4 fill-amber-400 text-amber-400" />
              <span>{(workshop.ratingAvg || 5.0).toFixed(1)} / 5</span>
              <span className="text-slate-400 text-xs">({workshop.reviewCount} avis)</span>
            </span>
          </div>
        </div>

        {/* Localisation & Hours */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-200 space-y-1">
            <div className="flex items-center gap-2 text-xs font-bold text-brand-primary uppercase tracking-wider">
              <MapPin className="w-4 h-4 text-brand-accent" />
              <span>Adresse & Quartier</span>
            </div>
            <p className="text-xs text-slate-700 font-medium">
              {workshop.addressZone || "Bamako, République du Mali"}
            </p>
            {workshop.user.address && (
              <p className="text-[11px] text-slate-500 italic">
                Repère : {workshop.user.address}
              </p>
            )}
          </div>

          <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-200 space-y-1">
            <div className="flex items-center gap-2 text-xs font-bold text-brand-primary uppercase tracking-wider">
              <Clock className="w-4 h-4 text-emerald-600" />
              <span>Horaires de comptoir</span>
            </div>
            <p className="text-xs text-slate-700 font-medium">
              Lundi – Samedi : 08h30 – 19h00
            </p>
            <p className="text-[11px] text-slate-500">
              Service d'urgence SOS disponible 24/7 sur la plateforme
            </p>
          </div>
        </div>

        {/* Domaine d'expertise */}
        <div className="space-y-2">
          <div className="text-xs font-bold text-slate-700 uppercase tracking-wider flex items-center gap-1.5">
            <Wrench className="w-4 h-4 text-brand-accent" />
            <span>Spécialités & Équipements pris en charge</span>
          </div>
          <div className="flex flex-wrap gap-2">
            {specialties.map((spec, i) => (
              <span
                key={i}
                className="px-3 py-1.5 rounded-xl bg-orange-50 text-brand-accent text-xs font-bold border border-orange-200"
              >
                ✓ {spec}
              </span>
            ))}
          </div>
        </div>

        {/* Engagements de garantie */}
        <div className="p-4 rounded-2xl bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200/80 space-y-2">
          <div className="flex items-center gap-2 text-xs font-bold text-emerald-800 uppercase tracking-wider">
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
            <span>Garanties Réseau TechSOS</span>
          </div>
          <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs text-emerald-900 font-medium">
            <li className="flex items-center gap-2">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>Garantie pièce & main d'œuvre 15 jours</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>Devis préalable sans surprise en FCFA</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>Notification de statut par WhatsApp</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>Technicien vérifié par notre équipe</span>
            </li>
          </ul>
        </div>

        {/* Direct Action Buttons */}
        <div className="pt-2 flex flex-col sm:flex-row items-center gap-3">
          <a
            href={`https://wa.me/${cleanPhone}?text=${waMessage}`}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:flex-1 py-3 px-4 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-sm transition-colors"
          >
            <MessageSquare className="w-4 h-4" />
            <span>Discuter sur WhatsApp</span>
          </a>

          <a
            href={`tel:${workshop.user.phone}`}
            className="w-full sm:flex-1 py-3 px-4 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold flex items-center justify-center gap-2 transition-colors"
          >
            <Phone className="w-4 h-4 text-brand-primary" />
            <span>Appeler l'Atelier</span>
          </a>

          <Link href="/sos-panne" className="w-full sm:w-auto">
            <Button variant="accent" size="md" rightIcon={<ArrowRight className="w-4 h-4" />}>
              Déposer SOS Panne
            </Button>
          </Link>
        </div>
      </div>
    </Modal>
  );
};
