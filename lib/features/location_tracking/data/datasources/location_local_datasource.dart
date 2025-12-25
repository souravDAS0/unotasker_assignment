import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
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

  /// Forces the Hive box to close and reopen to read fresh data from disk.
  /// Useful for cross-isolate data synchronization.
  Future<void> refreshBox();
}

/// Implementation of LocationLocalDataSource using Hive for persistence.
///
/// IMPORTANT: Uses Box<String> with JSON serialization instead of typed box
/// for better cross-isolate data visibility between main app and background service.
class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  LocationLocalDataSourceImpl();

  /// Gets a fresh box reference to ensure cross-isolate data visibility.
  /// Now uses Box<String> instead of Box<LocationRecordModel>
  Box<String> get _box => Hive.box<String>(AppConstants.locationBoxName);

  @override
  Future<void> saveRecord(LocationRecordModel record) async {
    try {
      // Convert model to JSON string before storing
      final jsonString = record.toJsonString();
      await _box.add(jsonString);
      await _box.compact();
      print('[LocalDataSource] Saved record as JSON: ${record.timestamp}');
    } catch (e) {
      throw StorageException('Failed to save location record', e);
    }
  }

  @override
  Future<List<LocationRecordModel>> getAllRecords() async {
    try {
      // Get fresh box reference to see data written by other isolates
      final jsonStrings = _box.values.toList();

      // Parse JSON strings back to models
      final records = jsonStrings
          .map((jsonString) {
            try {
              return LocationRecordModel.fromJsonString(jsonString);
            } catch (e) {
              print('[LocalDataSource] Failed to parse record: $e');
              return null;
            }
          })
          .whereType<LocationRecordModel>() // Filter out nulls
          .toList();

      // Sort in reverse chronological order (newest first)
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('[LocalDataSource] Loaded ${records.length} records from Hive');
      return records;
    } catch (e) {
      throw StorageException('Failed to fetch location records', e);
    }
  }

  @override
  Future<void> deleteAllRecords() async {
    try {
      await _box.clear();
      await _box.compact();
    } catch (e) {
      throw StorageException('Failed to delete location records', e);
    }
  }

  @override
  Future<void> refreshBox() async {
    try {
      // Close the box to clear in-memory cache
      await _box.close();
      print('[LocalDataSource] Closed Hive box');

      // Reopen the box to force read from disk
      await Hive.openBox<String>(AppConstants.locationBoxName);
      print('[LocalDataSource] Reopened Hive box - fresh data from disk');
    } catch (e) {
      print('[LocalDataSource] Failed to refresh box: $e');
      // If refresh fails, try to reopen anyway to recover
      try {
        if (!Hive.isBoxOpen(AppConstants.locationBoxName)) {
          await Hive.openBox<String>(AppConstants.locationBoxName);
        }
      } catch (reopenError) {
        throw StorageException('Failed to refresh Hive box', reopenError);
      }
    }
  }
}
