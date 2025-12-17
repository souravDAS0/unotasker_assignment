import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_record.dart';

part 'location_record_model.g.dart';

/// Data model for LocationRecord with Hive annotations for persistence.
/// Extends the domain entity and adds serialization capabilities.
@HiveType(typeId: AppConstants.locationRecordTypeId)
class LocationRecordModel extends LocationRecord {
  @HiveField(0)
  @override
  final DateTime timestamp;

  @HiveField(1)
  @override
  final double latitude;

  @HiveField(2)
  @override
  final double longitude;

  @HiveField(3)
  @override
  final String address;

  const LocationRecordModel({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
  }) : super(
          timestamp: timestamp,
          latitude: latitude,
          longitude: longitude,
          address: address,
        );

  /// Converts this model to a domain entity.
  LocationRecord toEntity() {
    return LocationRecord(
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  /// Creates a model from a domain entity.
  factory LocationRecordModel.fromEntity(LocationRecord entity) {
    return LocationRecordModel(
      timestamp: entity.timestamp,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
    );
  }

  @override
  String toString() {
    return 'LocationRecordModel(timestamp: $timestamp, latitude: $latitude, longitude: $longitude, address: $address)';
  }
}
