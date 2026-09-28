import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

export interface ProviderFilters {
  specialtyId?: string;
  zone?: string;
}

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Récupère le profil complet de l'utilisateur connecté avec son éventuel profil atelier
   */
  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        providerProfile: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }

  /**
   * Retourne l'annuaire des réparateurs actifs et qualifiés à Bamako
   * Triés par note moyenne décroissante (ratingAvg desc)
   */
  async findProviders(filters?: ProviderFilters) {
    const where: any = {
      subscriptionStatus: { in: ['FREE_TRIAL', 'ACTIVE'] },
    };

    if (filters?.zone) {
      where.addressZone = { contains: filters.zone };
    }

    if (filters?.specialtyId) {
      where.specialtiesJson = { contains: filters.specialtyId };
    }

    return this.prisma.providerProfile.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            phone: true,
            email: true,
            city: true,
            address: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: {
        ratingAvg: 'desc',
      },
    });
  }
}
