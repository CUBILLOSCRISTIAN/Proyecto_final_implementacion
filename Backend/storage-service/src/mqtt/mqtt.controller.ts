import { Controller } from '@nestjs/common';
import { MqttService } from './mqtt.service';
import { EventPattern, Payload } from '@nestjs/microservices';
import * as dotenv from 'dotenv';
dotenv.config();

@Controller('mqtt')
export class MqttController {
  constructor(private readonly mqttService: MqttService) {}

  @EventPattern(process.env.MQTT_TOPIC)
  handleMqttMessage(@Payload() message: any) {
    this.mqttService.handleMessage(message);
  }
}
