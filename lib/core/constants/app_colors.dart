import 'package:flutter/material.dart';

class AppColors {
  // Status Colors
  static const Color normal = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber / Yellow
  static const Color fault = Color(0xFFEF4444); // Red
  static const Color critical = Color(0xFFDC2626); // Dark Red
  static const Color noData = Color(0xFF6B7280); // Grey
  static const Color offline = Color(0xFF9CA3AF); // Light Grey

  // Connection Colors
  static const Color connected = Color(0xFF10B981);
  static const Color connecting = Color(0xFF3B82F6);
  static const Color disconnected = Color(0xFFEF4444);
  static const Color error = Color(0xFFDC2626);

  // Maintenance Priority Colors
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFEF4444);

  // Chart Lines
  static const Color chartVibration = Color(0xFF8B5CF6);
  static const Color chartTemperature = Color(0xFFF97316);
  static const Color chartRPM = Color(0xFF06B6D4);
  static const Color chartCurrent = Color(0xFF3B82F6);
  static const Color chartVoltage = Color(0xFF10B981);
  static const Color chartPower = Color(0xFFEC4899);
  static const Color chartLoad = Color(0xFF6366F1);
  static const Color chartHealth = Color(0xFF10B981);
}
