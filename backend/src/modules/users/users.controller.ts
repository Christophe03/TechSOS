import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async getMe(@CurrentUser() user: any) {
    const userId = user.userId || user.id;
    return this.usersService.getMe(userId);
  }

  @Get('providers')
  async findProviders(
    @Query('specialtyId') specialtyId?: string,
    @Query('zone') zone?: string,
  ) {
    return this.usersService.findProviders({ specialtyId, zone });
  }
}
