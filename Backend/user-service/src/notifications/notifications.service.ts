import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User } from 'src/user/schema/user.schema';
import { Data } from './schema/data.schema';
import admin from 'src/firebase/firebase.provider';

@Injectable()
export class NotificationsService {
  private logger = new Logger(NotificationsService.name);

  constructor(
    @InjectModel(User.name) private userModel: Model<User>,
    @InjectModel(Data.name) private dataModel: Model<Data>,
  ) {}

  async VerificarLimites(data: any) {
    const { deviceId, timestamp } = data;
    const fecha = new Date(timestamp);

    const usuario = await this.userModel.findOne({ deviceId });

    if (!usuario) {
      this.logger.warn(`Usuario con deviceId ${deviceId} no encontrado`);
      return;
    }

    const consumoDia = await this.getConsumoDia(deviceId, fecha);

    const litrosHoy = consumoDia.liters;

    const consumoMes = await this.getConsumoMes(deviceId, fecha);
    const litrosMes = consumoMes.litrosMes;

    if (litrosMes >= usuario.limiteMensual) {
      this.logger.warn(
        `ALERTA: El usuario ${deviceId} superó su límite mensual (${litrosMes}/${usuario.limiteMensual})`,
      );

      if (usuario.fcmToken) {
        await admin.messaging().send({
          token: usuario.fcmToken,
          notification: {
            title: 'Límite mensual alcanzado',
            body: `Has superado tu límite mensual de ${usuario.limiteMensual} litros. Tu consumo actual es de ${litrosMes} litros.`,
          },
          data: {
            tipo: 'limite_mensual',
            deviceId: deviceId,
          },
        });
      }
    }
    if (litrosHoy >= usuario.limiteDiario) {
      this.logger.warn(
        `ALERTA: El usuario ${deviceId} superó su límite diario (${litrosHoy}/${usuario.limiteDiario})`,
      );
      if (usuario.fcmToken) {
        await admin.messaging().send({
          token: usuario.fcmToken,
          notification: {
            title: 'Límite diario alcanzado',
            body: `Has superado tu límite diario de ${usuario.limiteDiario} litros. Tu consumo actual es de ${litrosHoy} litros.`,
          },
          data: {
            tipo: 'limite_diario',
            deviceId: deviceId,
          },
        });
      }
    }
  }

  async getConsumoDia(
    deviceId: string,
    timestamp: Date,
  ): Promise<{
    deviceId: string;
    timestamp: Date;
    liters: number;
  }> {
    const startOfDay = new Date(timestamp);
    startOfDay.setUTCHours(0, 0, 0, 0);

    const endOfDay = new Date(timestamp);
    endOfDay.setUTCHours(23, 59, 59, 999);

    const registros = await this.dataModel.find({
      deviceId,
      timestamp: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
    });

    const litrosHoy = registros.reduce(
      (acc, doc) => acc + (doc.litres ?? 0),
      0,
    );

    return {
      deviceId,
      timestamp,
      liters: litrosHoy,
    };
  }

  async getConsumoMes(
    deviceId: string,
    timestamp: Date,
  ): Promise<{
    deviceId: string;
    mes: string;
    litrosMes: number;
  }> {
    const year = timestamp.getUTCFullYear();
    const month = timestamp.getUTCMonth();

    const startOfMonth = new Date(Date.UTC(year, month, 1, 0, 0, 0));
    const endOfMonth = new Date(Date.UTC(year, month + 1, 0, 23, 59, 59, 999));

    const registros = await this.dataModel.find({
      deviceId,
      timestamp: {
        $gte: startOfMonth,
        $lte: endOfMonth,
      },
    });

    const litrosMes = registros.reduce(
      (acc, doc) => acc + (doc.litres ?? 0),
      0,
    );

    return {
      deviceId,
      mes: `${year}-${(month + 1).toString().padStart(2, '0')}`,
      litrosMes: parseFloat(litrosMes.toFixed(2)),
    };
  }
}
