"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { usersApi, ProviderItem } from "@/lib/api/users";
import { POPULAR_DISTRICTS } from "@/lib/constants/bamako";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import {
  Wrench,
  Search,
  MapPin,
  Star,
  MessageSquare,
  Phone,
  ShieldCheck,
  CheckCircle2,
  Clock,
  ArrowRight,
  Filter,
  Sparkles,
  Info,
  Navigation,
  Compass,
  LocateFixed,
} from "lucide-react";
import { useAuth } from "@/lib/context/AuthContext";
import { getDistanceToWorkshop, calculateDistanceKm } from "@/lib/utils/geo";
import { WorkshopDetailModal } from "@/components/workshop/WorkshopDetailModal";

// Curated verified workshop directory for Bamako
const DEFAULT_BAMAKO_WORKSHOPS: ProviderItem[] = [
  {
    id: "ws-1",
    userId: "u-1",
    workshopName: "Clinique Électronique ACI",
    addressZone: "Hamdallaye ACI 2000, Rue 314",
    specialtiesJson: JSON.stringify([
      "Smartphones & Tablettes",
      "PC & Mac Portables",
      "Micro-soudure",
    ]),
    ratingAvg: 4.9,
    reviewCount: 38,
    subscriptionStatus: "ACTIVE",
    user: {
      id: "u-1",
      fullName: "Mamadou Koné",
      phone: "+223 76 00 00 01",
      city: "Bamako",
      address: "Face BNDA ACI 2000",
    },
  },
  {
    id: "ws-2",
    userId: "u-2",
    workshopName: "TechPro Badalabougou",
    addressZone: "Badalabougou, Près Palais de la Culture",
    specialtiesJson: JSON.stringify([
      "PC & Mac Portables",
      "Imprimantes & Bureautique",
      "Réseaux",
    ]),
    ratingAvg: 4.8,
    reviewCount: 29,
    subscriptionStatus: "ACTIVE",
    user: {
      id: "u-2",
      fullName: "Ibrahim Diarra",
      phone: "+223 70 12 34 56",
      city: "Bamako",
      address: "Rue de l'Université",
    },
  },
  {
    id: "ws-3",
    userId: "u-3",
    workshopName: "Express Dépannage Lafiabougou",
    addressZone: "Lafiabougou, Rue Kôrôfina",
    specialtiesJson: JSON.stringify([
      "Smartphones & Tablettes",
      "Connecteurs & Écrans",
      "Désoxydation",
    ]),
    ratingAvg: 4.9,
    reviewCount: 44,
    subscriptionStatus: "ACTIVE",
    user: {
      id: "u-3",
      fullName: "Ousmane Coulibaly",
      phone: "+223 66 78 90 12",
      city: "Bamako",
      address: "Carrefour Shell Lafiabougou",
    },
  },
  {
    id: "ws-4",
    userId: "u-4",
    workshopName: "Baco Électro Service",
    addressZone: "Baco Djicoroni, Golf",
    specialtiesJson: JSON.stringify([
      "Électronique & TV",
      "Onduleurs & Cartes",
      "Alimentations",
    ]),
    ratingAvg: 4.7,
    reviewCount: 21,
    subscriptionStatus: "ACTIVE",
    user: {
      id: "u-4",
      fullName: "Bakary Sanogo",
      phone: "+223 78 45 67 89",
      city: "Bamako",
      address: "Près du Grand Marché Baco",
    },
  },
  {
    id: "ws-5",
    userId: "u-5",
    workshopName: "Médina Tech Solutions",
    addressZone: "Médina Coura, Rue 18",
    specialtiesJson: JSON.stringify([
      "Imprimantes & Scanners",
      "Bureautique Pro",
      "Ordinateurs Fixes",
    ]),
    ratingAvg: 4.8,
    reviewCount: 19,
    subscriptionStatus: "ACTIVE",
    user: {
      id: "u-5",
      fullName: "Adama Traoré",
      phone: "+223 72 34 56 78",
      city: "Bamako",
      address: "Derrière Stade Omnisports",
    },
  },
  {
    id: "ws-6",
    userId: "u-6",
    workshopName: "Faladié Mobile & Informatique",
    addressZone: "Faladié, Tour d'Afrique",
    specialtiesJson: JSON.stringify([
      "Smartphones & Tablettes",
      "PC Portables",
      "Batteries & Chargeurs",
    ]),
    ratingAvg: 4.9,
    reviewCount: 33,
    subscriptionStatus: "ACTIVE",
    user: {
      id: "u-6",
      fullName: "Seydou Keita",
      phone: "+223 65 43 21 09",
      city: "Bamako",
      address: "Rond-point Tour d'Afrique",
    },
  },
];

