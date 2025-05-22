import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flow_sensor_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeController extends GetxController {
  final nameController = TextEditingController();
  final dailyLimit = 10.0.obs; // valor inicial razonable
  final monthlyLimit = 1000.0.obs; // valor inicial razonable
  final termsAccepted = false.obs;
  final cubicMeterValueM3Controller = TextEditingController();

  void continueIfValid() async {
    final prefs = await SharedPreferences.getInstance();
    final name = nameController.text.trim();
    final cubicMeterValueM3 = cubicMeterValueM3Controller.text.trim();

    if (name.isEmpty || !termsAccepted.value) {
      Get.snackbar(
        'Error',
        'Por favor ingresa tu nombre y acepta los términos.',
      );
      return;
    }

    if (cubicMeterValueM3.isEmpty) {
      await prefs.setString('cubicMeterValueM3', cubicMeterValueM3);
    }

    final deviceToken = await getDeviceToken();
    if (deviceToken == null) {
      Get.snackbar('Error', 'No se pudo obtener el token del dispositivo.');
      return;
    }

    // Guardar configuración
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('username', name);
    await prefs.setString('device_token', deviceToken);
    await prefs.setDouble('daily_limit', dailyLimit.value);
    await prefs.setDouble('monthly_limit', monthlyLimit.value);

    //TODO : Guardar el token en el servidor

    // Navegar a la siguiente pantalla
    Get.offAllNamed(AppRoutes.linkDevice);
  }

  Future<String?> getDeviceToken() async {
    final fcm = FirebaseMessaging.instance;

    // Solicita permisos (para iOS, en Android se da automáticamente)
    NotificationSettings settings = await fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await fcm.getToken();
      print('📱 Token FCM: $token');
      return token;
    } else {
      print('🔒 Permiso para notificaciones no concedido');
      return null;
    }
  }
}
