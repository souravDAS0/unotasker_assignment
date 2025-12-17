import '../entities/location_record.dart';

abstract class LocationRepository {
  /// Requests location permissions from the user.
  /// Returns true if permissions are granted, false otherwise.
  Future<bool> requestPermissions();

  /// Checks if location permissions are currently granted.
  Future<bool> hasPermissions();

  /// Fetches the current GPS location.
  /// Returns latitude and longitude coordinates.
  /// Throws [LocationException] if location services are unavailable.
  Future<Map<String, double>> getCurrentLocation();

  /// Converts GPS coordinates to a human-readable address.
  /// Returns the formatted address string or 'Address unavailable' on failure.
  Future<String> geocodeLocation(double latitude, double longitude);

  /// Saves a location record to local storage.
  Future<void> saveRecord(LocationRecord record);

  /// Retrieves all saved location records from local storage.
  /// Returns records in reverse chronological order (newest first).
  Future<List<LocationRecord>> getAllRecords();

  /// Deletes all location records from local storage.
  /// Called when tracking is stopped.
  Future<void> deleteAllRecords();

  /// Shows a persistent notification with location data.
  Future<void> showNotification(LocationRecord record);

  /// Updates the existing notification with new location data.
  Future<void> updateNotification(LocationRecord record);

  /// Clears the persistent notification.
  Future<void> clearNotification();

  /// Starts the background service for periodic location tracking.
  Future<void> startBackgroundService();

  /// Stops the background service and cancels periodic location tracking.
  Future<void> stopBackgroundService();

  /// Checks if the background service is currently running.
  /// Returns true if active, false otherwise.
  Future<bool> checkServiceStatus();
}
