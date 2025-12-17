/// Base class for all custom exceptions in the application.
/// Exceptions represent unexpected errors during operations.
abstract class AppException implements Exception {
  final String message;
  final dynamic cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when location services fail.
class LocationException extends AppException {
  const LocationException(super.message, [super.cause]);

  @override
  String toString() => 'LocationException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when permission requests fail or are denied.
class PermissionException extends AppException {
  const PermissionException(super.message, [super.cause]);

  @override
  String toString() => 'PermissionException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when local storage operations fail.
class StorageException extends AppException {
  const StorageException(super.message, [super.cause]);

  @override
  String toString() => 'StorageException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when notification operations fail.
class NotificationException extends AppException {
  const NotificationException(super.message, [super.cause]);

  @override
  String toString() => 'NotificationException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when background service operations fail.
class BackgroundServiceException extends AppException {
  const BackgroundServiceException(super.message, [super.cause]);

  @override
  String toString() => 'BackgroundServiceException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Exception thrown when geocoding operations fail.
class GeocodingException extends AppException {
  const GeocodingException(super.message, [super.cause]);

  @override
  String toString() => 'GeocodingException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
