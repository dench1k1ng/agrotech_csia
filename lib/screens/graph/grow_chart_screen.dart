// Пример экрана с графиком
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 1. Сначала создаем модель данных
class GrowthMeasurement {
  final DateTime date;
  final double height;

  GrowthMeasurement({required this.date, required this.height});
}

// 2. Корректный экран с графиком
class GrowthChartScreen extends StatefulWidget {
  final List<GrowthMeasurement> measurements;

  const GrowthChartScreen({required this.measurements, Key? key})
    : super(key: key);

  @override
  _GrowthChartScreenState createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('График роста')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          widget.measurements.map((m) {
                            // Преобразуем дату в дни относительно первой даты
                            final firstDate = widget.measurements.first.date;
                            final daysDiff =
                                m.date.difference(firstDate).inDays.toDouble();
                            return FlSpot(daysDiff, m.height);
                          }).toList(),
                      isCurved: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                  minX: 0,
                  maxX:
                      widget.measurements.length > 1
                          ? widget.measurements.last.date
                              .difference(widget.measurements.first.date)
                              .inDays
                              .toDouble()
                          : 1,
                  minY: 0,
                  maxY:
                      widget.measurements.fold(
                        0.0,
                        (max, m) => m.height > max ? m.height : max,
                      ) +
                      2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() < widget.measurements.length) {
                            final date =
                                widget.measurements[value.toInt()].date;
                            return Text(DateFormat('MMM dd').format(date));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
