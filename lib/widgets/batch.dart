import 'package:flutter/material.dart';

class Batch {
  final String id;
  final String name;
  final String date;
  final String status;
  final String? imagePath;

  Batch({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.imagePath,
  });

  // Конструктор из Map
  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Без названия',
      date: map['date'] ?? 'Не указана',
      status: map['status'] ?? 'Неизвестен',
      imagePath: map['imagePath'],
    );
  }

  // Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'status': status,
      'imagePath': imagePath,
    };
  }
}
