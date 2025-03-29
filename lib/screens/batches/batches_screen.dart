import 'dart:io';
import 'package:agrotech_hacakaton/screens/batches/add_batch_screen.dart';
import 'package:agrotech_hacakaton/screens/batches/batch_detail_screen.dart';
import 'package:agrotech_hacakaton/widgets/batch_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BatchesScreen extends StatefulWidget {
  @override
  _BatchesScreenState createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  List<Map<String, dynamic>> _batches = [];
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
          _batches =
              decoded.map((item) => Map<String, dynamic>.from(item)).toList();
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

  Future<void> _addBatch(Map<String, dynamic> newBatch) async {
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
          content: Text('Партия "${removedBatch['name']}" удалена'),
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
      await prefs.setString('batches', json.encode(_batches));
    } catch (e) {
      debugPrint('Error saving batches: $e');
      rethrow;
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
              icon: Icon(Icons.delete_sweep),
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
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadBatches, child: Text('Повторить')),
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
            SizedBox(height: 16),
            Text('Нет добавленных партий'),
            SizedBox(height: 8),
            Text('Нажмите + чтобы добавить новую'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: _batches.length,
        itemBuilder: (context, index) {
          final batch = _batches[index];
          return Dismissible(
            key: ValueKey(batch['name'] + index.toString()),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) => _confirmDismiss(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: BatchCard(
              name: batch['name'] ?? 'Без названия',
              date: batch['date'] ?? 'Дата не указана',
              status: batch['status'] ?? 'Статус неизвестен',
              imagePath: batch['imagePath'] ?? '',
              onTap: () => _showBatchDetails(batch),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDismiss(int index) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Удалить партию?'),
            content: Text(
              'Вы уверены, что хотите удалить "${_batches[index]['name']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Удалить', style: TextStyle(color: Colors.red)),
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
            title: Text('Очистить все?'),
            content: Text('Вы уверены, что хотите удалить все партии?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Очистить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _batches.clear());
      await _saveBatches();
    }
  }

  Future<void> _navigateToAddBatch() async {
    final newBatch = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => AddBatchScreen()),
    );

    if (newBatch != null) {
      await _addBatch(newBatch);
    }
  }

  void _showBatchDetails(Map<String, dynamic> batch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BatchDetailScreen(batch: batch)),
    );
  }

  @override
  void dispose() {
    // Можно добавить очистку контроллеров, если они есть
    super.dispose();
  }
}
