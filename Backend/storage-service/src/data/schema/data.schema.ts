import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Data extends Document {
  @Prop({ required: true })
  deviceId: string;

  @Prop({ required: true })
  timestamp: Date;

  @Prop({ required: true })
  flowRate: number;

  @Prop({ required: true })
  litres: number;

  @Prop({ required: true })
  totalLitres: number;
}

export const DataSchema = SchemaFactory.createForClass(Data);
