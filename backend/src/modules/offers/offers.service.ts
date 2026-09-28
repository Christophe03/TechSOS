import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateOfferDto } from './dto/create-offer.dto';

@Injectable()
export class OffersService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Crée une offre pour une demande de réparation.
   * Vérifie le profil réparateur, l'existence et l'éligibilité de la demande,
   * l'absence d'offre préexistante, met à jour le statut de la demande et retourne l'offre.
   */
  async create(providerUserId: string, repairId: string, dto: CreateOfferDto) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const repair = await this.prisma.repairRequest.findUnique({
      where: { id: repairId },
    });

    if (!repair) {
      throw new NotFoundException('Annonce de panne introuvable');
    }

    if (repair.status !== 'PENDING' && repair.status !== 'OFFERS_RECEIVED') {
      throw new BadRequestException(
        'Impossible de soumettre une offre pour cette demande',
      );
    }

    const existingOffer = await this.prisma.offer.findFirst({
      where: {
        repairRequestId: repairId,
        providerId: providerProfile.id,
      },
    });

    if (existingOffer) {
      throw new ConflictException(
        'Vous avez déjà soumis une offre pour cette annonce',
      );
    }

    const offer = await this.prisma.offer.create({
      data: {
        repairRequestId: repairId,
        providerId: providerProfile.id,
        priceCfa: dto.priceCfa,
        estimatedDuration: dto.estimatedDuration,
        comment: dto.comment,
        status: 'PENDING',
      },
      include: {
        provider: {
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
                avatarUrl: true,
              },
            },
          },
        },
      },
    });

    if (repair.status === 'PENDING') {
      await this.prisma.repairRequest.update({
        where: { id: repairId },
        data: { status: 'OFFERS_RECEIVED' },
      });
    }

    return offer;
  }

  /**
   * Retourne toutes les offres pour une demande de réparation donnée.
   */
  async findByRepair(repairId: string) {
    return this.prisma.offer.findMany({
      where: { repairRequestId: repairId },
      include: {
        provider: {
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                phone: true,
                avatarUrl: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  /**
   * Retourne toutes les offres soumises par un réparateur connecté.
   */
  async findMyOffers(providerUserId: string) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    return this.prisma.offer.findMany({
      where: { providerId: providerProfile.id },
      include: {
        repairRequest: {
          include: {
            category: true,
            issueType: true,
            client: {
              select: {
                id: true,
                fullName: true,
                phone: true,
                city: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  /**
   * Accepte une offre : l'offre passe à ACCEPTED, les autres à REJECTED,
   * et la demande de réparation passe à IN_PROGRESS avec selectedOfferId renseigné.
   */
  async acceptOffer(clientUserId: string, offerId: string) {
    const offer = await this.prisma.offer.findUnique({
      where: { id: offerId },
      include: {
        repairRequest: true,
      },
    });

    if (!offer) {
      throw new NotFoundException('Offre introuvable');
    }

    if (offer.repairRequest.clientId !== clientUserId) {
      throw new ForbiddenException(
        "Vous n'êtes pas autorisé à accepter cette offre",
      );
    }

    if (
      offer.repairRequest.status !== 'PENDING' &&
      offer.repairRequest.status !== 'OFFERS_RECEIVED'
    ) {
      throw new BadRequestException(
        "Cette demande n'est plus en attente d'offres",
      );
    }

    await this.prisma.offer.update({
      where: { id: offerId },
      data: { status: 'ACCEPTED' },
    });

    await this.prisma.offer.updateMany({
      where: {
        repairRequestId: offer.repairRequestId,
        id: { not: offerId },
      },
      data: { status: 'REJECTED' },
    });

    return this.prisma.repairRequest.update({
      where: { id: offer.repairRequestId },
      data: {
        status: 'IN_PROGRESS',
        selectedOfferId: offer.id,
      },
      include: {
        offers: {
          include: {
            provider: {
              include: {
                user: {
                  select: {
                    id: true,
                    fullName: true,
                    phone: true,
                    avatarUrl: true,
                  },
                },
              },
            },
          },
        },
        category: true,
        issueType: true,
      },
    });
  }
}
