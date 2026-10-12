"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { workshopApi } from "@/lib/api/workshop";
import { repairsApi } from "@/lib/api/repairs";
import { Repair } from "@/lib/types";
import { POPULAR_DISTRICTS } from "@/lib/constants/bamako";
import { WorkshopNav } from "@/components/workshop/WorkshopNav";
import { SubmitOfferModal } from "@/components/workshop/SubmitOfferModal";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import {
  Radio,
  MapPin,
  Clock,
  Volume2,
  DollarSign,
  Filter,
  CheckCircle2,
  Loader2,
  Search,
  Sparkles,
} from "lucide-react";

export default function FilUrgencesPage() {
  const router = useRouter();
  const { user, isLoading: authLoading } = useAuth();

  const [feed, setFeed] = useState<Repair[]>([]);
  const [selectedDistrict, setSelectedDistrict] = useState<string>("ALL");
  const [searchTerm, setSearchTerm] = useState("");
  const [withAudioOnly, setWithAudioOnly] = useState(false);
  const [loading, setLoading] = useState(true);
  const [selectedRepairForOffer, setSelectedRepairForOffer] = useState<Repair | null>(null);

  const loadFeed = async () => {
    setLoading(true);
    try {
      const data = await workshopApi.getFeed();
      setFeed(data);
    } catch (e) {
      console.error("Feed load error", e);
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
      loadFeed();
    }
  }, [user, authLoading, router]);

  const filteredFeed = feed.filter((r) => {
    const matchDistrict = selectedDistrict === "ALL" || r.district === selectedDistrict;
    const matchSearch =
      searchTerm.trim() === "" ||
      r.equipmentTitle.toLowerCase().includes(searchTerm.toLowerCase()) ||
      r.issueDescription.toLowerCase().includes(searchTerm.toLowerCase());
    const matchAudio = !withAudioOnly || !!r.audioVoiceUrl;

    return matchDistrict && matchSearch && matchAudio;
  });

  return (
    <div className="py-10 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-8">
      <div>
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 rounded-full bg-brand-accent animate-ping" />
          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            Fil des Urgences en Direct (Bamako)
          </h1>
        </div>
        <p className="text-sm text-slate-500 mt-1">
          Pannes signalées par des clients particuliers et entreprises à la recherche d'un réparateur qualifié
        </p>
      </div>

      <WorkshopNav />

      {/* Filter and Search Box */}
      <div className="space-y-4">
        <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
          <div className="relative w-full sm:w-96">
            <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3 pointer-events-none" />
            <input
              type="text"
              placeholder="Rechercher par appareil ou panne (ex: iPhone, écran, PC)..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary shadow-sm"
            />
          </div>

          <button
            onClick={() => setWithAudioOnly(!withAudioOnly)}
            className={`px-3.5 py-2 rounded-xl text-xs font-bold flex items-center gap-2 transition-all border ${
              withAudioOnly
                ? "bg-emerald-600 text-white border-emerald-600 shadow-sm"
                : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"
            }`}
          >
            <Volume2 className="w-4 h-4" />
            <span>Note vocale incluse uniquement</span>
          </button>
        </div>

        {/* District filter */}
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1 mr-2">
            <Filter className="w-3.5 h-3.5" /> Filtrer par quartier :
          </span>
          <button
            onClick={() => setSelectedDistrict("ALL")}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              selectedDistrict === "ALL"
                ? "bg-brand-primary text-white"
                : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
            }`}
          >
            Tous ({feed.length})
          </button>
          {POPULAR_DISTRICTS.map((dist) => (
            <button
              key={dist}
              onClick={() => setSelectedDistrict(dist)}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                selectedDistrict === dist
                  ? "bg-brand-primary text-white"
                  : "bg-white text-slate-600 border border-slate-200 hover:bg-slate-50"
              }`}
            >
              {dist}
            </button>
          ))}
        </div>
      </div>

      {/* Feed list */}
      {loading ? (
        <div className="py-20 flex flex-col items-center justify-center space-y-3">
          <Loader2 className="w-8 h-8 animate-spin text-brand-primary" />
          <p className="text-sm text-slate-500">Actualisation des opportunités en cours...</p>
        </div>
      ) : filteredFeed.length === 0 ? (
        <Card className="text-center py-16 px-4 space-y-3">
          <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center">
            <Radio className="w-6 h-6" />
          </div>
          <h3 className="text-base font-bold text-slate-800">
            Aucune panne disponible pour ce quartier
          </h3>
          <p className="text-xs text-slate-500 max-w-sm mx-auto">
            Restez connecté : les notifications de nouvelles annonces apparaissent dès leur publication par les usagers.
          </p>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {filteredFeed.map((repair) => (
            <Card
              key={repair.id}
              hover
              className="p-6 border-slate-200 hover:border-brand-primary/40 flex flex-col justify-between space-y-5"
            >
              <div className="space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h3 className="text-base font-extrabold text-slate-900">
                      {repair.equipmentTitle}
                    </h3>
                    <div className="flex items-center gap-3 text-xs text-slate-400 mt-1">
                      <span className="flex items-center gap-1 font-semibold text-brand-accent">
                        <MapPin className="w-3.5 h-3.5" />
                        <span>{repair.district}</span>
                      </span>
                      <span>·</span>
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
                    </div>
                  </div>
                  <Badge variant="pending">En attente de devis</Badge>
                </div>

                <div className="p-3 bg-slate-50 rounded-xl border border-slate-200/80 text-xs text-slate-700 leading-relaxed">
                  "{repair.issueDescription}"
                </div>

                {repair.audioVoiceUrl && (
                  <div className="pt-2 border-t border-slate-100 space-y-1">
                    <div className="flex items-center gap-1.5 text-xs font-bold text-emerald-700">
                      <Volume2 className="w-3.5 h-3.5" />
                      <span>Note vocale du client :</span>
                    </div>
                    <audio
                      controls
                      src={repairsApi.getMediaUrl(repair.audioVoiceUrl)}
                      className="w-full h-8 rounded"
                    />
                  </div>
                )}
              </div>

              <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
                <span className="text-xs text-slate-400">
                  {repair.offers?.length || 0} devis déjà soumis
                </span>
                <Button
                  variant="accent"
                  size="sm"
                  onClick={() => setSelectedRepairForOffer(repair)}
                >
                  Proposer mon devis
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {selectedRepairForOffer && (
        <SubmitOfferModal
          repair={selectedRepairForOffer}
          isOpen={true}
          onClose={() => setSelectedRepairForOffer(null)}
          onOfferSubmitted={() => loadFeed()}
        />
      )}
    </div>
  );
}
