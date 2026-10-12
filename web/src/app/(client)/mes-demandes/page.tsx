"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { repairsApi } from "@/lib/api/repairs";
import { Repair, RepairStatus } from "@/lib/types";
import { Card } from "@/components/ui/Card";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import {
  AlertCircle,
  Plus,
  Clock,
  MapPin,
  ChevronRight,
  Volume2,
  FileText,
  Loader2,
} from "lucide-react";

export default function MesDemandesPage() {
  const router = useRouter();
  const { user, isLoading: authLoading } = useAuth();

  const [repairs, setRepairs] = useState<Repair[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<"ALL" | RepairStatus>("ALL");

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/connexion");
      return;
    }

    if (user) {
      repairsApi
        .getMyRepairs()
        .then((data) => setRepairs(data))
        .catch((err) => console.error("Error loading repairs", err))
        .finally(() => setLoading(false));
    }
  }, [user, authLoading, router]);

  const getStatusBadge = (status: RepairStatus, offersCount: number = 0) => {
    switch (status) {
      case "PENDING":
        if (offersCount > 0) {
          return <Badge variant="offers">{offersCount} Devis Reçu{offersCount > 1 ? "s" : ""}</Badge>;
        }
        return <Badge variant="pending">En attente de devis</Badge>;
      case "OFFERS_RECEIVED":
        return <Badge variant="offers">{offersCount} Devis Reçu{offersCount > 1 ? "s" : ""}</Badge>;
      case "IN_PROGRESS":
        return <Badge variant="in_progress">Prise en charge atelier</Badge>;
      case "COMPLETED":
        return <Badge variant="completed">Réparation terminée</Badge>;
      case "CANCELLED":
        return <Badge variant="cancelled">Annulée</Badge>;
      default:
        return <Badge variant="neutral">{status}</Badge>;
    }
  };

  const filteredRepairs = repairs.filter((r) => {
    if (filter === "ALL") return true;
    return r.status === filter;
  });

  if (authLoading || loading) {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center space-y-4">
        <Loader2 className="w-8 h-8 animate-spin text-brand-primary" />
        <p className="text-sm font-semibold text-slate-500">
          Chargement de vos demandes de réparation...
        </p>
      </div>
    );
  }

  return (
    <div className="py-10 px-4 sm:px-6 lg:px-8 max-w-5xl mx-auto space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            Mes Demandes de Dépannage
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Suivez l'avancement de vos pannes et comparez les devis des techniciens
          </p>
        </div>

        <Link href="/sos-panne">
          <Button variant="accent" leftIcon={<Plus className="w-4 h-4" />}>
            Nouveau SOS Panne
          </Button>
        </Link>
      </div>

      {/* Filter Tabs */}
      <div className="flex flex-wrap gap-2 border-b border-slate-200 pb-3">
        <button
          onClick={() => setFilter("ALL")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors ${
            filter === "ALL"
              ? "bg-brand-primary text-white"
              : "text-slate-600 hover:bg-slate-100"
          }`}
        >
          Toutes ({repairs.length})
        </button>
        <button
          onClick={() => setFilter("PENDING")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors ${
            filter === "PENDING"
              ? "bg-brand-primary text-white"
              : "text-slate-600 hover:bg-slate-100"
          }`}
        >
          En attente
        </button>
        <button
          onClick={() => setFilter("IN_PROGRESS")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors ${
            filter === "IN_PROGRESS"
              ? "bg-brand-primary text-white"
              : "text-slate-600 hover:bg-slate-100"
          }`}
        >
          En cours d'atelier
        </button>
        <button
          onClick={() => setFilter("COMPLETED")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors ${
            filter === "COMPLETED"
              ? "bg-brand-primary text-white"
              : "text-slate-600 hover:bg-slate-100"
          }`}
        >
          Terminées
        </button>
      </div>

      {/* Repairs List */}
      {filteredRepairs.length === 0 ? (
        <Card className="text-center py-16 px-4 space-y-4">
          <div className="w-16 h-16 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center">
            <AlertCircle className="w-8 h-8" />
          </div>
          <div className="space-y-1">
            <h3 className="text-lg font-bold text-slate-800">
              Aucune demande trouvée
            </h3>
            <p className="text-sm text-slate-500 max-w-md mx-auto">
              Vous n'avez pas de demande de réparation correspondant à ce filtre. Vous pouvez publier un SOS à tout moment.
            </p>
          </div>
          <Link href="/sos-panne">
            <Button variant="accent" size="sm">
              Déclarer une panne maintenant
            </Button>
          </Link>
        </Card>
      ) : (
        <div className="space-y-4">
          {filteredRepairs.map((repair) => {
            const offersCount = repair.offers?.length || 0;
            return (
              <Link
                key={repair.id}
                href={`/demandes/${repair.id}`}
                className="block group"
              >
                <Card hover className="p-5 sm:p-6 transition-all">
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div className="space-y-2">
                      <div className="flex flex-wrap items-center gap-2.5">
                        <span className="text-base font-extrabold text-slate-900 group-hover:text-brand-accent transition-colors">
                          {repair.equipmentTitle}
                        </span>
                        {getStatusBadge(repair.status, offersCount)}
                      </div>

                      <p className="text-xs sm:text-sm text-slate-600 line-clamp-2">
                        {repair.issueDescription}
                      </p>

                      <div className="flex flex-wrap items-center gap-4 text-xs text-slate-400 pt-1">
                        <span className="flex items-center gap-1">
                          <MapPin className="w-3.5 h-3.5 text-brand-accent" />
                          <span>{repair.district}</span>
                        </span>
                        <span className="flex items-center gap-1">
                          <Clock className="w-3.5 h-3.5" />
                          <span>
                            {new Date(repair.createdAt).toLocaleDateString("fr-FR", {
                              day: "numeric",
                              month: "short",
                              hour: "2-digit",
                              minute: "2-digit",
                            })}
                          </span>
                        </span>
                        {repair.audioVoiceUrl && (
                          <span className="flex items-center gap-1 text-emerald-600 font-medium">
                            <Volume2 className="w-3.5 h-3.5" />
                            <span>Note vocale</span>
                          </span>
                        )}
                      </div>
                    </div>

                    <div className="flex items-center justify-between sm:justify-end gap-3 shrink-0 pt-3 sm:pt-0 border-t sm:border-t-0 border-slate-100">
                      {offersCount > 0 && repair.status === "PENDING" ? (
                        <div className="text-right">
                          <span className="text-xs font-bold text-emerald-700 block">
                            {offersCount} offre{offersCount > 1 ? "s" : ""} disponible{offersCount > 1 ? "s" : ""}
                          </span>
                          <span className="text-[11px] text-slate-400">À comparer</span>
                        </div>
                      ) : null}
                      <div className="w-8 h-8 rounded-full bg-slate-50 group-hover:bg-brand-primary group-hover:text-white text-slate-400 flex items-center justify-center transition-colors">
                        <ChevronRight className="w-4 h-4" />
                      </div>
                    </div>
                  </div>
                </Card>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
