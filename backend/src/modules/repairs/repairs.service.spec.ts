import { Test, TestingModule } from '@nestjs/testing';
import { RepairsService } from './repairs.service';
import { PrismaService } from '../../database/prisma.service';
import { NotFoundException, BadRequestException } from '@nestjs/common';

describe('RepairsService', () => {
  let service: RepairsService;
  let prisma: {
    deviceCategory: {
      findUnique: jest.Mock;
    };
    issueType: {
      findUnique: jest.Mock;
      create: jest.Mock;
    };
    repairRequest: {
      create: jest.Mock;
      findMany: jest.Mock;
      findUnique: jest.Mock;
    };
    providerProfile: {
      findUnique: jest.Mock;
    };
  };

  beforeEach(async () => {
    prisma = {
      deviceCategory: {
        findUnique: jest.fn(),
      },
      issueType: {
        findUnique: jest.fn(),
        create: jest.fn(),
      },
      repairRequest: {
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
      },
      providerProfile: {
        findUnique: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RepairsService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<RepairsService>(RepairsService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('doit créer une demande de réparation avec texte, note vocale et photos', async () => {
      const mockCategory = {
        id: 'cat-phones',
        name: 'Téléphone / Smartphone',
      };
      const mockIssue = {
        id: 'issue-screen',
        categoryId: 'cat-phones',
        name: 'Écran cassé',
        isOfficial: true,
      };
      const mockCreatedRepair = {
        id: 'rep-1',
        clientId: 'client-1',
        categoryId: 'cat-phones',
        issueTypeId: 'issue-screen',
        customIssueTitle: null,
        descriptionText: 'Mon écran est brisé après une chute à moto',
        voiceAudioUrl: '/uploads/vocale-1.m4a',
        photoUrlsJson: JSON.stringify([
          '/uploads/photo-1.jpg',
          '/uploads/photo-2.jpg',
        ]),
        status: 'PENDING',
        locationAddress: 'Badalabougou Rue 20',
        category: mockCategory,
        issueType: mockIssue,
      };

      prisma.deviceCategory.findUnique.mockResolvedValue(mockCategory);
      prisma.issueType.findUnique.mockResolvedValue(mockIssue);
      prisma.repairRequest.create.mockResolvedValue(mockCreatedRepair);

      const dto = {
        categoryId: 'cat-phones',
        issueTypeId: 'issue-screen',
        descriptionText: 'Mon écran est brisé après une chute à moto',
        voiceAudioUrl: '/uploads/vocale-1.m4a',
        photoUrls: ['/uploads/photo-1.jpg', '/uploads/photo-2.jpg'],
        locationAddress: 'Badalabougou Rue 20',
      };

      const result = await service.create('client-1', dto);

      expect(prisma.deviceCategory.findUnique).toHaveBeenCalledWith({
        where: { id: 'cat-phones' },
      });
      expect(prisma.issueType.findUnique).toHaveBeenCalledWith({
        where: { id: 'issue-screen' },
      });
      expect(prisma.repairRequest.create).toHaveBeenCalledWith({
        data: {
          clientId: 'client-1',
          categoryId: 'cat-phones',
          issueTypeId: 'issue-screen',
          customIssueTitle: null,
          descriptionText: 'Mon écran est brisé après une chute à moto',
          voiceAudioUrl: '/uploads/vocale-1.m4a',
          photoUrlsJson: JSON.stringify([
            '/uploads/photo-1.jpg',
            '/uploads/photo-2.jpg',
          ]),
          status: 'PENDING',
          locationAddress: 'Badalabougou Rue 20',
        },
        include: {
          category: true,
          issueType: true,
        },
      });

      expect(result).toEqual(mockCreatedRepair);
    });

    it('doit lever NotFoundException si la catégorie est introuvable', async () => {
      prisma.deviceCategory.findUnique.mockResolvedValue(null);

      await expect(
        service.create('client-1', {
          categoryId: 'cat-inexistant',
          descriptionText: 'Panne inconnue',
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('doit lever BadRequestException si l issueTypeId n appartient pas à la catégorie', async () => {
      prisma.deviceCategory.findUnique.mockResolvedValue({
        id: 'cat-phones',
        name: 'Téléphones',
      });
      prisma.issueType.findUnique.mockResolvedValue({
        id: 'issue-printer-paper',
        categoryId: 'cat-printers',
        name: 'Bourrage papier',
      });

      await expect(
        service.create('client-1', {
          categoryId: 'cat-phones',
          issueTypeId: 'issue-printer-paper',
          descriptionText: 'Problème écran',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('doit gérer une panne personnalisée en créant un IssueType non officiel', async () => {
      const mockCategory = {
        id: 'cat-phones',
        name: 'Téléphone / Smartphone',
      };
      const mockCustomIssue = {
        id: 'issue-custom-99',
        categoryId: 'cat-phones',
        name: 'Connecteur USB-C oxydé',
        isOfficial: false,
      };
      const mockCreatedRepair = {
        id: 'rep-2',
        clientId: 'client-1',
        categoryId: 'cat-phones',
        issueTypeId: 'issue-custom-99',
        customIssueTitle: 'Connecteur USB-C oxydé',
        descriptionText: 'Le téléphone ne charge plus',
        voiceAudioUrl: null,
        photoUrlsJson: '[]',
        status: 'PENDING',
        locationAddress: null,
        category: mockCategory,
        issueType: mockCustomIssue,
      };

      prisma.deviceCategory.findUnique.mockResolvedValue(mockCategory);
      prisma.issueType.create.mockResolvedValue(mockCustomIssue);
      prisma.repairRequest.create.mockResolvedValue(mockCreatedRepair);

      const dto = {
        categoryId: 'cat-phones',
        customIssueTitle: 'Connecteur USB-C oxydé',
        descriptionText: 'Le téléphone ne charge plus',
      };

      const result = await service.create('client-1', dto);

      expect(prisma.issueType.create).toHaveBeenCalledWith({
        data: {
          categoryId: 'cat-phones',
          name: 'Connecteur USB-C oxydé',
          isOfficial: false,
        },
      });

      expect(prisma.repairRequest.create).toHaveBeenCalledWith({
        data: {
          clientId: 'client-1',
          categoryId: 'cat-phones',
          issueTypeId: 'issue-custom-99',
          customIssueTitle: 'Connecteur USB-C oxydé',
          descriptionText: 'Le téléphone ne charge plus',
          voiceAudioUrl: null,
          photoUrlsJson: '[]',
          status: 'PENDING',
          locationAddress: null,
        },
        include: {
          category: true,
          issueType: true,
        },
      });

      expect(result.customIssueTitle).toBe('Connecteur USB-C oxydé');
      expect(result.issueTypeId).toBe('issue-custom-99');
    });
  });

  describe('findAll', () => {
    it('doit retourner la liste des réparations avec filtres éventuels', async () => {
      const mockRepairs = [
        {
          id: 'rep-1',
          descriptionText: 'Écran cassé',
          status: 'PENDING',
          category: { name: 'Téléphones' },
          issueType: { name: 'Écran' },
          client: {
            id: 'c-1',
            fullName: 'Fanta Touré',
            phone: '+22370001122',
            city: 'Bamako',
          },
          _count: { offers: 2 },
        },
      ];

      prisma.repairRequest.findMany.mockResolvedValue(mockRepairs);

      const result = await service.findAll({
        categoryId: 'cat-1',
        status: 'PENDING',
      });

      expect(prisma.repairRequest.findMany).toHaveBeenCalledWith({
        where: {
          categoryId: 'cat-1',
          status: 'PENDING',
        },
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

      expect(result).toEqual(mockRepairs);
    });
  });

  describe('findFeedForProvider', () => {
    it('doit filtrer le feed selon les spécialités du réparateur pour les demandes PENDING et OFFERS_RECEIVED', async () => {
      const mockProfile = {
        id: 'prof-1',
        userId: 'prov-user-1',
        specialtiesJson: JSON.stringify(['cat-phones', 'issue-laptop-screen']),
      };

      const mockFeed = [
        {
          id: 'rep-1',
          categoryId: 'cat-phones',
          issueTypeId: null,
          status: 'PENDING',
        },
        {
          id: 'rep-2',
          categoryId: 'cat-laptops',
          issueTypeId: 'issue-laptop-screen',
          status: 'OFFERS_RECEIVED',
        },
      ];

      prisma.providerProfile.findUnique.mockResolvedValue(mockProfile);
      prisma.repairRequest.findMany.mockResolvedValue(mockFeed);

      const result = await service.findFeedForProvider('prov-user-1');

      expect(prisma.providerProfile.findUnique).toHaveBeenCalledWith({
        where: { userId: 'prov-user-1' },
      });

      expect(prisma.repairRequest.findMany).toHaveBeenCalledWith({
        where: {
          status: { in: ['PENDING', 'OFFERS_RECEIVED'] },
          OR: [
            { categoryId: { in: ['cat-phones', 'issue-laptop-screen'] } },
            { issueTypeId: { in: ['cat-phones', 'issue-laptop-screen'] } },
          ],
        },
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

      expect(result).toEqual(mockFeed);
    });

    it('doit retourner toutes les demandes sans filtre OR si les spécialités sont vides', async () => {
      const mockProfile = {
        id: 'prof-2',
        userId: 'prov-user-2',
        specialtiesJson: '[]',
      };

      prisma.providerProfile.findUnique.mockResolvedValue(mockProfile);
      prisma.repairRequest.findMany.mockResolvedValue([]);

      await service.findFeedForProvider('prov-user-2');

      expect(prisma.repairRequest.findMany).toHaveBeenCalledWith({
        where: {
          status: { in: ['PENDING', 'OFFERS_RECEIVED'] },
        },
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
    });

    it('doit lever NotFoundException si le profil réparateur n existe pas', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(
        service.findFeedForProvider('prov-inconnu'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('findMyRequests', () => {
    it('doit retourner les demandes du client avec les offres et le compteur', async () => {
      const mockMyRequests = [
        {
          id: 'rep-1',
          clientId: 'client-1',
          descriptionText: 'Batterie iPhone',
          status: 'PENDING',
          category: { name: 'Téléphones' },
          issueType: { name: 'Batterie' },
          offers: [
            {
              id: 'off-1',
              priceCfa: 15000,
              estimatedDuration: '1h',
              provider: {
                workshopName: 'Bamako Réparations',
                user: {
                  id: 'prov-1',
                  fullName: 'Amadou Sanogo',
                  phone: '+22376001122',
                  avatarUrl: null,
                },
              },
            },
          ],
          _count: { offers: 1 },
        },
      ];

      prisma.repairRequest.findMany.mockResolvedValue(mockMyRequests);

      const result = await service.findMyRequests('client-1');

      expect(prisma.repairRequest.findMany).toHaveBeenCalledWith({
        where: { clientId: 'client-1' },
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

      expect(result).toEqual(mockMyRequests);
    });
  });

  describe('findById', () => {
    it('doit retourner les détails complets de la demande avec offres et réparateurs', async () => {
      const mockRepair = {
        id: 'rep-1',
        clientId: 'client-1',
        descriptionText: 'Changement vitre arrière',
        category: { id: 'cat-1', name: 'Téléphone' },
        issueType: { id: 'iss-1', name: 'Vitre arrière' },
        client: {
          id: 'client-1',
          fullName: 'Sékou Traoré',
          phone: '+22370112233',
          city: 'Bamako',
          address: 'Hamdallaye',
          avatarUrl: null,
        },
        offers: [],
      };

      prisma.repairRequest.findUnique.mockResolvedValue(mockRepair);

      const result = await service.findById('rep-1');

      expect(prisma.repairRequest.findUnique).toHaveBeenCalledWith({
        where: { id: 'rep-1' },
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

      expect(result).toEqual(mockRepair);
    });

    it('doit lever NotFoundException("Annonce de panne introuvable") si la demande n existe pas', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue(null);

      await expect(service.findById('rep-inconnu')).rejects.toThrow(
        new NotFoundException('Annonce de panne introuvable'),
      );
    });
  });
});
