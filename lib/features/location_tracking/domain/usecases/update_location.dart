import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location_record.dart';
import '../repositories/location_repository.dart';

/// Use case for updating location in the background.
/// Called periodically by WorkManager every 5 minutes.
/// Orchestrates the flow: get location → geocode → save → update notification.
class UpdateLocation {
  final LocationRepository repository;

  UpdateLocation({required this.repository});

  /// Executes the background location update flow.
  /// Returns Right(LocationRecord) on success or Left(Failure) on error.
  Future<Either<Failure, LocationRecord>> call() async {
    try {
      // Step 1: Check if we have permissions
      final hasPermissions = await repository.hasPermissions();
      if (!hasPermissions) {
        return const Left(PermissionFailure('Location permission not granted'));
      }

      // Step 2: Get current location
      final locationData = await repository.getCurrentLocation();
      final latitude = locationData['latitude']!;
      final longitude = locationData['longitude']!;

      // Step 3: Geocode to address
      final address = await repository.geocodeLocation(latitude, longitude);

      // Step 4: Create and save record
      final record = LocationRecord(
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      await repository.saveRecord(record);

      // Step 5: Update notification with new data
      await repository.updateNotification(record);

      return Right(record);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } on GeocodingException catch (e) {
      return Left(GeocodingFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(
        LocationFailure('Failed to update location: ${e.toString()}'),
      );
    }
  }
}
