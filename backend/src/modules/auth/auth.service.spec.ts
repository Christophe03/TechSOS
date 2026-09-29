import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../../database/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: {
    user: {
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
    };
    providerProfile: {
      create: jest.Mock;
    };
  };
  let jwtService: {
    sign: jest.Mock;
  };

  beforeEach(async () => {
    prisma = {
      user: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
      },
      providerProfile: {
        create: jest.fn(),
      },
    };

    jwtService = {
      sign: jest.fn().mockReturnValue('mocked_jwt_token_bamako_2026'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
        {
          provide: JwtService,
          useValue: jwtService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  describe('registerClient', () => {
    const registerClientDto = {
      phone: '+22370123456',
      fullName: 'Amadou Diallo',
      password: 'secretPassword123',
      email: 'amadou.diallo@example.ml',
      city: 'Bamako',
      address: 'Badalabougou Rue 12',
    };

    it('doit inscrire un client avec succès, hasher le mot de passe et retourner un token JWT', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      const fakeCreatedUser = {
        id: 'client-uuid-1',
        phone: registerClientDto.phone,
        fullName: registerClientDto.fullName,
        passwordHash: '$2b$10$hashedPasswordHere',
        email: registerClientDto.email,
        role: 'CLIENT',
        city: 'Bamako',
        address: registerClientDto.address,
        avatarUrl: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      prisma.user.create.mockResolvedValue(fakeCreatedUser);

      const result = await service.registerClient(registerClientDto);

      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { phone: registerClientDto.phone },
      });
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { email: registerClientDto.email },
      });
      expect(prisma.user.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            phone: registerClientDto.phone,
            fullName: registerClientDto.fullName,
            role: 'CLIENT',
            city: 'Bamako',
          }),
        }),
      );

      // Le mot de passe ne doit pas être stocké en clair
      const createCallArg = prisma.user.create.mock.calls[0][0].data;
      expect(createCallArg.passwordHash).toBeDefined();
      expect(createCallArg.passwordHash).not.toEqual(registerClientDto.password);
      expect(await bcrypt.compare(registerClientDto.password, createCallArg.passwordHash)).toBe(true);

      // Résultat attendu : access_token et user sans passwordHash
      expect(result.access_token).toBe('mocked_jwt_token_bamako_2026');
      expect(result.user).toBeDefined();
      expect((result.user as any).passwordHash).toBeUndefined();
      expect(result.user.id).toBe('client-uuid-1');
      expect(result.user.role).toBe('CLIENT');
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: 'client-uuid-1',
        phone: registerClientDto.phone,
        role: 'CLIENT',
      });
    });

    it('doit lever ConflictException si le numéro de téléphone est déjà utilisé', async () => {
      prisma.user.findUnique.mockImplementation(async ({ where }: any) => {
        if (where.phone) {
          return { id: 'existing-user-id', phone: registerClientDto.phone };
        }
        return null;
      });

      await expect(service.registerClient(registerClientDto)).rejects.toThrow(
        ConflictException,
      );
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('doit lever ConflictException si l email est déjà utilisé', async () => {
      prisma.user.findUnique.mockImplementation(async ({ where }: any) => {
        if (where.phone) return null;
        if (where.email) {
          return { id: 'existing-user-id', email: registerClientDto.email };
        }
        return null;
      });

      await expect(service.registerClient(registerClientDto)).rejects.toThrow(
        ConflictException,
      );
      expect(prisma.user.create).not.toHaveBeenCalled();
    });
  });

  describe('registerProvider', () => {
    const registerProviderDto = {
      phone: '+22376998877',
      fullName: 'Oumar Traoré',
      password: 'providerSecret123',
      email: 'oumar.tech@bamako.ml',
      workshopName: 'Atelier Électronique Hamdallaye',
      addressZone: 'Hamdallaye ACI 2000',
      bio: 'Spécialiste réparation micro-soudure et smartphones',
      specialties: ['cat-phone-id', 'cat-laptop-id'],
    };

    it('doit inscrire un réparateur avec son profil atelier et retourner access_token et profil', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      const fakeProviderUser = {
        id: 'provider-uuid-1',
        phone: registerProviderDto.phone,
        fullName: registerProviderDto.fullName,
        passwordHash: '$2b$10$hashedProviderPass',
        email: registerProviderDto.email,
        role: 'PROVIDER',
        city: 'Bamako',
        address: null,
        avatarUrl: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        providerProfile: {
          id: 'profile-uuid-1',
          userId: 'provider-uuid-1',
          workshopName: registerProviderDto.workshopName,
          addressZone: registerProviderDto.addressZone,
          bio: registerProviderDto.bio,
          isVerified: false,
          ratingAvg: 5.0,
          reviewCount: 0,
          subscriptionStatus: 'FREE_TRIAL',
          specialtiesJson: JSON.stringify(registerProviderDto.specialties),
        },
      };

      prisma.user.create.mockResolvedValue(fakeProviderUser);

      const result = await service.registerProvider(registerProviderDto);

      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { phone: registerProviderDto.phone },
      });
      expect(prisma.user.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            phone: registerProviderDto.phone,
            role: 'PROVIDER',
            city: 'Bamako',
            providerProfile: {
              create: {
                workshopName: registerProviderDto.workshopName,
                addressZone: registerProviderDto.addressZone,
                bio: registerProviderDto.bio,
                specialtiesJson: JSON.stringify(registerProviderDto.specialties),
              },
            },
          }),
          include: {
            providerProfile: true,
          },
        }),
      );

      expect(result.access_token).toBe('mocked_jwt_token_bamako_2026');
      expect((result.user as any).passwordHash).toBeUndefined();
      expect(result.user.providerProfile).toBeDefined();
      expect(result.user.providerProfile.workshopName).toBe(registerProviderDto.workshopName);
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: 'provider-uuid-1',
        phone: registerProviderDto.phone,
        role: 'PROVIDER',
      });
    });

    it('doit lever ConflictException si le numéro de téléphone réparateur existe déjà', async () => {
      prisma.user.findUnique.mockResolvedValue({ id: 'existing-id' });

      await expect(service.registerProvider(registerProviderDto)).rejects.toThrow(
        ConflictException,
      );
      expect(prisma.user.create).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    const rawPassword = 'correctPassword2026';
    let hashedPassword: string;

    beforeAll(async () => {
      hashedPassword = await bcrypt.hash(rawPassword, 10);
    });

    it('doit connecter un utilisateur avec son numéro de téléphone et retourner un token', async () => {
      const mockUser = {
        id: 'user-123',
        phone: '+22370123456',
        email: 'user@techsos.ml',
        passwordHash: hashedPassword,
        fullName: 'Fatoumata Coulibaly',
        role: 'CLIENT',
        city: 'Bamako',
        address: 'Lafiabougou',
        avatarUrl: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        providerProfile: null,
      };

      prisma.user.findFirst.mockResolvedValue(mockUser);

      const result = await service.login({
        identifier: '+22370123456',
        password: rawPassword,
      });

      expect(prisma.user.findFirst).toHaveBeenCalledWith({
        where: {
          OR: [
            { phone: '+22370123456' },
            { email: '+22370123456' },
            { phone: '70123456' },
          ],
        },
        include: {
          providerProfile: true,
        },
      });

      expect(result.access_token).toBe('mocked_jwt_token_bamako_2026');
      expect(result.user.id).toBe('user-123');
      expect((result.user as any).passwordHash).toBeUndefined();
    });

    it('doit connecter un utilisateur avec son email et retourner un token', async () => {
      const mockUser = {
        id: 'user-123',
        phone: '+22370123456',
        email: 'user@techsos.ml',
        passwordHash: hashedPassword,
        fullName: 'Fatoumata Coulibaly',
        role: 'CLIENT',
        city: 'Bamako',
        address: 'Lafiabougou',
        avatarUrl: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        providerProfile: null,
      };

      prisma.user.findFirst.mockResolvedValue(mockUser);

      const result = await service.login({
        identifier: 'user@techsos.ml',
        password: rawPassword,
      });

      expect(result.access_token).toBe('mocked_jwt_token_bamako_2026');
      expect(result.user.email).toBe('user@techsos.ml');
    });

    it('doit lever UnauthorizedException si l identifiant n existe pas', async () => {
      prisma.user.findFirst.mockResolvedValue(null);

      await expect(
        service.login({
          identifier: 'inconnu@bamako.ml',
          password: 'anyPassword',
        }),
      ).rejects.toThrow(new UnauthorizedException('Identifiants invalides'));
    });

    it('doit lever UnauthorizedException si le mot de passe est erroné', async () => {
      const mockUser = {
        id: 'user-123',
        phone: '+22370123456',
        email: 'user@techsos.ml',
        passwordHash: hashedPassword,
        fullName: 'Fatoumata Coulibaly',
        role: 'CLIENT',
        providerProfile: null,
      };

      prisma.user.findFirst.mockResolvedValue(mockUser);

      await expect(
        service.login({
          identifier: '+22370123456',
          password: 'wrongPassword',
        }),
      ).rejects.toThrow(new UnauthorizedException('Identifiants invalides'));
    });
  });
});
