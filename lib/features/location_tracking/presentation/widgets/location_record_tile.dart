import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/location_record.dart';

/// Widget that displays a single location record in a modern card format.
/// Shows timestamp with relative time badge, coordinates, and address.
class LocationRecordTile extends StatelessWidget {
  final LocationRecord record;

  const LocationRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppTheme.spacingSm,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(
          color: AppTheme.surface.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.lowElevation,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp with relative time badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Text(
                            DateFormatter.formatTimestamp(record.timestamp),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.gray900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Relative time badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: AppTheme.pillDecoration(AppTheme.purple50),
                    child: Text(
                      DateFormatter.getRelativeTime(record.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.purple700,
                      ),
                    ),
                  ),
                ],
              ),

              // Divider
              const Divider(height: 16, color: AppTheme.gray100, thickness: 1),

              // Coordinates
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppTheme.pink500,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude: ${record.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.gray700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Longitude: ${record.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Address
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.gray50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.gray200, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.map,
                      size: 18,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        record.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray700,
                          fontStyle: record.address == 'Address unavailable'
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
