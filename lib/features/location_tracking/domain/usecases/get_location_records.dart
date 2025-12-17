import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location_record.dart';
import '../repositories/location_repository.dart';

/// Use case for retrieving all saved location records.
/// Returns records in reverse chronological order (newest first).
class GetLocationRecords {
  final LocationRepository repository;

  GetLocationRecords({required this.repository});

  /// Fetches all location records from storage.
  /// Returns Right(List<LocationRecord>) on success or Left(Failure) on error.
  Future<Either<Failure, List<LocationRecord>>> call() async {
    try {
      final records = await repository.getAllRecords();
      return Right(records);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Failed to fetch records: ${e.toString()}'));
    }
  }
}
