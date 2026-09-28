import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { PayMobileMoneyDto } from './dto/pay-mobile-money.dto';

@Injectable()
export class SubscriptionsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Récupère l'état de l'abonnement du réparateur (essai gratuit, actif, expiré) et les dates de validité.
   */
  async getCurrentSubscription(providerUserId: string) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const latestSubscription = await this.prisma.subscription.findFirst({
      where: {
        providerId: providerProfile.id,
        status: 'ACTIVE',
      },
      orderBy: {
        endDate: 'desc',
      },
    });

    const now = new Date();

    if (latestSubscription && latestSubscription.endDate > now) {
      const remainingDays = Math.ceil(
        (latestSubscription.endDate.getTime() - now.getTime()) /
          (1000 * 60 * 60 * 24),
      );

      return {
        status: 'ACTIVE',
        subscriptionStatus: providerProfile.subscriptionStatus,
        planName: latestSubscription.planName,
        amountCfa: latestSubscription.amountCfa,
        startDate: latestSubscription.startDate,
        endDate: latestSubscription.endDate,
        remainingDays,
        subscription: latestSubscription,
      };
    }

    if (providerProfile.subscriptionStatus === 'FREE_TRIAL') {
      return {
        status: 'FREE_TRIAL',
        subscriptionStatus: 'FREE_TRIAL',
        planName: 'Essai Gratuit',
        amountCfa: 0,
        isTrial: true,
        remainingDays: 30,
        subscription: null,
      };
    }

    return {
      status: 'EXPIRED',
      subscriptionStatus: 'EXPIRED',
      planName: 'Standard Pro',
      amountCfa: 5000,
      remainingDays: 0,
      subscription: latestSubscription || null,
    };
  }

  /**
   * Effectue un paiement instantané par Orange Money ou Moov Money (5 000 FCFA / 30 jours).
   * Si un abonnement actif existe déjà, prolonge la durée à partir de la date de fin courante.
   */
  async payMobileMoney(providerUserId: string, dto: PayMobileMoneyDto) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    const now = new Date();

    // Recherche d'un abonnement actif non expiré
    const activeSubscription = await this.prisma.subscription.findFirst({
      where: {
        providerId: providerProfile.id,
        status: 'ACTIVE',
        endDate: { gt: now },
      },
      orderBy: { endDate: 'desc' },
    });

    const startDate = activeSubscription ? activeSubscription.endDate : now;
    const endDate = new Date(startDate.getTime() + 30 * 24 * 60 * 60 * 1000);

    const prefix =
      dto.paymentMethod === 'ORANGE_MONEY' ? 'TECHSOS-OM-' : 'TECHSOS-MOOV-';
    const transactionRef = `${prefix}${Date.now()}-${Math.floor(
      1000 + Math.random() * 9000,
    )}`;

    const subscription = await this.prisma.subscription.create({
      data: {
        providerId: providerProfile.id,
        planName: 'Standard Pro',
        amountCfa: 5000,
        startDate,
        endDate,
        status: 'ACTIVE',
        paymentMethod: dto.paymentMethod,
        transactionRef,
      },
    });

    await this.prisma.providerProfile.update({
      where: { id: providerProfile.id },
      data: { subscriptionStatus: 'ACTIVE' },
    });

    return {
      success: true,
      message: 'Abonnement activé avec succès',
      subscription,
      transactionRef,
    };
  }
}
