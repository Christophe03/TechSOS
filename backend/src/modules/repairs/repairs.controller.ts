import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { RepairsService, RepairFilters } from './repairs.service';
import { CreateRepairDto } from './dto/create-repair.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('repairs')
export class RepairsController {
  constructor(private readonly repairsService: RepairsService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CLIENT')
  async create(@CurrentUser() user: any, @Body() dto: CreateRepairDto) {
    const userId = user.userId || user.id;
    return this.repairsService.create(userId, dto);
  }

  @Get()
  async findAll(
    @Query('categoryId') categoryId?: string,
    @Query('status') status?: string,
  ) {
    const filters: RepairFilters = {};
    if (categoryId) filters.categoryId = categoryId;
    if (status) filters.status = status;
    return this.repairsService.findAll(filters);
  }

  @Get('feed')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('PROVIDER')
  async findFeedForProvider(@CurrentUser() user: any) {
    const userId = user.userId || user.id;
    return this.repairsService.findFeedForProvider(userId);
  }

  @Get('my-requests')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CLIENT')
  async findMyRequests(@CurrentUser() user: any) {
    const userId = user.userId || user.id;
    return this.repairsService.findMyRequests(userId);
  }

  @Get(':id')
  async findById(@Param('id') id: string) {
    return this.repairsService.findById(id);
  }
}
