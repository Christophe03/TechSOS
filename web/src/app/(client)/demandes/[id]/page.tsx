"use client";

import React, { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { repairsApi } from "@/lib/api/repairs";
import { Repair, Offer } from "@/lib/types";
import { Card } from "@/components/ui/Card";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { ReviewModal } from "@/components/client/ReviewModal";
import {
  ArrowLeft,
  MapPin,
  Clock,
  Volume2,
  Image as ImageIcon,
  CheckCircle2,
  Wrench,
  Star,
  Check,
  Phone,
  MessageSquare,
  ShieldCheck,
  AlertCircle,
  Loader2,
  ArrowUpDown,
  Zap,
} from "lucide-react";

export default function DemandeDetailPage() {
  const params = useParams();
  const router = useRouter();
  const repairId = params?.id as string;

  const [repair, setRepair] = useState<Repair | null>(null);
  const [loading, setLoading] = useState(true);
  const [acceptingOfferId, setAcceptingOfferId] = useState<string | null>(null);
  const [reviewModalOpen, setReviewModalOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sortCriteria, setSortCriteria] = useState<"cheapest" | "fastest" | "best_rated">("cheapest");

  const fetchRepair = () => {
    if (!repairId) return;
    setLoading(true);
    repairsApi
      .getRepairById(repairId)
      .then((data) => setRepair(data))
      .catch((err) => setError(err.message || "Erreur de chargement."))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchRepair();
  }, [repairId]);

  const handleAcceptOffer = async (offerId: string) => {
    if (!confirm("Voulez-vous accepter cette offre et confier votre appareil à cet atelier ?")) {
      return;
    }
    setAcceptingOfferId(offerId);
    try {
      await repairsApi.acceptOffer(offerId);
      fetchRepair();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'acceptation de l'offre.");
    } finally {
      setAcceptingOfferId(null);
    }
  };

  if (loading) {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center space-y-4">
        <Loader2 className="w-8 h-8 animate-spin text-brand-primary" />
        <p className="text-sm font-semibold text-slate-500">Chargement du détail de la panne...</p>
      </div>
    );
  }

  if (error || !repair) {
    return (
      <div className="py-12 max-w-xl mx-auto px-4 text-center space-y-4">
        <div className="text-rose-600 font-bold text-lg">Demande introuvable</div>
        <p className="text-sm text-slate-500">{error || "La demande n'existe pas ou a été supprimée."}</p>
        <Link href="/mes-demandes">
          <Button variant="outline" size="sm" leftIcon={<ArrowLeft className="w-4 h-4" />}>
            Retour à mes demandes
          </Button>
        </Link>
      </div>
    );
  }

  const offers = repair.offers || [];
  const selectedOffer = offers.find((o) => o.id === repair.selectedOfferId);

  return (
    <div className="py-10 px-4 sm:px-6 lg:px-8 max-w-5xl mx-auto space-y-8">
      {/* Top back button & header */}
      <div className="space-y-4">
        <Link
          href="/mes-demandes"
          className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-500 hover:text-brand-primary transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Retour à la liste de mes demandes</span>
        </Link>

        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
                {repair.equipmentTitle}
              </h1>
              <Badge variant={repair.status === "COMPLETED" ? "completed" : repair.status === "IN_PROGRESS" ? "in_progress" : "pending"}>
                {repair.status === "COMPLETED"
                  ? "Terminée"
                  : repair.status === "IN_PROGRESS"
                  ? "Prise en charge"
                  : "En attente"}
              </Badge>
            </div>
            <div className="flex flex-wrap items-center gap-4 text-xs text-slate-400 mt-2">
              <span className="flex items-center gap-1">
                <MapPin className="w-3.5 h-3.5 text-brand-accent" />
                <span>{repair.district}</span>
              </span>
              <span className="flex items-center gap-1">
                <Clock className="w-3.5 h-3.5" />
                <span>
                  Publiée le {new Date(repair.createdAt).toLocaleDateString("fr-FR", {
                    day: "numeric",
                    month: "long",
                    year: "numeric",
                  })}
                </span>
              </span>
            </div>
          </div>

          {repair.status === "COMPLETED" && (
            <Button
              variant="accent"
              size="sm"
              leftIcon={<Star className="w-4 h-4 fill-white" />}
              onClick={() => setReviewModalOpen(true)}
            >
              Évaluer la Réparation
            </Button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Column: Breakdown Info */}
        <div className="lg:col-span-1 space-y-6">
          <Card className="space-y-4 p-5">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500">
              Détails signalés
            </h3>

            <div className="space-y-1">
              <div className="text-xs text-slate-400 font-semibold">Problème décrit :</div>
              <p className="text-sm text-slate-800 bg-slate-50 p-3 rounded-xl border border-slate-200/80 leading-relaxed">
                {repair.issueDescription}
              </p>
            </div>

            {/* Voice Audio player if present */}
            {repair.audioVoiceUrl && (
              <div className="space-y-2 pt-2 border-t border-slate-100">
                <div className="flex items-center gap-2 text-xs font-bold text-brand-primary">
                  <Volume2 className="w-4 h-4 text-brand-accent" />
                  <span>Note vocale enregistrée</span>
                </div>
                <audio
                  controls
                  src={repairsApi.getMediaUrl(repair.audioVoiceUrl)}
                  className="w-full h-10 rounded-lg"
                />
              </div>
            )}

            {/* Photos if present */}
            {repair.photosUrls && (
              <div className="space-y-2 pt-2 border-t border-slate-100">
                <div className="flex items-center gap-2 text-xs font-bold text-slate-700">
                  <ImageIcon className="w-4 h-4 text-slate-500" />
                  <span>Photos jointes</span>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  {repair.photosUrls.split(",").map((p, idx) => (
                    <a
                      key={idx}
                      href={repairsApi.getMediaUrl(p)}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="block rounded-lg overflow-hidden border border-slate-200 hover:opacity-90"
                    >
                      <img
                        src={repairsApi.getMediaUrl(p)}
                        alt={`Photo ${idx + 1}`}
                        className="w-full h-24 object-cover"
                      />
                    </a>
                  ))}
                </div>
              </div>
            )}
          </Card>
        </div>

        {/* Right Column: Offers Comparator & Status Tracking */}
        <div className="lg:col-span-2 space-y-6">
          {repair.status === "PENDING" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-bold text-slate-900">
                  Offres et Devis Reçus ({offers.length})
                </h2>
                <span className="text-xs text-slate-500">
                  {offers.length > 0 ? "Comparez et validez en 1 clic" : "En attente de devis..."}
                </span>
              </div>

              {offers.length === 0 ? (
                <Card className="text-center py-12 px-4 space-y-3">
                  <div className="w-12 h-12 rounded-full bg-orange-50 text-brand-accent mx-auto flex items-center justify-center">
                    <Clock className="w-6 h-6 animate-spin" />
                  </div>
                  <h3 className="text-base font-bold text-slate-800">
                    Votre annonce est visible par les réparateurs de Bamako
                  </h3>
                  <p className="text-xs text-slate-500 max-w-sm mx-auto">
                    Les techniciens de votre quartier analysent votre panne. Vous recevrez une notification dès qu'une proposition de prix sera émise.
                  </p>
                </Card>
              ) : (
                <div className="space-y-4">
                  {/* Sorting filters */}
                  <div className="flex items-center gap-1.5 p-1 bg-slate-100 rounded-xl text-xs font-bold w-fit">
                    <button
                      onClick={() => setSortCriteria("cheapest")}
                      className={`px-3 py-1.5 rounded-lg transition-all ${
                        sortCriteria === "cheapest"
                          ? "bg-white text-emerald-700 shadow-sm"
                          : "text-slate-600 hover:text-slate-900"
                      }`}
                    >
                      💰 Le moins cher
                    </button>
                    <button
                      onClick={() => setSortCriteria("fastest")}
                      className={`px-3 py-1.5 rounded-lg transition-all ${
                        sortCriteria === "fastest"
                          ? "bg-white text-brand-primary shadow-sm"
                          : "text-slate-600 hover:text-slate-900"
                      }`}
                    >
                      ⚡ Le plus rapide
                    </button>
                    <button
                      onClick={() => setSortCriteria("best_rated")}
                      className={`px-3 py-1.5 rounded-lg transition-all ${
                        sortCriteria === "best_rated"
                          ? "bg-white text-amber-700 shadow-sm"
                          : "text-slate-600 hover:text-slate-900"
                      }`}
                    >
                      ⭐ Mieux noté
                    </button>
                  </div>

                  {offers
                    .slice()
                    .sort((a, b) => {
                      if (sortCriteria === "cheapest") return a.priceXof - b.priceXof;
                      if (sortCriteria === "best_rated") {
                        const rA = a.provider?.ratingAvg || 5.0;
                        const rB = b.provider?.ratingAvg || 5.0;
                        return rB - rA;
                      }
                      return 0;
                    })
                    .map((offer) => {
                    const provider = offer.provider;
                    return (
                      <Card
                        key={offer.id}
                        hover
                        className="p-5 border-slate-200 hover:border-brand-primary/40 space-y-4"
                      >
                        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                          <div className="space-y-1">
                            <div className="flex items-center gap-2">
                              <span className="text-base font-bold text-slate-900">
                                {provider?.workshopName || provider?.fullName || "Atelier Partenaire"}
                              </span>
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-amber-50 text-amber-800 text-[11px] font-bold border border-amber-200">
                                <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                                <span>{(provider?.ratingAvg || 5.0).toFixed(1)}</span>
                                <span className="text-slate-400">({provider?.reviewCount || 1})</span>
                              </span>
                            </div>

                            <p className="text-xs text-slate-500">
                              Spécialités : {provider?.specialties || "Électronique générale"}
                            </p>

                            {offer.comment && (
                              <p className="text-xs text-slate-700 bg-slate-50 p-2.5 rounded-lg border border-slate-100 mt-2">
                                💬 "{offer.comment}"
                              </p>
                            )}
                          </div>

                          <div className="text-left sm:text-right shrink-0 space-y-1 sm:space-y-2">
                            <div>
                              <span className="text-xs text-slate-400 block uppercase font-bold tracking-wider">
                                Tarif proposé
                              </span>
                              <span className="text-xl font-extrabold text-emerald-700">
                                {offer.priceXof.toLocaleString("fr-FR")} FCFA
                              </span>
                            </div>
                            <div className="text-xs font-semibold text-slate-500">
                              Délai : {offer.estimatedDuration}
                            </div>
                          </div>
                        </div>

                        <div className="pt-3 border-t border-slate-100 flex items-center justify-between">
                          <span className="text-xs text-slate-400 flex items-center gap-1">
                            <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                            Garantie atelier 15 jours incluse
                          </span>

                          <Button
                            variant="accent"
                            size="sm"
                            isLoading={acceptingOfferId === offer.id}
                            onClick={() => handleAcceptOffer(offer.id)}
                            leftIcon={<Check className="w-4 h-4" />}
                          >
                            Accepter cette offre
                          </Button>
                        </div>
                      </Card>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {/* If In Progress or Completed: Show Accepted Partner Card */}
          {repair.status !== "PENDING" && selectedOffer && (
            <Card className="p-6 bg-emerald-50/50 border-emerald-200 space-y-5">
              <div className="flex items-center gap-2 text-emerald-800 font-bold text-sm">
                <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                <span>Offre acceptée · Réparateur en charge</span>
              </div>

              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 bg-white rounded-xl border border-emerald-200/80 shadow-sm">
                <div>
                  <h4 className="text-base font-extrabold text-slate-900">
                    {selectedOffer.provider?.workshopName || selectedOffer.provider?.fullName}
                  </h4>
                  <div className="text-xs text-slate-500 mt-0.5">
                    Téléphone : <strong className="text-slate-800">{selectedOffer.provider?.phone}</strong>
                  </div>
                </div>

                <div className="text-right">
                  <div className="text-lg font-black text-emerald-700">
                    {selectedOffer.priceXof.toLocaleString("fr-FR")} FCFA
                  </div>
                  <div className="text-xs font-medium text-slate-500">
                    Délai convenu : {selectedOffer.estimatedDuration}
                  </div>
                </div>
              </div>

              {/* Action buttons to call or WhatsApp workshop */}
              {selectedOffer.provider?.phone && (
                <div className="grid grid-cols-2 gap-3 pt-1">
                  <a
                    href={`https://wa.me/${selectedOffer.provider.phone.replace(/[\s\-\+\(\)]/g, "")}?text=${encodeURIComponent(
                      `Bonjour ${selectedOffer.provider.workshopName || ""}, je vous contacte concernant la réparation de mon appareil (${repair.equipmentTitle}) sur TechSOS.`
                    )}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="py-2.5 px-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-sm transition-colors"
                  >
                    <MessageSquare className="w-4 h-4" />
                    <span>WhatsApp Atelier</span>
                  </a>

                  <a
                    href={`tel:${selectedOffer.provider.phone}`}
                    className="py-2.5 px-3 rounded-xl bg-brand-primary hover:bg-brand-primary-dark text-white text-xs font-bold flex items-center justify-center gap-2 shadow-sm transition-colors"
                  >
                    <Phone className="w-4 h-4" />
                    <span>Appeler Direct</span>
                  </a>
                </div>
              )}

              <div className="text-xs text-slate-600 bg-white/70 p-3 rounded-lg border border-emerald-100">
                💡 Vous pouvez contacter le technicien directement par appel ou WhatsApp. Une fois l'appareil testé et récupéré, le statut passera à "Terminée".
              </div>
            </Card>
          )}
        </div>
      </div>

      {/* Review Modal */}
      {selectedOffer?.provider && (
        <ReviewModal
          isOpen={reviewModalOpen}
          repairId={repair.id}
          providerName={selectedOffer.provider.workshopName || selectedOffer.provider.fullName}
          onClose={() => setReviewModalOpen(false)}
          onReviewSubmitted={() => fetchRepair()}
        />
      )}
    </div>
  );
}
