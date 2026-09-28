import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
} from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { PayMobileMoneyDto } from './dto/pay-mobile-money.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('subscriptions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('PROVIDER')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get('current')
  async getCurrentSubscription(@CurrentUser() user: any) {
    const userId = user.userId || user.id;
    return this.subscriptionsService.getCurrentSubscription(userId);
  }

  @Post('pay-mobile-money')
  async payMobileMoney(
    @CurrentUser() user: any,
    @Body() dto: PayMobileMoneyDto,
  ) {
    const userId = user.userId || user.id;
    return this.subscriptionsService.payMobileMoney(userId, dto);
  }
}
