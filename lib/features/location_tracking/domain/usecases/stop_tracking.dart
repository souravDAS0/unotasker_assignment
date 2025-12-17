import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

/// Use case for stopping location tracking.
/// Orchestrates the flow: stop background service → delete all records → clear notification.
class StopTracking {
  final LocationRepository repository;

  StopTracking({required this.repository});

  /// Executes the stop tracking flow.
  /// Returns Right(void) on success or Left(Failure) on error.
  Future<Either<Failure, void>> call() async {
    try {
      // Step 1: Stop background service
      await repository.stopBackgroundService();

      // Step 2: Delete all records (critical requirement)
      await repository.deleteAllRecords();

      // Step 3: Clear notification
      await repository.clearNotification();

      return const Right(null);
    } on BackgroundServiceException catch (e) {
      return Left(BackgroundServiceFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on NotificationException catch (e) {
      return Left(NotificationFailure(e.message));
    } catch (e) {
      return Left(BackgroundServiceFailure('Failed to stop tracking: ${e.toString()}'));
    }
  }
}
