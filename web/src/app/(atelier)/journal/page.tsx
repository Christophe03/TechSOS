"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { workshopApi } from "@/lib/api/workshop";
import { WorkshopEntry, WorkshopStatus } from "@/lib/types";
import { WorkshopNav } from "@/components/workshop/WorkshopNav";
import { QuickEntryModal } from "@/components/workshop/QuickEntryModal";
import { WhatsAppNotificationButton } from "@/components/workshop/WhatsAppNotificationButton";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import {
  BookOpen,
  Plus,
  Search,
  Filter,
  CheckCircle,
  Clock,
  User,
  Phone,
  Smartphone,
  Loader2,
  Download,
  Banknote,
  Calendar,
} from "lucide-react";

export default function WorkshopJournalPage() {
  const router = useRouter();
  const { user, isLoading: authLoading } = useAuth();

  const [entries, setEntries] = useState<WorkshopEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("ALL");
  const [quickEntryOpen, setQuickEntryOpen] = useState(false);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const loadJournal = async () => {
    setLoading(true);
    try {
      const data = await workshopApi.getJournalEntries();
      setEntries(data);
    } catch (e) {
      console.error("Journal load error", e);
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
      loadJournal();
    }
  }, [user, authLoading, router]);

  const handleStatusChange = async (id: string, newStatus: WorkshopStatus) => {
    setUpdatingId(id);
    try {
      await workshopApi.updateEntryStatus(id, newStatus);
      setEntries((prev) =>
        prev.map((e) => (e.id === id ? { ...e, status: newStatus } : e))
      );
    } catch (err: any) {
      alert(err.message || "Erreur de mise à jour du statut.");
    } finally {
      setUpdatingId(null);
    }
  };

  const handleExportCsv = () => {
    if (entries.length === 0) {
      alert("Le journal est vide. Aucun enregistrement à exporter.");
      return;
    }

    const headers = [
      "Ticket",
      "Client",
      "Telephone",
      "Appareil",
      "Panne",
      "Devis FCFA",
      "Statut",
      "Date",
    ];

    const rows = entries.map((e) => [
      `"${e.id.slice(0, 8)}"`,
      `"${e.clientName.replace(/"/g, '""')}"`,
      `"${e.clientPhone}"`,
      `"${e.deviceBrandModel.replace(/"/g, '""')}"`,
      `"${e.issueReported.replace(/"/g, '""')}"`,
      e.estimatedPriceXof,
      `"${e.status}"`,
      `"${new Date(e.createdAt).toLocaleDateString("fr-FR")}"`,
    ]);

    const csvContent =
      "data:text/csv;charset=utf-8,\uFEFF" +
      [headers.join(";"), ...rows.map((r) => r.join(";"))].join("\n");

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute(
      "download",
      `techsos-journal-comptoir-${new Date().toISOString().slice(0, 10)}.csv`
    );
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const totalDevis = entries.reduce((acc, curr) => acc + curr.estimatedPriceXof, 0);
  const deliveredDevis = entries
    .filter((e) => e.status === "LIVRE")
    .reduce((acc, curr) => acc + curr.estimatedPriceXof, 0);

  const filteredEntries = entries.filter((e) => {
    const matchSearch =
      e.clientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      e.clientPhone.includes(searchTerm) ||
      e.deviceBrandModel.toLowerCase().includes(searchTerm.toLowerCase());

    const matchStatus = statusFilter === "ALL" || e.status === statusFilter;
    return matchSearch && matchStatus;
  });

  return (
    <div className="py-10 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-8">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            Journal d'Atelier de Comptoir
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Enregistrez les clients physiques, changez les statuts et relancez automatiquement par WhatsApp
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Button
            variant="outline"
            size="sm"
            leftIcon={<Download className="w-4 h-4 text-emerald-600" />}
            onClick={handleExportCsv}
          >
            Exporter CSV
          </Button>

          <Button
            variant="accent"
            size="sm"
            leftIcon={<Plus className="w-4 h-4" />}
            onClick={() => setQuickEntryOpen(true)}
          >
            Prise en charge rapide
          </Button>
        </div>
      </div>

      {/* Summary KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="p-4 bg-slate-50/80 border-slate-200 flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-slate-500 uppercase">Total Appareils</div>
            <div className="text-xl font-black text-slate-900 mt-0.5">{entries.length} fiches</div>
          </div>
          <div className="w-10 h-10 rounded-xl bg-brand-primary/10 text-brand-primary flex items-center justify-center font-bold">
            📱
          </div>
        </Card>

        <Card className="p-4 bg-emerald-50/60 border-emerald-200 flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-emerald-800 uppercase">Recettes Encaissées (Livrés)</div>
            <div className="text-xl font-black text-emerald-700 mt-0.5">
              {deliveredDevis.toLocaleString("fr-FR")} FCFA
            </div>
          </div>
          <div className="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
            <Banknote className="w-5 h-5" />
          </div>
        </Card>

        <Card className="p-4 bg-amber-50/60 border-amber-200 flex items-center justify-between">
          <div>
            <div className="text-xs font-bold text-amber-800 uppercase">Devis en cours de travaux</div>
            <div className="text-xl font-black text-amber-700 mt-0.5">
              {(totalDevis - deliveredDevis).toLocaleString("fr-FR")} FCFA
            </div>
          </div>
          <div className="w-10 h-10 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center font-bold">
            <Clock className="w-5 h-5" />
          </div>
        </Card>
      </div>

      <WorkshopNav />

      {/* Search and Filters */}
      <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="relative w-full sm:w-80">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            placeholder="Rechercher client, téléphone, modèle..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-white border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary shadow-sm"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0">
          <button
            onClick={() => setStatusFilter("ALL")}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all shrink-0 ${
              statusFilter === "ALL"
                ? "bg-brand-primary text-white"
                : "bg-white text-slate-600 border border-slate-200"
            }`}
          >
            Tous ({entries.length})
          </button>
          <button
            onClick={() => setStatusFilter("RECEPTIONNE")}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all shrink-0 ${
              statusFilter === "RECEPTIONNE"
                ? "bg-brand-primary text-white"
                : "bg-white text-slate-600 border border-slate-200"
            }`}
          >
            Réceptionné
          </button>
          <button
            onClick={() => setStatusFilter("EN_REPARATION")}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all shrink-0 ${
              statusFilter === "EN_REPARATION"
                ? "bg-brand-primary text-white"
                : "bg-white text-slate-600 border border-slate-200"
            }`}
          >
            En réparation
          </button>
          <button
            onClick={() => setStatusFilter("PRET_RECUPERATION")}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all shrink-0 ${
              statusFilter === "PRET_RECUPERATION"
                ? "bg-brand-primary text-white"
                : "bg-white text-slate-600 border border-slate-200"
            }`}
          >
            Prêt
          </button>
          <button
            onClick={() => setStatusFilter("LIVRE")}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all shrink-0 ${
              statusFilter === "LIVRE"
                ? "bg-brand-primary text-white"
                : "bg-white text-slate-600 border border-slate-200"
            }`}
          >
            Livré
          </button>
        </div>
      </div>

      {/* Journal Table / Cards */}
      {loading ? (
        <div className="py-20 flex flex-col items-center justify-center space-y-3">
          <Loader2 className="w-8 h-8 animate-spin text-brand-primary" />
          <p className="text-sm text-slate-500">Chargement du journal d'atelier...</p>
        </div>
      ) : filteredEntries.length === 0 ? (
        <Card className="text-center py-16 px-4 space-y-4">
          <div className="w-14 h-14 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center">
            <BookOpen className="w-7 h-7" />
          </div>
          <div className="space-y-1">
            <h3 className="text-base font-bold text-slate-800">
              Aucune entrée dans le journal
            </h3>
            <p className="text-xs text-slate-500 max-w-sm mx-auto">
              Utilisez le bouton "Quick Entry" pour enregistrer les clients qui se présentent directement à votre atelier.
            </p>
          </div>
          <Button variant="accent" size="sm" onClick={() => setQuickEntryOpen(true)}>
            Ajouter un appareil au comptoir
          </Button>
        </Card>
      ) : (
        <div className="space-y-3">
          {filteredEntries.map((entry) => (
            <Card key={entry.id} className="p-4 sm:p-5 border-slate-200 space-y-4">
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="space-y-1.5">
                  <div className="flex flex-wrap items-center gap-2.5">
                    <span className="font-extrabold text-slate-900 text-sm sm:text-base">
                      {entry.deviceBrandModel}
                    </span>
                    <span className="text-xs text-slate-500 font-medium">
                      (Ticket #{entry.id.slice(0, 6).toUpperCase()})
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center gap-4 text-xs text-slate-500">
                    <span className="flex items-center gap-1 font-semibold text-slate-700">
                      <User className="w-3.5 h-3.5 text-brand-primary" />
                      <span>{entry.clientName}</span>
                    </span>
                    <span className="flex items-center gap-1">
                      <Phone className="w-3.5 h-3.5 text-emerald-600" />
                      <span>{entry.clientPhone}</span>
                    </span>
                    <span>·</span>
                    <span className="font-bold text-emerald-800">
                      Devis : {entry.estimatedPriceXof.toLocaleString("fr-FR")} FCFA
                    </span>
                  </div>

                  <div className="text-xs text-slate-600 bg-slate-50 p-2.5 rounded-lg border border-slate-100 mt-2">
                    Panne : {entry.issueReported}
                  </div>
                </div>

                <div className="flex flex-wrap items-center justify-between md:justify-end gap-3 pt-3 md:pt-0 border-t md:border-t-0 border-slate-100">
                  {/* Status Dropdown */}
                  <select
                    disabled={updatingId === entry.id}
                    value={entry.status}
                    onChange={(e) =>
                      handleStatusChange(entry.id, e.target.value as WorkshopStatus)
                    }
                    className="text-xs font-bold px-3 py-2 rounded-xl bg-slate-100 border border-slate-300 text-slate-800 focus:outline-none focus:ring-2 focus:ring-brand-primary/20"
                  >
                    <option value="RECEPTIONNE">1. RÉCEPTIONNÉ</option>
                    <option value="DIAGNOSTIC">2. DIAGNOSTIC</option>
                    <option value="EN_REPARATION">3. EN RÉPARATION</option>
                    <option value="PRET_RECUPERATION">4. PRÊT RÉCUPÉRATION</option>
                    <option value="LIVRE">5. LIVRÉ AU CLIENT</option>
                  </select>

                  {/* WhatsApp Action Button */}
                  <WhatsAppNotificationButton
                    entry={entry}
                    workshopName={user?.workshopName || "Atelier TechSOS"}
                  />
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Quick Entry Modal */}
      <QuickEntryModal
        isOpen={quickEntryOpen}
        onClose={() => setQuickEntryOpen(false)}
        onEntryCreated={() => loadJournal()}
      />
    </div>
  );
}
