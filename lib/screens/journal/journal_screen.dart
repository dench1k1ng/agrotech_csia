import 'dart:convert';

import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalScreen extends StatefulWidget {
  final Batch batch;

  JournalScreen({required this.batch});

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late List<JournalEntry> _entries;
  late List<GrowthMeasurement> _growthMeasurements;

  @override
  void initState() {
    super.initState();
    _entries = widget.batch.journalEntries;
    _growthMeasurements =
        widget.batch.growthMeasurements; // Инициализируем измерения роста
  }

  // Добавляем новую запись в журнал и обновляем график
  _addEntry(double height, String notes) {
    final newEntry = JournalEntry(
      date: DateTime.now(),
      height: height,
      notes: notes,
    );

    setState(() {
      _entries.add(newEntry);
      // Добавляем измерение роста в график
      _growthMeasurements.add(
        GrowthMeasurement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          height: height,
        ),
      );
    });

    // После обновления данных, можно обновить график
    _updateGraph();
  }

  // Обновление графика (можно использовать зависимости от библиотеки для графиков, например, charts_flutter)
  _updateGraph() {
    // Логика обновления графика (например, пересоздавать график с новыми данными)
    setState(() {
      // Пример обновления графика
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Журнал для ${widget.batch.name}')),
      body: Column(
        children: [
          // Здесь вы можете отобразить график, используя _growthMeasurements
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return ListTile(
                  title: Text('${entry.date.toLocal()}'),
                  subtitle: Text(
                    'Высота: ${entry.height} см, Заметки: ${entry.notes}',
                  ),
                );
              },
            ),
          ),
          // Пример отображения графика с использованием _growthMeasurements
          // Например, для отображения графика с помощью charts_flutter:
          // charts_flutter.ChartWidget(data: _growthMeasurements),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Окно для добавления новой записи
          final result = await showDialog<List<String>>(
            context: context,
            builder: (context) {
              final heightController = TextEditingController();
              final notesController = TextEditingController();
              return AlertDialog(
                title: Text('Добавить запись'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: heightController,
                      decoration: InputDecoration(labelText: 'Высота растения'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(labelText: 'Заметки'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      final height = double.tryParse(heightController.text);
                      if (height != null) {
                        Navigator.of(
                          context,
                        ).pop([heightController.text, notesController.text]);
                      }
                    },
                    child: Text('Добавить'),
                  ),
                ],
              );
            },
          );

          if (result != null && result.isNotEmpty) {
            final height = double.tryParse(result[0]);
            final notes = result[1];

            if (height != null) {
              _addEntry(height, notes); // Добавляем запись в журнал
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Логика для добавления новой записи

  _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final batchMap = widget.batch.toMap();
    prefs.setString(widget.batch.id, json.encode(batchMap));
  }
}
