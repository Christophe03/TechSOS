import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { WhatsAppService } from '../notifications/whatsapp.service';
import { CreateWorkshopEntryDto } from './dto/create-workshop-entry.dto';
import { UpdateWorkshopStatusDto } from './dto/update-workshop-status.dto';

@Injectable()
export class WorkshopService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly whatsappService: WhatsAppService,
  ) {}

  /**
   * Retourne la liste des fiches d'atelier pour le réparateur connecté avec filtres optionnels.
   */
  async findAll(
    providerUserId: string,
    filters?: { status?: string; origin?: string },
  ) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const where: any = {
      providerId: providerProfile.id,
    };

    if (filters?.status) {
      where.status = filters.status;
    }

    if (filters?.origin) {
      where.origin = filters.origin;
    }

    return this.prisma.workshopEntry.findMany({
      where,
      orderBy: {
        updatedAt: 'desc',
      },
    });
  }

  /**
   * Enregistre un appareil à l'atelier (physique ou appli) et envoie la notification WhatsApp de prise en charge.
   */
  async quickEntry(providerUserId: string, dto: CreateWorkshopEntryDto) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const createdEntry = await this.prisma.workshopEntry.create({
      data: {
        providerId: providerProfile.id,
        clientName: dto.clientName,
        clientPhone: dto.clientPhone,
        deviceModel: dto.deviceModel,
        issueSummary: dto.issueSummary,
        voiceNoteUrl: dto.voiceNoteUrl,
        origin: dto.origin || 'WALK_IN_OFFLINE',
        priceCfa: dto.priceCfa,
        status: 'DEPOSITED',
      },
    });

    await this.whatsappService.sendTicketCreatedNotification(
      dto.clientPhone,
      dto.clientName,
      providerProfile.workshopName,
      dto.deviceModel,
      createdEntry.id,
    );

    const updatedEntry = await this.prisma.workshopEntry.update({
      where: { id: createdEntry.id },
      data: {
        whatsappNotifiedAt: new Date(),
      },
    });

    return updatedEntry;
  }

  /**
   * Met à jour le statut d'une fiche d'atelier.
   * Si le nouveau statut est READY_FOR_PICKUP, déclenche la notification WhatsApp.
   */
  async updateStatus(
    providerUserId: string,
    entryId: string,
    dto: UpdateWorkshopStatusDto,
  ) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const entry = await this.prisma.workshopEntry.findUnique({
      where: { id: entryId },
    });

    if (!entry) {
      throw new NotFoundException("Fiche d'atelier introuvable");
    }

    if (entry.providerId !== providerProfile.id) {
      throw new ForbiddenException(
        "Vous n'êtes pas autorisé à modifier cette fiche d'atelier",
      );
    }

    const dataToUpdate: any = {
      status: dto.status,
    };

    if (dto.priceCfa !== undefined) {
      dataToUpdate.priceCfa = dto.priceCfa;
    }

    if (dto.status === 'READY_FOR_PICKUP') {
      const finalPrice =
        dto.priceCfa !== undefined ? dto.priceCfa : entry.priceCfa;

      await this.whatsappService.sendReadyForPickupNotification(
        entry.clientPhone,
        entry.clientName,
        providerProfile.workshopName,
        entry.deviceModel,
        finalPrice ?? undefined,
      );

      dataToUpdate.whatsappNotifiedAt = new Date();
    }

    return this.prisma.workshopEntry.update({
      where: { id: entryId },
      data: dataToUpdate,
    });
  }

  /**
   * Retourne les statistiques globales de l'atelier du réparateur.
   */
  async getStats(providerUserId: string) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const [
      total,
      deposited,
      diagnostic,
      inRepair,
      readyForPickup,
      delivered,
    ] = await Promise.all([
      this.prisma.workshopEntry.count({
        where: { providerId: providerProfile.id },
      }),
      this.prisma.workshopEntry.count({
        where: { providerId: providerProfile.id, status: 'DEPOSITED' },
      }),
      this.prisma.workshopEntry.count({
        where: { providerId: providerProfile.id, status: 'DIAGNOSTIC' },
      }),
      this.prisma.workshopEntry.count({
        where: { providerId: providerProfile.id, status: 'IN_REPAIR' },
      }),
      this.prisma.workshopEntry.count({
        where: { providerId: providerProfile.id, status: 'READY_FOR_PICKUP' },
      }),
      this.prisma.workshopEntry.count({
        where: { providerId: providerProfile.id, status: 'DELIVERED' },
      }),
    ]);

    return {
      total,
      deposited,
      diagnostic,
      inRepair,
      readyForPickup,
      delivered,
      totalRepaired: readyForPickup + delivered,
      totalDelivered: delivered,
    };
  }
}
