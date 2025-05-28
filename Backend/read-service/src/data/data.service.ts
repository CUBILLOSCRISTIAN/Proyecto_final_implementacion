import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Data } from './schema/data.schema';
import { Model } from 'mongoose';

@Injectable()
export class DataService {
  constructor(@InjectModel(Data.name) private dataModel: Model<Data>) {}

  async findByDevice(deviceId: string) {
    return this.dataModel.find({ deviceId }).sort({ timestamp: -1 }).exec();
  }

  async findLatestByDevice(deviceId: string) {
    return this.dataModel.findOne({ deviceId }).sort({ timestamp: -1 }).exec();
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

  async getPromedioUltimos12Meses(
    deviceId: string,
    timestamp: Date,
  ): Promise<{
    deviceId: string;
    desde: Date;
    hasta: Date;
    promedioMensual: number;
  }> {
    const start = new Date(timestamp);
    start.setUTCMonth(timestamp.getUTCMonth() - 11);
    start.setUTCDate(1);
    start.setUTCHours(0, 0, 0, 0);

    const end = new Date(timestamp);
    end.setUTCDate(1);
    end.setUTCMonth(end.getUTCMonth() + 1);
    end.setUTCHours(0, 0, 0, 0);
    end.setUTCDate(0);

    const result = await this.dataModel.aggregate([
      {
        $match: {
          deviceId,
          timestamp: {
            $gte: start,
            $lte: end,
          },
        },
      },
      {
        $group: {
          _id: {
            year: { $year: '$timestamp' },
            month: { $month: '$timestamp' },
          },
          litrosMes: { $sum: '$litres' },
        },
      },
    ]);

    const sumaTotal = result.reduce((acc, mes) => acc + mes.litrosMes, 0);
    const promedioMensual =
      result.length > 0
        ? parseFloat((sumaTotal / result.length).toFixed(2))
        : 0;

    return {
      deviceId,
      desde: start,
      hasta: end,
      promedioMensual,
    };
  }

  async getConsumo5Horas(
    deviceId: string,
    timestamp: Date,
  ): Promise<{ hora: string; litros: number }[]> {
    const start = new Date(timestamp.getTime() - 5 * 60 * 60 * 1000);

    const resultado = await this.dataModel.aggregate([
      {
        $match: {
          deviceId,
          timestamp: { $gte: start, $lte: timestamp },
        },
      },
      {
        $project: {
          litres: 1,
          bloque: {
            $dateTrunc: {
              date: '$timestamp',
              unit: 'minute',
              binSize: 5,
            },
          },
        },
      },
      {
        $group: {
          _id: '$bloque',
          litros: { $sum: '$litres' },
        },
      },
      {
        $sort: { _id: 1 },
      },
      {
        $project: {
          _id: 0,
          hora: '$_id',
          litros: { $round: ['$litros', 2] },
        },
      },
    ]);

    return resultado;
  }

  async getLitrosPorMes(
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

  async getLitrosUltimos7Dias(
    deviceId: string,
    timestamp: Date,
  ): Promise<{
    deviceId: string;
    desde: string;
    hasta: string;
    consumoUltimos7Dias: { fecha: string; litros: number }[];
  }> {
    const referenceDate = timestamp;
    referenceDate.setUTCHours(0, 0, 0, 0);

    const startDate = new Date(referenceDate);
    startDate.setUTCDate(referenceDate.getUTCDate() - 6);
    const endDate = new Date(referenceDate);
    endDate.setUTCHours(23, 59, 59, 999);

    const registros = await this.dataModel.find({
      deviceId,
      timestamp: {
        $gte: startDate,
        $lte: endDate,
      },
    });

    const consumoPorDia = new Map<string, number>();
    for (let i = 0; i < 7; i++) {
      const d = new Date(startDate);
      d.setUTCDate(startDate.getUTCDate() + i);
      const key = d.toISOString().split('T')[0];
      consumoPorDia.set(key, 0);
    }

    registros.forEach((reg) => {
      const fecha = new Date(reg.timestamp).toISOString().split('T')[0];
      if (consumoPorDia.has(fecha)) {
        consumoPorDia.set(fecha, consumoPorDia.get(fecha)! + (reg.litres ?? 0));
      }
    });

    const resultado = Array.from(consumoPorDia.entries()).map(
      ([fecha, litros]) => ({
        fecha,
        litros: parseFloat(litros.toFixed(2)),
      }),
    );

    return {
      deviceId,
      desde: startDate.toISOString().split('T')[0],
      hasta: endDate.toISOString().split('T')[0],
      consumoUltimos7Dias: resultado,
    };
  }
}
