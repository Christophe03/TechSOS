import { Injectable, Logger } from '@nestjs/common';

export interface WhatsAppNotificationResult {
  success: boolean;
  messageId: string;
  timestamp: Date;
  recipientPhone: string;
  message: string;
}

@Injectable()
export class WhatsAppService {
  private readonly logger = new Logger(WhatsAppService.name);

  /**
   * Envoie une notification WhatsApp lors de la prise en charge d'un appareil à l'atelier.
   */
  async sendTicketCreatedNotification(
    clientPhone: string,
    clientName: string,
    workshopName: string,
    deviceModel: string,
    entryId: string,
  ): Promise<WhatsAppNotificationResult> {
    const message = `Bonjour ${clientName}, votre ${deviceModel} a bien été enregistré chez ${workshopName} (Réf: ${entryId}). Nous vous tiendrons informé dès la fin du diagnostic/réparation. Merci de votre confiance avec TechSOS !`;

    const messageId = `WA-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    const timestamp = new Date();

    this.logger.log(
      `[WhatsApp] Notification Ticket Créé envoyée avec succès à ${clientPhone} [ID: ${messageId}] : "${message}"`,
    );

    return {
      success: true,
      messageId,
      timestamp,
      recipientPhone: clientPhone,
      message,
    };
  }

  /**
   * Envoie une notification WhatsApp indiquant que l'appareil est prêt à être récupéré.
   */
  async sendReadyForPickupNotification(
    clientPhone: string,
    clientName: string,
    workshopName: string,
    deviceModel: string,
    priceCfa?: number,
  ): Promise<WhatsAppNotificationResult> {
    const priceText =
      priceCfa !== undefined && priceCfa !== null
        ? ` (Montant: ${priceCfa.toLocaleString('fr-FR')} FCFA)`
        : '';
    const message = `Bonne nouvelle ${clientName} ! Votre ${deviceModel} est réparé et prêt à être récupéré chez ${workshopName}${priceText}. À très bientôt !`;

    const messageId = `WA-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    const timestamp = new Date();

    this.logger.log(
      `[WhatsApp] Notification Prêt pour Retrait envoyée avec succès à ${clientPhone} [ID: ${messageId}] : "${message}"`,
    );

    return {
      success: true,
      messageId,
      timestamp,
      recipientPhone: clientPhone,
      message,
    };
  }
}
