import { IsNotEmpty, IsOptional, IsString, IsInt } from 'class-validator';

export class CreateCategoryDto {
  @IsNotEmpty({ message: 'Le nom de la catégorie est obligatoire' })
  @IsString({ message: 'Le nom doit être une chaîne de caractères' })
  name: string;

  @IsOptional()
  @IsString({ message: "L'icône doit être une chaîne de caractères" })
  iconName?: string = 'devices';

  @IsOptional()
  @IsInt({ message: "L'ordre d'affichage doit être un entier" })
  sortOrder?: number = 0;
}
