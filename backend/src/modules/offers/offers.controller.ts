import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { OffersService } from './offers.service';
import { CreateOfferDto } from './dto/create-offer.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller()
export class OffersController {
  constructor(private readonly offersService: OffersService) {}

  @Post('repairs/:repairId/offers')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('PROVIDER')
  async create(
    @CurrentUser() user: any,
    @Param('repairId') repairId: string,
    @Body() dto: CreateOfferDto,
  ) {
    const userId = user.userId || user.id;
    return this.offersService.create(userId, repairId, dto);
  }

  @Get('repairs/:repairId/offers')
  @UseGuards(JwtAuthGuard)
  async findByRepair(@Param('repairId') repairId: string) {
    return this.offersService.findByRepair(repairId);
  }

  @Get('offers/my-offers')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('PROVIDER')
  async findMyOffers(@CurrentUser() user: any) {
    const userId = user.userId || user.id;
    return this.offersService.findMyOffers(userId);
  }

  @Post('offers/:offerId/accept')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CLIENT')
  async acceptOffer(
    @CurrentUser() user: any,
    @Param('offerId') offerId: string,
  ) {
    const userId = user.userId || user.id;
    return this.offersService.acceptOffer(userId, offerId);
  }
}
