import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FlowHeatmapChart extends StatelessWidget {
  final Map<DateTime, double> dailyData;

  const FlowHeatmapChart({super.key, required this.dailyData});

  Color _getColorForValue(double? value) {
    if (value == null) return Colors.grey.shade200;

    if (value < 40) return Colors.blue.shade100;
    if (value < 60) return Colors.blue.shade300;
    if (value < 130) return Colors.blue.shade600;
    return Colors.blue.shade900;
  }

  Color _getTextColor(double? value) {
    if (value == null) return Colors.black54;

    // Texto claro para colores oscuros y oscuro para colores claros
    if (value < 200) {
      return Colors.black87;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue.shade700),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.blue.shade700,
        ),
      ),
      calendarStyle: CalendarStyle(
        defaultDecoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade400,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.7),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        weekendDecoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dateKey = DateTime(day.year, day.month, day.day);
          final value = dailyData[dateKey];
          final color = _getColorForValue(value);
          final textColor = _getTextColor(value);

          return Tooltip(
            message:
                value != null ? '${value.toStringAsFixed(2)} L' : 'Sin datos',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow:
                    value != null && value > 200
                        ? [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}
