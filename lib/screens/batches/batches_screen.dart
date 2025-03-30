import 'package:agrotech_hacakaton/screens/batches/batch_detail_screen.dart';
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
    }
  }

  Future<void> _navigateToAddBatch() async {
    // Переход на экран добавления новой партии и получение данных
    final newBatch = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => AddBatchScreen()),
    );

    // Если данные возвращены, добавляем партию
    if (newBatch != null) {
      final batch = Batch.fromMap(
        newBatch,
      ); // Преобразуем данные в объект Batch
      await _addBatch(batch); // Добавляем партию в список
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
      onDismissed: (_) => _removeBatch(index),
      child: GestureDetector(
        onTap: () => _navigateToDetailScreen(context, batch), // Передаем Batch
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
                        batch.imagePath != null &&
                                File(batch.imagePath!).existsSync()
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

  Future<void> _navigateToDetailScreen(
    BuildContext context,
    Batch batch,
  ) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BatchDetailScreen(batch: batch),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка навигации: ${e.toString()}')),
      );
    }
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
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JournalScreen(batch: batch)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка навигации: ${e.toString()}')),
      );
    }
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
  final String location;
  final String quantity;
  final String? imagePath; // Путь к изображению
  final List<JournalEntry> journalEntries; // Записи журнала
  final double initialHeight; // Начальная высота
  final String specialConditions; // Особые условия
  final String harvestDate;
  final String wateringTime; // Дата полива
  final List<GrowthMeasurement> growthMeasurements; // Измерения роста

  Batch({
    required this.journalEntries,
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.location,
    required this.quantity,
    required this.wateringTime,
    required this.initialHeight,
    required this.specialConditions,
    required this.harvestDate,
    this.imagePath,
    required this.growthMeasurements,
  });

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      journalEntries:
          (map['journalEntries'] as List<dynamic>?)
              ?.map((e) => JournalEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? 'Без названия',
      date: map['date'] ?? DateFormat('dd MMM yyyy').format(DateTime.now()),
      status: map['status'] ?? 'Новый',
      location: map['location'] ?? 'Не указано',
      quantity: map['quantity'] ?? '0',
      wateringTime: map['wateringTime'] ?? 'Не указано',
      initialHeight: (map['initialHeight'] as num?)?.toDouble() ?? 0.0,
      specialConditions: map['specialConditions'] ?? 'Нет',
      harvestDate: map['harvestDate'] ?? 'Не указано',
      imagePath: map['imagePath'],
      growthMeasurements:
          (map['growthMeasurements'] as List<dynamic>?)
              ?.map((e) => GrowthMeasurement.fromMap(e as Map<String, dynamic>))
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
      'location': location,
      'quantity': quantity,
      'imagePath': imagePath,
      'journalEntries': journalEntries.map((entry) => entry.toMap()).toList(),
      'initialHeight': initialHeight,
      'specialConditions': specialConditions,
      'harvestDate': harvestDate,
      'wateringTime': wateringTime,
      'growthMeasurements': growthMeasurements.map((gm) => gm.toMap()).toList(),
    };
  }
}

class JournalEntry {
  final DateTime date;
  final double height;
  final String notes;

  JournalEntry({required this.date, required this.height, required this.notes});

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      date: DateTime.parse(map['date']),
      height: map['height'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date.toIso8601String(), 'height': height, 'notes': notes};
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
