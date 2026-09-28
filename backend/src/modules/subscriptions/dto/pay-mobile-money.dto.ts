import { IsIn, IsNotEmpty, IsString } from 'class-validator';

export class PayMobileMoneyDto {
  @IsString()
  @IsNotEmpty()
  phoneNumber: string;

  @IsString()
  @IsNotEmpty()
  @IsIn(['ORANGE_MONEY', 'MOOV_MONEY'])
  paymentMethod: 'ORANGE_MONEY' | 'MOOV_MONEY';
}
