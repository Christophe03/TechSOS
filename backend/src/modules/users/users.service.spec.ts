import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../../database/prisma.service';
import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('UsersService', () => {
  let service: UsersService;
  let prisma: {
    user: {
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      update: jest.Mock;
    };
    providerProfile: {
      findMany: jest.Mock;
      update: jest.Mock;
      create: jest.Mock;
    };
  };

  beforeEach(async () => {
    prisma = {
      user: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      providerProfile: {
        findMany: jest.fn(),
        update: jest.fn(),
        create: jest.fn(),
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

  describe('updateProfile', () => {
    it('doit mettre à jour les infos du client avec succès', async () => {
      const existingUser = {
        id: 'usr-1',
        fullName: 'Amadou Client',
        email: 'amadou@test.ml',
        city: 'Bamako',
        address: 'Kalaban Coura',
        providerProfile: null,
      };

      prisma.user.findUnique.mockResolvedValue(existingUser);
      prisma.user.update.mockResolvedValue({
        ...existingUser,
        fullName: 'Amadou Nouveau Nom',
        address: 'Badalabougou Rue 10',
      });

      const updated = await service.updateProfile('usr-1', {
        fullName: 'Amadou Nouveau Nom',
        address: 'Badalabougou Rue 10',
      });

      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'usr-1' },
        data: {
          fullName: 'Amadou Nouveau Nom',
          address: 'Badalabougou Rue 10',
        },
      });
      expect(updated).toBeDefined();
    });

    it('doit mettre à jour le profil atelier du réparateur', async () => {
      const existingProvider = {
        id: 'prov-1',
        role: 'PROVIDER',
        fullName: 'Moussa Réparateur',
        email: 'moussa@atelier.ml',
        city: 'Bamako',
        address: 'ACI 2000',
        providerProfile: {
          id: 'prof-1',
          workshopName: 'Ancien Atelier',
          addressZone: 'ACI 2000',
          bio: 'Ancienne bio',
        },
      };

      prisma.user.findUnique.mockResolvedValue(existingProvider);
      prisma.user.update.mockResolvedValue(existingProvider);
      prisma.providerProfile.update.mockResolvedValue({
        ...existingProvider.providerProfile,
        workshopName: 'Nouvel Atelier Tech',
        addressZone: 'Lafiabougou',
      });

      await service.updateProfile('prov-1', {
        workshopName: 'Nouvel Atelier Tech',
        addressZone: 'Lafiabougou',
      });

      expect(prisma.providerProfile.update).toHaveBeenCalledWith({
        where: { userId: 'prov-1' },
        data: {
          workshopName: 'Nouvel Atelier Tech',
          addressZone: 'Lafiabougou',
        },
      });
    });

    it('doit refuser si l email est déjà pris par un autre compte', async () => {
      prisma.user.findUnique.mockResolvedValue({
        id: 'usr-1',
        email: 'monemail@test.ml',
      });
      prisma.user.findFirst.mockResolvedValue({
        id: 'usr-2',
        email: 'pris@test.ml',
      });

      await expect(
        service.updateProfile('usr-1', { email: 'pris@test.ml' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('changePassword', () => {
    it('doit modifier le mot de passe quand le mot de passe actuel est valide', async () => {
      const oldPass = 'oldPassword123';
      const oldHash = await bcrypt.hash(oldPass, 10);
      const user = {
        id: 'usr-1',
        passwordHash: oldHash,
      };

      prisma.user.findUnique.mockResolvedValue(user);
      prisma.user.update.mockResolvedValue(user);

      const result = await service.changePassword('usr-1', {
        currentPassword: 'oldPassword123',
        newPassword: 'newSecurePassword456',
      });

      expect(result.success).toBe(true);
      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'usr-1' },
        data: expect.objectContaining({
          passwordHash: expect.any(String),
        }),
      });

      const updatedHash = prisma.user.update.mock.calls[0][0].data.passwordHash;
      expect(await bcrypt.compare('newSecurePassword456', updatedHash)).toBe(true);
    });

    it('doit lever BadRequestException si le mot de passe actuel est erroné', async () => {
      const oldHash = await bcrypt.hash('correctPassword', 10);
      prisma.user.findUnique.mockResolvedValue({
        id: 'usr-1',
        passwordHash: oldHash,
      });

      await expect(
        service.changePassword('usr-1', {
          currentPassword: 'wrongPassword',
          newPassword: 'newSecurePassword456',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});

