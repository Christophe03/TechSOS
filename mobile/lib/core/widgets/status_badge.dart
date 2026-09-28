import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// TechSOS Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  _StatusConfig _getConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return _StatusConfig(
          label: 'En attente',
          backgroundColor: TechSosColors.alert.withValues(alpha: 0.15),
          textColor: TechSosColors.alert,
        );
      case 'OFFERS_RECEIVED':
        return _StatusConfig(
          label: 'Offres reçues',
          backgroundColor: TechSosColors.primary.withValues(alpha: 0.15),
          textColor: TechSosColors.primary,
        );
      case 'IN_PROGRESS':
        return _StatusConfig(
          label: 'Prise en charge',
          backgroundColor: TechSosColors.accent.withValues(alpha: 0.15),
          textColor: TechSosColors.accent,
        );
      case 'COMPLETED':
        return _StatusConfig(
          label: 'Terminée',
          backgroundColor: TechSosColors.success.withValues(alpha: 0.15),
          textColor: TechSosColors.success,
        );
      case 'CANCELLED':
        return _StatusConfig(
          label: 'Annulée',
          backgroundColor: Colors.grey.withValues(alpha: 0.15),
          textColor: Colors.grey,
        );
      default:
        return _StatusConfig(
          label: status,
          backgroundColor: Colors.grey.withValues(alpha: 0.15),
          textColor: Colors.grey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    final size = fontSize ?? 12.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: config.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: size,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
