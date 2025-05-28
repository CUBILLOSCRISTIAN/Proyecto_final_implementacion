import { Controller } from '@nestjs/common';
import { MqttService } from './mqtt.service';
import { Ctx, EventPattern, MqttContext, Payload } from '@nestjs/microservices';

@Controller()
export class MqttController {
  constructor(private readonly mqttService: MqttService) {}

  @EventPattern('agua/medicion')
  async handleAnalisisTrigger(
    @Payload() payload: any,
    @Ctx() context: MqttContext,
  ) {
    const { deviceId, timestamp } = payload;
    if (!deviceId || !timestamp) return;

    const dateTimestamp = new Date(timestamp);

    await this.mqttService.publishLiveData(deviceId, dateTimestamp);
  }
}
