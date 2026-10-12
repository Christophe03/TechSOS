import type { Metadata } from "next";
import "./globals.css";
import { AuthProvider } from "@/lib/context/AuthContext";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";

export const metadata: Metadata = {
  title: "TechSOS · Dépannage Informatique & Électronique d'Urgence à Bamako",
  description:
    "Plateforme n°1 à Bamako reliant les particuliers et professionnels en détresse technique aux réparateurs qualifiés et certifiés. Diagnostic express, devis en FCFA et garantie atelier.",
  keywords: [
    "dépannage informatique Bamako",
    "réparation smartphone Mali",
    "réparation pc portable Bamako",
    "réparateur agréé ACI 2000",
    "TechSOS",
    "SOS panne électronique",
  ],
  authors: [{ name: "Golden Innovation Tech" }],
  openGraph: {
    title: "TechSOS · Dépannage d'urgence à Bamako",
    description: "Trouvez un réparateur certifié près de chez vous en moins de 15 minutes.",
    locale: "fr_FR",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr" className="scroll-smooth">
      <body className="min-h-screen flex flex-col antialiased text-slate-900 bg-brand-surface">
        <AuthProvider>
          <Navbar />
          <main className="flex-1">{children}</main>
          <Footer />
        </AuthProvider>
      </body>
    </html>
  );
}
