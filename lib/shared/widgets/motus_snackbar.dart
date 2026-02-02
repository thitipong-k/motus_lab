import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

/// Helper class for showing standardized SnackBars
class MotusSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppColors.warning, Icons.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.primary, Icons.info);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Floating creates a "Toast" feel
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
