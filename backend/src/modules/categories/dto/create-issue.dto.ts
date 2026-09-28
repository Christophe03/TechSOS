import { IsBoolean, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateIssueDto {
  @IsNotEmpty({ message: 'Le nom du type de panne est obligatoire' })
  @IsString({ message: 'Le nom doit être une chaîne de caractères' })
  name: string;

  @IsOptional()
  @IsBoolean({ message: 'isOfficial doit être un booléen' })
  isOfficial?: boolean = true;
}
