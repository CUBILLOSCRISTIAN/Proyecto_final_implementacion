const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    await mongoose.connect(
      "mongodb+srv://waterMonitor:qA%2BSMzQp6d1lMy8xI4%2B%2FC%7C05s7iP%7D2@water-monitor.mongocluster.cosmos.azure.com/?tls=true&authMechanism=SCRAM-SHA-256&retrywrites=false&maxIdleTimeMS=120000"
    );
    console.log("Conexión a MongoDB exitosa");
  } catch (error) {
    console.error("Error al conectar a MongoDB:", error);
    process.exit(1);
  }
};

const dataSchema = new mongoose.Schema({
  deviceId: { type: String, required: true },
  timestamp: { type: Date, required: true },
  flowRate: { type: Number, required: true },
  litres: { type: Number, required: true },
  totalLitres: { type: Number, required: true },
});

const Data = mongoose.model("Data", dataSchema);

const getLitersDay = async (deviceId, timestamp) => {
  const startOfDay = new Date(timestamp);
  startOfDay.setUTCHours(0, 0, 0, 0);

  const endOfDay = new Date(timestamp);
  endOfDay.setUTCHours(23, 59, 59, 999);

  const registros = await Data.find({
    deviceId,
    timestamp: {
      $gte: startOfDay,
      $lte: endOfDay,
    },
  });

  const litrosHoy = registros.reduce((acc, doc) => acc + (doc.litres ?? 0), 0);

  return {
    deviceId,
    timestamp,
    liters: litrosHoy,
  };
};

const getPromedioUltimos12Meses = async (deviceId, timestamp) => {
  const start = new Date(timestamp);
  start.setUTCMonth(timestamp.getUTCMonth() - 11);
  start.setUTCDate(1);
  start.setUTCHours(0, 0, 0, 0);

  const end = new Date(timestamp);
  end.setUTCDate(1);
  end.setUTCMonth(end.getUTCMonth() + 1);
  end.setUTCHours(0, 0, 0, 0);
  end.setUTCDate(0);

  const result = await Data.aggregate([
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
          year: { $year: "$timestamp" },
          month: { $month: "$timestamp" },
        },
        litrosMes: { $sum: "$litres" },
      },
    },
  ]);

  const sumaTotal = result.reduce((acc, mes) => acc + mes.litrosMes, 0);
  const promedioMensual =
    result.length > 0 ? parseFloat((sumaTotal / result.length).toFixed(2)) : 0;

  return {
    deviceId,
    desde: start,
    hasta: end,
    promedioMensual,
  };
};

const getConsumo5Horas = async (deviceId, timestamp) => {
  const start = new Date(timestamp.getTime() - 5 * 60 * 60 * 1000);

  const resultado = await Data.aggregate([
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
            date: "$timestamp",
            unit: "minute",
            binSize: 5,
          },
        },
      },
    },
    {
      $group: {
        _id: "$bloque",
        litros: { $sum: "$litres" },
      },
    },
    {
      $sort: { _id: 1 },
    },
    {
      $project: {
        _id: 0,
        hora: "$_id",
        litros: { $round: ["$litros", 2] },
      },
    },
  ]);

  return resultado;
};

const getLitrosPorMes = async (deviceId, timestamp) => {
  const year = timestamp.getUTCFullYear();
  const month = timestamp.getUTCMonth();

  const startOfMonth = new Date(Date.UTC(year, month, 1, 0, 0, 0));
  const endOfMonth = new Date(Date.UTC(year, month + 1, 0, 23, 59, 59, 999));

  const registros = await Data.find({
    deviceId,
    timestamp: {
      $gte: startOfMonth,
      $lte: endOfMonth,
    },
  });

  const litrosMes = registros.reduce((acc, doc) => acc + (doc.litres ?? 0), 0);

  return {
    deviceId,
    mes: `${year}-${(month + 1).toString().padStart(2, "0")}`,
    litrosMes: parseFloat(litrosMes.toFixed(2)),
  };
};

const getLitrosUltimos7Dias = async(
    deviceId,
    timestamp,
  ) => {
    const referenceDate = timestamp;
    referenceDate.setUTCHours(0, 0, 0, 0);

    const startDate = new Date(referenceDate);
    startDate.setUTCDate(referenceDate.getUTCDate() - 6);
    const endDate = new Date(referenceDate);
    endDate.setUTCHours(23, 59, 59, 999);

    const registros = await Data.find({
      deviceId,
      timestamp: {
        $gte: startDate,
        $lte: endDate,
      },
    });

    // Inicializar mapa de fechas con 0
    const consumoPorDia = new Map();
    for (let i = 0; i < 7; i++) {
      const d = new Date(startDate);
      d.setUTCDate(startDate.getUTCDate() + i);
      const key = d.toISOString().split('T')[0];
      consumoPorDia.set(key, 0);
    }

    // Acumular litros por día
    registros.forEach((reg) => {
      const fecha = new Date(reg.timestamp).toISOString().split('T')[0];
      if (consumoPorDia.has(fecha)) {
        consumoPorDia.set(fecha, consumoPorDia.get(fecha) + (reg.litres ?? 0));
      }
    });

    // Formatear resultado
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

connectDB().then(() => {
  console.log(
    "Conexión establecida, puedes realizar consultas a la base de datos."
  );

  const litrosHoy = getLitersDay(
    "esp32-agua-01",
    new Date("2025-05-27T03:18:42.000Z")
  ).then((result) => {
    console.log("Litros consumidos hoy:", result);
  });

  const promedioUltimos12Meses = getPromedioUltimos12Meses(
    "esp32-agua-01",
    new Date("2025-05-27T03:18:42.000Z")
  ).then((result) => {
    console.log("Promedio mensual de los últimos 12 meses:", result);
  });

  const consumo5Horas = getConsumo5Horas(
    "esp32-agua-01",
    new Date("2025-05-27T03:18:42.000Z")
  ).then((result) => {
    console.log("Consumo en las últimas 5 horas:", result);
  });

  const litrosPorMes = getLitrosPorMes(
    "esp32-agua-01",
    new Date("2025-05-27T03:18:42.000Z")
  ).then((result) => {
    console.log("Litros consumidos en el mes:", result);
  });

  const litrosUltimos7Dias = getLitrosUltimos7Dias(
    "esp32-agua-01",
    new Date("2025-05-27T03:18:42.000Z")
  ).then((result) => {
    console.log("Litros consumidos en los últimos 7 días:", result);
  });
});
