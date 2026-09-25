import 'package:intl/intl.dart';

/// Centralized data formatting helpers.
class Formatters {
  Formatters._();

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  static String formatDateShort(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}';
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String scoreLabel(int score) {
    if (score >= 90) return 'Flawless Form';
    if (score >= 80) return 'Good Form';
    if (score >= 70) return 'Fair Form';
    if (score >= 60) return 'Needs Practice';
    return 'Improper Form';
  }
}
