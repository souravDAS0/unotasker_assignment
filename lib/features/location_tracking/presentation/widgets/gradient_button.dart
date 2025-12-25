import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';

/// Gradient button widget with gradient background and smooth animations.
///
class GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;
  final List<Color> disabledColors;
  final bool isLoading;
  final List<BoxShadow>? shadow;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.gradientColors,
    required this.disabledColors,
    this.isLoading = false,
    this.shadow,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppTheme.fastAnimation,
        curve: Curves.easeInOut,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled ? widget.gradientColors : widget.disabledColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: isEnabled
                ? (widget.shadow ?? AppTheme.lowElevation)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.surface,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.icon,
                              size: 20,
                              color: isEnabled
                                  ? AppTheme.surface
                                  : AppTheme.gray400,
                            ),
                            const SizedBox(width: AppTheme.spacingXs),
                            Expanded(
                              child: FittedBox(
                                child: Text(
                                  widget.label,
                                  style: isEnabled
                                      ? AppTheme.labelLarge
                                      : AppTheme.labelLarge.copyWith(
                                          color: AppTheme.gray400,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
