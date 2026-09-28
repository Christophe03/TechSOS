import { IsIn, IsInt, IsNotEmpty, IsOptional, IsPositive } from 'class-validator';

export class UpdateWorkshopStatusDto {
  @IsNotEmpty()
  @IsIn([
    'DEPOSITED',
    'DIAGNOSTIC',
    'IN_REPAIR',
    'READY_FOR_PICKUP',
    'DELIVERED',
  ])
  status: string;

  @IsOptional()
  @IsInt()
  @IsPositive()
  priceCfa?: number;
}
