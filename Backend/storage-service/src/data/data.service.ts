import { Injectable } from '@nestjs/common';
import { Model } from 'mongoose';
import { Data } from './schema/data.schema';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class DataService {
  constructor(@InjectModel(Data.name) private dataModel: Model<Data>) {}

  async save(data: Partial<Data>): Promise<Data> {
    const { timestamp }= data;
    const date = new Date(timestamp!);
    const created = new this.dataModel({...data, timestamp: date });
    return created.save();
  }
}
