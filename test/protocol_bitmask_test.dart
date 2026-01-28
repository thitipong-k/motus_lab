import 'package:flutter_test/flutter_test.dart';
import 'package:motus_lab/core/protocol/expression_evaluator.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';

void main() {
  group('Bitmask Decoding Verification', () {
    late ProtocolEngine engine;

    setUp(() {
      engine = ProtocolEngine(evaluator: ExpressionEvaluator());
    });

    test('Should correctly decode 0100 bitmask from MockConnection', () {
      // Mock Response: 41 00 18 3B 00 00
      // 18 = 0001 1000 -> PID 04, 05
      // 3B = 0011 1011 -> PID 0B, 0C, 0D, 0F, 10
      final response = [0x41, 0x00, 0x18, 0x3B, 0x00, 0x00];

      final supportedPids = engine.decodeSupportedPids(response, 0x00);

      print('Decoded PIDs: $supportedPids');

      // Verify count
      expect(supportedPids.length, 7);

      // Verify specific PIDs are present
      expect(supportedPids.contains("0104"), isTrue); // Load
      expect(supportedPids.contains("0105"), isTrue); // Coolant
      expect(supportedPids.contains("010B"), isTrue); // MAP
      expect(supportedPids.contains("010C"), isTrue); // RPM
      expect(supportedPids.contains("010D"), isTrue); // Speed
      expect(supportedPids.contains("010F"), isTrue); // IAT
      expect(supportedPids.contains("0110"), isTrue); // MAF

      // Verify non-supported PIDs are absent
      expect(supportedPids.contains("0101"), isFalse);
      expect(supportedPids.contains("0120"), isFalse);
    });

    test('Should return empty list for invalid response', () {
      final response = [0x41, 0x00]; // Too short
      final result = engine.decodeSupportedPids(response, 0x00);
      expect(result.isEmpty, isTrue);
    });
  });
}
