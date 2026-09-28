import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller()
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post('repairs/:repairId/complete')
  @UseGuards(JwtAuthGuard)
  async completeRepair(
    @CurrentUser() user: any,
    @Param('repairId') repairId: string,
  ) {
    const userId = user.userId || user.id;
    return this.reviewsService.completeRepair(userId, repairId);
  }

  @Post('repairs/:repairId/reviews')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CLIENT')
  async createReview(
    @CurrentUser() user: any,
    @Param('repairId') repairId: string,
    @Body() dto: CreateReviewDto,
  ) {
    const userId = user.userId || user.id;
    return this.reviewsService.createReview(userId, repairId, dto);
  }

  @Get('reviews/provider/:providerId')
  async findByProvider(@Param('providerId') providerId: string) {
    return this.reviewsService.findByProvider(providerId);
  }
}
