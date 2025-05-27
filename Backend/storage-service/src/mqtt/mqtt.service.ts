import { Injectable, Logger } from '@nestjs/common';
import { DataService } from 'src/data/data.service';

@Injectable()
export class MqttService {
  private readonly logger = new Logger(MqttService.name);
  constructor(private readonly dataService: DataService) {}

  async handleMessage(message: any) {
    try {
      console.log('Received MQTT message:', message);
      const payload = message;

      const { deviceId, timestamp, flowRate, litres, totalLitres } = payload;

      if (
        deviceId &&
        timestamp &&
        flowRate != null &&
        litres != null &&
        totalLitres != null
      ) {
        await this.dataService.save({
          deviceId,
          timestamp,
          flowRate,
          litres,
          totalLitres,
        });
        this.logger.log(`Data saved for device ${deviceId}`);
      } else {
        this.logger.warn('Received incomplete data');
      }
    } catch (error) {
      this.logger.error('Failed to handle MQTT message', error);
    }
  }
}
