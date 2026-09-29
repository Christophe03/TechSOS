import {
  Injectable,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../database/prisma.service';
import { RegisterClientDto } from './dto/register-client.dto';
import { RegisterProviderDto } from './dto/register-provider.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Inscription d'un nouveau client (particulier cherchant une réparation)
   */
  async registerClient(dto: RegisterClientDto) {
    // Vérification de l'unicité du numéro de téléphone
    const existingPhone = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });
    if (existingPhone) {
      throw new ConflictException('Ce numéro de téléphone est déjà utilisé');
    }

    // Vérification de l'unicité de l'email si fourni
    if (dto.email) {
      const existingEmail = await this.prisma.user.findUnique({
        where: { email: dto.email },
      });
      if (existingEmail) {
        throw new ConflictException('Cette adresse email est déjà utilisée');
      }
    }

    // Hachage sécurisé du mot de passe avec bcrypt
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.password, saltRounds);

    const user = await this.prisma.user.create({
      data: {
        phone: dto.phone,
        fullName: dto.fullName,
        passwordHash,
        email: dto.email || null,
        city: dto.city || 'Bamako',
        address: dto.address || null,
        role: 'CLIENT',
      },
    });

    const payload = {
      sub: user.id,
      phone: user.phone,
      role: user.role,
    };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Inscription d'un réparateur / atelier avec son profil d'activité
   */
  async registerProvider(dto: RegisterProviderDto) {
    // Vérification de l'unicité du téléphone
    const existingPhone = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });
    if (existingPhone) {
      throw new ConflictException('Ce numéro de téléphone est déjà utilisé');
    }

    // Vérification de l'unicité de l'email si fourni
    if (dto.email) {
      const existingEmail = await this.prisma.user.findUnique({
        where: { email: dto.email },
      });
      if (existingEmail) {
        throw new ConflictException('Cette adresse email est déjà utilisée');
      }
    }

    // Hachage du mot de passe
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.password, saltRounds);

    const specialtiesJson = JSON.stringify(dto.specialties || []);

    const user = await this.prisma.user.create({
      data: {
        phone: dto.phone,
        fullName: dto.fullName,
        passwordHash,
        email: dto.email || null,
        city: 'Bamako',
        role: 'PROVIDER',
        providerProfile: {
          create: {
            workshopName: dto.workshopName,
            addressZone: dto.addressZone,
            bio: dto.bio || null,
            specialtiesJson,
          },
        },
      },
      include: {
        providerProfile: true,
      },
    });

    const payload = {
      sub: user.id,
      phone: user.phone,
      role: user.role,
    };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Connexion unifiée pour clients et réparateurs
   */
  async login(dto: LoginDto) {
    const rawIdentifier = dto.identifier.trim();
    const digitsOnly = rawIdentifier.replace(/\D/g, '');
    
    // Génère les variantes possibles pour le numéro (ex: +22370000001, 70000001, email)
    const searchConditions: Array<{ phone?: string; email?: string }> = [
      { phone: rawIdentifier },
      { email: rawIdentifier.toLowerCase() },
    ];

    if (digitsOnly.length === 8) {
      if (rawIdentifier !== `+223${digitsOnly}`) {
        searchConditions.push({ phone: `+223${digitsOnly}` });
      }
      if (rawIdentifier !== digitsOnly) {
        searchConditions.push({ phone: digitsOnly });
      }
    } else if (digitsOnly.startsWith('223') && digitsOnly.length === 11) {
      const local = digitsOnly.substring(3);
      if (rawIdentifier !== `+${digitsOnly}`) {
        searchConditions.push({ phone: `+${digitsOnly}` });
      }
      if (rawIdentifier !== local) {
        searchConditions.push({ phone: local });
      }
    }

    const user = await this.prisma.user.findFirst({
      where: {
        OR: searchConditions,
      },
      include: {
        providerProfile: true,
      },
    });

    if (!user) {

      throw new UnauthorizedException('Identifiants invalides');
    }

    const isMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    const payload = {
      sub: user.id,
      phone: user.phone,
      role: user.role,
    };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Supprime les champs sensibles tels que le mot de passe haché
   */
  private sanitizeUser(user: any) {
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }
}
