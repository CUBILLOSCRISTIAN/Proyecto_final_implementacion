import { Module } from '@nestjs/common';
import { MqttController } from './mqtt/mqtt.controller';
import { MqttService } from './mqtt/mqtt.service';
import { DataService } from './data/data.service';
import { MongooseModule } from '@nestjs/mongoose';
import * as dotenv from 'dotenv';
import { Data, DataSchema } from './data/schema/data.schema';

dotenv.config();

@Module({
  imports: [
    MongooseModule.forRoot(process.env.MONGO_URI!),
    MongooseModule.forFeature([{ name: Data.name, schema: DataSchema }]),
  ],
  controllers: [MqttController],
  providers: [MqttService, DataService],
})
export class AppModule {}
