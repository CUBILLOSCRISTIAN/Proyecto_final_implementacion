import 'package:flow_sensor_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeController extends GetxController {
  final nameController = TextEditingController();
  final dailyLimit = 10.0.obs; // valor inicial razonable
  final monthlyLimit = 1000.0.obs; // valor inicial razonable
  final termsAccepted = false.obs;

  void continueIfValid() async {
    final name = nameController.text.trim();

    if (name.isEmpty || !termsAccepted.value) {
      Get.snackbar(
        'Error',
        'Por favor ingresa tu nombre y acepta los términos.',
      );
      return;
    }

    // Guardar configuración
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('username', name);
    await prefs.setDouble('daily_limit', dailyLimit.value);
    await prefs.setDouble('monthly_limit', monthlyLimit.value);

    Get.offAllNamed(AppRoutes.linkDevice);
  }
}
