import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../injection_container.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/location_record_tile.dart';
import '../widgets/gradient_button.dart';

/// Main dashboard screen for the location tracking app.
/// Displays tracking status, start/stop buttons, and list of location records.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackingProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,

      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(isTracking: state.isTracking),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacingMd),
                    // Control buttons card
                    _buildControlCard(context, ref, state),

                    // Error message (if present)
                    if (state.errorMessage != null)
                      _buildErrorMessage(context, ref, state.errorMessage!),

                    // Records header (if records exist)
                    if (state.records.isNotEmpty)
                      _buildRecordsHeader(context, state.records.length),

                    // Records list or empty state
                    Expanded(
                      child: state.records.isEmpty
                          ? const EmptyStateWidget()
                          : RefreshIndicator(
                              onRefresh: () async {
                                await ref
                                    .read(trackingProvider.notifier)
                                    .loadRecords();
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  bottom: AppTheme.spacingMd,
                                ),
                                itemCount: state.records.length,
                                itemBuilder: (context, index) {
                                  return LocationRecordTile(
                                    record: state.records[index],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the control buttons card with Start and Stop tracking buttons.
  Widget _buildControlCard(BuildContext context, WidgetRef ref, state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Control Tracking', style: AppTheme.headingMedium),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              // Start Tracking Button
              Expanded(
                child: GradientButton(
                  label: 'Start Tracking',
                  icon: Icons.play_arrow,
                  gradientColors: const [
                    AppTheme.primaryPurple,
                    Color(0xFF9b84f5),
                  ],
                  disabledColors: [
                    AppTheme.gray200,
                    Color.fromARGB(255, 236, 231, 255),
                  ],
                  onPressed: state.isTracking || state.isLoading
                      ? null
                      : () => ref
                            .read(trackingProvider.notifier)
                            .startTrackingAction(),
                  isLoading: state.isLoading && !state.isTracking,
                  shadow: AppTheme.purpleGlow,
                ),
              ),

              const SizedBox(width: 12),

              // Stop Tracking Button
              Expanded(
                child: GradientButton(
                  label: 'Stop Tracking',
                  icon: Icons.stop,
                  gradientColors: const [AppTheme.errorRed, Color(0xFFf87171)],
                  disabledColors: [
                    AppTheme.gray200,
                    Color.fromARGB(255, 255, 240, 240),
                  ],
                  onPressed: !state.isTracking || state.isLoading
                      ? null
                      : () => ref
                            .read(trackingProvider.notifier)
                            .stopTrackingAction(),
                  isLoading: state.isLoading && state.isTracking,
                  shadow: AppTheme.redGlow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the error message container with slide-in animation.
  Widget _buildErrorMessage(
    BuildContext context,
    WidgetRef ref,
    String errorMessage,
  ) {
    return AnimatedSlide(
      offset: Offset.zero,
      duration: AppTheme.normalAnimation,
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.errorRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFdc2626), // red-600
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFb91c1c), // red-700
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: const Color(0xFFdc2626), // red-600
              onPressed: () => ref.read(trackingProvider.notifier).clearError(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the records header card with count badge.
  Widget _buildRecordsHeader(BuildContext context, int recordCount) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: AppTheme.normalAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.lowElevation,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text('Location History', style: AppTheme.headingSmall),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: AppTheme.pillDecoration(AppTheme.purple50),
              child: Text(
                '$recordCount ${recordCount == 1 ? 'record' : 'records'}',
                style: AppTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
