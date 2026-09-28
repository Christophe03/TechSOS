import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './database/database.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { StorageModule } from './modules/storage/storage.module';
import { RepairsModule } from './modules/repairs/repairs.module';
import { OffersModule } from './modules/offers/offers.module';
import { ReviewsModule } from './modules/reviews/reviews.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    DatabaseModule,
    CategoriesModule,
    AuthModule,
    UsersModule,
    StorageModule,
    RepairsModule,
    OffersModule,
    ReviewsModule,
  ],
})
export class AppModule {}
