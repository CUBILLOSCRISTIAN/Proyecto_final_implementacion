import 'package:flow_sensor_app/modules/welcome/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.water_drop, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                "¡Bienvenido a FlowSense!",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Monitorea en tiempo real el consumo de agua de tus dispositivos. Esta app te ayuda a tomar decisiones inteligentes para ahorrar recursos y detectar fugas.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Nombre
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: '¿Cómo te llamas?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 32),

              // Límite diario con Slider y tooltip
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Límite diario (L/min)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tooltip(
                    message:
                        'Máximo litros por minuto que deseas permitir por día. Si lo sobrepasas, recibirás una alerta.',
                    child: const Icon(Icons.info_outline, color: Colors.grey),
                  ),
                ],
              ),
              Obx(() {
                return Slider(
                  value: controller.dailyLimit.value,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: controller.dailyLimit.value.toStringAsFixed(1),
                  onChanged: (val) => controller.dailyLimit.value = val,
                );
              }),
              Text(
                '${controller.dailyLimit.value.toStringAsFixed(1)} L/min',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Límite mensual con Slider y tooltip
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Límite mensual (L/min)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tooltip(
                    message:
                        'Máximo litros por minuto que deseas permitir por mes. Útil para controlar consumo general.',
                    child: const Icon(Icons.info_outline, color: Colors.grey),
                  ),
                ],
              ),
              Obx(() {
                return Slider(
                  value: controller.monthlyLimit.value,
                  min: 10,
                  max: 3000,
                  divisions: 299,
                  label: controller.monthlyLimit.value.toStringAsFixed(0),
                  onChanged: (val) => controller.monthlyLimit.value = val,
                );
              }),
              Text(
                '${controller.monthlyLimit.value.toStringAsFixed(0)} L/min',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              Obx(() {
                return CheckboxListTile(
                  title: const Text('Acepto los términos y condiciones'),
                  value: controller.termsAccepted.value,
                  onChanged:
                      (val) => controller.termsAccepted.value = val ?? false,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.continueIfValid,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Comenzar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
