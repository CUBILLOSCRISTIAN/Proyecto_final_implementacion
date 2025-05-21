import 'package:pocketbase/pocketbase.dart';

class PocketbaseService {
  final PocketBase pb = PocketBase(
    'https://backend-pocketbase.azurewebsites.net',
  );

  // Singleton opcional
  static final PocketbaseService _instance = PocketbaseService._internal();
  factory PocketbaseService() => _instance;
  PocketbaseService._internal();

  /// Obtiene los últimos Measurement para un dispositivo
  Future<List<RecordModel>> getLatestRecordsBySerial(String serial) async {
    final result = await pb
        .collection('Measurement')
        .getList(
          page: 1,
          perPage: 1,
          filter: 'device_id="$serial"',
          sort: '-created',
        );
    return result.items;
  }

  /// Suscripción en tiempo real
  void subscribeToDevice(String serial, Function(RecordModel) onData) {
    pb.collection('Measurement').subscribe('*', (e) {
      final record = e.record;
      if (record != null && record.data['device_id'] == serial) {
        onData(record);
      }
    });
  }

  void unsubscribeAll() {
    pb.collection('Measurement').unsubscribe('*');
  }

  /// Crea un nuevo dispositivo
  Future<RecordModel> createDevice(Map<String, dynamic> body) async {
    final record = await pb.collection('Device').create(body: body);
    return record;
  }

  /// Obtiene los últimos N registros de flujo por dispositivo
  Future<List<RecordModel>> getHistoricalRecordsBySerial(
    String serial, {
    int count = 50,
  }) async {
    final result = await pb
        .collection('Measurement')
        .getList(
          page: 1,
          perPage: count,
          filter: 'device_id="$serial"',
          sort: '-created',
        );
    return result.items;
  }

  Future<List<RecordModel>> getAllMeasurementsBySerial(String serial) async {
    final result = await pb
        .collection('Measurement')
        .getFullList(
          batch: 200, // ajusta según cantidad de datos
          filter: 'device_id="$serial"',
          sort: '+timestamp',
        );
    return result;
  }
}
