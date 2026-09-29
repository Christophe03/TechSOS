import { IsOptional, IsString, MinLength } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MinLength(2, { message: 'Le nom complet doit comporter au moins 2 caractères' })
  fullName?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  address?: string;

  // Champs spécifiques aux ateliers / prestataires
  @IsOptional()
  @IsString()
  workshopName?: string;

  @IsOptional()
  @IsString()
  addressZone?: string;

  @IsOptional()
  @IsString()
  bio?: string;
}
