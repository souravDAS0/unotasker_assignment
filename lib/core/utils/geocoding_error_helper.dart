import 'package:flutter/material.dart';

import '../../features/location_tracking/domain/entities/geocoding_error_type.dart';
import '../constants/app_theme.dart';

/// Helper class for geocoding error UI presentation.
/// Provides centralized logic for displaying error messages, icons, and colors.
class GeocodingErrorHelper {
  GeocodingErrorHelper._();

  /// Get user-friendly error message for error type
  static String getErrorMessage(GeocodingErrorType errorType) {
    switch (errorType) {
      case GeocodingErrorType.networkError:
        return 'No internet connection';
      case GeocodingErrorType.serviceUnavailable:
        return 'Geocoding service unavailable';
      case GeocodingErrorType.noAddressFound:
        return 'No address found for location';
      case GeocodingErrorType.invalidCoordinates:
        return 'Invalid coordinates';
      case GeocodingErrorType.unknown:
        return 'Geocoding error';
      case GeocodingErrorType.none:
        return '';
    }
  }

  /// Get icon for error type
  static IconData getErrorIcon(GeocodingErrorType errorType) {
    switch (errorType) {
      case GeocodingErrorType.networkError:
        return Icons.wifi_off;
      case GeocodingErrorType.serviceUnavailable:
        return Icons.cloud_off;
      case GeocodingErrorType.noAddressFound:
        return Icons.location_off;
      case GeocodingErrorType.invalidCoordinates:
        return Icons.error_outline;
      case GeocodingErrorType.unknown:
        return Icons.warning;
      case GeocodingErrorType.none:
        return Icons.check_circle;
    }
  }

  /// Get badge foreground color for error type
  static Color getBadgeColor(GeocodingErrorType errorType) {
    switch (errorType) {
      case GeocodingErrorType.networkError:
        return AppTheme.errorRed; // Red for critical errors
      case GeocodingErrorType.serviceUnavailable:
        return const Color(0xFFf59e0b); // Amber for temporary issues
      case GeocodingErrorType.noAddressFound:
        return AppTheme.gray400; // Gray for expected scenarios
      case GeocodingErrorType.invalidCoordinates:
        return AppTheme.errorRed; // Red for critical errors
      case GeocodingErrorType.unknown:
        return const Color(0xFFf59e0b); // Amber for unknown issues
      case GeocodingErrorType.none:
        return AppTheme.successGreen; // Green for success
    }
  }

  /// Get badge background color for error type
  static Color getBadgeBackgroundColor(GeocodingErrorType errorType) {
    switch (errorType) {
      case GeocodingErrorType.networkError:
        return const Color(0xFFfee2e2); // Light red background
      case GeocodingErrorType.serviceUnavailable:
        return const Color(0xFFfef3c7); // Light amber background
      case GeocodingErrorType.noAddressFound:
        return AppTheme.gray100; // Light gray background
      case GeocodingErrorType.invalidCoordinates:
        return const Color(0xFFfee2e2); // Light red background
      case GeocodingErrorType.unknown:
        return const Color(0xFFfef3c7); // Light amber background
      case GeocodingErrorType.none:
        return const Color(0xFFd1fae5); // Light green background
    }
  }
}
