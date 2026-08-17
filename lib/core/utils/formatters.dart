import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm:ss');

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatTimeOnly(DateTime dateTime) {
    return _timeOnlyFormat.format(dateTime);
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatScore(double value) {
    return value.toStringAsFixed(1);
  }

  static String formatDouble(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }
}
