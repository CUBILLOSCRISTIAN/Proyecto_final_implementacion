import { Injectable, OnModuleInit } from '@nestjs/common';
import { connect, MqttClient } from 'mqtt';
import { RealtimeGateway } from '../websocket/realtime.gateway';

@Injectable()
export class MqttService implements OnModuleInit {
  private client: MqttClient;

  constructor(private wsGateway: RealtimeGateway) {}

  onModuleInit() {
    this.client = connect('mqtt://localhost:1883');

    this.client.on('connect', () => {
      console.log('Conectado a MQTT');
      this.client.subscribe('agua/medicion');
    });

    this.client.on('message', (topic, message) => {
      if (topic === 'agua/medicion') {
        const payload = JSON.parse(message.toString());
        const { deviceId } = payload;

        this.wsGateway.enviarDatosTiempoReal(deviceId, payload);
      }
    });
  }
}
