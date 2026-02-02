import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:motus_lab/core/utils/logger.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isSupportChecked = false;
  bool _isSupported = false;

  /// Check if hardware is available
  Future<bool> get isDeviceSupported async {
    if (_isSupportChecked) return _isSupported;
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      _isSupported = canCheckBiometrics || isDeviceSupported;
      _isSupportChecked = true;
      return _isSupported;
    } on PlatformException catch (e) {
      Logger.error("Biometric Check Failed", e);
      return false;
    }
  }

  /// Helper to get list of enrolled biometrics (Face, Fingerprint)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      Logger.error("Get Biometrics Failed", e);
      return [];
    }
  }

  /// Trigger authentication dialog
  /// Returns [true] if authenticated successfully
  Future<bool> authenticate({
    String reason = 'Please authenticate to access this feature',
  }) async {
    // 1. Check support first
    if (!await isDeviceSupported) {
      Logger.info("Biometrics not supported on this device. Bypassing.");
      // If hardware not supported, should we allow or block?
      // For now, return true (Bypass) implies "Security not available"
      // But typically we should return false if strict.
      // Let's return false, and UI should handle "Not Supported" state.
      return false;
    }

    try {
      Logger.info("Starting Authentication...");
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Passcode fallback
        ),
      );
      Logger.info("Auth Result: $didAuthenticate");
      return didAuthenticate;
    } on PlatformException catch (e) {
      Logger.error("Authentication Error", e);
      if (e.code == auth_error.notAvailable) {
        // Hardware issue
      } else if (e.code == auth_error.lockedOut) {
        // Too many attempts
      }
      return false;
    }
  }
}
