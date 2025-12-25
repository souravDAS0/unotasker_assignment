import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';

/// Custom AppBar widget displaying the unotasker logo and tracking status.

class CustomAppBar extends StatelessWidget {
  final bool isTracking;

  const CustomAppBar({super.key, required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(color: AppTheme.surface),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/unotasker_logo.png',
                height: 40,
                width: 80,
                fit: BoxFit.contain,
              ),

              _StatusBadge(isTracking: isTracking),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isTracking;

  const _StatusBadge({required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTheme.normalAnimation,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        gradient: isTracking ? AppTheme.greenGradient : null,
        color: isTracking ? null : AppTheme.gray100,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: isTracking
            ? null
            : Border.all(color: AppTheme.gray300, width: 1),
        boxShadow: isTracking ? AppTheme.greenGlow : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTracking ? Icons.location_on : Icons.location_off,
            size: 18,
            color: isTracking ? AppTheme.surface : AppTheme.gray600,
          ),
          const SizedBox(width: AppTheme.spacingSm),

          Text(
            isTracking ? 'Tracking Started' : 'Tracking Stopped',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isTracking ? AppTheme.surface : AppTheme.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
