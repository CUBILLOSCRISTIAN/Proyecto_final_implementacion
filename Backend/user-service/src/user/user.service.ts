import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { User } from './schema/user.schema';
import { Model } from 'mongoose';

@Injectable()
export class UserService {
  constructor(@InjectModel(User.name) private userModel: Model<User>) {}

  async save(data: Partial<User>): Promise<User> {
    const usuarioExistente = await this.userModel.findOne({
      deviceId: data.deviceId,
    });
    if (usuarioExistente) {
      return this.userModel.findOneAndUpdate(
        { deviceId: data.deviceId },
        { ...data },
        { new: true },
      )as Promise<User>;
    }

    const nuevoUsuario = new this.userModel(data);
    return nuevoUsuario.save();
  }
}
