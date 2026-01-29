import 'dart:async';
import 'dart:math';

class BroadcastScanner {
  /// Simulates a broadcast for now.
  /// In the future, this will use the ConnectionManager to send 0x7DF requests.
  Stream<String> scan() async* {
    // Simulate initial network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulating these IDs responding from the "vehicle"
    final simulatedResponses = [
      "0x7E0", // ECM
      "0x7E1", // TCM
      "0x7E2", // ABS
      "0x7E3", // BCM
      "0x7E8", // TPMS
      "0x7E9", // PDM
      "0x7EA", // DDM
    ];

    for (final id in simulatedResponses) {
      // Small random delay between responses to simulate separate ECUs replying
      await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(300)));
      yield id;
    }
  }
}
