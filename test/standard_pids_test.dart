import 'package:flutter_test/flutter_test.dart';
import 'package:motus_lab/core/protocol/expression_evaluator.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';

void main() {
  group('Standard Pids Verification', () {
    late ExpressionEvaluator evaluator;
    late ProtocolEngine engine;

    setUp(() {
      evaluator = ExpressionEvaluator();
      engine = ProtocolEngine(evaluator: evaluator);
    });

    test('All Standard PIDs should have valid formulas', () {
      final pids = StandardPids.all;
      expect(pids.isNotEmpty, true);

      // Dummy data [A, B, C, D]
      final dummyData = [100, 50, 25, 10];

      for (var pid in pids) {
        if (pid.formula.isNotEmpty) {
          // Try to evaluate formula with dummy data
          // If formula is invalid, this will throw
          try {
            final result = evaluator.evaluate(pid.formula, dummyData);
            print(
                'PID: ${pid.name} (${pid.code}) -> Formula: ${pid.formula} -> Result: $result');
            expect(result, isNotNull);
          } catch (e) {
            fail(
                'Failed to evaluate formula for PID ${pid.name}: ${pid.formula}. Error: $e');
          }
        }
      }
    });

    test('ProtocolEngine should return all standard PIDs', () {
      final pids = engine.getAllSupportedPids();
      expect(pids.length, StandardPids.all.length);
      expect(pids.first.name, StandardPids.all.first.name);
    });
  });
}
