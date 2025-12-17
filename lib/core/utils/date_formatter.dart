import 'package:intl/intl.dart';

/// Utility class for formatting dates and times throughout the application.
class DateFormatter {
  DateFormatter._();

  /// Formats a DateTime to a full timestamp string.
  /// Example: "Dec 17, 2025 - 10:30 AM"
  static String formatTimestamp(DateTime dateTime) {
    final datePart = DateFormat('MMM dd, yyyy').format(dateTime);
    final timePart = DateFormat('hh:mm a').format(dateTime);
    return '$datePart - $timePart';
  }

  /// Formats a DateTime to show only the time.
  /// Example: "10:30 AM"
  static String formatTimeOnly(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Formats a DateTime to show only the date.
  /// Example: "Dec 17, 2025"
  static String formatDateOnly(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  /// Formats a DateTime to a compact format.
  /// Example: "12/17/25 10:30 AM"
  static String formatCompact(DateTime dateTime) {
    return DateFormat('MM/dd/yy hh:mm a').format(dateTime);
  }
}
