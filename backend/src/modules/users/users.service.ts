import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../database/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';

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
   * Met à jour les informations du profil utilisateur et atelier
   */
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const existing = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { providerProfile: true },
    });

    if (!existing) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    // Vérification de l'unicité de l'email s'il est modifié
    if (dto.email && dto.email !== existing.email) {
      const emailTaken = await this.prisma.user.findFirst({
        where: {
          email: dto.email,
          NOT: { id: userId },
        },
      });
      if (emailTaken) {
        throw new ConflictException('Cette adresse email est déjà associée à un autre compte');
      }
    }

    // Mise à jour de la table User
    const userUpdateData: any = {};
    if (dto.fullName !== undefined) userUpdateData.fullName = dto.fullName.trim();
    if (dto.email !== undefined) userUpdateData.email = dto.email.trim();
    if (dto.city !== undefined) userUpdateData.city = dto.city.trim();
    if (dto.address !== undefined) userUpdateData.address = dto.address.trim();

    await this.prisma.user.update({
      where: { id: userId },
      data: userUpdateData,
    });

    // Mise à jour du profil prestataire si des champs atelier sont fournis
    const hasProviderFields =
      dto.workshopName !== undefined ||
      dto.addressZone !== undefined ||
      dto.bio !== undefined;

    if (hasProviderFields) {
      if (existing.providerProfile) {
        const profileUpdateData: any = {};
        if (dto.workshopName !== undefined) profileUpdateData.workshopName = dto.workshopName.trim();
        if (dto.addressZone !== undefined) profileUpdateData.addressZone = dto.addressZone.trim();
        if (dto.bio !== undefined) profileUpdateData.bio = dto.bio.trim();

        await this.prisma.providerProfile.update({
          where: { userId },
          data: profileUpdateData,
        });
      } else if (existing.role === 'PROVIDER') {
        await this.prisma.providerProfile.create({
          data: {
            userId,
            workshopName: dto.workshopName?.trim() || 'Atelier Réparation',
            addressZone: dto.addressZone?.trim() || 'Bamako',
            bio: dto.bio?.trim() || null,
          },
        });
      }
    }

    return this.getMe(userId);
  }

  /**
   * Modifie le mot de passe après vérification du mot de passe actuel
   */
  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Utilisateur introuvable');
    }

    const isMatch = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!isMatch) {
      throw new BadRequestException('Le mot de passe actuel est incorrect');
    }

    const saltRounds = 10;
    const newPasswordHash = await bcrypt.hash(dto.newPassword, saltRounds);

    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newPasswordHash },
    });

    return {
      success: true,
      message: 'Mot de passe modifié avec succès',
    };
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
