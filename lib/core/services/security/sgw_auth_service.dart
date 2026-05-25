import 'dart:async';
import 'package:motus_lab/core/utils/logger.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';

class SgwAuthService {
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  Future<bool> authenticate(String username, String password) async {
    Logger.info("SgwAuthService: Attempting to authenticate with AutoAuth/SFD server...");
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (username.isNotEmpty && password.isNotEmpty) {
      _isUnlocked = true;
      Logger.info("SgwAuthService: SGW Unlocked successfully via $username");
      
      // Backdoor to tell MockConnection to stop sending 0x33
      try {
        final conn = locator<ConnectionInterface>();
        conn.send(ObdRequest(command: "AA BB CC")); // Secret unlock code for mock
      } catch (_) {}

      return true;
    }
    
    Logger.error("SgwAuthService: Authentication failed (Invalid credentials)");
    return false;
  }

  void lock() {
    _isUnlocked = false;
    Logger.info("SgwAuthService: SGW Locked manually");
  }
}
