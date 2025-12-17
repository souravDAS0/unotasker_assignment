/// Pure Dart entity representing a location record.
/// This class has ZERO external dependencies (framework-agnostic).
class LocationRecord {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;

  const LocationRecord({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationRecord &&
        other.timestamp == timestamp &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        address.hashCode;
  }

  @override
  String toString() {
    return 'LocationRecord(timestamp: $timestamp, latitude: $latitude, longitude: $longitude, address: $address)';
  }

  /// Creates a copy of this LocationRecord with the given fields replaced.
  LocationRecord copyWith({
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return LocationRecord(
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}
