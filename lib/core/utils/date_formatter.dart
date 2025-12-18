import 'package:intl/intl.dart';

/// Utility class for formatting dates and times throughout the application.
class DateFormatter {
  DateFormatter._();

  /// Formats a DateTime to a full timestamp string.
  /// Example: "Dec 17, 2025 - 10:30 AM"
  static String formatTimestamp(DateTime dateTime) {
    final datePart = DateFormat('MMM dd, yyyy').format(dateTime);
    final timePart = DateFormat('hh:mm:ss a').format(dateTime);
    return '$datePart - $timePart';
  }

  /// Formats a DateTime to show only the time.
  /// Example: "10:30 AM"
  static String formatTimeOnly(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime);
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

  /// Formats a DateTime to show relative time (e.g., "2m ago", "1h ago").
  /// Useful for showing how long ago a location was recorded.
  ///
  /// Examples:
  /// - Less than 1 minute: "Just now"
  /// - 1-59 minutes: "2m ago", "45m ago"
  static String getRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }
}
