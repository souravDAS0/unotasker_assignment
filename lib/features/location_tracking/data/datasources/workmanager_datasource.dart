import 'package:workmanager/workmanager.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Abstract interface for background service operations.
abstract class WorkManagerDataSource {
  /// Registers a periodic task to run at specified intervals.
  Future<void> registerPeriodicTask();

  /// Cancels the registered periodic task.
  Future<void> cancelTask();
}

/// Implementation of WorkManagerDataSource using the workmanager package.
class WorkManagerDataSourceImpl implements WorkManagerDataSource {
  @override
  Future<void> registerPeriodicTask() async {
    try {
      final interval = AppConstants.trackingInterval;

      // WorkManager has a minimum frequency of 15 minutes for periodic tasks
      // For testing with shorter intervals, use one-off tasks with rescheduling
      if (interval.inMinutes < 15) {
        // Use one-off task for intervals < 15 minutes (testing mode)
        await Workmanager().registerOneOffTask(
          AppConstants.trackingTaskName,
          AppConstants.trackingTaskName,
          initialDelay: interval,
          constraints: Constraints(
            networkType: NetworkType.notRequired,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
        print('[WorkManager] Registered one-off task with ${interval.inSeconds}s delay');
      } else {
        // Use periodic task for intervals >= 15 minutes (production mode)
        await Workmanager().registerPeriodicTask(
          AppConstants.trackingTaskName,
          AppConstants.trackingTaskName,
          frequency: interval,
          constraints: Constraints(
            networkType: NetworkType.notRequired,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
        print('[WorkManager] Registered periodic task with ${interval.inMinutes}min frequency');
      }
    } catch (e) {
      throw BackgroundServiceException('Failed to register task', e);
    }
  }

  @override
  Future<void> cancelTask() async {
    try {
      await Workmanager().cancelByUniqueName(AppConstants.trackingTaskName);
    } catch (e) {
      throw BackgroundServiceException('Failed to cancel periodic task', e);
    }
  }
}
