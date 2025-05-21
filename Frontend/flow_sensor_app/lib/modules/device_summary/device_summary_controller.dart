import 'package:flow_sensor_app/modules/link_device/linked_device_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/pocketbase_service.dart';

class DeviceSummaryController extends GetxController {
  late final LinkedDevice device;

  final data = {}.obs;
  final chartData = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  final latestFlow = 0.0.obs;
  final maxFlow = 0.0.obs;
  final minFlow = double.infinity.obs;
  final avgFlow = 0.0.obs;

  final dailySummary = <String, double>{}.obs;

  final _pbService = PocketbaseService();

  @override
  void onInit() {
    super.onInit();
    device = Get.arguments as LinkedDevice;
    _loadInitialData();
    generateDailySummary();
    loadHistoricalData();
    _listenForUpdates();
  }

  void _updateStats() {
    if (chartData.isEmpty) return;

    final flows = chartData.map((e) => e['flujo'] as double).toList();
    latestFlow.value = flows.last;
    maxFlow.value = flows.reduce((a, b) => a > b ? a : b);
    minFlow.value = flows.reduce((a, b) => a < b ? a : b);
    avgFlow.value = flows.reduce((a, b) => a + b) / flows.length;
  }

  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
      final records = await _pbService.getLatestRecordsBySerial(
        device.id ?? device.serial,
      );
      if (records.isNotEmpty) {
        data.value = records.first.data;
      } else {
        error.value = 'No hay datos disponibles.';
      }
    } catch (e) {
      error.value = 'Error al cargar los datos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _listenForUpdates() {
    _pbService.subscribeToDevice(device.id ?? device.serial, (record) {
      final flujo = double.tryParse(record.data['flow_rate'].toString()) ?? 0.0;
      final created =
          DateTime.tryParse(record.data['created']) ?? DateTime.now();

      data.value = record.data;
      chartData.add({'flujo': flujo, 'created': created});

      if (chartData.length > 50) {
        chartData.removeAt(0);
      }
      _updateStats();
    });
  }

  Future<void> loadHistoricalData() async {
    try {
      final records = await _pbService.getHistoricalRecordsBySerial(
        device.id ?? device.serial,
        count: 50,
      );

      final dataPoints =
          records.reversed.map((r) {
            return {
              'flujo': double.tryParse(r.data['flow_rate'].toString()) ?? 0.0,
              'created': DateTime.tryParse(r.data['created']) ?? DateTime.now(),
            };
          }).toList();

      chartData.assignAll(dataPoints);

      _updateStats();
    } catch (e) {
      error.value = 'Error cargando historial: $e';
    }
  }

  Future<void> generateDailySummary() async {
    final allRecords = await _pbService.getAllMeasurementsBySerial(
      device.id ?? device.serial,
    );

    final grouped = <String, double>{};

    for (final record in allRecords) {
      final createdStr = record.data['timestamp'];
      final createdDate = DateTime.tryParse(createdStr) ?? DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(createdDate);
      final value = double.tryParse(record.data['flow_rate'].toString()) ?? 0.0;
      grouped[date] = (grouped[date] ?? 0) + value;
    }

    dailySummary.value = grouped;
  }


  @override
  void onClose() {
    _pbService.unsubscribeAll();
    super.onClose();
  }
}
