"use client";

import React, { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/context/AuthContext";
import { Loader2, ShieldAlert } from "lucide-react";
import { Button } from "@/components/ui/Button";
import Link from "next/link";

export default function WorkshopLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { user, isLoading } = useAuth();

  useEffect(() => {
    if (!isLoading && !user) {
      router.push("/connexion");
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="min-h-[70vh] flex flex-col items-center justify-center space-y-4">
        <Loader2 className="w-10 h-10 animate-spin text-brand-primary" />
        <p className="text-sm font-semibold text-slate-600">
          Vérification des accès atelier en cours...
        </p>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  if (user.role !== "PROVIDER") {
    return (
      <div className="min-h-[70vh] flex flex-col items-center justify-center px-4 text-center">
        <div className="p-4 rounded-full bg-rose-100 text-rose-600 mb-4">
          <ShieldAlert className="w-12 h-12" />
        </div>
        <h1 className="text-2xl font-extrabold text-slate-900 mb-2">
          Accès Réservé aux Professionnels & Réparateurs
        </h1>
        <p className="text-slate-600 max-w-md text-sm mb-6">
          Votre compte actuel (<span className="font-semibold">{user.phone}</span>) est enregistré en tant que <strong className="text-brand-primary">Client</strong>.
          L'Espace Atelier et la gestion de comptoir sont exclusivement réservés aux comptes Réparateur / Atelier agréé.
        </p>
        <div className="flex flex-col sm:flex-row gap-3">
          <Link href="/">
            <Button variant="outline">Retour à l'accueil</Button>
          </Link>
          <Link href="/inscription">
            <Button variant="accent">Créer un compte Réparateur</Button>
          </Link>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
