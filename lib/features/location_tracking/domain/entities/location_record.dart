import 'geocoding_error_type.dart';

/// Pure Dart entity representing a location record.
/// This class has ZERO external dependencies (framework-agnostic).
class LocationRecord {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;
  final GeocodingErrorType? geocodingError;

  const LocationRecord({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.geocodingError,
  });

  /// Helper method to check if geocoding encountered an error
  bool get hasGeocodingError =>
      geocodingError != null && geocodingError != GeocodingErrorType.none;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationRecord &&
        other.timestamp == timestamp &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.geocodingError == geocodingError;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        address.hashCode ^
        geocodingError.hashCode;
  }

  @override
  String toString() {
    return 'LocationRecord(timestamp: $timestamp, latitude: $latitude, longitude: $longitude, address: $address, geocodingError: $geocodingError)';
  }
}
