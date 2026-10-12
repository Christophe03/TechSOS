"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { workshopApi } from "@/lib/api/workshop";
import { WorkshopEntry, Repair, SubscriptionStatus } from "@/lib/types";
import { WorkshopNav } from "@/components/workshop/WorkshopNav";
import { QuickEntryModal } from "@/components/workshop/QuickEntryModal";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import {
  Wrench,
  Radio,
  BookOpen,
  Plus,
  Star,
  Banknote,
  TrendingUp,
  MapPin,
  Clock,
  ArrowRight,
  ShieldCheck,
  Loader2,
} from "lucide-react";

export default function WorkshopDashboardPage() {
  const router = useRouter();
  const { user, isLoading: authLoading } = useAuth();

  const [feed, setFeed] = useState<Repair[]>([]);
  const [entries, setEntries] = useState<WorkshopEntry[]>([]);
  const [subStatus, setSubStatus] = useState<SubscriptionStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [quickEntryOpen, setQuickEntryOpen] = useState(false);

  const loadData = async () => {
    try {
      const [feedData, journalData, subData] = await Promise.all([
        workshopApi.getFeed().catch(() => []),
        workshopApi.getJournalEntries().catch(() => []),
        workshopApi.getSubscriptionStatus().catch(() => null),
      ]);
      setFeed(feedData);
      setEntries(journalData);
      setSubStatus(subData);
    } catch (e) {
      console.error("Dashboard data load error", e);
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
      loadData();
    }
  }, [user, authLoading, router]);

  if (authLoading || loading) {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center space-y-4">
        <Loader2 className="w-8 h-8 animate-spin text-brand-primary" />
        <p className="text-sm font-semibold text-slate-500">
          Chargement de votre atelier...
        </p>
      </div>
    );
  }

  const activeEntries = entries.filter((e) => e.status !== "LIVRE");
  const estimatedRevenue = entries.reduce((acc, curr) => acc + curr.estimatedPriceXof, 0);

  return (
    <div className="py-10 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-8">
      {/* Header with workshop name and Pro Badge */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              {user?.workshopName || user?.fullName || "Mon Atelier"}
            </h1>
            <span className="px-3 py-1 rounded-full text-xs font-bold bg-orange-100 text-brand-accent border border-orange-200">
              {subStatus?.isActive ? "Atelier Pro Certifié" : "Abonnement Standard"}
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Gérez votre comptoir physique et captez les urgences publiées dans le district de Bamako
          </p>
        </div>

        <Button
          variant="accent"
          leftIcon={<Plus className="w-4 h-4" />}
          onClick={() => setQuickEntryOpen(true)}
        >
          Nouvelle Entrée Comptoir (Quick Entry)
        </Button>
      </div>

      <WorkshopNav />

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <Card className="p-5 flex items-center justify-between border-slate-200">
          <div>
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block">
              En cours d'atelier
            </span>
            <span className="text-2xl font-black text-slate-900 mt-1 block">
              {activeEntries.length} appareil{activeEntries.length > 1 ? "s" : ""}
            </span>
            <span className="text-[11px] text-slate-500">Sur les bancs de test</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-blue-50 text-brand-primary flex items-center justify-center">
            <Wrench className="w-6 h-6" />
          </div>
        </Card>

        <Card className="p-5 flex items-center justify-between border-slate-200">
          <div>
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block">
              Urgences disponibles
            </span>
            <span className="text-2xl font-black text-brand-accent mt-1 block">
              {feed.length} panne{feed.length > 1 ? "s" : ""}
            </span>
            <span className="text-[11px] text-slate-500">À Bamako maintenant</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-orange-50 text-brand-accent flex items-center justify-center">
            <Radio className="w-6 h-6 animate-pulse" />
          </div>
        </Card>

        <Card className="p-5 flex items-center justify-between border-slate-200">
          <div>
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block">
              Volume atelier
            </span>
            <span className="text-2xl font-black text-emerald-700 mt-1 block">
              {estimatedRevenue.toLocaleString("fr-FR")} FCFA
            </span>
            <span className="text-[11px] text-slate-500">Total journal</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
            <Banknote className="w-6 h-6" />
          </div>
        </Card>

        <Card className="p-5 flex items-center justify-between border-slate-200">
          <div>
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block">
              Réputation Atelier
            </span>
            <div className="flex items-center gap-1.5 mt-1">
              <span className="text-2xl font-black text-slate-900">
                {(user?.ratingAvg || 5.0).toFixed(1)}
              </span>
              <Star className="w-5 h-5 fill-amber-400 text-amber-400" />
            </div>
            <span className="text-[11px] text-slate-500">
              {user?.reviewCount || 1} avis vérifié{user?.reviewCount && user.reviewCount > 1 ? "s" : ""}
            </span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
            <ShieldCheck className="w-6 h-6" />
          </div>
        </Card>
      </div>

      {/* Main Grid: Feed Urgent vs Recent Workshop Entries */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Urgent Breakdowns in Bamako */}
        <Card className="p-6 space-y-5">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <Radio className="w-5 h-5 text-brand-accent" />
              <h3 className="text-base font-bold text-slate-900">
                Dernières urgences publiées (Bamako)
              </h3>
            </div>
            <Link
              href="/atelier/fil-urgences"
              className="text-xs font-bold text-brand-accent hover:underline flex items-center gap-1"
            >
              <span>Voir tout</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          {feed.length === 0 ? (
            <div className="text-center py-10 text-slate-400 text-xs">
              Aucune panne non traitée dans votre zone actuellement.
            </div>
          ) : (
            <div className="space-y-3">
              {feed.slice(0, 4).map((repair) => (
                <div
                  key={repair.id}
                  className="p-3.5 rounded-xl bg-slate-50 hover:bg-slate-100/80 border border-slate-200 transition-colors flex items-center justify-between gap-3"
                >
                  <div className="space-y-1">
                    <div className="font-bold text-xs sm:text-sm text-slate-900">
                      {repair.equipmentTitle}
                    </div>
                    <div className="flex items-center gap-2 text-xs text-slate-500">
                      <span className="flex items-center gap-1">
                        <MapPin className="w-3 h-3 text-brand-accent" />
                        <span>{repair.district}</span>
                      </span>
                      <span>·</span>
                      <span className="line-clamp-1 max-w-[200px]">
                        {repair.issueDescription}
                      </span>
                    </div>
                  </div>

                  <Link href="/atelier/fil-urgences">
                    <Button variant="outline" size="sm">
                      Proposer devis
                    </Button>
                  </Link>
                </div>
              ))}
            </div>
          )}
        </Card>

        {/* Counter journal recent items */}
        <Card className="p-6 space-y-5">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <BookOpen className="w-5 h-5 text-brand-primary" />
              <h3 className="text-base font-bold text-slate-900">
                Journal de comptoir récent
              </h3>
            </div>
            <Link
              href="/atelier/journal"
              className="text-xs font-bold text-brand-primary hover:underline flex items-center gap-1"
            >
              <span>Ouvrir journal</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          {entries.length === 0 ? (
            <div className="text-center py-10 space-y-3">
              <p className="text-slate-400 text-xs">
                Votre journal est vide pour le moment.
              </p>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setQuickEntryOpen(true)}
              >
                Ajouter un premier client
              </Button>
            </div>
          ) : (
            <div className="space-y-3">
              {entries.slice(0, 4).map((entry) => (
                <div
                  key={entry.id}
                  className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between gap-3"
                >
                  <div className="space-y-1">
                    <div className="font-bold text-xs sm:text-sm text-slate-900">
                      {entry.deviceBrandModel} · {entry.clientName}
                    </div>
                    <div className="text-xs text-slate-500">
                      Devis : <strong className="text-emerald-700">{entry.estimatedPriceXof.toLocaleString("fr-FR")} FCFA</strong>
                    </div>
                  </div>

                  <Badge variant={entry.status === "PRET_RECUPERATION" ? "completed" : entry.status === "EN_REPARATION" ? "in_progress" : "pending"}>
                    {entry.status}
                  </Badge>
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>

      {/* Quick Entry Modal */}
      <QuickEntryModal
        isOpen={quickEntryOpen}
        onClose={() => setQuickEntryOpen(false)}
        onEntryCreated={() => loadData()}
      />
    </div>
  );
}
