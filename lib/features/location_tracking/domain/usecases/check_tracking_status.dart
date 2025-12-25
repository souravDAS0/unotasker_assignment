import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

/// Use case for checking if the background tracking service is currently running.
/// This is used to sync UI state with actual service status on app initialization.
class CheckTrackingStatus {
  final LocationRepository repository;

  CheckTrackingStatus({required this.repository});

  /// Checks if the background service is active.
  /// Returns Right(bool) on success or Left(Failure) on error.
  Future<Either<Failure, bool>> call() async {
    try {
      final isRunning = await repository.checkServiceStatus();
      return Right(isRunning);
    } on BackgroundServiceException catch (e) {
      return Left(BackgroundServiceFailure(e.message));
    } catch (e) {
      return Left(
        BackgroundServiceFailure(
          'Failed to check service status: ${e.toString()}',
        ),
      );
    }
  }
}
