import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';

enum BadgeStatus { success, warning, error, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeStatus status;

  const StatusBadge({
    super.key,
    required this.text,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case BadgeStatus.success:
        backgroundColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        break;
      case BadgeStatus.warning:
        backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
        textColor = AppTheme.warning;
        break;
      case BadgeStatus.error:
        backgroundColor = AppTheme.error.withValues(alpha: 0.1);
        textColor = AppTheme.error;
        break;
      case BadgeStatus.info:
        backgroundColor = AppTheme.primaryBlue.withValues(alpha: 0.1);
        textColor = AppTheme.primaryBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
