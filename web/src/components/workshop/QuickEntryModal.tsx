"use client";

import React, { useState } from "react";
import { X, User, Phone, Smartphone, AlertCircle, Banknote, MessageSquare } from "lucide-react";
import { Button } from "../ui/Button";
import { workshopApi, QuickEntryPayload } from "@/lib/api/workshop";

interface QuickEntryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onEntryCreated: () => void;
}

export const QuickEntryModal: React.FC<QuickEntryModalProps> = ({
  isOpen,
  onClose,
  onEntryCreated,
}) => {
  const [clientName, setClientName] = useState("");
  const [clientPhone, setClientPhone] = useState("+223 ");
  const [deviceBrandModel, setDeviceBrandModel] = useState("");
  const [issueReported, setIssueReported] = useState("");
  const [estimatedPriceXof, setEstimatedPriceXof] = useState<number>(15000);
  const [notifyWhatsApp, setNotifyWhatsApp] = useState(true);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const entry = await workshopApi.createQuickEntry({
        clientName,
        clientPhone,
        deviceBrandModel,
        issueReported,
        estimatedPriceXof,
      });

      if (notifyWhatsApp) {
        let cleanPhone = clientPhone.replace(/[\s\-\+\(\)]/g, "");
        if (!cleanPhone.startsWith("223") && cleanPhone.length === 8) {
          cleanPhone = "223" + cleanPhone;
        }
        const text = encodeURIComponent(
          `Bonjour ${clientName}, votre appareil ${deviceBrandModel} a été réceptionné à notre atelier. Référence ticket : #${entry.id.slice(0, 8)}. Devis estimé : ${estimatedPriceXof.toLocaleString("fr-FR")} FCFA. Merci de votre confiance !`
        );
        window.open(`https://wa.me/${cleanPhone}?text=${text}`, "_blank");
      }

      onEntryCreated();
      onClose();
    } catch (err: any) {
      setError(err.message || "Erreur lors de l'enregistrement de l'entrée.");
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
              Prise en charge comptoir (Quick Entry)
            </h3>
            <p className="text-xs text-slate-500">
              Enregistrez un client physique en 30 secondes
            </p>
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
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                Nom du Client
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <User className="w-3.5 h-3.5" />
                </div>
                <input
                  type="text"
                  required
                  placeholder="Ex: Fatoumata Coulibaly"
                  value={clientName}
                  onChange={(e) => setClientName(e.target.value)}
                  className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                Téléphone WhatsApp
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <Phone className="w-3.5 h-3.5 text-emerald-600" />
                </div>
                <input
                  type="tel"
                  required
                  placeholder="+223 70 00 00 00"
                  value={clientPhone}
                  onChange={(e) => setClientPhone(e.target.value)}
                  className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
                />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
              Marque & Modèle de l'appareil
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                <Smartphone className="w-3.5 h-3.5" />
              </div>
              <input
                type="text"
                required
                placeholder="Ex: Samsung A14 / Dell Latitude 5490 / Camon 20"
                value={deviceBrandModel}
                onChange={(e) => setDeviceBrandModel(e.target.value)}
                className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
              Panne constatée au comptoir
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 pt-2.5 pointer-events-none text-slate-400">
                <AlertCircle className="w-3.5 h-3.5" />
              </div>
              <textarea
                required
                rows={2}
                placeholder="Ex: Écran fissuré, ne charge pas, problème de circuit de charge."
                value={issueReported}
                onChange={(e) => setIssueReported(e.target.value)}
                className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary resize-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
              Devis estimé au dépôt (FCFA)
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                <Banknote className="w-3.5 h-3.5 text-emerald-600" />
              </div>
              <input
                type="number"
                min="0"
                step="500"
                required
                value={estimatedPriceXof}
                onChange={(e) => setEstimatedPriceXof(parseInt(e.target.value) || 0)}
                className="w-full pl-9 pr-14 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
              />
              <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-xs font-bold text-slate-400">
                FCFA
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2 pt-1">
            <input
              type="checkbox"
              id="notify-wa"
              checked={notifyWhatsApp}
              onChange={(e) => setNotifyWhatsApp(e.target.checked)}
              className="w-4 h-4 text-emerald-600 rounded focus:ring-emerald-500"
            />
            <label htmlFor="notify-wa" className="text-xs text-slate-700 flex items-center gap-1.5 cursor-pointer font-medium">
              <MessageSquare className="w-3.5 h-3.5 text-emerald-600" />
              Envoyer immédiatement le ticket de dépôt sur WhatsApp
            </label>
          </div>

          <div className="pt-3 border-t border-slate-100 flex items-center justify-end gap-2.5">
            <Button type="button" variant="outline" size="sm" onClick={onClose}>
              Annuler
            </Button>
            <Button type="submit" variant="accent" size="sm" isLoading={loading}>
              Enregistrer l'appareil
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
