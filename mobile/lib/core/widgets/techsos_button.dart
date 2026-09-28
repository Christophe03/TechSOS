import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

/// TechSOS Standard Button Widget
class TechSosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const TechSosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final loadingWidget = SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isSecondary ? TechSosColors.primary : Colors.white,
        ),
      ),
    );

    final contentWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: isSecondary ? TechSosColors.primary : Colors.white,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: isSecondary
              ? TechSosStyles.button.copyWith(color: TechSosColors.primary)
              : TechSosStyles.button,
        ),
      ],
    );

    if (isSecondary) {
      return SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: TechSosColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: isLoading ? loadingWidget : contentWidget,
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TechSosColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: TechSosColors.accent.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading ? loadingWidget : contentWidget,
      ),
    );
  }
}
