/// Base class for all failures in the application.
/// Failures represent expected errors that should be handled gracefully.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Failure related to location services.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Failure related to permissions.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Failure related to local storage operations.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Failure related to notification operations.
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

/// Failure related to background service operations.
class BackgroundServiceFailure extends Failure {
  const BackgroundServiceFailure(super.message);
}

/// Failure related to geocoding operations.
class GeocodingFailure extends Failure {
  const GeocodingFailure(super.message);
}
