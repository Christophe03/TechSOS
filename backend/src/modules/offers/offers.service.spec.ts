import { Test, TestingModule } from '@nestjs/testing';
import { OffersService } from './offers.service';
import { PrismaService } from '../../database/prisma.service';
import {
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';

describe('OffersService', () => {
  let service: OffersService;
  let prisma: {
    providerProfile: {
      findUnique: jest.Mock;
    };
    repairRequest: {
      findUnique: jest.Mock;
      update: jest.Mock;
    };
    offer: {
      findFirst: jest.Mock;
      create: jest.Mock;
      findMany: jest.Mock;
      findUnique: jest.Mock;
      update: jest.Mock;
      updateMany: jest.Mock;
    };
  };

  beforeEach(async () => {
    prisma = {
      providerProfile: {
        findUnique: jest.fn(),
      },
      repairRequest: {
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      offer: {
        findFirst: jest.fn(),
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OffersService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<OffersService>(OffersService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('doit lever NotFoundException si le profil réparateur est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(
        service.create('prov-user-unknown', 'repair-1', {
          priceCfa: 15000,
          estimatedDuration: '2 heures',
        }),
      ).rejects.toThrow(new NotFoundException('Profil réparateur introuvable'));
    });

    it('doit lever NotFoundException si l annonce de panne est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue({
        id: 'prov-prof-1',
        userId: 'prov-user-1',
      });
      prisma.repairRequest.findUnique.mockResolvedValue(null);

      await expect(
        service.create('prov-user-1', 'repair-unknown', {
          priceCfa: 15000,
          estimatedDuration: '2 heures',
        }),
      ).rejects.toThrow(new NotFoundException('Annonce de panne introuvable'));
    });

    it('doit lever BadRequestException si l annonce n est ni PENDING ni OFFERS_RECEIVED', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue({
        id: 'prov-prof-1',
        userId: 'prov-user-1',
      });
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'repair-1',
        status: 'IN_PROGRESS',
      });

      await expect(
        service.create('prov-user-1', 'repair-1', {
          priceCfa: 15000,
          estimatedDuration: '2 heures',
        }),
      ).rejects.toThrow(
        new BadRequestException(
          'Impossible de soumettre une offre pour cette demande',
        ),
      );
    });

    it('doit lever ConflictException si le réparateur a déjà soumis une offre pour cette annonce', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue({
        id: 'prov-prof-1',
        userId: 'prov-user-1',
      });
      prisma.repairRequest.findUnique.mockResolvedValue({
        id: 'repair-1',
        status: 'PENDING',
      });
      prisma.offer.findFirst.mockResolvedValue({
        id: 'existing-offer-1',
        providerId: 'prov-prof-1',
        repairRequestId: 'repair-1',
      });

      await expect(
        service.create('prov-user-1', 'repair-1', {
          priceCfa: 15000,
          estimatedDuration: '2 heures',
        }),
      ).rejects.toThrow(
        new ConflictException(
          'Vous avez déjà soumis une offre pour cette annonce',
        ),
      );
    });

    it('doit soumettre une offre et changer le statut de la demande de PENDING à OFFERS_RECEIVED', async () => {
      const mockProfile = {
        id: 'prov-prof-1',
        userId: 'prov-user-1',
        workshopName: 'Atelier Bamako Tech',
      };
      const mockRepair = {
        id: 'repair-1',
        status: 'PENDING',
      };
      const mockCreatedOffer = {
        id: 'offer-1',
        repairRequestId: 'repair-1',
        providerId: 'prov-prof-1',
        priceCfa: 25000,
        estimatedDuration: '24h',
        comment: 'Pièce d origine disponible immédiatement',
        status: 'PENDING',
        provider: {
          workshopName: 'Atelier Bamako Tech',
          user: {
            id: 'prov-user-1',
            fullName: 'Bakary Diallo',
            phone: '+22370123456',
            avatarUrl: null,
          },
        },
      };

      prisma.providerProfile.findUnique.mockResolvedValue(mockProfile);
      prisma.repairRequest.findUnique.mockResolvedValue(mockRepair);
      prisma.offer.findFirst.mockResolvedValue(null);
      prisma.offer.create.mockResolvedValue(mockCreatedOffer);
      prisma.repairRequest.update.mockResolvedValue({
        ...mockRepair,
        status: 'OFFERS_RECEIVED',
      });

      const dto = {
        priceCfa: 25000,
        estimatedDuration: '24h',
        comment: 'Pièce d origine disponible immédiatement',
      };

      const result = await service.create('prov-user-1', 'repair-1', dto);

      expect(prisma.offer.create).toHaveBeenCalledWith({
        data: {
          repairRequestId: 'repair-1',
          providerId: 'prov-prof-1',
          priceCfa: 25000,
          estimatedDuration: '24h',
          comment: 'Pièce d origine disponible immédiatement',
          status: 'PENDING',
        },
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
      });

      expect(prisma.repairRequest.update).toHaveBeenCalledWith({
        where: { id: 'repair-1' },
        data: { status: 'OFFERS_RECEIVED' },
      });

      expect(result).toEqual(mockCreatedOffer);
    });

    it('ne doit pas mettre à jour le statut si la demande est déjà en OFFERS_RECEIVED', async () => {
      const mockProfile = {
        id: 'prov-prof-2',
        userId: 'prov-user-2',
      };
      const mockRepair = {
        id: 'repair-2',
        status: 'OFFERS_RECEIVED',
      };
      const mockCreatedOffer = {
        id: 'offer-2',
        repairRequestId: 'repair-2',
        providerId: 'prov-prof-2',
        priceCfa: 18000,
        estimatedDuration: '2 jours',
        status: 'PENDING',
      };

      prisma.providerProfile.findUnique.mockResolvedValue(mockProfile);
      prisma.repairRequest.findUnique.mockResolvedValue(mockRepair);
      prisma.offer.findFirst.mockResolvedValue(null);
      prisma.offer.create.mockResolvedValue(mockCreatedOffer);

      const result = await service.create('prov-user-2', 'repair-2', {
        priceCfa: 18000,
        estimatedDuration: '2 jours',
      });

      expect(prisma.repairRequest.update).not.toHaveBeenCalled();
      expect(result).toEqual(mockCreatedOffer);
    });
  });

  describe('findByRepair', () => {
    it('doit retourner les offres associées à une demande avec détails réparateur', async () => {
      const mockOffers = [
        {
          id: 'off-1',
          repairRequestId: 'rep-1',
          priceCfa: 10000,
          estimatedDuration: '1h',
          status: 'PENDING',
          provider: {
            workshopName: 'Service Rapide',
            user: { fullName: 'Moussa Diakité', phone: '+22376112233' },
          },
        },
      ];

      prisma.offer.findMany.mockResolvedValue(mockOffers);

      const result = await service.findByRepair('rep-1');

      expect(prisma.offer.findMany).toHaveBeenCalledWith({
        where: { repairRequestId: 'rep-1' },
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
      });

      expect(result).toEqual(mockOffers);
    });
  });

  describe('findMyOffers', () => {
    it('doit lever NotFoundException si le profil réparateur est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(service.findMyOffers('prov-unknown')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('doit retourner les offres soumises par le réparateur avec détails des pannes', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue({
        id: 'prov-prof-1',
        userId: 'prov-user-1',
      });

      const mockOffers = [
        {
          id: 'off-1',
          priceCfa: 20000,
          repairRequest: {
            id: 'rep-1',
            descriptionText: 'Panne connecteur de charge',
            category: { name: 'Téléphones' },
            issueType: { name: 'Connecteur' },
            client: { fullName: 'Awa Koné', phone: '+22366112233' },
          },
        },
      ];

      prisma.offer.findMany.mockResolvedValue(mockOffers);

      const result = await service.findMyOffers('prov-user-1');

      expect(prisma.offer.findMany).toHaveBeenCalledWith({
        where: { providerId: 'prov-prof-1' },
        include: {
          repairRequest: {
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
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });

      expect(result).toEqual(mockOffers);
    });
  });

  describe('acceptOffer', () => {
    it('doit lever NotFoundException si l offre n existe pas', async () => {
      prisma.offer.findUnique.mockResolvedValue(null);

      await expect(
        service.acceptOffer('client-1', 'offer-unknown'),
      ).rejects.toThrow(new NotFoundException('Offre introuvable'));
    });

    it('doit lever ForbiddenException si l utilisateur n est pas le propriétaire de la demande', async () => {
      prisma.offer.findUnique.mockResolvedValue({
        id: 'offer-1',
        repairRequestId: 'rep-1',
        repairRequest: {
          id: 'rep-1',
          clientId: 'client-legitime',
          status: 'PENDING',
        },
      });

      await expect(
        service.acceptOffer('client-usurpateur', 'offer-1'),
      ).rejects.toThrow(
        new ForbiddenException(
          "Vous n'êtes pas autorisé à accepter cette offre",
        ),
      );
    });

    it('doit lever BadRequestException si la demande n est plus en attente d offres', async () => {
      prisma.offer.findUnique.mockResolvedValue({
        id: 'offer-1',
        repairRequestId: 'rep-1',
        repairRequest: {
          id: 'rep-1',
          clientId: 'client-1',
          status: 'IN_PROGRESS',
        },
      });

      await expect(
        service.acceptOffer('client-1', 'offer-1'),
      ).rejects.toThrow(
        new BadRequestException("Cette demande n'est plus en attente d'offres"),
      );
    });

    it('doit accepter l offre, rejeter les autres offres et passer la réparation à IN_PROGRESS', async () => {
      const mockOffer = {
        id: 'offer-accepted-1',
        repairRequestId: 'rep-1',
        status: 'PENDING',
        repairRequest: {
          id: 'rep-1',
          clientId: 'client-1',
          status: 'OFFERS_RECEIVED',
        },
      };

      const mockUpdatedRepair = {
        id: 'rep-1',
        status: 'IN_PROGRESS',
        selectedOfferId: 'offer-accepted-1',
        offers: [
          { id: 'offer-accepted-1', status: 'ACCEPTED' },
          { id: 'offer-other-2', status: 'REJECTED' },
        ],
      };

      prisma.offer.findUnique.mockResolvedValue(mockOffer);
      prisma.offer.update.mockResolvedValue({
        ...mockOffer,
        status: 'ACCEPTED',
      });
      prisma.offer.updateMany.mockResolvedValue({ count: 1 });
      prisma.repairRequest.update.mockResolvedValue(mockUpdatedRepair);

      const result = await service.acceptOffer('client-1', 'offer-accepted-1');

      expect(prisma.offer.update).toHaveBeenCalledWith({
        where: { id: 'offer-accepted-1' },
        data: { status: 'ACCEPTED' },
      });

      expect(prisma.offer.updateMany).toHaveBeenCalledWith({
        where: {
          repairRequestId: 'rep-1',
          id: { not: 'offer-accepted-1' },
        },
        data: { status: 'REJECTED' },
      });

      expect(prisma.repairRequest.update).toHaveBeenCalledWith({
        where: { id: 'rep-1' },
        data: {
          status: 'IN_PROGRESS',
          selectedOfferId: 'offer-accepted-1',
        },
        include: {
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
          },
          category: true,
          issueType: true,
        },
      });

      expect(result).toEqual(mockUpdatedRepair);
    });
  });
});
