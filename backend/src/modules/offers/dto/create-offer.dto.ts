import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
  Min,
} from 'class-validator';

export class CreateOfferDto {
  @IsInt()
  @IsPositive()
  @Min(500)
  priceCfa: number;

  @IsString()
  @IsNotEmpty()
  estimatedDuration: string;

  @IsOptional()
  @IsString()
  comment?: string;
}
