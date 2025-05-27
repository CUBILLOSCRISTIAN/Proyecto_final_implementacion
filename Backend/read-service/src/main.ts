import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
dotenv.config();

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AppModule,
    {
      transport: Transport.MQTT,
      options: {
        url: `mqtt://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
      },
    },
  );
  await app.listen();
  console.log('Read Microservice is listening...');
}
bootstrap();
