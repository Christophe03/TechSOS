import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../../database/prisma.service';
import { NotFoundException } from '@nestjs/common';

describe('UsersService', () => {
  let service: UsersService;
  let prisma: {
    user: {
      findUnique: jest.Mock;
    };
    providerProfile: {
      findMany: jest.Mock;
    };
  };

  beforeEach(async () => {
    prisma = {
      user: {
        findUnique: jest.fn(),
      },
      providerProfile: {
        findMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('getMe', () => {
    it('doit retourner les données de l utilisateur sans passwordHash avec son profil réparateur', async () => {
      const mockUser = {
        id: 'usr-1',
        phone: '+22370123456',
        email: 'user@techsos.ml',
        passwordHash: '$2b$10$hashedSecured',
        fullName: 'Ibrahim Maiga',
        role: 'PROVIDER',
        city: 'Bamako',
        address: 'ACI 2000',
        avatarUrl: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        providerProfile: {
          id: 'prof-1',
          workshopName: 'Maiga Tech',
          addressZone: 'Hamdallaye ACI 2000',
          ratingAvg: 4.8,
          reviewCount: 15,
        },
      };

      prisma.user.findUnique.mockResolvedValue(mockUser);

      const result = await service.getMe('usr-1');

      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { id: 'usr-1' },
        include: {
          providerProfile: true,
        },
      });

      expect((result as any).passwordHash).toBeUndefined();
      expect(result.id).toBe('usr-1');
      expect(result.fullName).toBe('Ibrahim Maiga');
      expect(result.providerProfile?.workshopName).toBe('Maiga Tech');
    });

    it('doit lever NotFoundException si l utilisateur n existe pas', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      await expect(service.getMe('usr-inconnu')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('findProviders', () => {
    it('doit retourner les réparateurs actifs triés par note moyenne décroissante', async () => {
      const mockProviders = [
        {
          id: 'prof-1',
          workshopName: 'Bamako Réparations Pro',
          addressZone: 'Hamdallaye ACI 2000',
          ratingAvg: 4.9,
          reviewCount: 32,
          subscriptionStatus: 'ACTIVE',
          specialtiesJson: '["cat-phone"]',
          user: {
            id: 'usr-1',
            fullName: 'Moussa Diakité',
            phone: '+22371223344',
            email: 'moussa@reparations.ml',
            city: 'Bamako',
            address: 'Rue 312',
            avatarUrl: null,
          },
        },
        {
          id: 'prof-2',
          workshopName: 'Badalabougou Électronique',
          addressZone: 'Badalabougou',
          ratingAvg: 4.5,
          reviewCount: 12,
          subscriptionStatus: 'FREE_TRIAL',
          specialtiesJson: '["cat-phone", "cat-laptop"]',
          user: {
            id: 'usr-2',
            fullName: 'Aliou Koné',
            phone: '+22372334455',
            email: 'aliou@kone.ml',
            city: 'Bamako',
            address: 'Avenue OUA',
            avatarUrl: null,
          },
        },
      ];

      prisma.providerProfile.findMany.mockResolvedValue(mockProviders);

      const result = await service.findProviders();

      expect(prisma.providerProfile.findMany).toHaveBeenCalledWith({
        where: {
          subscriptionStatus: { in: ['FREE_TRIAL', 'ACTIVE'] },
        },
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

      expect(result).toEqual(mockProviders);
    });

    it('doit filtrer par quartier (zone) et par spécialité', async () => {
      prisma.providerProfile.findMany.mockResolvedValue([]);

      await service.findProviders({
        zone: 'Hamdallaye',
        specialtyId: 'cat-phone',
      });

      expect(prisma.providerProfile.findMany).toHaveBeenCalledWith({
        where: {
          subscriptionStatus: { in: ['FREE_TRIAL', 'ACTIVE'] },
          addressZone: { contains: 'Hamdallaye' },
          specialtiesJson: { contains: 'cat-phone' },
        },
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
    });
  });
});
