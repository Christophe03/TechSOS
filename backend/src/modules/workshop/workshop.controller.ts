import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { WorkshopService } from './workshop.service';
import { CreateWorkshopEntryDto } from './dto/create-workshop-entry.dto';
import { UpdateWorkshopStatusDto } from './dto/update-workshop-status.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('workshop')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('PROVIDER')
export class WorkshopController {
  constructor(private readonly workshopService: WorkshopService) {}

  @Get()
  async findAll(
    @CurrentUser() user: any,
    @Query('status') status?: string,
    @Query('origin') origin?: string,
  ) {
    const userId = user.userId || user.id;
    return this.workshopService.findAll(userId, { status, origin });
  }

  @Get('stats')
  async getStats(@CurrentUser() user: any) {
    const userId = user.userId || user.id;
    return this.workshopService.getStats(userId);
  }

  @Post('quick-entry')
  async quickEntry(
    @CurrentUser() user: any,
    @Body() dto: CreateWorkshopEntryDto,
  ) {
    const userId = user.userId || user.id;
    return this.workshopService.quickEntry(userId, dto);
  }

  @Patch(':id/status')
  async updateStatus(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateWorkshopStatusDto,
  ) {
    const userId = user.userId || user.id;
    return this.workshopService.updateStatus(userId, id, dto);
  }
}
