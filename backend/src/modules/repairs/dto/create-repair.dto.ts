import { IsNotEmpty, IsOptional, IsString, IsArray } from 'class-validator';

export class CreateRepairDto {
  @IsNotEmpty({ message: 'La catégorie est requise' })
  @IsString()
  categoryId: string;

  @IsOptional()
  @IsString()
  issueTypeId?: string;

  @IsOptional()
  @IsString()
  customIssueTitle?: string;

  @IsNotEmpty({ message: 'La description du problème est requise' })
  @IsString()
  descriptionText: string;

  @IsOptional()
  @IsString()
  voiceAudioUrl?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  photoUrls?: string[];

  @IsOptional()
  @IsString()
  locationAddress?: string;
}
