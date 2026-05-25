import 'dart:async';
import 'dart:typed_data';
import 'package:motus_lab/core/protocol/transport/diagnostic_transport.dart';
import 'package:motus_lab/core/protocol/security/security_access_handler.dart';

class UdsSecurityException implements Exception {
  final String message;
  final int nrc;
  UdsSecurityException(this.message, {this.nrc = 0x33});

  @override
  String toString() => "UdsSecurityException: $message (NRC: 0x${nrc.toRadixString(16).toUpperCase()})";
}

/// Unified Diagnostic Services (UDS / ISO-14229) Engine
/// This engine relies solely on DiagnosticTransport, making it fully decoupled
/// from whether the physical connection is J2534, DoIP, BLE, or Serial.
class UdsEngine {
  final DiagnosticTransport _transport;

  UdsEngine(this._transport);

  void _checkNegativeResponse(List<int> response, int requestedSid) {
    if (response.length >= 3 && response[0] == 0x7F && response[1] == requestedSid) {
      final nrc = response[2];
      if (nrc == 0x33) {
        throw UdsSecurityException("Security Access Denied (SGW Locked)");
      }
      throw Exception("Negative Response Code: 0x${nrc.toRadixString(16).toUpperCase()}");
    }
  }

  /// 0x10 Diagnostic Session Control
  Future<bool> startSession(int sessionType) async {
    final payload = [0x10, sessionType];
    final response = await _transport.sendAndReceive(payload);
    
    // Positive response for 0x10 is 0x50
    return response.isNotEmpty && response[0] == 0x50;
  }

  /// 0x27 Security Access (Request Seed -> Compute Key -> Send Key)
  Future<bool> unlockSecurity(SecurityAccessHandler handler) async {
    // 1. Request Seed
    final seedRequest = [0x27, handler.securityLevel];
    final seedResponse = await _transport.sendAndReceive(seedRequest);

    if (seedResponse.isEmpty || seedResponse[0] != 0x67) {
      return false; // Negative response or error
    }

    // Extract seed (ignoring 0x67 and SubFunction)
    final seed = Uint8List.fromList(seedResponse.sublist(2));

    // 2. Compute Key using our injected SecurityAccessHandler
    final key = handler.computeKey(seed);

    // 3. Send Key
    final keyRequest = [0x27, handler.securityLevel + 1, ...key];
    final keyResponse = await _transport.sendAndReceive(keyRequest);

    // Positive response for sending key is 0x67
    return keyResponse.isNotEmpty && keyResponse[0] == 0x67;
  }

  /// 0x22 Read Data By Identifier (DID)
  Future<List<int>> readDataByIdentifier(int did) async {
    final payload = [
      0x22,
      (did >> 8) & 0xFF,
      did & 0xFF
    ];
    final response = await _transport.sendAndReceive(payload);
    _checkNegativeResponse(response, 0x22);

    if (response.isNotEmpty && response[0] == 0x62) {
      // Return data payload (ignoring 0x62 and DID)
      return response.sublist(3);
    }
    throw Exception("Negative Response for Read DID 0x${did.toRadixString(16)}");
  }

  /// 0x31 Routine Control (e.g. Start Routine for memory erasure or actuator test)
  Future<bool> startRoutine(int routineId, {List<int>? routineArgs}) async {
    final payload = [
      0x31,
      0x01, // 0x01 = Start Routine
      (routineId >> 8) & 0xFF,
      routineId & 0xFF,
      ...?routineArgs
    ];
    final response = await _transport.sendAndReceive(payload);
    _checkNegativeResponse(response, 0x31);

    return response.isNotEmpty && response[0] == 0x71;
  }

  /// 0x2F Input/Output Control By Identifier (Actuation Tests)
  /// [did] Data Identifier representing the component (e.g. 0x011A for cooling fan)
  /// [controlOption] e.g. 0x00 ReturnControlToECU, 0x03 ShortTermAdjustment
  /// [controlState] Optional state parameters (e.g. [0x01] for ON, [0x00] for OFF)
  Future<bool> inputOutputControlByIdentifier(int did, int controlOption, {List<int>? controlState}) async {
    final payload = [
      0x2F,
      (did >> 8) & 0xFF,
      did & 0xFF,
      controlOption,
      ...?controlState
    ];
    final response = await _transport.sendAndReceive(payload);
    _checkNegativeResponse(response, 0x2F);

    return response.isNotEmpty && response[0] == 0x6F;
  }
}
