import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateIssueDto } from './dto/create-issue.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Retourne toutes les catégories ordonnées par sortOrder croissant,
   * avec les types de pannes officielles associées ordonnées par nom.
   */
  async findAllWithIssues() {
    return this.prisma.deviceCategory.findMany({
      orderBy: { sortOrder: 'asc' },
      include: {
        issueTypes: {
          where: { isOfficial: true },
          orderBy: { name: 'asc' },
        },
      },
    });
  }

  /**
   * Crée une nouvelle catégorie d'appareil.
   */
  async createCategory(dto: CreateCategoryDto) {
    const existing = await this.prisma.deviceCategory.findUnique({
      where: { name: dto.name },
    });

    if (existing) {
      throw new ConflictException(
        `Une catégorie avec le nom "${dto.name}" existe déjà`,
      );
    }

    return this.prisma.deviceCategory.create({
      data: {
        name: dto.name,
        iconName: dto.iconName ?? 'devices',
        sortOrder: dto.sortOrder ?? 0,
      },
    });
  }

  /**
   * Crée un type de panne associé à une catégorie donnée.
   */
  async createIssue(categoryId: string, dto: CreateIssueDto) {
    const category = await this.prisma.deviceCategory.findUnique({
      where: { id: categoryId },
    });

    if (!category) {
      throw new NotFoundException(
        `Catégorie introuvable avec l'ID: ${categoryId}`,
      );
    }

    return this.prisma.issueType.create({
      data: {
        categoryId,
        name: dto.name,
        isOfficial: dto.isOfficial !== undefined ? dto.isOfficial : true,
      },
    });
  }

  /**
   * Retourne tous les types de pannes non officielles (créées librement par les utilisateurs),
   * en attente de modération, avec la catégorie associée.
   */
  async findPendingIssues() {
    return this.prisma.issueType.findMany({
      where: { isOfficial: false },
      include: {
        category: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Valide un type de panne en le rendant officiel.
   */
  async approveIssue(issueId: string) {
    const issue = await this.prisma.issueType.findUnique({
      where: { id: issueId },
    });

    if (!issue) {
      throw new NotFoundException(
        `Type de panne introuvable avec l'ID: ${issueId}`,
      );
    }

    return this.prisma.issueType.update({
      where: { id: issueId },
      data: { isOfficial: true },
    });
  }
}
