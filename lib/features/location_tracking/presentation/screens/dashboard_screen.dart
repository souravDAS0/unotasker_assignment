import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection_container.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/location_record_tile.dart';
import '../widgets/tracking_button.dart';

/// Main dashboard screen for the location tracking app.
/// Displays tracking status, start/stop buttons, and list of location records.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: state.isTracking ? Colors.green : Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isTracking ? Icons.location_on : Icons.location_off,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  state.isTracking ? 'Tracking Active' : 'Tracking Stopped',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TrackingButton(
                    label: 'Start Tracking',
                    onPressed: state.isTracking || state.isLoading
                        ? null
                        : () => ref
                              .read(trackingProvider.notifier)
                              .startTrackingAction(),
                    isLoading: state.isLoading && !state.isTracking,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TrackingButton(
                    label: 'Stop Tracking',
                    onPressed: !state.isTracking || state.isLoading
                        ? null
                        : () => ref
                              .read(trackingProvider.notifier)
                              .stopTrackingAction(),
                    isLoading: state.isLoading && state.isTracking,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (state.errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    color: Colors.red.shade700,
                    onPressed: () =>
                        ref.read(trackingProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),

          // Records count
          if (state.records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${state.records.length} location${state.records.length == 1 ? '' : 's'} recorded',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Records list or empty state
          Expanded(
            child: state.records.isEmpty
                ? const EmptyStateWidget()
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(trackingProvider.notifier).loadRecords();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.records.length,
                      itemBuilder: (context, index) {
                        return LocationRecordTile(record: state.records[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
