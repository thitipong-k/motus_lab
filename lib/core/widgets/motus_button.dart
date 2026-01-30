import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

enum ButtonType { primary, secondary, danger, warning }

class MotusButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;

  const MotusButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.isLoading = false,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return Colors.grey[700]!;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.warning:
        return Colors.amber[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final style = ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
