"use client";

import React from "react";
import { MessageSquare } from "lucide-react";
import { WorkshopEntry } from "@/lib/types";

interface WhatsAppNotificationButtonProps {
  entry: WorkshopEntry;
  workshopName?: string;
}

export const WhatsAppNotificationButton: React.FC<WhatsAppNotificationButtonProps> = ({
  entry,
  workshopName = "Atelier TechSOS",
}) => {
  const getWhatsAppMessage = (): string => {
    switch (entry.status) {
      case "RECEPTIONNE":
        return `Bonjour ${entry.clientName}, votre appareil ${entry.deviceBrandModel} a bien été réceptionné à ${workshopName}. Panne signalée : "${entry.issueReported}". Devis estimé : ${entry.estimatedPriceXof.toLocaleString("fr-FR")} FCFA. Nous débutons l'analyse technique.`;
      case "DIAGNOSTIC":
        return `Bonjour ${entry.clientName}, le diagnostic de votre appareil ${entry.deviceBrandModel} est en cours à ${workshopName}. Nous vous tiendrons informé dès confirmation des pièces.`;
      case "EN_REPARATION":
        return `Bonjour ${entry.clientName}, votre appareil ${entry.deviceBrandModel} est actuellement sur notre banc de réparation à ${workshopName}.`;
      case "PRET_RECUPERATION":
        return `Bonjour ${entry.clientName}, bonne nouvelle ! Votre appareil ${entry.deviceBrandModel} est entièrement réparé, testé et PRÊT À ÊTRE RÉCUPÉRÉ à ${workshopName}. Montant : ${entry.estimatedPriceXof.toLocaleString("fr-FR")} FCFA. À très bientôt !`;
      case "LIVRE":
        return `Bonjour ${entry.clientName}, merci d'avoir récupéré votre appareil ${entry.deviceBrandModel} à ${workshopName}. N'hésitez pas à nous recommander sur TechSOS Bamako !`;
      default:
        return `Bonjour ${entry.clientName}, suivi de votre réparation ${entry.deviceBrandModel} à ${workshopName}.`;
    }
  };

  const handleOpenWhatsApp = () => {
    let cleanPhone = entry.clientPhone.replace(/[\s\-\+\(\)]/g, "");
    if (!cleanPhone.startsWith("223") && cleanPhone.length === 8) {
      cleanPhone = "223" + cleanPhone;
    }

    const text = encodeURIComponent(getWhatsAppMessage());
    window.open(`https://wa.me/${cleanPhone}?text=${text}`, "_blank");
  };

  return (
    <button
      type="button"
      onClick={handleOpenWhatsApp}
      title="Envoyer une notification WhatsApp au client"
      className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200 transition-colors shadow-sm"
    >
      <MessageSquare className="w-3.5 h-3.5 text-emerald-600" />
      <span>WhatsApp</span>
    </button>
  );
};
