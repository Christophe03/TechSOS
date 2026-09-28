import { Test, TestingModule } from '@nestjs/testing';
import { SubscriptionsService } from './subscriptions.service';
import { PrismaService } from '../../database/prisma.service';
import { NotFoundException } from '@nestjs/common';
import { PayMobileMoneyDto } from './dto/pay-mobile-money.dto';

describe('SubscriptionsService', () => {
  let service: SubscriptionsService;
  let prisma: {
    providerProfile: {
      findUnique: jest.Mock;
      update: jest.Mock;
    };
    subscription: {
      findFirst: jest.Mock;
      create: jest.Mock;
    };
  };

  const mockProvider = {
    id: 'prov-profile-1',
    userId: 'user-prov-1',
    workshopName: 'Atelier Hamdallaye',
    subscriptionStatus: 'FREE_TRIAL',
  };

  beforeEach(async () => {
    prisma = {
      providerProfile: {
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      subscription: {
        findFirst: jest.fn(),
        create: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SubscriptionsService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<SubscriptionsService>(SubscriptionsService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('getCurrentSubscription', () => {
    it('doit lever NotFoundException si le profil réparateur est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(
        service.getCurrentSubscription('unknown-user'),
      ).rejects.toThrow(new NotFoundException('Profil réparateur introuvable'));
    });

    it('doit retourner le statut FREE_TRIAL si aucun abonnement actif et profil en essai', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue({
        ...mockProvider,
        subscriptionStatus: 'FREE_TRIAL',
      });
      prisma.subscription.findFirst.mockResolvedValue(null);

      const result = await service.getCurrentSubscription('user-prov-1');

      expect(result.status).toBe('FREE_TRIAL');
      expect(result.planName).toBe('Essai Gratuit');
      expect(result.amountCfa).toBe(0);
      expect(result.isTrial).toBe(true);
    });

    it('doit retourner le statut ACTIVE avec le nombre de jours restants', async () => {
      const futureDate = new Date(Date.now() + 15 * 24 * 60 * 60 * 1000);
      const startDate = new Date(Date.now() - 15 * 24 * 60 * 60 * 1000);

      prisma.providerProfile.findUnique.mockResolvedValue({
        ...mockProvider,
        subscriptionStatus: 'ACTIVE',
      });

      const mockSubscription = {
        id: 'sub-1',
        providerId: mockProvider.id,
        planName: 'Standard Pro',
        amountCfa: 5000,
        startDate,
        endDate: futureDate,
        status: 'ACTIVE',
        paymentMethod: 'ORANGE_MONEY',
        transactionRef: 'TECHSOS-OM-12345',
      };

      prisma.subscription.findFirst.mockResolvedValue(mockSubscription);

      const result = await service.getCurrentSubscription('user-prov-1');

      expect(result.status).toBe('ACTIVE');
      expect(result.remainingDays).toBeGreaterThanOrEqual(14);
      expect(result.remainingDays).toBeLessThanOrEqual(16);
      expect(result.amountCfa).toBe(5000);
      expect(result.subscription).toEqual(mockSubscription);
    });

    it('doit retourner le statut EXPIRED si l abonnement précédent est terminé', async () => {
      const pastDate = new Date(Date.now() - 5 * 24 * 60 * 60 * 1000);

      prisma.providerProfile.findUnique.mockResolvedValue({
        ...mockProvider,
        subscriptionStatus: 'EXPIRED',
      });

      prisma.subscription.findFirst.mockResolvedValue({
        id: 'sub-old',
        providerId: mockProvider.id,
        planName: 'Standard Pro',
        amountCfa: 5000,
        endDate: pastDate,
        status: 'ACTIVE',
      });

      const result = await service.getCurrentSubscription('user-prov-1');

      expect(result.status).toBe('EXPIRED');
      expect(result.remainingDays).toBe(0);
    });
  });

  describe('payMobileMoney', () => {
    it('doit lever NotFoundException si le réparateur est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      const dto: PayMobileMoneyDto = {
        phoneNumber: '+22370123456',
        paymentMethod: 'ORANGE_MONEY',
      };

      await expect(
        service.payMobileMoney('unknown-user', dto),
      ).rejects.toThrow(new NotFoundException('Profil réparateur introuvable'));
    });

    it('doit traiter un paiement Orange Money (5 000 FCFA, 30 jours, ref TECHSOS-OM-*)', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      prisma.subscription.findFirst.mockResolvedValue(null); // pas d'abonnement actif

      prisma.subscription.create.mockImplementation(({ data }) =>
        Promise.resolve({
          id: 'sub-new-1',
          ...data,
        }),
      );

      prisma.providerProfile.update.mockResolvedValue({
        ...mockProvider,
        subscriptionStatus: 'ACTIVE',
      });

      const dto: PayMobileMoneyDto = {
        phoneNumber: '+22370123456',
        paymentMethod: 'ORANGE_MONEY',
      };

      const result = await service.payMobileMoney('user-prov-1', dto);

      expect(result.success).toBe(true);
      expect(result.transactionRef).toMatch(/^TECHSOS-OM-/);
      expect(prisma.subscription.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          providerId: mockProvider.id,
          planName: 'Standard Pro',
          amountCfa: 5000,
          status: 'ACTIVE',
          paymentMethod: 'ORANGE_MONEY',
          transactionRef: expect.stringMatching(/^TECHSOS-OM-/),
        }),
      });

      expect(prisma.providerProfile.update).toHaveBeenCalledWith({
        where: { id: mockProvider.id },
        data: { subscriptionStatus: 'ACTIVE' },
      });
    });

    it('doit traiter un paiement Moov Money (ref TECHSOS-MOOV-*)', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      prisma.subscription.findFirst.mockResolvedValue(null);

      prisma.subscription.create.mockImplementation(({ data }) =>
        Promise.resolve({
          id: 'sub-new-2',
          ...data,
        }),
      );

      const dto: PayMobileMoneyDto = {
        phoneNumber: '+22366112233',
        paymentMethod: 'MOOV_MONEY',
      };

      const result = await service.payMobileMoney('user-prov-1', dto);

      expect(result.success).toBe(true);
      expect(result.transactionRef).toMatch(/^TECHSOS-MOOV-/);
      expect(prisma.subscription.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          paymentMethod: 'MOOV_MONEY',
          transactionRef: expect.stringMatching(/^TECHSOS-MOOV-/),
        }),
      });
    });

    it('doit prolonger la période d abonnement si un abonnement actif existe déjà', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue({
        ...mockProvider,
        subscriptionStatus: 'ACTIVE',
      });

      // Abonnement actif expirant dans 10 jours
      const existingEndDate = new Date(Date.now() + 10 * 24 * 60 * 60 * 1000);
      prisma.subscription.findFirst.mockResolvedValue({
        id: 'sub-existing',
        providerId: mockProvider.id,
        endDate: existingEndDate,
        status: 'ACTIVE',
      });

      prisma.subscription.create.mockImplementation(({ data }) =>
        Promise.resolve({
          id: 'sub-extended',
          ...data,
        }),
      );

      const dto: PayMobileMoneyDto = {
        phoneNumber: '+22370123456',
        paymentMethod: 'ORANGE_MONEY',
      };

      const result = await service.payMobileMoney('user-prov-1', dto);

      expect(result.success).toBe(true);
      expect(prisma.subscription.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          startDate: existingEndDate,
          endDate: new Date(
            existingEndDate.getTime() + 30 * 24 * 60 * 60 * 1000,
          ),
        }),
      });
    });
  });
});
