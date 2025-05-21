import 'package:flow_sensor_app/modules/link_device/linked_device_model.dart';
import 'package:flow_sensor_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'link_device_controller.dart';

class LinkDeviceView extends StatelessWidget {
  const LinkDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LinkDeviceController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tus dispositivos')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppPurposeBanner(context),
                const SizedBox(height: 16),
                controller.devices.isEmpty
                    ? Expanded(child: _buildEmptyState(context))
                    : Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dispositivos vinculados",
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.devices.length,
                              itemBuilder: (context, index) {
                                final device = controller.devices[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    title: Text(device.name),
                                    subtitle: Text('Serial: ${device.serial}'),
                                    onTap:
                                        () => Get.toNamed(
                                          AppRoutes.deviceSummary,
                                          arguments: device,
                                        ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => controller.removeDevice(device),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text("Vincular dispositivo"),
      ),
    );
  }

  Widget _buildAppPurposeBanner(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.lightBlue.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.water_drop, color: Colors.blue, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Monitorea tu consumo de agua",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Vincula sensores y visualiza tu consumo en tiempo real. Esta app está diseñada para ayudarte a ahorrar agua y controlar tus dispositivos conectados.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No hay dispositivos vinculados",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Para comenzar a monitorear el consumo de agua, vincula tu primer dispositivo.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed:
                () => _showAddDeviceDialog(
                  context,
                  Get.find<LinkDeviceController>(),
                ),
            icon: const Icon(Icons.add),
            label: const Text("Vincular ahora"),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog(
    BuildContext context,
    LinkDeviceController controller,
  ) {
    final nameController = TextEditingController();
    final serialController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Vincular nuevo dispositivo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del dispositivo',
                    prefixIcon: Icon(Icons.device_hub),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serialController,
                  decoration: const InputDecoration(
                    labelText: 'Serial (ID del backend)',
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final serial = serialController.text.trim();
                  if (name.isNotEmpty && serial.isNotEmpty) {
                    controller.addDevice(
                      LinkedDevice(name: name, serial: serial),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Vincular'),
              ),
            ],
          ),
    );
  }
}
