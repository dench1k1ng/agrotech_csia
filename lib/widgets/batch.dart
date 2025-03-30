import 'package:flutter/material.dart';

class Batch {
  final String id;
  final String name;
  final String date;
  final String status;
  final String location;
  final String quantity;
  final String wateringTime;
  final double initialHeight;
  final String specialConditions;
  final String? imagePath;

  Batch({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.location,
    required this.quantity,
    required this.wateringTime,
    required this.initialHeight,
    required this.specialConditions,
    this.imagePath,
  });
}
