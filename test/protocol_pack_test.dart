import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';

void main() {
  test('Should load Honda Civic Protocol Pack and parse commands correctly',
      () async {
    // Arrange
    final engine = ProtocolEngine();
    // Assuming test runs from project root
    final file = File('assets/protocols/honda_civic.json');

    // Ensure file exists before reading (sanity check for test setup)
    expect(await file.exists(), true,
        reason: "assets/protocols/honda_civic.json not found");

    final jsonString = await file.readAsString();

    // Act
    engine.loadProtocolPack(jsonString);
    final pids = engine.getAllSupportedPids();

    // Assert
    expect(pids.length, 4);

    // Check RPM (010C)
    final rpmCmd = pids.firstWhere((c) => c.code == '010C');
    expect(rpmCmd.name, 'Engine RPM');
    expect(rpmCmd.unit, 'RPM');
    expect(rpmCmd.formula, '((A * 256) + B) / 4');

    // Check Speed (010D)
    final speedCmd = pids.firstWhere((c) => c.code == '010D');
    expect(speedCmd.formula, 'A');
  });

  test('Should fallback to StandardPids if JSON is invalid', () {
    final engine = ProtocolEngine();

    // Act
    engine.loadProtocolPack('INVALID JSON');
    final pids = engine.getAllSupportedPids();

    // Assert
    expect(pids.isNotEmpty, true);
    // Should be standard list (StandardPids.all has more than 4 items usually)
    expect(pids.length, greaterThan(4));
  });
}
