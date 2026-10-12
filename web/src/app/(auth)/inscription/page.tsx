"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Logo } from "@/components/ui/Logo";
import {
  Phone,
  Lock,
  User,
  Wrench,
  Store,
  ArrowRight,
  CheckCircle2,
} from "lucide-react";

const SPECIALTIES_LIST = [
  "Smartphones & Tablettes",
  "PC & Mac Portables",
  "Imprimantes & Bureautique",
  "TV, Audio & Électronique",
  "Réseaux & Alimentations",
];

export default function InscriptionPage() {
  const router = useRouter();
  const { registerClient, registerProvider } = useAuth();

  const [role, setRole] = useState<"CLIENT" | "PROVIDER">("CLIENT");
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");

  // Provider specific
  const [workshopName, setWorkshopName] = useState("");
  const [selectedSpecialties, setSelectedSpecialties] = useState<string[]>([
    "Smartphones & Tablettes",
  ]);

  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const toggleSpecialty = (spec: string) => {
    if (selectedSpecialties.includes(spec)) {
      if (selectedSpecialties.length > 1) {
        setSelectedSpecialties(selectedSpecialties.filter((s) => s !== spec));
      }
    } else {
      setSelectedSpecialties([...selectedSpecialties, spec]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (role === "CLIENT") {
        await registerClient({
          fullName,
          phone,
          password,
        });
        router.push("/mes-demandes");
      } else {
        if (!workshopName.trim()) {
          throw new Error("Veuillez renseigner le nom de votre atelier.");
        }
        await registerProvider({
          fullName,
          phone,
          password,
          workshopName,
          specialties: selectedSpecialties,
        });
        router.push("/atelier/dashboard");
      }
    } catch (err: any) {
      setError(err.message || "Erreur lors de la création du compte.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-lg space-y-6">
        <div className="text-center space-y-2">
          <Logo size="lg" className="justify-center" />
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">
            Créer un compte TechSOS
          </h1>
          <p className="text-sm text-slate-500">
            Rejoignez le réseau leader du dépannage électronique à Bamako
          </p>
        </div>

        {/* Role toggle */}
        <div className="grid grid-cols-2 p-1 bg-slate-200/80 rounded-2xl gap-1">
          <button
            type="button"
            onClick={() => setRole("CLIENT")}
            className={`py-3 px-4 rounded-xl text-sm font-bold flex items-center justify-center gap-2 transition-all ${
              role === "CLIENT"
                ? "bg-white text-brand-primary shadow-sm"
                : "text-slate-600 hover:text-slate-900"
            }`}
          >
            <User className="w-4 h-4 text-brand-accent" />
            <span>Je suis Client</span>
          </button>
          <button
            type="button"
            onClick={() => setRole("PROVIDER")}
            className={`py-3 px-4 rounded-xl text-sm font-bold flex items-center justify-center gap-2 transition-all ${
              role === "PROVIDER"
                ? "bg-white text-brand-primary shadow-sm"
                : "text-slate-600 hover:text-slate-900"
            }`}
          >
            <Wrench className="w-4 h-4 text-brand-accent" />
            <span>Je suis Réparateur</span>
          </button>
        </div>

        <Card className="shadow-hover">
          {error && (
            <div className="mb-5 p-3.5 bg-rose-50 border border-rose-200 text-rose-800 text-sm rounded-xl flex items-start gap-2.5">
              <span className="shrink-0 font-bold">⚠️</span>
              <div>{error}</div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Nom Complet
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <User className="w-4 h-4" />
                </div>
                <input
                  type="text"
                  required
                  placeholder={role === "CLIENT" ? "Ex: Amadou Diallo" : "Ex: Moussa Traoré"}
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary transition-all text-slate-900"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Numéro de Téléphone (Mali)
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Phone className="w-4 h-4" />
                </div>
                <input
                  type="tel"
                  required
                  placeholder="+223 70 00 00 00"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary transition-all text-slate-900"
                />
              </div>
            </div>

            {role === "PROVIDER" && (
              <>
                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                    Nom de votre Atelier
                  </label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                      <Store className="w-4 h-4" />
                    </div>
                    <input
                      type="text"
                      required
                      placeholder="Ex: Clinique Électronique ACI"
                      value={workshopName}
                      onChange={(e) => setWorkshopName(e.target.value)}
                      className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary transition-all text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
                    Vos Spécialités Techniques
                  </label>
                  <div className="flex flex-wrap gap-2">
                    {SPECIALTIES_LIST.map((spec) => {
                      const isSelected = selectedSpecialties.includes(spec);
                      return (
                        <button
                          key={spec}
                          type="button"
                          onClick={() => toggleSpecialty(spec)}
                          className={`text-xs px-3 py-1.5 rounded-lg font-medium transition-all flex items-center gap-1.5 ${
                            isSelected
                              ? "bg-brand-primary text-white"
                              : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                          }`}
                        >
                          {isSelected && <CheckCircle2 className="w-3.5 h-3.5 text-brand-accent" />}
                          <span>{spec}</span>
                        </button>
                      );
                    })}
                  </div>
                </div>
              </>
            )}

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Mot de Passe (6 caractères min.)
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Lock className="w-4 h-4" />
                </div>
                <input
                  type="password"
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary transition-all text-slate-900"
                />
              </div>
            </div>

            <Button
              type="submit"
              variant="accent"
              className="w-full mt-2"
              isLoading={loading}
              rightIcon={<ArrowRight className="w-4 h-4" />}
            >
              {role === "CLIENT" ? "Créer mon Compte Client" : "Inscrire mon Atelier Pro"}
            </Button>
          </form>
        </Card>

        <div className="text-center text-sm text-slate-500">
          Vous avez déjà un compte ?{" "}
          <Link
            href="/connexion"
            className="font-bold text-brand-accent hover:underline"
          >
            Se connecter
          </Link>
        </div>
      </div>
    </div>
  );
}
