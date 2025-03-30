import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JournalScreen extends StatefulWidget {
  final Batch batch; // Получаем выбранную партию

  JournalScreen({required this.batch});

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late List<JournalEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.batch.journalEntries;
    _saveEntries();
  }

  // Сохраняем записи в SharedPreferences
  _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final batchMap = widget.batch.toMap();
    prefs.setString(widget.batch.id, json.encode(batchMap));
  }

  // Добавляем новую запись в журнал
  _addEntry(double height, String notes) {
    final newEntry = JournalEntry(
      date: DateTime.now(),
      height: height,
      notes: notes,
    );

    setState(() {
      _entries.add(newEntry);
    });

    // Обновляем записи в batch
    widget.batch.journalEntries.add(newEntry);
    _saveEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Журнал для ${widget.batch.name}')),
      body: ListView.builder(
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
              _addEntry(height, notes);
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
