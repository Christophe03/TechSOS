import { Test, TestingModule } from '@nestjs/testing';
import { WorkshopService } from './workshop.service';
import { PrismaService } from '../../database/prisma.service';
import { WhatsAppService } from '../notifications/whatsapp.service';
import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { CreateWorkshopEntryDto } from './dto/create-workshop-entry.dto';
import { UpdateWorkshopStatusDto } from './dto/update-workshop-status.dto';

describe('WorkshopService', () => {
  let service: WorkshopService;
  let prisma: {
    providerProfile: {
      findUnique: jest.Mock;
    };
    workshopEntry: {
      findUnique: jest.Mock;
      findMany: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
      count: jest.Mock;
    };
  };
  let whatsappService: {
    sendTicketCreatedNotification: jest.Mock;
    sendReadyForPickupNotification: jest.Mock;
  };

  const mockProvider = {
    id: 'prov-profile-1',
    userId: 'user-prov-1',
    workshopName: 'Atelier Électronique Hamdallaye',
    subscriptionStatus: 'ACTIVE',
  };

  beforeEach(async () => {
    prisma = {
      providerProfile: {
        findUnique: jest.fn(),
      },
      workshopEntry: {
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        count: jest.fn(),
      },
    };

    whatsappService = {
      sendTicketCreatedNotification: jest.fn().mockResolvedValue({
        success: true,
        messageId: 'WA-123456',
        timestamp: new Date(),
      }),
      sendReadyForPickupNotification: jest.fn().mockResolvedValue({
        success: true,
        messageId: 'WA-789012',
        timestamp: new Date(),
      }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkshopService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
        {
          provide: WhatsAppService,
          useValue: whatsappService,
        },
      ],
    }).compile();

    service = module.get<WorkshopService>(WorkshopService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('doit lever NotFoundException si le profil réparateur est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(
        service.findAll('unknown-user'),
      ).rejects.toThrow(new NotFoundException('Profil réparateur introuvable'));
    });

    it('doit retourner les fiches d atelier ordonnées avec les filtres appliqués', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      const mockEntries = [
        { id: 'entry-1', clientName: 'Moussa Diarra', status: 'IN_REPAIR' },
      ];
      prisma.workshopEntry.findMany.mockResolvedValue(mockEntries);

      const result = await service.findAll('user-prov-1', {
        status: 'IN_REPAIR',
        origin: 'WALK_IN_OFFLINE',
      });

      expect(prisma.providerProfile.findUnique).toHaveBeenCalledWith({
        where: { userId: 'user-prov-1' },
      });
      expect(prisma.workshopEntry.findMany).toHaveBeenCalledWith({
        where: {
          providerId: 'prov-profile-1',
          status: 'IN_REPAIR',
          origin: 'WALK_IN_OFFLINE',
        },
        orderBy: { updatedAt: 'desc' },
      });
      expect(result).toEqual(mockEntries);
    });
  });

  describe('quickEntry', () => {
    const dto: CreateWorkshopEntryDto = {
      clientName: 'Amadou Traoré',
      clientPhone: '+22370112233',
      deviceModel: 'Samsung Galaxy A52',
      issueSummary: 'Écran fissuré et tactile inopérant',
      origin: 'WALK_IN_OFFLINE',
      priceCfa: 25000,
    };

    it('doit lever NotFoundException si le réparateur n a pas de profil', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(
        service.quickEntry('unknown-user', dto),
      ).rejects.toThrow(new NotFoundException('Profil réparateur introuvable'));
    });

    it('doit créer une fiche en statut DEPOSITED, déclencher la notification WhatsApp et mettre à jour whatsappNotifiedAt', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);

      const createdEntryMock = {
        id: 'entry-uuid-1',
        providerId: mockProvider.id,
        ...dto,
        status: 'DEPOSITED',
        whatsappNotifiedAt: null,
      };

      const updatedEntryMock = {
        ...createdEntryMock,
        whatsappNotifiedAt: new Date(),
      };

      prisma.workshopEntry.create.mockResolvedValue(createdEntryMock);
      prisma.workshopEntry.update.mockResolvedValue(updatedEntryMock);

      const result = await service.quickEntry('user-prov-1', dto);

      expect(prisma.workshopEntry.create).toHaveBeenCalledWith({
        data: {
          providerId: mockProvider.id,
          clientName: dto.clientName,
          clientPhone: dto.clientPhone,
          deviceModel: dto.deviceModel,
          issueSummary: dto.issueSummary,
          voiceNoteUrl: undefined,
          origin: 'WALK_IN_OFFLINE',
          priceCfa: 25000,
          status: 'DEPOSITED',
        },
      });

      expect(
        whatsappService.sendTicketCreatedNotification,
      ).toHaveBeenCalledWith(
        dto.clientPhone,
        dto.clientName,
        mockProvider.workshopName,
        dto.deviceModel,
        'entry-uuid-1',
      );

      expect(prisma.workshopEntry.update).toHaveBeenCalledWith({
        where: { id: 'entry-uuid-1' },
        data: {
          whatsappNotifiedAt: expect.any(Date),
        },
      });

      expect(result).toEqual(updatedEntryMock);
    });
  });

  describe('updateStatus', () => {
    it('doit lever NotFoundException si le profil réparateur est introuvable', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(null);

      await expect(
        service.updateStatus('unknown-user', 'entry-1', {
          status: 'IN_REPAIR',
        }),
      ).rejects.toThrow(new NotFoundException('Profil réparateur introuvable'));
    });

    it('doit lever NotFoundException si la fiche d atelier n existe pas', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      prisma.workshopEntry.findUnique.mockResolvedValue(null);

      await expect(
        service.updateStatus('user-prov-1', 'nonexistent-entry', {
          status: 'IN_REPAIR',
        }),
      ).rejects.toThrow(new NotFoundException("Fiche d'atelier introuvable"));
    });

    it('doit lever ForbiddenException si la fiche appartient à un autre réparateur', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      prisma.workshopEntry.findUnique.mockResolvedValue({
        id: 'entry-1',
        providerId: 'other-provider-id',
      });

      await expect(
        service.updateStatus('user-prov-1', 'entry-1', {
          status: 'IN_REPAIR',
        }),
      ).rejects.toThrow(
        new ForbiddenException(
          "Vous n'êtes pas autorisé à modifier cette fiche d'atelier",
        ),
      );
    });

    it('doit mettre à jour le statut sans déclencher WhatsApp si status !== READY_FOR_PICKUP', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      prisma.workshopEntry.findUnique.mockResolvedValue({
        id: 'entry-1',
        providerId: mockProvider.id,
        status: 'DEPOSITED',
        priceCfa: 10000,
      });

      prisma.workshopEntry.update.mockResolvedValue({
        id: 'entry-1',
        status: 'IN_REPAIR',
        priceCfa: 12000,
      });

      const dto: UpdateWorkshopStatusDto = {
        status: 'IN_REPAIR',
        priceCfa: 12000,
      };

      const result = await service.updateStatus('user-prov-1', 'entry-1', dto);

      expect(
        whatsappService.sendReadyForPickupNotification,
      ).not.toHaveBeenCalled();
      expect(prisma.workshopEntry.update).toHaveBeenCalledWith({
        where: { id: 'entry-1' },
        data: {
          status: 'IN_REPAIR',
          priceCfa: 12000,
        },
      });
      expect(result.status).toBe('IN_REPAIR');
    });

    it('doit déclencher la notification WhatsApp READY_FOR_PICKUP avec le prix et rafraîchir whatsappNotifiedAt', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);
      prisma.workshopEntry.findUnique.mockResolvedValue({
        id: 'entry-1',
        providerId: mockProvider.id,
        clientName: 'Fatoumata Coulibaly',
        clientPhone: '+22376001122',
        deviceModel: 'HP EliteBook 840 G5',
        status: 'IN_REPAIR',
        priceCfa: 35000,
      });

      prisma.workshopEntry.update.mockResolvedValue({
        id: 'entry-1',
        status: 'READY_FOR_PICKUP',
        priceCfa: 35000,
        whatsappNotifiedAt: new Date(),
      });

      const dto: UpdateWorkshopStatusDto = {
        status: 'READY_FOR_PICKUP',
      };

      const result = await service.updateStatus('user-prov-1', 'entry-1', dto);

      expect(
        whatsappService.sendReadyForPickupNotification,
      ).toHaveBeenCalledWith(
        '+22376001122',
        'Fatoumata Coulibaly',
        mockProvider.workshopName,
        'HP EliteBook 840 G5',
        35000,
      );

      expect(prisma.workshopEntry.update).toHaveBeenCalledWith({
        where: { id: 'entry-1' },
        data: {
          status: 'READY_FOR_PICKUP',
          whatsappNotifiedAt: expect.any(Date),
        },
      });
      expect(result.status).toBe('READY_FOR_PICKUP');
    });
  });

  describe('getStats', () => {
    it('doit retourner les compteurs par statut et les totaux', async () => {
      prisma.providerProfile.findUnique.mockResolvedValue(mockProvider);

      prisma.workshopEntry.count
        .mockResolvedValueOnce(15) // total
        .mockResolvedValueOnce(3) // deposited
        .mockResolvedValueOnce(2) // diagnostic
        .mockResolvedValueOnce(4) // inRepair
        .mockResolvedValueOnce(3) // readyForPickup
        .mockResolvedValueOnce(3); // delivered

      const stats = await service.getStats('user-prov-1');

      expect(stats).toEqual({
        total: 15,
        deposited: 3,
        diagnostic: 2,
        inRepair: 4,
        readyForPickup: 3,
        delivered: 3,
        totalRepaired: 6,
        totalDelivered: 3,
      });
    });
  });
});
