import 'dart:io';

import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:flutter/material.dart';
import 'package:agrotech_hacakaton/data/batches_data.dart';

// Пример модели данных для записи в журнале
class JournalEntry {
  final DateTime date;
  final String description;
  final String? imagePath;

  JournalEntry({required this.date, required this.description, this.imagePath});
}

// Пример экрана журнала
class JournalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Журнал наблюдений')),
      body:
          batches.isEmpty
              ? const Center(child: Text('Нет добавленных партий'))
              : ListView.builder(
                itemCount: batches.length,
                itemBuilder: (ctx, index) {
                  final batchData = batches[index];
                  final batch = Batch.fromMap(
                    batchData,
                  ); // Convert Map to Batch
                  return ListTile(
                    title: Text(batch.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BatchJournalScreen(batch: batch),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

// Экран журнала для конкретной партии
class BatchJournalScreen extends StatefulWidget {
  final Batch batch; // ✅ Исправлено с Match на Batch

  const BatchJournalScreen({required this.batch});

  @override
  _BatchJournalScreenState createState() => _BatchJournalScreenState();
}

class _BatchJournalScreenState extends State<BatchJournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.batch.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.batch.journalEntries.length,
              itemBuilder: (ctx, index) {
                final entry = widget.batch.journalEntries[index];
                return ListTile(
                  title: Text(entry.description),
                  subtitle: Text("${entry.date.toLocal()}".split(' ')[0]),
                  leading:
                      entry.imagePath != null
                          ? Image.file(
                            File(entry.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : Icon(Icons.notes),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Реализация добавления записи в журнал
            },
            child: Text("Добавить запись"),
          ),
        ],
      ),
    );
  }
}
