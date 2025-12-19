import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location_record.dart';
import '../repositories/location_repository.dart';

/// Use case for starting location tracking.
/// Orchestrates the flow: request permissions → get location → geocode → save → notify → start background service.
class StartTracking {
  final LocationRepository repository;

  StartTracking({required this.repository});

  /// Executes the start tracking flow.
  /// Returns Right(void) on success or Left(Failure) on error.
  Future<Either<Failure, void>> call() async {
    try {
      // Step 1: Request permissions
      final hasPermissions = await repository.requestPermissions();
      if (!hasPermissions) {
        return const Left(PermissionFailure('Location permission denied'));
      }

      // Step 2: Get current location
      final locationData = await repository.getCurrentLocation();
      final latitude = locationData['latitude']!;
      final longitude = locationData['longitude']!;

      // Step 3: Geocode to address (returns tuple with error type)
      final (address, errorType) =
          await repository.geocodeLocation(latitude, longitude);

      // Step 4: Create and save record (includes error state)
      final record = LocationRecord(
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        address: address,
        geocodingError: errorType,
      );
      await repository.saveRecord(record);

      // Step 5: Show notification
      await repository.showNotification(record);

      // Step 6: Start background service
      await repository.startBackgroundService();

      return const Right(null);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } on BackgroundServiceException catch (e) {
      return Left(BackgroundServiceFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Failed to start tracking: ${e.toString()}'));
    }
  }
}
