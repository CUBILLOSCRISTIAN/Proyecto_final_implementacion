import { Module } from '@nestjs/common';
import { MqttController } from './mqtt/mqtt.controller';
import { MqttService } from './mqtt/mqtt.service';

@Module({
  controllers: [MqttController],
  providers: [MqttService],
})
export class AppModule {}
