import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailySummaryChart extends StatelessWidget {
  final Map<String, double> dailySummary;

  const DailySummaryChart({super.key, required this.dailySummary});

  @override
  Widget build(BuildContext context) {
    final entries = dailySummary.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text("No hay datos para mostrar."));
    }

    // Calcular el máximo valor para ajustar la escala
    final maxValue = entries
        .map((e) => e.value)
        .reduce((value, element) => value > element ? value : element);
    final maxY = maxValue * 1.2; // margen del 20% para no quedar pegado al tope

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5, // Dividir en 5 líneas de escala
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    final date = entries[index].key;
                    return Text(
                      date.substring(5), // MM-DD
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(entries.length, (index) {
            final litros = entries[index].value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: litros,
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade200.withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY, // Ajustar fondo a la escala dinámica
                    color: Colors.blue.shade100.withOpacity(0.3),
                  ),
                ),
              ],
            );
          }),
          maxY: maxY, // Asignar el máximo dinámico calculado
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blue.shade300,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = entries[group.x.toInt()].key;
                return BarTooltipItem(
                  '$date\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${rod.toY.toStringAsFixed(2)} L',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
