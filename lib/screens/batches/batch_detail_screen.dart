import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class BatchDetailScreen extends StatelessWidget {
  final Batch batch;

  const BatchDetailScreen({Key? key, required this.batch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(batch.name ?? 'Детали партии'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Карточка с изображением
            Hero(
              tag: 'batch-image-${batch.name}',
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      batch.imagePath != null && batch.imagePath!.isNotEmpty
                          ? Image.file(
                            File(batch.imagePath!),
                            fit: BoxFit.cover,
                          )
                          : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.eco,
                                size: 50,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Информационная панель
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailItem(Icons.local_florist, 'Название', batch.name),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.calendar_today,
                    'Дата посева',
                    batch.date,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.access_time,
                    'Время полива',
                    batch.wateringTime,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.timeline,
                    'Начальная высота',
                    batch.initialHeight.toString(),
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.event_available,
                    'Дата созревания',
                    batch.harvestDate,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.thermostat,
                    'Статус',
                    batch.status,
                    statusColor: _getStatusColor(batch.status),
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.location_on,
                    'Местоположение',
                    batch.location,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.format_list_numbered,
                    'Количество',
                    batch.quantity,
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.info_outline,
                    'Особые условия',
                    batch.specialConditions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String? value, {
    Color? statusColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  value ?? 'Не указано',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('проросл')) {
      return Colors.green;
    } else if (status.toLowerCase().contains('прорастает')) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}

// Строим элемент информации
Widget _buildDetailItem(
  IconData icon,
  String label,
  String? value, {
  Color? statusColor,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                value ?? 'Не указано',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: statusColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Разделитель
Widget _buildDivider() {
  return Divider(height: 1, color: Colors.grey[200]);
}

// Получаем цвет статуса
Color _getStatusColor(String status) {
  if (status.toLowerCase().contains('проросл')) {
    return Colors.green;
  } else if (status.toLowerCase().contains('прорастает')) {
    return Colors.orange;
  }
  return Colors.grey;
}

class GrowthChartScreen extends StatelessWidget {
  final Map<String, dynamic> batch;

  const GrowthChartScreen({Key? key, required this.batch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Экран для отображения графиков роста (пока заглушка)
    return Scaffold(
      appBar: AppBar(title: Text("Графики роста")),
      body: Center(
        child: Text("Здесь будут графики роста для ${batch['name']}"),
      ),
    );
  }
}
