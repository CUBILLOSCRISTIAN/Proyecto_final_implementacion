import { Module } from '@nestjs/common';
import { MqttService } from './mqtt/mqtt.service';
import { RealtimeGateway } from './websocket/realtime.gateway';
import { UsuarioController } from './rest/user.controller';
import { UserService } from './rest/user.service';
@Module({
  imports: [],
  controllers: [UsuarioController],
  providers: [MqttService, RealtimeGateway, UserService],
})
export class AppModule {}
