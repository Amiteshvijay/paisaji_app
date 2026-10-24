import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class AiSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AiSuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
      side: const BorderSide(color: AppTheme.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
