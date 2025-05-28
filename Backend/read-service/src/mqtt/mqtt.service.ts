import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { connect, MqttClient } from 'mqtt';
import { DataService } from 'src/data/data.service';
import * as dotenv from 'dotenv';

dotenv.config();

@Injectable()
export class MqttService implements OnModuleInit {
  private client: MqttClient;
  private readonly logger = new Logger(MqttService.name);

  constructor(private readonly dataService: DataService) {}

  onModuleInit() {
    this.client = connect(
      `mqtt://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
    );
    this.client.on('connect', () => {
      this.logger.log('MQTT publisher conectado');
    });
  }

  publish(topic: string, message: any) {
    if (!this.client?.connected) {
      this.logger.warn(
        `MQTT client no conectado, no se pudo publicar en ${topic}`,
      );
      return;
    }
    const msg = typeof message === 'string' ? message : JSON.stringify(message);
    this.client.publish(topic, msg);
    this.logger.log(`Publicado en ${topic}: ${msg}`);
  }

  async publishLiveData(deviceId: string, timestamp: Date) {
    const updatedData = await this.dinamicDashboardData(deviceId, timestamp);

    const payload = JSON.stringify(updatedData);

    this.client.publish('mobile/data', payload, {}, (err) => {
      if (err) {
        console.error('Error publicando en mobile/data:', err);
      } else {
        console.log('Publicado en mobile/data');
      }
    });
  }

  async dinamicDashboardData(deviceId: string, timestamp: Date) {
    const fecha = new Date(timestamp);

    const dayResult = await this.dataService.getConsumoDia(deviceId, fecha);
    const averageMonths = await this.dataService.getPromedioUltimos12Meses(
      deviceId,
      fecha,
    );
    const hoursLater = await this.dataService.getConsumo5Horas(deviceId, fecha);
    const sevenDays = await this.dataService.getLitrosUltimos7Dias(
      deviceId,
      fecha,
    );
    const month = await this.dataService.getLitrosPorMes(deviceId, fecha);

    const result = {
      dayResult,
      averageMonths,
      hoursLater,
      sevenDays,
      month,
    };

    return result;
  }
}
