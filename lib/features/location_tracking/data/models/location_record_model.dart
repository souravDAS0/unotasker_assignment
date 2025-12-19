import 'dart:convert';

import '../../domain/entities/geocoding_error_type.dart';
import '../../domain/entities/location_record.dart';

/// Data model for LocationRecord with JSON serialization.
/// Extends the domain entity and adds serialization capabilities.
class LocationRecordModel extends LocationRecord {
  @override
  final DateTime timestamp;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String address;
  @override
  final GeocodingErrorType? geocodingError;

  const LocationRecordModel({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.geocodingError,
  }) : super(
         timestamp: timestamp,
         latitude: latitude,
         longitude: longitude,
         address: address,
         geocodingError: geocodingError,
       );

  /// Converts this model to a domain entity.
  LocationRecord toEntity() {
    return LocationRecord(
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      address: address,
      geocodingError: geocodingError,
    );
  }

  /// Creates a model from a domain entity.
  factory LocationRecordModel.fromEntity(LocationRecord entity) {
    return LocationRecordModel(
      timestamp: entity.timestamp,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      geocodingError: entity.geocodingError,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'geocodingError': geocodingError?.name,
    };
  }

  /// Creates a model from a JSON map.
  factory LocationRecordModel.fromJson(Map<String, dynamic> json) {
    return LocationRecordModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      geocodingError: json['geocodingError'] != null
          ? GeocodingErrorType.values.firstWhere(
              (e) => e.name == json['geocodingError'],
              orElse: () => GeocodingErrorType.unknown,
            )
          : null,
    );
  }

  /// Encodes this model to a JSON string for Hive storage.
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Decodes a model from a JSON string from Hive storage.
  factory LocationRecordModel.fromJsonString(String jsonString) {
    return LocationRecordModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'LocationRecordModel(timestamp: $timestamp, latitude: $latitude, longitude: $longitude, address: $address, geocodingError: $geocodingError)';
  }
}
