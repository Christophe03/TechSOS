import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
} from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateIssueDto } from './dto/create-issue.dto';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  async findAllWithIssues() {
    return this.categoriesService.findAllWithIssues();
  }

  @Get('pending-issues')
  async findPendingIssues() {
    return this.categoriesService.findPendingIssues();
  }

  @Post()
  async createCategory(@Body() dto: CreateCategoryDto) {
    return this.categoriesService.createCategory(dto);
  }

  @Post(':id/issues')
  async createIssue(
    @Param('id') categoryId: string,
    @Body() dto: CreateIssueDto,
  ) {
    return this.categoriesService.createIssue(categoryId, dto);
  }

  @Patch('issues/:id/approve')
  async approveIssue(@Param('id') issueId: string) {
    return this.categoriesService.approveIssue(issueId);
  }
}
