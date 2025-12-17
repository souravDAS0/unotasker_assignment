import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/location_record_model.dart';

/// Abstract interface for local storage operations.
abstract class LocationLocalDataSource {
  /// Saves a location record to local storage.
  Future<void> saveRecord(LocationRecordModel record);

  /// Retrieves all saved location records.
  /// Returns records in reverse chronological order (newest first).
  Future<List<LocationRecordModel>> getAllRecords();

  /// Deletes all location records from local storage.
  Future<void> deleteAllRecords();
}

/// Implementation of LocationLocalDataSource using Hive for persistence.
class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Box<LocationRecordModel> hiveBox;

  LocationLocalDataSourceImpl({required this.hiveBox});

  @override
  Future<void> saveRecord(LocationRecordModel record) async {
    try {
      await hiveBox.add(record);
    } catch (e) {
      throw StorageException('Failed to save location record', e);
    }
  }

  @override
  Future<List<LocationRecordModel>> getAllRecords() async {
    try {
      final records = hiveBox.values.toList();
      // Sort in reverse chronological order (newest first)
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return records;
    } catch (e) {
      throw StorageException('Failed to fetch location records', e);
    }
  }

  @override
  Future<void> deleteAllRecords() async {
    try {
      await hiveBox.clear();
    } catch (e) {
      throw StorageException('Failed to delete location records', e);
    }
  }
}
