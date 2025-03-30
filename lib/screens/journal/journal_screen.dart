import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  final Batch batch;

  const JournalScreen({required this.batch, Key? key}) : super(key: key);

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late List<JournalEntry> _entries;
  late List<GrowthMeasurement> _growthMeasurements;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.batch.journalEntries);
    _growthMeasurements = List.from(widget.batch.growthMeasurements);
  }

  void _addEntry(double height, String notes) {
    final newEntry = JournalEntry(
      date: DateTime.now(),
      height: height,
      notes: notes,
    );

    final newMeasurement = GrowthMeasurement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      height: height,
    );

    setState(() {
      _entries.add(newEntry);
      _growthMeasurements.add(newMeasurement);
    });
  }

  void _showAddEntryDialog() async {
    final heightController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Добавить запись'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    labelText: 'Высота растения (см)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Заметки'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  if (heightController.text.isNotEmpty) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Добавить'),
              ),
            ],
          ),
    );

    if (result == true) {
      final height = double.tryParse(heightController.text) ?? 0.0;
      final notes = notesController.text;
      _addEntry(height, notes);
    }
  }

  Widget _buildGrowthChart() {
    if (_growthMeasurements.isEmpty) {
      return const Center(child: Text('Нет данных для построения графика'));
    }

    // Сортируем измерения по дате
    _growthMeasurements.sort((a, b) => a.date.compareTo(b!.date));

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < _growthMeasurements.length) {
                      final date = _growthMeasurements[value.toInt()].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd.MM').format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()} см');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX:
                _growthMeasurements.length > 1
                    ? (_growthMeasurements.length - 1).toDouble()
                    : 1,
            minY: 0,
            maxY:
                _growthMeasurements.fold(
                  0.0,
                  (max, m) => m.height > max ? m.height : max,
                ) +
                5,
            lineBarsData: [
              LineChartBarData(
                spots:
                    _growthMeasurements.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.height);
                    }).toList(),
                isCurved: true,
                color: Colors.green,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withOpacity(0.3),
                ),
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Журнал: ${widget.batch.name}')),
      body: Column(
        children: [
          _buildGrowthChart(),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return ListTile(
                  title: Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(entry.date),
                  ),
                  subtitle: Text('Высота: ${entry.height} см'),
                  trailing:
                      entry.notes.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.note),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Заметки'),
                                      content: Text(entry.notes),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Закрыть'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          )
                          : null,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
