import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateRepairDto } from './dto/create-repair.dto';

export interface RepairFilters {
  categoryId?: string;
  status?: string;
}

@Injectable()
export class RepairsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Crée une nouvelle demande de réparation (SOS panne).
   * Vérifie la catégorie, valide l'issueTypeId ou crée un IssueType non officiel à partir de customIssueTitle,
   * enregistre la note vocale et les photos éventuelles.
   */
  async create(clientId: string, dto: CreateRepairDto) {
    const category = await this.prisma.deviceCategory.findUnique({
      where: { id: dto.categoryId },
    });

    if (!category) {
      throw new NotFoundException(
        `Catégorie introuvable avec l'ID: ${dto.categoryId}`,
      );
    }

    let resolvedIssueTypeId = dto.issueTypeId;

    if (dto.issueTypeId) {
      const issueType = await this.prisma.issueType.findUnique({
        where: { id: dto.issueTypeId },
      });

      if (!issueType || issueType.categoryId !== dto.categoryId) {
        throw new BadRequestException(
          "Le type de panne sélectionné est invalide ou n'appartient pas à cette catégorie",
        );
      }
    } else if (dto.customIssueTitle && dto.customIssueTitle.trim().length > 0) {
      const customIssue = await this.prisma.issueType.create({
        data: {
          categoryId: dto.categoryId,
          name: dto.customIssueTitle.trim(),
          isOfficial: false,
        },
      });
      resolvedIssueTypeId = customIssue.id;
    }

    const photoUrlsJson = JSON.stringify(dto.photoUrls || []);

    return this.prisma.repairRequest.create({
      data: {
        clientId,
        categoryId: dto.categoryId,
        issueTypeId: resolvedIssueTypeId,
        customIssueTitle: dto.customIssueTitle?.trim() || null,
        descriptionText: dto.descriptionText,
        voiceAudioUrl: dto.voiceAudioUrl || null,
        photoUrlsJson,
        status: 'PENDING',
        locationAddress: dto.locationAddress || null,
      },
      include: {
        category: true,
        issueType: true,
      },
    });
  }

  /**
   * Retourne la liste générale des demandes de réparation filtrable,
   * triée par createdAt décroissant avec catégorie, type de panne, client sécurisé et nombre d'offres.
   */
  async findAll(filters?: RepairFilters) {
    const where: any = {};

    if (filters?.categoryId) {
      where.categoryId = filters.categoryId;
    }

    if (filters?.status) {
      where.status = filters.status;
    }

    return this.prisma.repairRequest.findMany({
      where,
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
        _count: {
          select: { offers: true },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  /**
   * Retourne le flux d'opportunités de dépannage personnalisé pour un réparateur
   * basé sur ses spécialités enregistrées et les statuts PENDING / OFFERS_RECEIVED.
   */
  async findFeedForProvider(providerUserId: string) {
    const providerProfile = await this.prisma.providerProfile.findUnique({
      where: { userId: providerUserId },
    });

    if (!providerProfile) {
      throw new NotFoundException('Profil réparateur introuvable');
    }

    let specialties: string[] = [];
    if (providerProfile.specialtiesJson) {
      try {
        const parsed = JSON.parse(providerProfile.specialtiesJson);
        if (Array.isArray(parsed)) {
          specialties = parsed;
        }
      } catch {
        specialties = [];
      }
    }

    const where: any = {
      status: { in: ['PENDING', 'OFFERS_RECEIVED'] },
    };

    if (specialties.length > 0) {
      where.OR = [
        { categoryId: { in: specialties } },
        { issueTypeId: { in: specialties } },
      ];
    }

    return this.prisma.repairRequest.findMany({
      where,
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
        _count: {
          select: { offers: true },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  /**
   * Retourne toutes les demandes créées par un client avec les offres reçues.
   */
  async findMyRequests(clientId: string) {
    return this.prisma.repairRequest.findMany({
      where: { clientId },
      include: {
        category: true,
        issueType: true,
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
          orderBy: { createdAt: 'desc' },
        },
        _count: {
          select: { offers: true },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  /**
   * Retourne le détail complet d'une demande par son identifiant.
   * Lève une NotFoundException avec le message exact si non trouvée.
   */
  async findById(id: string) {
    const repair = await this.prisma.repairRequest.findUnique({
      where: { id },
      include: {
        category: true,
        issueType: true,
        client: {
          select: {
            id: true,
            fullName: true,
            phone: true,
            city: true,
            address: true,
            avatarUrl: true,
          },
        },
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
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!repair) {
      throw new NotFoundException('Annonce de panne introuvable');
    }

    return repair;
  }
}
