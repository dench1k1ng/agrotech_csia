import 'package:flutter/material.dart';
import 'dart:io';

class BatchDetailScreen extends StatelessWidget {
  final Map<String, dynamic> batch;

  const BatchDetailScreen({Key? key, required this.batch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          batch['name'] ?? 'Детали партии',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Карточка с изображением
            Hero(
              tag: 'batch-image-${batch['name']}',
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
                      batch['imagePath'] != null &&
                              batch['imagePath'].isNotEmpty
                          ? Image.file(
                            File(batch['imagePath']),
                            fit: BoxFit.cover,
                          )
                          : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.eco,
                                size: 80,
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
                  _buildDetailItem(
                    Icons.local_florist,
                    'Название',
                    batch['name'],
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.calendar_today,
                    'Дата посева',
                    batch['date'],
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.thermostat,
                    'Статус',
                    batch['status'],
                    statusColor: _getStatusColor(batch['status']),
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.location_on,
                    'Местоположение',
                    batch['location'],
                  ),
                  _buildDivider(),
                  _buildDetailItem(
                    Icons.format_list_numbered,
                    'Количество',
                    batch['quantity'],
                  ),
                ],
              ),
            ),

            // Заметки (если есть)
            if (batch['notes'] != null && batch['notes'].isNotEmpty) ...[
              SizedBox(height: 30),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes, color: Colors.green[700], size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Заметки',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      batch['notes'],
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
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
