import 'dart:convert';
import 'package:flow_sensor_app/modules/link_device/linked_device_model.dart';
import 'package:flow_sensor_app/services/pocketbase_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkDeviceController extends GetxController {
  final devices = <LinkedDevice>[].obs;

  final _pbService = PocketbaseService();

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  Future<void> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('devices') ?? [];

    final loadedDevices =
        list.map((item) {
          final jsonItem = json.decode(item);
          return LinkedDevice.fromJson(jsonItem);
        }).toList();

    devices.assignAll(loadedDevices);
  }

  Future<void> addDevice(LinkedDevice device) async {
    final prefs = await SharedPreferences.getInstance();

    final body = <String, dynamic>{
      "serial_number": device.serial,
      "name": device.name,
    };

    try {
      final record = await _pbService.createDevice(body);

      final linkedDevice = LinkedDevice(
        id: record.id,
        serial: device.serial,
        name: device.name,
      );

      devices.add(linkedDevice);

      final deviceStrings =
          devices.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList('devices', deviceStrings);
    } catch (e) {
      // Manejo de errores
      print('Error al crear el dispositivo: $e');
      Get.snackbar('Error', 'No se pudo vincular el dispositivo.');
    }
  }

  Future<void> removeDevice(LinkedDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    devices.remove(device);

    final deviceStrings = devices.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('devices', deviceStrings);
  }
}
