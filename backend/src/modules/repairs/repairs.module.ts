import { Module } from '@nestjs/common';
import { RepairsController } from './repairs.controller';
import { RepairsService } from './repairs.service';
import { StorageModule } from '../storage/storage.module';

@Module({
  imports: [StorageModule],
  controllers: [RepairsController],
  providers: [RepairsService],
  exports: [RepairsService],
})
export class RepairsModule {}
