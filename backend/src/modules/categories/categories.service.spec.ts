import { Test, TestingModule } from '@nestjs/testing';
import { CategoriesService } from './categories.service';
import { PrismaService } from '../../database/prisma.service';
import { NotFoundException, ConflictException } from '@nestjs/common';

describe('CategoriesService', () => {
  let service: CategoriesService;
  let prisma: {
    deviceCategory: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      create: jest.Mock;
    };
    issueType: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
  };

  beforeEach(async () => {
    prisma = {
      deviceCategory: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
      },
      issueType: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      } as any,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CategoriesService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<CategoriesService>(CategoriesService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('findAllWithIssues', () => {
    it('doit retourner la hiérarchie des catégories avec les pannes officielles triées', async () => {
      const mockResult = [
        {
          id: 'cat-1',
          name: 'Téléphone / Smartphone',
          iconName: 'smartphone',
          sortOrder: 1,
          issueTypes: [
            { id: 'iss-1', name: 'Batterie défaillante', isOfficial: true },
            { id: 'iss-2', name: 'Écran cassé', isOfficial: true },
          ],
        },
      ];

      prisma.deviceCategory.findMany.mockResolvedValue(mockResult);

      const result = await service.findAllWithIssues();

      expect(prisma.deviceCategory.findMany).toHaveBeenCalledWith({
        orderBy: { sortOrder: 'asc' },
        include: {
          issueTypes: {
            where: { isOfficial: true },
            orderBy: { name: 'asc' },
          },
        },
      });
      expect(result).toEqual(mockResult);
    });
  });

  describe('createCategory', () => {
    it('doit créer et persister une nouvelle catégorie', async () => {
      const dto = {
        name: 'Montre connectée',
        iconName: 'watch',
        sortOrder: 6,
      };

      const createdCat = {
        id: 'cat-new',
        ...dto,
        createdAt: new Date(),
      };

      prisma.deviceCategory.findUnique.mockResolvedValue(null);
      prisma.deviceCategory.create.mockResolvedValue(createdCat);

      const result = await service.createCategory(dto);

      expect(prisma.deviceCategory.findUnique).toHaveBeenCalledWith({
        where: { name: dto.name },
      });
      expect(prisma.deviceCategory.create).toHaveBeenCalledWith({
        data: {
          name: dto.name,
          iconName: 'watch',
          sortOrder: 6,
        },
      });
      expect(result).toEqual(createdCat);
    });

    it('doit utiliser les valeurs par défaut si non spécifiées', async () => {
      const dto = {
        name: 'Console de jeu',
      };

      const createdCat = {
        id: 'cat-new-2',
        name: 'Console de jeu',
        iconName: 'devices',
        sortOrder: 0,
        createdAt: new Date(),
      };

      prisma.deviceCategory.findUnique.mockResolvedValue(null);
      prisma.deviceCategory.create.mockResolvedValue(createdCat);

      const result = await service.createCategory(dto);

      expect(prisma.deviceCategory.create).toHaveBeenCalledWith({
        data: {
          name: dto.name,
          iconName: 'devices',
          sortOrder: 0,
        },
      });
      expect(result).toEqual(createdCat);
    });

    it('doit lever ConflictException si une catégorie avec le même nom existe déjà', async () => {
      const dto = {
        name: 'Téléphone / Smartphone',
      };

      prisma.deviceCategory.findUnique.mockResolvedValue({
        id: 'existing-id',
        name: 'Téléphone / Smartphone',
      });

      await expect(service.createCategory(dto)).rejects.toThrow(ConflictException);
      expect(prisma.deviceCategory.create).not.toHaveBeenCalled();
    });
  });

  describe('createIssue', () => {
    it('doit ajouter un type de panne à une catégorie existante', async () => {
      const categoryId = 'cat-1';
      const dto = {
        name: 'Face ID hors service',
        isOfficial: true,
      };

      const createdIssue = {
        id: 'iss-new',
        categoryId,
        name: dto.name,
        isOfficial: true,
        createdAt: new Date(),
      };

      prisma.deviceCategory.findUnique.mockResolvedValue({
        id: categoryId,
        name: 'Téléphone / Smartphone',
      });
      prisma.issueType.create.mockResolvedValue(createdIssue);

      const result = await service.createIssue(categoryId, dto);

      expect(prisma.deviceCategory.findUnique).toHaveBeenCalledWith({
        where: { id: categoryId },
      });
      expect(prisma.issueType.create).toHaveBeenCalledWith({
        data: {
          categoryId,
          name: dto.name,
          isOfficial: true,
        },
      });
      expect(result).toEqual(createdIssue);
    });

    it('doit lever NotFoundException si la catégorie cible n existe pas', async () => {
      const categoryId = 'cat-non-existent';
      const dto = {
        name: 'Panne inconnue',
      };

      prisma.deviceCategory.findUnique.mockResolvedValue(null);

      await expect(service.createIssue(categoryId, dto)).rejects.toThrow(
        NotFoundException,
      );
      expect(prisma.issueType.create).not.toHaveBeenCalled();
    });
  });

  describe('findPendingIssues', () => {
    it('doit retourner les pannes non officielles avec leur catégorie associée', async () => {
      const pendingIssues = [
        {
          id: 'iss-custom-1',
          categoryId: 'cat-1',
          name: 'Bouton volume bloqué',
          isOfficial: false,
          category: { id: 'cat-1', name: 'Téléphone / Smartphone' },
        },
      ];

      prisma.issueType.findMany.mockResolvedValue(pendingIssues);

      const result = await service.findPendingIssues();

      expect(prisma.issueType.findMany).toHaveBeenCalledWith({
        where: { isOfficial: false },
        include: { category: true },
        orderBy: { createdAt: 'desc' },
      });
      expect(result).toEqual(pendingIssues);
    });
  });

  describe('approveIssue', () => {
    it('doit marquer une panne comme officielle', async () => {
      const issueId = 'iss-custom-1';
      const existingIssue = {
        id: issueId,
        name: 'Bouton volume bloqué',
        isOfficial: false,
      };
      const approvedIssue = {
        ...existingIssue,
        isOfficial: true,
      };

      prisma.issueType.findUnique.mockResolvedValue(existingIssue);
      prisma.issueType.update.mockResolvedValue(approvedIssue);

      const result = await service.approveIssue(issueId);

      expect(prisma.issueType.findUnique).toHaveBeenCalledWith({
        where: { id: issueId },
      });
      expect(prisma.issueType.update).toHaveBeenCalledWith({
        where: { id: issueId },
        data: { isOfficial: true },
      });
      expect(result).toEqual(approvedIssue);
    });

    it('doit lever NotFoundException si la panne à approuver n existe pas', async () => {
      const issueId = 'iss-missing';

      prisma.issueType.findUnique.mockResolvedValue(null);

      await expect(service.approveIssue(issueId)).rejects.toThrow(
        NotFoundException,
      );
      expect(prisma.issueType.update).not.toHaveBeenCalled();
    });
  });
});
