import {
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateWorkshopEntryDto {
  @IsString()
  @IsNotEmpty()
  clientName: string;

  @IsString()
  @IsNotEmpty()
  clientPhone: string;

  @IsString()
  @IsNotEmpty()
  deviceModel: string;

  @IsString()
  @IsNotEmpty()
  issueSummary: string;

  @IsOptional()
  @IsString()
  voiceNoteUrl?: string;

  @IsOptional()
  @IsIn(['FROM_APP', 'WALK_IN_OFFLINE'])
  origin?: string;

  @IsOptional()
  @IsInt()
  @IsPositive()
  priceCfa?: number;
}
