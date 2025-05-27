import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import * as dotenv from 'dotenv';
import { connect, MqttClient } from 'mqtt';
import { ConfigDto } from 'src/dto/config.dto';
dotenv.config();

@Injectable()
export class MqttService implements OnModuleInit {
  private readonly logger = new Logger(MqttService.name);
  private client: MqttClient;

  onModuleInit() {
    this.client = connect(
      `mqtt://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
    );
    this.client.on('connect', () => {
      this.logger.log('Connected to MQTT broker');
    });
  }

  async processConfigMessage(message: any) {
    try {
      const payload = message;

      const config = plainToInstance(ConfigDto, payload);
      const errors = await validate(config, {
        whitelist: true,
        forbidNonWhitelisted: true,
      });

      if (errors.length > 0) {
        this.logger.warn(`Invalid config received: ${JSON.stringify(errors)}`);
        return;
      }

      const topic = `${process.env.MQTT_OUTPUT_TOPIC_PREFIX}/${config.deviceId}`;
      const data = JSON.stringify(payload);

      this.client.publish(topic, data);
      this.logger.log(`Published raw config to topic ${topic}`);
    } catch (error) {
      this.logger.error('Failed to process config message', error);
    }
  }
}
