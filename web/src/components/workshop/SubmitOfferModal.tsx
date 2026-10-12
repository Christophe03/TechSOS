"use client";

import React, { useState } from "react";
import { X, Banknote, Clock, ShieldCheck } from "lucide-react";
import { Button } from "../ui/Button";
import { workshopApi } from "@/lib/api/workshop";
import { Repair } from "@/lib/types";

interface SubmitOfferModalProps {
  repair: Repair;
  isOpen: boolean;
  onClose: () => void;
  onOfferSubmitted: () => void;
}

const DURATION_CHIPS = ["30 minutes", "1 heure", "2 heures", "24 heures", "48 heures"];

export const SubmitOfferModal: React.FC<SubmitOfferModalProps> = ({
  repair,
  isOpen,
  onClose,
  onOfferSubmitted,
}) => {
  const [priceXof, setPriceXof] = useState<number>(10000);
  const [estimatedDuration, setEstimatedDuration] = useState("1 heure");
  const [comment, setComment] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (priceXof < 500) {
      setError("Le tarif minimum est de 500 FCFA.");
      return;
    }

    setError(null);
    setLoading(true);

    try {
      await workshopApi.submitOffer({
        repairId: repair.id,
        priceXof,
        estimatedDuration,
        comment: comment.trim() || undefined,
      });
      onOfferSubmitted();
      onClose();
    } catch (err: any) {
      setError(err.message || "Erreur lors de l'envoi du devis.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in">
      <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div>
            <h3 className="text-lg font-bold text-slate-900">
              Proposer un devis
            </h3>
            <p className="text-xs text-slate-500">{repair.equipmentTitle}</p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {error && (
          <div className="p-3 bg-rose-50 text-rose-700 text-xs rounded-xl border border-rose-200">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Votre tarif ferme en FCFA (Toutes pièces incluses)
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <Banknote className="w-4 h-4 text-emerald-600" />
              </div>
              <input
                type="number"
                min="500"
                step="500"
                required
                value={priceXof}
                onChange={(e) => setPriceXof(parseInt(e.target.value) || 0)}
                className="w-full pl-10 pr-16 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-base font-bold text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
              />
              <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-xs font-bold text-slate-400">
                FCFA
              </div>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
              Délai d'intervention estimé
            </label>
            <div className="flex flex-wrap gap-2">
              {DURATION_CHIPS.map((chip) => (
                <button
                  key={chip}
                  type="button"
                  onClick={() => setEstimatedDuration(chip)}
                  className={`text-xs px-3 py-1.5 rounded-lg font-medium transition-all ${
                    estimatedDuration === chip
                      ? "bg-brand-primary text-white"
                      : "bg-slate-100 text-slate-700 hover:bg-slate-200"
                  }`}
                >
                  {chip}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Précision technique pour le client (optionnel)
            </label>
            <textarea
              rows={2}
              placeholder="Ex: Pièce d'origine disponible en stock, garantie 1 mois, test préalable gratuit."
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary text-slate-900 resize-none"
            />
          </div>

          <div className="pt-2 border-t border-slate-100 flex items-center justify-between">
            <span className="text-[11px] text-slate-400 flex items-center gap-1">
              <ShieldCheck className="w-3.5 h-3.5 text-brand-accent" />
              Devis sans commission cachée
            </span>

            <div className="flex items-center gap-2">
              <Button type="button" variant="outline" size="sm" onClick={onClose}>
                Annuler
              </Button>
              <Button type="submit" variant="accent" size="sm" isLoading={loading}>
                Envoyer le devis
              </Button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};
