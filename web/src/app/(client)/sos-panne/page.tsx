"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { repairsApi } from "@/lib/api/repairs";
import { Category } from "@/lib/types";
import { POPULAR_DISTRICTS } from "@/lib/constants/bamako";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { WebAudioRecorder } from "@/components/audio/WebAudioRecorder";
import {
  AlertTriangle,
  Upload,
  X,
  MapPin,
  CheckCircle2,
  Smartphone,
  Laptop,
  Printer,
  Tv,
  ArrowRight,
  Navigation,
  LocateFixed,
} from "lucide-react";

export default function SosPannePage() {
  const router = useRouter();
  const { user, userDistrict, setUserDistrict, requestGeoLocation, isLocating } = useAuth();

  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [equipmentTitle, setEquipmentTitle] = useState("");
  const [issueDescription, setIssueDescription] = useState("");
  const [district, setDistrict] = useState(userDistrict || POPULAR_DISTRICTS[0]);
  const [audioBlob, setAudioBlob] = useState<Blob | null>(null);
  const [photos, setPhotos] = useState<File[]>([]);
  const [photoPreviews, setPhotoPreviews] = useState<string[]>([]);

  useEffect(() => {
    if (userDistrict) {
      setDistrict(userDistrict);
    }
  }, [userDistrict]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    repairsApi
      .getCategories()
      .then((cats) => {
        setCategories(cats);
        if (cats.length > 0) {
          setSelectedCategory(cats[0].id);
        }
      })
      .catch((err) => {
        console.warn("Failed to load categories from API, using fallback", err);
      });
  }, []);

  const handlePhotoSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const filesArray = Array.from(e.target.files);
      setPhotos((prev) => [...prev, ...filesArray]);

      const previews = filesArray.map((f) => URL.createObjectURL(f));
      setPhotoPreviews((prev) => [...prev, ...previews]);
    }
  };

  const removePhoto = (index: number) => {
    setPhotos((prev) => prev.filter((_, i) => i !== index));
    URL.revokeObjectURL(photoPreviews[index]);
    setPhotoPreviews((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!user) {
      // Require auth
      sessionStorage.setItem(
        "techsos_pending_sos",
        JSON.stringify({
          categoryId: selectedCategory,
          equipmentTitle,
          issueDescription,
          district,
        })
      );
      router.push("/connexion");
      return;
    }

    if (!selectedCategory) {
      setError("Veuillez sélectionner une catégorie d'appareil.");
      return;
    }

    setLoading(true);
    try {
      await repairsApi.createRepair({
        categoryId: selectedCategory,
        equipmentTitle,
        issueDescription,
        district,
        audioBlob: audioBlob || undefined,
        photos: photos.length > 0 ? photos : undefined,
      });

      router.push("/mes-demandes");
    } catch (err: any) {
      setError(err.message || "Erreur lors de la publication de la panne.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="py-12 px-4 sm:px-6 lg:px-8 max-w-4xl mx-auto">
      <div className="text-center space-y-3 mb-10">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-orange-100 text-brand-accent text-xs font-bold uppercase tracking-wider">
          <AlertTriangle className="w-3.5 h-3.5" />
          <span>Intervention d'Urgence Bamako</span>
        </div>
        <h1 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
          Déclarer un SOS Panne
        </h1>
        <p className="text-sm sm:text-base text-slate-600 max-w-xl mx-auto">
          Remplissez les détails ci-dessous. Les réparateurs certifiés à proximité vous répondront avec un devis ferme sous 15 minutes.
        </p>
      </div>

      <Card className="shadow-hover p-6 sm:p-8">
        {error && (
          <div className="mb-6 p-4 bg-rose-50 border border-rose-200 text-rose-800 text-sm rounded-xl flex items-start gap-3">
            <span className="font-bold">⚠️</span>
            <div>{error}</div>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-8">
          {/* 1. Catégorie */}
          <div className="space-y-3">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
              1. Type d'équipement
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setSelectedCategory(cat.id)}
                  className={`p-3.5 rounded-xl border text-left transition-all flex flex-col justify-between ${
                    selectedCategory === cat.id
                      ? "border-brand-accent bg-orange-50/50 ring-2 ring-brand-accent/20"
                      : "border-slate-200 hover:border-slate-300 bg-white"
                  }`}
                >
                  <div className="font-bold text-sm text-slate-900">{cat.name}</div>
                  {selectedCategory === cat.id && (
                    <span className="text-[11px] font-bold text-brand-accent mt-2 flex items-center gap-1">
                      <CheckCircle2 className="w-3 h-3" /> Sélectionné
                    </span>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* 2. Modèle */}
          <div className="space-y-2">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
              2. Marque et modèle précis de l'appareil
            </label>
            <input
              type="text"
              required
              placeholder="Ex: iPhone 13 Pro 128Go / HP ProBook 450 G8 / Imprimante Canon G3010"
              value={equipmentTitle}
              onChange={(e) => setEquipmentTitle(e.target.value)}
              className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary text-slate-900"
            />
          </div>

          {/* 3. Description & Note vocale */}
          <div className="space-y-4">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
              3. Description de la panne
            </label>
            <textarea
              required
              rows={3}
              placeholder="Décrivez ce qui s'est passé : l'écran reste noir, tombé dans l'eau, bruit de ventilateur, odeur de brûlé..."
              value={issueDescription}
              onChange={(e) => setIssueDescription(e.target.value)}
              className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary text-slate-900 resize-none"
            />

            {/* Micro component */}
            <WebAudioRecorder onAudioReady={(blob) => setAudioBlob(blob)} />
          </div>

          {/* 4. Photos */}
          <div className="space-y-3">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
              4. Photos de l'appareil (optionnel mais utile)
            </label>
            <div className="flex flex-wrap gap-3 items-center">
              {photoPreviews.map((preview, i) => (
                <div key={i} className="relative w-20 h-20 rounded-xl overflow-hidden border border-slate-200">
                  <img src={preview} alt="Aperçu" className="w-full h-full object-cover" />
                  <button
                    type="button"
                    onClick={() => removePhoto(i)}
                    className="absolute top-1 right-1 p-1 bg-black/60 hover:bg-black/80 text-white rounded-full"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </div>
              ))}

              <label className="w-20 h-20 rounded-xl border-2 border-dashed border-slate-300 hover:border-brand-primary flex flex-col items-center justify-center cursor-pointer text-slate-400 hover:text-brand-primary transition-colors bg-slate-50">
                <Upload className="w-5 h-5 mb-1" />
                <span className="text-[10px] font-bold uppercase">Ajouter</span>
                <input
                  type="file"
                  multiple
                  accept="image/*"
                  onChange={handlePhotoSelect}
                  className="hidden"
                />
              </label>
            </div>
          </div>

          {/* 5. Quartier */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
                5. Votre quartier à Bamako
              </label>
              <button
                type="button"
                onClick={requestGeoLocation}
                disabled={isLocating}
                className="text-xs font-semibold text-brand-primary hover:text-brand-accent flex items-center gap-1 transition-colors"
              >
                <Navigation className={`w-3.5 h-3.5 ${isLocating ? "animate-spin" : ""}`} />
                <span>{isLocating ? "Localisation..." : "Détecter ma position"}</span>
              </button>
            </div>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <MapPin className="w-4 h-4 text-brand-accent" />
              </div>
              <select
                value={district}
                onChange={(e) => {
                  setDistrict(e.target.value);
                  setUserDistrict(e.target.value);
                }}
                className="w-full pl-10 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary text-slate-900"
              >
                {POPULAR_DISTRICTS.map((dist) => (
                  <option key={dist} value={dist}>
                    {dist} {dist === userDistrict ? "📍 (Mon quartier)" : ""}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-4">
            <span className="text-xs text-slate-500">
              ⚡ Devis gratuits sans engagement · Confidentialité de vos données garantie
            </span>
            <Button
              type="submit"
              variant="accent"
              size="lg"
              isLoading={loading}
              rightIcon={<ArrowRight className="w-4 h-4" />}
            >
              Envoyer la Demande SOS
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
