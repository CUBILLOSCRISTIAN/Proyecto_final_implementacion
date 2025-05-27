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
}
