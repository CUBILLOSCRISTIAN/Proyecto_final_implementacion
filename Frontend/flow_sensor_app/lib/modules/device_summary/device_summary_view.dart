import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flow_sensor_app/shared/widgets/build_legend_row.dart';
import 'package:flow_sensor_app/shared/widgets/daily_summary_chart.dart';
import 'package:flow_sensor_app/shared/widgets/device_summary_shimmer.dart';
import 'package:flow_sensor_app/shared/widgets/flow_chart.dart';
import 'package:flow_sensor_app/shared/widgets/flow_heatmap_chart.dart';
import 'package:flow_sensor_app/shared/widgets/show_info_dialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'device_summary_controller.dart';

class DeviceSummaryView extends StatelessWidget {
  const DeviceSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeviceSummaryController>();
    

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const DeviceSummaryShimmer();
          } else if (controller.chartData.isEmpty) {
            return const Center(child: Text("Sin datos"));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, controller),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Resumen rápido"),
                  const SizedBox(height: 8),
                  statsDashboard(controller),
                  const SizedBox(height: 24),
                  _sectionCard(
                    context,
                    title: "Flujo en tiempo real",
                    icon: Icons.timeline,
                    child: SizedBox(
                      height: 300,
                      child: FlowChart(data: controller.chartData),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionCard(
                    context,
                    title: "Consumo diario",
                    icon: Icons.bar_chart,
                    child: DailySummaryChart(
                      dailySummary: controller.dailySummary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionCard(
                    context,
                    title: "Mapa de calor",
                    icon: Icons.calendar_month,
                    onInfoTap:
                        () => showInfoDialog(
                          context,
                          title: "Leyenda del mapa de calor",
                          iconColor: Colors.blue.shade700,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLegendRow(
                                Colors.blue.shade100,
                                "Consumo bajo (menos de 100 L)",
                              ),
                              buildLegendRow(
                                Colors.blue.shade300,
                                "Consumo moderado (100 - 199 L)",
                              ),
                              buildLegendRow(
                                Colors.blue.shade600,
                                "Consumo alto (200 - 299 L)",
                              ),
                              buildLegendRow(
                                Colors.blue.shade900,
                                "Consumo muy alto (300 L o más)",
                              ),
                              const SizedBox(height: 8),
                              buildLegendRow(
                                Colors.grey.shade200,
                                "Sin datos disponibles",
                              ),
                            ],
                          ),
                        ),
                    child: FlowHeatmapChart(
                      dailyData: controller.dailySummary.map(
                        (key, value) => MapEntry(DateTime.parse(key), value),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }


  Widget _header(BuildContext context, DeviceSummaryController controller) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final name = snapshot.hasData
            ? (snapshot.data!.getString('username') ?? "Usuario")
            : "Usuario";
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hola, $name",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    DateFormat("MMMM d 'del' yyyy", 'es_ES').format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    bool isAwayFromHome = false;
    final dailyLimitController = TextEditingController();
    final monthlyLimitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Configuración"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dailyLimitController,
                decoration: const InputDecoration(
                  labelText: "Límite diario (L)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: monthlyLimitController,
                decoration: const InputDecoration(
                  labelText: "Límite mensual (L)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) {
                  return SwitchListTile(
                    value: isAwayFromHome,
                    onChanged: (value) {
                      setState(() => isAwayFromHome = value);
                      // Aquí puedes guardar esta preferencia en tu controlador o base de datos
                    },
                    title: const Text("Modo 'Fuera de casa'"),
                    subtitle: const Text(
                      "Actívalo si no estás en casa. Si se detecta consumo, recibirás una alerta.",
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para guardar configuración
                Get.back();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget statsDashboard(DeviceSummaryController controller) {
    return Obx(() {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildStatCard(
            "Actual",
            controller.latestFlow.value,
            color: Colors.blue,
          ),
          _buildStatCard(
            "Promedio",
            controller.avgFlow.value,
            color: Colors.orange,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, double value, {Color? color}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              "${value.toStringAsFixed(2)} L/min",
              style: TextStyle(fontSize: 18, color: color ?? Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    VoidCallback? onInfoTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onInfoTap != null)
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.blue.shade700),
                    onPressed: onInfoTap,
                    tooltip: 'Información',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
