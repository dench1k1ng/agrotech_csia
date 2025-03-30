import 'package:flutter/material.dart';
import 'dart:io';

import 'package:intl/intl.dart';

class BatchCard extends StatelessWidget {
  final String name;
  final String date;
  final String status;
  final String? imagePath;
  final VoidCallback onTap;
  final bool showBottomNavigation;

  const BatchCard({
    required this.name,
    required this.date,
    required this.status,
    this.imagePath,
    required this.onTap,
    this.showBottomNavigation = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with error handling
                _buildImageSection(),
                // Text section
                _buildTextSection(),
              ],
            ),
          ),
        ),
        if (showBottomNavigation) _buildBottomNavigationBar(),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 120, // Fixed height for all cards
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        color: Colors.grey[200],
      ),
      child:
          (imagePath != null && imagePath!.isNotEmpty)
              ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholder(),
                ),
              )
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.photo_camera, size: 45, color: Colors.grey[500]),
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "Статус: $status",
                style: TextStyle(fontSize: 12, color: _getStatusColor(status)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? harvestDate) {
    if (harvestDate == null || harvestDate.isEmpty) {
      return Colors.grey; // Если дата созревания не указана
    }

    // Преобразуем строку в DateTime
    DateTime harvestDateTime;
    try {
      harvestDateTime = DateFormat(
        'dd MMM yyyy',
      ).parse(harvestDate); // Преобразуем строку в DateTime
    } catch (e) {
      return Colors
          .grey; // Если не удалось преобразовать строку в дату, возвращаем серый
    }

    final now = DateTime.now();

    // Сравниваем текущую дату с датой созревания
    if (harvestDateTime.isBefore(now)) {
      return Colors.green; // Если дата созревания прошла, ставим зелёный
    } else if (harvestDateTime.isAfter(now)) {
      print(harvestDateTime.toString());
      return Colors
          .orange; // Если дата созревания ещё не наступила, ставим оранжевый
    } else {
      return Colors
          .grey; // Если дата созревания невалидна или ошибка в вычислениях
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home'),
          _buildNavItem(Icons.person, 'Profile'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
