import { Test, TestingModule } from '@nestjs/testing';
import { ReviewsService } from './reviews.service';
import { PrismaService } from '../../database/prisma.service';
import {
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';

describe('ReviewsService', () => {
  let service: ReviewsService;
  let prisma: {
    repairRequest: {
      findUnique: jest.Mock;
      update: jest.Mock;
    };
    offer: {
      findUnique: jest.Mock;
    };
    review: {
      findUnique: jest.Mock;
      create: jest.Mock;
      aggregate: jest.Mock;
      findMany: jest.Mock;
    };
    providerProfile: {
      update: jest.Mock;
    };
  };

  beforeEach(async () => {
    prisma = {
      repairRequest: {
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      offer: {
        findUnique: jest.fn(),
      },
      review: {
        findUnique: jest.fn(),
        create: jest.fn(),
        aggregate: jest.fn(),
        findMany: jest.fn(),
      },
      providerProfile: {
        update: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReviewsService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<ReviewsService>(ReviewsService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('completeRepair', () => {
    it('doit lever NotFoundException si la demande est introuvable', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue(null);

      await expect(
        service.completeRepair('user-1', 'repair-unknown'),
      ).rejects.toThrow(new NotFoundException('Annonce de panne introuvable'));
    });

    it('doit lever ForbiddenException si l utilisateur n est ni le client ni le réparateur sélectionné', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'IN_PROGRESS',
        offers: [
          {
            id: 'off-1',
            status: 'ACCEPTED',
            provider: { userId: 'prov-user-1' },
          },
        ],
      });

      await expect(
        service.completeRepair('user-intruder', 'rep-1'),
      ).rejects.toThrow(
        new ForbiddenException(
          "Vous n'êtes pas autorisé à marquer cette réparation comme terminée",
        ),
      );
    });

    it('doit lever BadRequestException si la réparation n est pas en cours (IN_PROGRESS)', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'PENDING',
        offers: [],
      });

      await expect(
        service.completeRepair('client-1', 'rep-1'),
      ).rejects.toThrow(
        new BadRequestException(
          'Seule une réparation en cours peut être marquée comme terminée',
        ),
      );
    });

    it('doit permettre au client de marquer la réparation comme COMPLETED', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'IN_PROGRESS',
        offers: [
          {
            id: 'off-1',
            status: 'ACCEPTED',
            provider: { userId: 'prov-user-1' },
          },
        ],
      });
      prisma.repairRequest.update.mockResolvedValue({
        id: 'rep-1',
        status: 'COMPLETED',
      });

      const result = await service.completeRepair('client-1', 'rep-1');

      expect(prisma.repairRequest.update).toHaveBeenCalledWith({
        where: { id: 'rep-1' },
        data: { status: 'COMPLETED' },
      });
      expect(result.status).toBe('COMPLETED');
    });

    it('doit permettre au réparateur retenu de marquer la réparation comme COMPLETED', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'IN_PROGRESS',
        offers: [
          {
            id: 'off-1',
            status: 'ACCEPTED',
            provider: { userId: 'prov-user-1' },
          },
        ],
      });
      prisma.repairRequest.update.mockResolvedValue({
        id: 'rep-1',
        status: 'COMPLETED',
      });

      const result = await service.completeRepair('prov-user-1', 'rep-1');

      expect(prisma.repairRequest.update).toHaveBeenCalledWith({
        where: { id: 'rep-1' },
        data: { status: 'COMPLETED' },
      });
      expect(result.status).toBe('COMPLETED');
    });
  });

  describe('createReview', () => {
    it('doit lever NotFoundException si la demande n existe pas', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue(null);

      await expect(
        service.createReview('client-1', 'rep-unknown', { rating: 5 }),
      ).rejects.toThrow(new NotFoundException('Annonce de panne introuvable'));
    });

    it('doit lever ForbiddenException si l utilisateur n est pas le client de la demande', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-legitime',
        status: 'COMPLETED',
        offers: [{ providerId: 'prov-1' }],
      });

      await expect(
        service.createReview('client-usurpateur', 'rep-1', { rating: 5 }),
      ).rejects.toThrow(
        new ForbiddenException(
          "Vous n'êtes pas autorisé à évaluer cette réparation",
        ),
      );
    });

    it('doit empêcher l évaluation si la réparation n est pas terminée (status !== COMPLETED)', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'IN_PROGRESS',
        offers: [{ providerId: 'prov-1' }],
      });

      await expect(
        service.createReview('client-1', 'rep-1', { rating: 5 }),
      ).rejects.toThrow(
        new BadRequestException(
          "Impossible d'évaluer une réparation non terminée",
        ),
      );
    });

    it('doit lever ConflictException si la réparation a déjà été évaluée', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'COMPLETED',
        offers: [{ providerId: 'prov-1' }],
      });
      prisma.review.findUnique.mockResolvedValue({
        id: 'existing-rev-1',
        repairRequestId: 'rep-1',
        rating: 4,
      });

      await expect(
        service.createReview('client-1', 'rep-1', { rating: 5 }),
      ).rejects.toThrow(
        new ConflictException('Vous avez déjà évalué cette réparation'),
      );
    });

    it('doit enregistrer l avis et recalculer la note moyenne et le nombre d avis du réparateur', async () => {
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'rep-1',
        clientId: 'client-1',
        status: 'COMPLETED',
        offers: [{ providerId: 'prov-1' }],
      });
      prisma.review.findUnique.mockResolvedValue(null);

      const mockCreatedReview = {
        id: 'rev-1',
        repairRequestId: 'rep-1',
        clientId: 'client-1',
        providerId: 'prov-1',
        rating: 5,
        comment: 'Super travail rapide et pro à Hamdallaye !',
      };
      prisma.review.create.mockResolvedValue(mockCreatedReview);

      prisma.review.aggregate.mockResolvedValue({
        _avg: { rating: 4.666666 },
        _count: { rating: 3 },
      });
      prisma.providerProfile.update.mockResolvedValue({
        id: 'prov-1',
        ratingAvg: 4.7,
        reviewCount: 3,
      });

      const result = await service.createReview('client-1', 'rep-1', {
        rating: 5,
        comment: 'Super travail rapide et pro à Hamdallaye !',
      });

      expect(prisma.review.create).toHaveBeenCalledWith({
        data: {
          repairRequestId: 'rep-1',
          clientId: 'client-1',
          providerId: 'prov-1',
          rating: 5,
          comment: 'Super travail rapide et pro à Hamdallaye !',
        },
      });

      expect(prisma.review.aggregate).toHaveBeenCalledWith({
        where: { providerId: 'prov-1' },
        _avg: { rating: true },
        _count: { rating: true },
      });

      expect(prisma.providerProfile.update).toHaveBeenCalledWith({
        where: { id: 'prov-1' },
        data: {
          ratingAvg: 4.7,
          reviewCount: 3,
        },
      });

      expect(result).toEqual(mockCreatedReview);
    });
  });

  describe('findByProvider', () => {
    it('doit retourner les avis reçus par un réparateur ordonnés par date décroissante', async () => {
      const mockReviews = [
        {
          id: 'rev-1',
          rating: 5,
          comment: 'Très sérieux',
          client: { id: 'c-1', fullName: 'Ousmane Sangaré', avatarUrl: null },
          repairRequest: { category: { name: 'Téléphone' } },
        },
      ];

      prisma.review.findMany.mockResolvedValue(mockReviews);

      const result = await service.findByProvider('prov-1');

      expect(prisma.review.findMany).toHaveBeenCalledWith({
        where: { providerId: 'prov-1' },
        include: {
          client: {
            select: {
              id: true,
              fullName: true,
              avatarUrl: true,
            },
          },
          repairRequest: {
            include: {
              category: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      expect(result).toEqual(mockReviews);
    });
  });
});
