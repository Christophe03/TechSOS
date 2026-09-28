import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Marque une réparation en cours comme terminée (COMPLETED).
   * Accessible par le client propriétaire ou le réparateur retenu.
   */
  async completeRepair(userId: string, repairId: string) {
    const repair = await this.prisma.repairRequest.findUnique({
      where: { id: repairId },
      include: {
        offers: {
          where: { status: 'ACCEPTED' },
          include: {
            provider: true,
          },
        },
      },
    });

    if (!repair) {
      throw new NotFoundException('Annonce de panne introuvable');
    }

    const isClient = repair.clientId === userId;
    const acceptedOffer = repair.offers[0];
    const isSelectedProvider = acceptedOffer?.provider?.userId === userId;

    if (!isClient && !isSelectedProvider) {
      throw new ForbiddenException(
        "Vous n'êtes pas autorisé à marquer cette réparation comme terminée",
      );
    }

    if (repair.status !== 'IN_PROGRESS') {
      throw new BadRequestException(
        'Seule une réparation en cours peut être marquée comme terminée',
      );
    }

    return this.prisma.repairRequest.update({
      where: { id: repairId },
      data: { status: 'COMPLETED' },
    });
  }

  /**
   * Crée un avis (1 à 5 étoiles) pour une réparation terminée.
   * Vérifie le propriétaire, l'état COMPLETED, l'absence d'avis préalable,
   * enregistre l'avis et recalcule la note moyenne et le nombre d'avis du réparateur.
   */
  async createReview(
    clientUserId: string,
    repairId: string,
    dto: CreateReviewDto,
  ) {
    const repair = await this.prisma.repairRequest.findUnique({
      where: { id: repairId },
      include: {
        offers: {
          where: { status: 'ACCEPTED' },
        },
      },
    });

    if (!repair) {
      throw new NotFoundException('Annonce de panne introuvable');
    }

    if (repair.clientId !== clientUserId) {
      throw new ForbiddenException(
        "Vous n'êtes pas autorisé à évaluer cette réparation",
      );
    }

    if (repair.status !== 'COMPLETED') {
      throw new BadRequestException(
        "Impossible d'évaluer une réparation non terminée",
      );
    }

    let providerId = repair.offers[0]?.providerId;
    if (!providerId && repair.selectedOfferId) {
      const selectedOffer = await this.prisma.offer.findUnique({
        where: { id: repair.selectedOfferId },
      });
      if (selectedOffer) {
        providerId = selectedOffer.providerId;
      }
    }

    if (!providerId) {
      throw new BadRequestException(
        'Aucun réparateur sélectionné pour cette réparation',
      );
    }

    const existingReview = await this.prisma.review.findUnique({
      where: { repairRequestId: repairId },
    });

    if (existingReview) {
      throw new ConflictException('Vous avez déjà évalué cette réparation');
    }

    const review = await this.prisma.review.create({
      data: {
        repairRequestId: repairId,
        clientId: clientUserId,
        providerId,
        rating: dto.rating,
        comment: dto.comment,
      },
    });

    // Recalcul de la réputation du réparateur
    const aggregate = await this.prisma.review.aggregate({
      where: { providerId },
      _avg: { rating: true },
      _count: { rating: true },
    });

    const avg = aggregate._avg?.rating ?? dto.rating;
    const count = aggregate._count?.rating ?? 1;
    const ratingAvg = Math.round(avg * 10) / 10;

    await this.prisma.providerProfile.update({
      where: { id: providerId },
      data: {
        ratingAvg,
        reviewCount: count,
      },
    });

    return review;
  }

  /**
   * Retourne tous les avis reçus par un réparateur, triés par date décroissante.
   */
  async findByProvider(providerId: string) {
    return this.prisma.review.findMany({
      where: { providerId },
      include: {
        client: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true,
          },
        },
        repairRequest: {
          include: {
            category: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }
}
