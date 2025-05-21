import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FlowChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const FlowChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty)
      return const Center(child: Text("Sin datos para graficar"));

    final textStyle = TextStyle(
      color: Colors.grey[700],
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );

    // Obtener el máximo flujo para ajustar escala Y
    final maxFlow = data
        .map((e) => e['flujo'] as double)
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxFlow * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxFlow / 4,
            getDrawingHorizontalLine:
                (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: (data.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  final time = data[index]['created'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                        style: textStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxFlow / 4,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(1), style: textStyle);
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = data[spot.x.toInt()]['created'] as DateTime;
                  return LineTooltipItem(
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}\n${spot.y.toStringAsFixed(2)} L/min',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index]['flujo']),
              ),
              isCurved: true,
              color: Colors.blue.shade400,
              barWidth: 2,
              dotData: FlDotData(
                show: false, // <-- Ocultamos los puntos
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade200.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
