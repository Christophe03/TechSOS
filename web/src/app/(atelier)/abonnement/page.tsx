"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { workshopApi } from "@/lib/api/workshop";
import { SubscriptionStatus } from "@/lib/types";
import { WorkshopNav } from "@/components/workshop/WorkshopNav";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import {
  CreditCard,
  Check,
  ShieldCheck,
  Phone,
  Sparkles,
  CheckCircle2,
  AlertCircle,
  Loader2,
} from "lucide-react";

export default function WorkshopAbonnementPage() {
  const router = useRouter();
  const { user, isLoading: authLoading } = useAuth();

  const [subStatus, setSubStatus] = useState<SubscriptionStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [paymentMethod, setPaymentMethod] = useState<"ORANGE_MONEY" | "MOOV_MONEY">(
    "ORANGE_MONEY"
  );
  const [phoneNumber, setPhoneNumber] = useState("+223 70 00 00 02");
  const [submitting, setSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadStatus = async () => {
    try {
      const data = await workshopApi.getSubscriptionStatus();
      setSubStatus(data);
    } catch (e) {
      console.error("Subscription status load error", e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/connexion");
      return;
    }
    if (user) {
      loadStatus();
    }
  }, [user, authLoading, router]);

  const handleSubscribe = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccessMessage(null);
    setSubmitting(true);

    try {
      await workshopApi.subscribe(paymentMethod, phoneNumber);
      setSuccessMessage("Abonnement activé avec succès ! Votre atelier bénéficie du statut Pro.");
      loadStatus();
    } catch (err: any) {
      setError(err.message || "Erreur lors du traitement du paiement.");
    } finally {
      setSubmitting(false);
    }
  };

  if (authLoading || loading) {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center space-y-4">
        <Loader2 className="w-8 h-8 animate-spin text-brand-primary" />
        <p className="text-sm font-semibold text-slate-500">Chargement de votre abonnement...</p>
      </div>
    );
  }

  return (
    <div className="py-10 px-4 sm:px-6 lg:px-8 max-w-5xl mx-auto space-y-8">
      <div>
        <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
          Abonnement Atelier Pro
        </h1>
        <p className="text-sm text-slate-500 mt-1">
          Débloquez l'accès complet au réseau TechSOS et captez les pannes de votre secteur
        </p>
      </div>

      <WorkshopNav />

      {successMessage && (
        <div className="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm rounded-xl flex items-center gap-3">
          <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
          <div className="font-semibold">{successMessage}</div>
        </div>
      )}

      {error && (
        <div className="p-4 bg-rose-50 border border-rose-200 text-rose-800 text-sm rounded-xl flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
          <div>{error}</div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Plan Presentation Card */}
        <div className="lg:col-span-7">
          <Card className="p-7 border-slate-200 space-y-6">
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-brand-accent">
                  Formule Professionnelle
                </span>
                <h2 className="text-2xl font-black text-slate-900 mt-1">
                  Atelier Partenaire Certifié
                </h2>
              </div>
              <div className="text-right">
                <span className="text-3xl font-black text-brand-primary">
                  5 000
                </span>
                <span className="text-xs text-slate-500 block font-bold">
                  FCFA / mois
                </span>
              </div>
            </div>

            <p className="text-sm text-slate-600 leading-relaxed">
              Un investissement rentable dès la première réparation traitée dans votre commune à Bamako.
            </p>

            <ul className="space-y-3.5 text-sm text-slate-700">
              <li className="flex items-start gap-3">
                <Check className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
                <span>
                  <strong>Accès illimité au fil des pannes :</strong> Soumettez vos devis en temps réel aux clients de votre commune.
                </span>
              </li>
              <li className="flex items-start gap-3">
                <Check className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
                <span>
                  <strong>Badge "Atelier Vérifié" :</strong> Augmentez votre taux de conversion et la confiance des usagers.
                </span>
              </li>
              <li className="flex items-start gap-3">
                <Check className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
                <span>
                  <strong>Journal de comptoir illimité :</strong> Suivi des dépôts physiques et relances automatiques WhatsApp.
                </span>
              </li>
              <li className="flex items-start gap-3">
                <Check className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
                <span>
                  <strong>Sans engagement :</strong> Renouvellement mensuel par Mobile Money selon votre activité.
                </span>
              </li>
            </ul>

            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 text-xs text-slate-500 flex items-center gap-2">
              <ShieldCheck className="w-4 h-4 text-brand-accent shrink-0" />
              <span>
                Statut actuel de votre compte :{" "}
                <strong className={subStatus?.isActive ? "text-emerald-700 font-bold" : "text-amber-700 font-bold"}>
                  {subStatus?.isActive ? "Actif (Pro Certifié)" : "Inactif"}
                </strong>
              </span>
            </div>
          </Card>
        </div>

        {/* Mobile Money Payment Simulator */}
        <div className="lg:col-span-5">
          <Card className="p-7 shadow-hover border-slate-200 space-y-6">
            <div>
              <h3 className="text-lg font-bold text-slate-900">
                Paiement Mobile Money
              </h3>
              <p className="text-xs text-slate-500 mt-1">
                Réglez en 1 minute via Orange Money ou Moov Money Mali
              </p>
            </div>

            <form onSubmit={handleSubscribe} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
                  Opérateur Mobile Money
                </label>
                <div className="grid grid-cols-2 gap-2.5">
                  <button
                    type="button"
                    onClick={() => setPaymentMethod("ORANGE_MONEY")}
                    className={`p-3 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 transition-all ${
                      paymentMethod === "ORANGE_MONEY"
                        ? "border-orange-500 bg-orange-50 text-orange-950 ring-2 ring-orange-500/20"
                        : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    <span className="w-2.5 h-2.5 rounded-full bg-orange-500" />
                    <span>Orange Money</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setPaymentMethod("MOOV_MONEY")}
                    className={`p-3 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 transition-all ${
                      paymentMethod === "MOOV_MONEY"
                        ? "border-blue-500 bg-blue-50 text-blue-950 ring-2 ring-blue-500/20"
                        : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    <span className="w-2.5 h-2.5 rounded-full bg-blue-500" />
                    <span>Moov Money</span>
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                  Numéro de débit
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                    <Phone className="w-4 h-4 text-emerald-600" />
                  </div>
                  <input
                    type="tel"
                    required
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-semibold text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
                  />
                </div>
              </div>

              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 space-y-1.5 text-xs text-slate-600">
                <div className="flex justify-between font-bold text-slate-900">
                  <span>Montant total :</span>
                  <span>5 000 FCFA</span>
                </div>
                <div className="text-[11px] text-slate-500">
                  Valable 30 jours à compter de la confirmation
                </div>
              </div>

              <Button
                type="submit"
                variant="accent"
                className="w-full"
                isLoading={submitting}
                leftIcon={<CreditCard className="w-4 h-4" />}
              >
                Activer mon abonnement Pro
              </Button>
            </form>
          </Card>
        </div>
      </div>
    </div>
  );
}
