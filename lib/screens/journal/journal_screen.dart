import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JournalScreen extends StatefulWidget {
  final Batch batch;

  const JournalScreen({required this.batch, Key? key}) : super(key: key);

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late List<JournalEntry> _entries;
  late List<GrowthMeasurement> _growthMeasurements;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.batch.journalEntries);
    _growthMeasurements = List.from(widget.batch.growthMeasurements);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedData = _prefs.getString('journal_${widget.batch.id}');
    if (savedData != null) {
      final decoded = json.decode(savedData) as Map<String, dynamic>;
      setState(() {
        _entries =
            (decoded['entries'] as List)
                .map((e) => JournalEntry.fromMap(e))
                .toList();
        _growthMeasurements =
            (decoded['measurements'] as List)
                .map((e) => GrowthMeasurement.fromMap(e))
                .toList();
      });
    }
  }

  Future<void> _saveData() async {
    final dataToSave = {
      'entries': _entries.map((e) => e.toMap()).toList(),
      'measurements': _growthMeasurements.map((m) => m.toMap()).toList(),
    };
    await _prefs.setString(
      'journal_${widget.batch.id}',
      json.encode(dataToSave),
    );
  }

  Future<void> _addEntry(double height, String notes) async {
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

    await _saveData();
  }

  Future<void> _deleteEntry(int index) async {
    setState(() {
      _entries.removeAt(index);
      if (index < _growthMeasurements.length) {
        _growthMeasurements.removeAt(index);
      }
    });
    await _saveData();
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
      await _addEntry(height, notes);
    }
  }

  Widget _buildGrowthChart() {
    if (_growthMeasurements.isEmpty) {
      return const Center(child: Text('Нет данных для построения графика'));
    }

    _growthMeasurements.sort((a, b) => a.date.compareTo(b.date));

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
      appBar: AppBar(
        title: Text('Журнал: ${widget.batch.name}'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Очистить журнал',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Очистить журнал?'),
                        content: const Text(
                          'Все записи будут удалены безвозвратно',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Очистить'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  setState(() {
                    _entries.clear();
                    _growthMeasurements.clear();
                  });
                  await _saveData();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildGrowthChart(),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Dismissible(
                  key: Key('${entry.date.millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Удалить запись?'),
                            content: Text(
                              'Запись от ${DateFormat('dd.MM.yyyy').format(entry.date)} будет удалена',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Удалить'),
                              ),
                            ],
                          ),
                    );
                  },
                  onDismissed: (direction) => _deleteEntry(index),
                  child: ListTile(
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
                  ),
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
