import 'package:flutter/services.dart';

/// Service for handling physical haptic feedback across the application.
/// Provides tactile confirmation for digital interactions.
class HapticService {
  /// Light tap for subtle feedback like button clicks or tab switches.
  Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap for significant confirmations like successful connection.
  Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for critical actions or results.
  Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// Distinct vibration for errors or warnings.
  Future<void> errorFeedback() async {
    await HapticFeedback.vibrate();
  }

  /// Selection feedback for list scrolling or slider adjustments.
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }
}
