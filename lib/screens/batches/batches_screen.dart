import 'package:agrotech_hacakaton/screens/journal/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';

import 'package:agrotech_hacakaton/screens/batches/add_batch_screen.dart';

class BatchesScreen extends StatefulWidget {
  @override
  _BatchesScreenState createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  List<Batch> _batches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final savedBatches = prefs.getString('batches');

      if (savedBatches != null) {
        final decoded = json.decode(savedBatches) as List;
        setState(() {
          _batches = decoded.map((item) => Batch.fromMap(item)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки данных';
      });
      debugPrint('Error loading batches: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addBatch(Batch newBatch) async {
    try {
      setState(() {
        _batches.add(newBatch);
      });
      await _saveBatches();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении: ${e.toString()}')),
      );
      rethrow;
    }
  }

  Future<void> _removeBatch(int index) async {
    final removedBatch = _batches[index];

    try {
      setState(() {
        _batches.removeAt(index);
      });
      await _saveBatches();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Партия "${removedBatch.name}" удалена'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () async {
              setState(() => _batches.insert(index, removedBatch));
              await _saveBatches();
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении: ${e.toString()}')),
      );
      rethrow;
    }
  }

  Future<void> _saveBatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'batches',
        json.encode(_batches.map((batch) => batch.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving batches: $e');
      rethrow;
    }
  }

  Future<void> _navigateToAddBatch() async {
    final newBatch = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => AddBatchScreen()),
    );

    if (newBatch != null) {
      await _addBatch(Batch.fromMap(newBatch));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои партии'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          if (_batches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _confirmClearAll,
              tooltip: 'Очистить все',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBatch,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBatches,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Нет добавленных партий'),
            const SizedBox(height: 8),
            const Text('Нажмите + чтобы добавить новую'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: _batches.length,
        itemBuilder: (context, index) {
          final batch = _batches[index];
          return _buildBatchCard(batch, index);
        },
      ),
    );
  }

  Widget _buildBatchCard(Batch batch, int index) {
    return Dismissible(
      key: Key(batch.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDismiss(index),
      child: GestureDetector(
        onTap: () => _navigateToJournal(batch),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.grey[200],
                    image:
                        batch.imagePath != null
                            ? DecorationImage(
                              image: FileImage(File(batch.imagePath!)),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      batch.imagePath == null
                          ? Center(
                            child: Icon(
                              Icons.eco,
                              size: 50,
                              color: Colors.green[700],
                            ),
                          )
                          : null,
                ),
              ),
              // Информация
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batch.date,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(batch.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          batch.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(batch.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDismiss(int index) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить партию?'),
            content: Text(
              'Вы уверены, что хотите удалить "${_batches[index].name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Очистить все?'),
            content: const Text('Вы уверены, что хотите удалить все партии?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Очистить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _batches.clear());
      await _saveBatches();
    }
  }

  void _navigateToJournal(Batch batch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BatchJournalScreen(batch: batch)),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('проросл')) return Colors.green;
    if (status.toLowerCase().contains('прорастает')) return Colors.orange;
    return Colors.grey;
  }
}

class Batch {
  final String id;
  final String name;
  final String date;
  final String status;
  final String? imagePath;
  final List<JournalEntry> journalEntries;
  final List<GrowthMeasurement> measurements;

  Batch({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.imagePath,
    this.journalEntries = const [],
    this.measurements = const [],
  });

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? 'Без названия',
      date: map['date'] ?? DateFormat('dd MMM yyyy').format(DateTime.now()),
      status: map['status'] ?? 'Новый',
      imagePath: map['imagePath'],
      journalEntries:
          (map['journalEntries'] as List?)
              ?.map((e) => JournalEntry.fromMap(e))
              .toList() ??
          [],
      measurements:
          (map['measurements'] as List?)
              ?.map((e) => GrowthMeasurement.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'status': status,
      'imagePath': imagePath,
      'journalEntries': journalEntries.map((e) => e.toMap()).toList(),
      'measurements': measurements.map((e) => e.toMap()).toList(),
    };
  }
}

class JournalEntry {
  final String id;
  final DateTime date;
  final String description;
  final String? imagePath;

  JournalEntry({
    required this.id,
    required this.date,
    required this.description,
    this.imagePath,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'imagePath': imagePath,
    };
  }
}

class GrowthMeasurement {
  final String id;
  final DateTime date;
  final double height;

  GrowthMeasurement({
    required this.id,
    required this.date,
    required this.height,
  });

  factory GrowthMeasurement.fromMap(Map<String, dynamic> map) {
    return GrowthMeasurement(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(map['date']),
      height: (map['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date.toIso8601String(), 'height': height};
  }
}