const SPECIALTY_OPTIONS = [
  "Toutes",
  "Smartphones & Tablettes",
  "PC & Mac Portables",
  "Imprimantes & Bureautique",
  "Électronique & TV",
];

export default function AteliersPage() {
  const { user, userDistrict, setUserDistrict, userCoords, isLocating, locationError, requestGeoLocation } = useAuth();
  const [providers, setProviders] = useState<ProviderItem[]>(DEFAULT_BAMAKO_WORKSHOPS);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedDistrict, setSelectedDistrict] = useState(userDistrict || "Hamdallaye ACI 2000");
  const [selectedSpecialty, setSelectedSpecialty] = useState("Toutes");
  const [selectedWorkshop, setSelectedWorkshop] = useState<ProviderItem | null>(null);
  const [onlyNearby, setOnlyNearby] = useState(true);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (userDistrict && userDistrict !== "ALL") {
      setSelectedDistrict(userDistrict);
    }
  }, [userDistrict]);

  useEffect(() => {
    usersApi
      .getProviders()
      .then((data) => {
        if (data && data.length > 0) {
          const combined = [...data];
          DEFAULT_BAMAKO_WORKSHOPS.forEach((def) => {
            if (!combined.some((c) => c.workshopName.toLowerCase() === def.workshopName.toLowerCase())) {
              combined.push(def);
            }
          });
          setProviders(combined);
        }
      })
      .catch((err) => {
        console.warn("API providers fetch failed, using Bamako directory base", err);
      });
  }, []);

  const parseSpecialties = (jsonString?: string | null): string[] => {
    if (!jsonString) return ["Électronique générale"];
    try {
      if (jsonString.startsWith("[")) {
        return JSON.parse(jsonString);
      }
      return jsonString.split(",").map((s) => s.trim());
    } catch {
      return [jsonString];
    }
  };

  const filteredWorkshops = providers.filter((p) => {
    const matchSearch =
      p.workshopName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.user.fullName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (p.addressZone && p.addressZone.toLowerCase().includes(searchTerm.toLowerCase()));

    // Proximity filter: if onlyNearby is enabled, filter strictly by selectedDistrict (user's location)
    let matchDistrict = true;
    if (onlyNearby && selectedDistrict !== "ALL") {
      matchDistrict = !!(p.addressZone && p.addressZone.toLowerCase().includes(selectedDistrict.toLowerCase()));
    } else if (selectedDistrict !== "ALL") {
      matchDistrict = !!(p.addressZone && p.addressZone.toLowerCase().includes(selectedDistrict.toLowerCase()));
    }

    const specs = parseSpecialties(p.specialtiesJson);
    const matchSpecialty =
      selectedSpecialty === "Toutes" ||
      specs.some((s) => s.toLowerCase().includes(selectedSpecialty.toLowerCase()));

    return matchSearch && matchDistrict && matchSpecialty;
  });

  const getCleanPhone = (phone: string) => {
    let clean = phone.replace(/[\s\-\+\(\)]/g, "");
    if (!clean.startsWith("223") && clean.length === 8) {
      clean = "223" + clean;
    }
    return clean;
  };

  return (
    <div className="py-12 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto space-y-10">
      {/* Top Hero Banner */}
      <div className="text-center max-w-3xl mx-auto space-y-4">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-orange-100 text-brand-accent text-xs font-bold uppercase tracking-wider">
          <ShieldCheck className="w-4 h-4" />
          <span>Réseau Officiel Certifié TechSOS</span>
        </div>
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-black text-slate-900 tracking-tight leading-tight">
          Annuaire des Ateliers de Réparation à{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-primary to-brand-accent">
            Bamako
          </span>
        </h1>
        <p className="text-base text-slate-600">
          Localisez les techniciens qualifiés les plus proches de chez vous. Chaque atelier partenaire est vérifié et soumis à notre charte de garantie de 15 jours.
        </p>
      </div>

      {/* User Proximity Bar */}
      <div className="bg-gradient-to-r from-brand-primary/5 via-orange-50 to-amber-50 p-4 sm:p-5 rounded-2xl border border-brand-primary/15 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-brand-primary text-white flex items-center justify-center shrink-0 shadow-sm">
            <LocateFixed className="w-5 h-5 text-brand-accent animate-pulse" />
          </div>
          <div>
            <div className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
              <span>Votre localisation détectée</span>
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
            </div>
            <div className="text-sm sm:text-base font-extrabold text-slate-900 flex items-center gap-2 mt-0.5">
              <span>Quartier : <span className="text-brand-primary">{selectedDistrict === "ALL" ? "Tout Bamako" : selectedDistrict}</span></span>
              {onlyNearby && selectedDistrict !== "ALL" && (
                <span className="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[11px] font-bold border border-emerald-200">
                  À proximité immédiate
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2.5 w-full md:w-auto">
          <Button
            variant="outline"
            size="sm"
            onClick={requestGeoLocation}
            isLoading={isLocating}
            leftIcon={<Navigation className="w-3.5 h-3.5 text-brand-accent" />}
            className="text-xs bg-white hover:bg-slate-50"
          >
            Actualiser ma position GPS
          </Button>

          <button
            onClick={() => {
              if (onlyNearby) {
                setOnlyNearby(false);
                setSelectedDistrict("ALL");
              } else {
                setOnlyNearby(true);
                setSelectedDistrict(userDistrict || "Hamdallaye ACI 2000");
              }
            }}
            className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all border flex items-center gap-1.5 ${
              onlyNearby && selectedDistrict !== "ALL"
                ? "bg-brand-accent text-white border-brand-accent shadow-sm"
                : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"
            }`}
          >
            <Compass className="w-3.5 h-3.5" />
            <span>{onlyNearby && selectedDistrict !== "ALL" ? "Afficher tous les quartiers" : "Voir uniquement à proximité"}</span>
          </button>
        </div>
      </div>

      {locationError && (
        <div className="text-xs p-3 rounded-xl bg-amber-50 text-amber-800 border border-amber-200 flex items-center gap-2">
          <span>⚠️ {locationError}</span>
        </div>
      )}

      {/* Filter and Search Bar */}
      <Card className="p-6 border-slate-200 shadow-hover space-y-5">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
          {/* Search Box */}
          <div className="md:col-span-5 relative">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <Search className="w-4 h-4" />
            </div>
            <input
              type="text"
              placeholder="Rechercher par nom d'atelier ou technicien..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary transition-all"
            />
          </div>

          {/* District Select */}
          <div className="md:col-span-4 relative">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <MapPin className="w-4 h-4 text-brand-accent" />
            </div>
            <select
              value={selectedDistrict}
              onChange={(e) => {
                const val = e.target.value;
                setSelectedDistrict(val);
                if (val !== "ALL") {
                  setUserDistrict(val);
                }
              }}
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
            >
              <option value="ALL">Tous les quartiers (District de Bamako)</option>
              {POPULAR_DISTRICTS.map((dist) => (
                <option key={dist} value={dist}>
                  {dist} {dist === userDistrict ? "📍 (Mon quartier)" : ""}
                </option>
              ))}
            </select>
          </div>

          {/* Specialty Select */}
          <div className="md:col-span-3 relative">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <Wrench className="w-4 h-4 text-brand-primary" />
            </div>
            <select
              value={selectedSpecialty}
              onChange={(e) => setSelectedSpecialty(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary"
            >
              {SPECIALTY_OPTIONS.map((spec) => (
                <option key={spec} value={spec}>
                  {spec}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Quick specialty tags */}
        <div className="flex flex-wrap items-center gap-2 pt-2 border-t border-slate-100 text-xs">
          <span className="font-bold text-slate-400 uppercase tracking-wider mr-1">
            Filtres rapides :
          </span>
          {SPECIALTY_OPTIONS.map((spec) => (
            <button
              key={spec}
              onClick={() => setSelectedSpecialty(spec)}
              className={`px-3 py-1 rounded-lg font-medium transition-all ${
                selectedSpecialty === spec
                  ? "bg-brand-primary text-white"
                  : "bg-slate-100 text-slate-600 hover:bg-slate-200"
              }`}
            >
              {spec}
            </button>
          ))}
        </div>
      </Card>

      {/* Directory Grid */}
      <div className="space-y-4">
        <div className="flex items-center justify-between text-xs text-slate-500 font-semibold px-1">
          <span>{filteredWorkshops.length} atelier{filteredWorkshops.length > 1 ? "s" : ""} référencé{filteredWorkshops.length > 1 ? "s" : ""} à Bamako</span>
          <span className="flex items-center gap-1 text-emerald-700">
            <Clock className="w-3.5 h-3.5" /> Réponse moyenne en atelier : 15 min
          </span>
        </div>

        {filteredWorkshops.length === 0 ? (
          <Card className="text-center py-16 px-4 space-y-4">
            <div className="w-14 h-14 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center">
              <Wrench className="w-7 h-7" />
            </div>
            <div className="space-y-1">
              <h3 className="text-base font-bold text-slate-800">
                Aucun atelier ne correspond à votre recherche
              </h3>
              <p className="text-xs text-slate-500 max-w-sm mx-auto">
                Essayez d'élargir votre recherche ou de sélectionner "Tous les quartiers".
              </p>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                setSearchTerm("");
                setSelectedDistrict("ALL");
                setSelectedSpecialty("Toutes");
              }}
            >
              Réinitialiser les filtres
            </Button>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredWorkshops.map((workshop) => {
              const specialties = parseSpecialties(workshop.specialtiesJson);
              const cleanPhone = getCleanPhone(workshop.user.phone);
              const waMessage = encodeURIComponent(
                `Bonjour ${workshop.workshopName}, je vous contacte via la plateforme TechSOS Bamako pour un dépannage.`
              );

              return (
                <Card
                  key={workshop.id}
                  hover
                  className="p-6 border-slate-200 hover:border-brand-primary/40 flex flex-col justify-between space-y-6"
                >
                  <div className="space-y-4">
                    {/* Header */}
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-1.5">
                          <h3 className="text-lg font-black text-slate-900 group-hover:text-brand-accent transition-colors">
                            {workshop.workshopName}
                          </h3>
                        </div>
                        <p className="text-xs text-slate-500 font-medium mt-0.5">
                          Responsable : <strong className="text-slate-700">{workshop.user.fullName}</strong>
                        </p>
                      </div>

                      <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-amber-50 text-amber-900 text-xs font-bold border border-amber-200/80 shrink-0">
                        <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                        <span>{(workshop.ratingAvg || 5.0).toFixed(1)}</span>
                        <span className="text-slate-400">({workshop.reviewCount})</span>
                      </span>
                    </div>

                    {/* Zone / Address & Distance Badge */}
                    <div className="p-3 bg-slate-50 rounded-xl border border-slate-200/80 text-xs text-slate-700 flex items-start justify-between gap-2">
                      <div className="flex items-start gap-2">
                        <MapPin className="w-4 h-4 text-brand-accent shrink-0 mt-0.5" />
                        <span>{workshop.addressZone || "Bamako"}</span>
                      </div>
                      {(() => {
                        const distKm = getDistanceToWorkshop(userCoords, workshop.addressZone);
                        const isSameDistrict =
                          selectedDistrict !== "ALL" &&
                          workshop.addressZone?.toLowerCase().includes(selectedDistrict.toLowerCase());

                        if (distKm !== null) {
                          return (
                            <span className="shrink-0 px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold border border-emerald-200">
                              ~{distKm} km
                            </span>
                          );
                        } else if (isSameDistrict) {
                          return (
                            <span className="shrink-0 px-2 py-0.5 rounded-full bg-orange-100 text-brand-accent text-[10px] font-bold border border-orange-200">
                              Votre quartier
                            </span>
                          );
                        }
                        return null;
                      })()}
                    </div>

                    {/* Specialties chips */}
                    <div className="space-y-1.5">
                      <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                        Compétences atelier :
                      </div>
                      <div className="flex flex-wrap gap-1.5">
                        {specialties.map((spec, i) => (
                          <span
                            key={i}
                            className="px-2.5 py-1 rounded-lg bg-slate-100 text-slate-700 text-[11px] font-semibold border border-slate-200"
                          >
                            {spec}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Actions footer */}
                  <div className="pt-5 border-t border-slate-100 space-y-2.5">
                    <Button
                      variant="outline"
                      size="sm"
                      className="w-full text-xs"
                      leftIcon={<Info className="w-3.5 h-3.5 text-brand-primary" />}
                      onClick={() => setSelectedWorkshop(workshop)}
                    >
                      Consulter la fiche complète
                    </Button>

                    <div className="grid grid-cols-2 gap-2">
                      <a
                        href={`https://wa.me/${cleanPhone}?text=${waMessage}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="py-2 px-3 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-emerald-800 text-xs font-bold flex items-center justify-center gap-1.5 border border-emerald-200 transition-colors"
                      >
                        <MessageSquare className="w-3.5 h-3.5 text-emerald-600" />
                        <span>WhatsApp</span>
                      </a>

                      <a
                        href={`tel:${workshop.user.phone}`}
                        className="py-2 px-3 rounded-xl bg-slate-50 hover:bg-slate-100 text-slate-800 text-xs font-bold flex items-center justify-center gap-1.5 border border-slate-200 transition-colors"
                      >
                        <Phone className="w-3.5 h-3.5 text-brand-primary" />
                        <span>Appeler</span>
                      </a>
                    </div>

                    <Link
                      href="/sos-panne"
                      className="block"
                    >
                      <Button
                        variant="accent"
                        size="sm"
                        className="w-full text-xs"
                        rightIcon={<ArrowRight className="w-3.5 h-3.5" />}
                      >
                        Déposer une demande SOS
                      </Button>
                    </Link>
                  </div>
                </Card>
              );
            })}
          </div>
        )}
      </div>

      {/* Callout: Are you a repair shop in Bamako? */}
      <div className="bg-gradient-to-r from-brand-primary to-slate-900 text-white rounded-3xl p-8 sm:p-10 flex flex-col md:flex-row items-center justify-between gap-6 shadow-xl">
        <div className="space-y-2 text-center md:text-left">
          <div className="inline-flex items-center gap-2 text-xs font-bold text-brand-accent uppercase tracking-wider">
            <Sparkles className="w-4 h-4" />
            <span>Vous possédez un atelier à Bamako ?</span>
          </div>
          <h3 className="text-2xl font-black tracking-tight">
            Référencez votre atelier gratuitement sur TechSOS
          </h3>
          <p className="text-sm text-slate-300 max-w-xl">
            Rejoignez le réseau des professionnels certifiés, recevez les pannes de votre quartier en temps réel et développez votre clientèle.
          </p>
        </div>

        <Link href="/inscription" className="shrink-0">
          <Button variant="accent" size="lg">
            Inscrire mon Atelier Pro
          </Button>
        </Link>
      </div>

      {/* Modal: Full Workshop Info */}
      {selectedWorkshop && (
        <WorkshopDetailModal
          workshop={selectedWorkshop}
          isOpen={true}
          onClose={() => setSelectedWorkshop(null)}
          specialties={parseSpecialties(selectedWorkshop.specialtiesJson)}
        />
      )}
    </div>
  );
}
