import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ProfilesModule } from './profiles/profiles.module';
import { CommunitiesModule } from './communities/communities.module';
import { MembershipsModule } from './memberships/memberships.module';
import { PresenceModule } from './presence/presence.module';
import { DiscoveryModule } from './discovery/discovery.module';
import { ConnectionsModule } from './connections/connections.module';
import { ChatsModule } from './chats/chats.module';
import { MessagesModule } from './messages/messages.module';
import { NotificationsModule } from './notifications/notifications.module';
import { BlocksModule } from './blocks/blocks.module';
import { ReportsModule } from './reports/reports.module';
import { DatabaseModule } from './database/database.module';
import { RedisModule } from './redis/redis.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    UsersModule,
    ProfilesModule,
    CommunitiesModule,
    MembershipsModule,
    PresenceModule,
    DiscoveryModule,
    ConnectionsModule,
    ChatsModule,
    MessagesModule,
    NotificationsModule,
    BlocksModule,
    ReportsModule,
    DatabaseModule,
    RedisModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
