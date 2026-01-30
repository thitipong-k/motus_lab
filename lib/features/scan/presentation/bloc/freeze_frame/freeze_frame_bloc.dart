import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/domain/entities/command.dart';

part 'freeze_frame_event.dart';
part 'freeze_frame_state.dart';

class FreezeFrameBloc extends Bloc<FreezeFrameEvent, FreezeFrameState> {
  final ConnectionInterface _connection;

  FreezeFrameBloc({required ConnectionInterface connection})
      : _connection = connection,
        super(FreezeFrameInitial()) {
    on<LoadFreezeFrameData>(_onLoadFreezeFrameData);
  }

  Future<void> _onLoadFreezeFrameData(
      LoadFreezeFrameData event, Emitter<FreezeFrameState> emit) async {
    emit(FreezeFrameLoading());

    try {
      if (!_connection.isConnected) {
        emit(const FreezeFrameError("Not connected to vehicle"));
        return;
      }

      final Map<String, dynamic> results = {};
      String dtcCode = "Unknown";

      // 1. Get DTC that caused freeze frame (PID 02)
      // Custom parsing for Mode 02 PID 02 (DTC)
      try {
        // Mode 02, PID 02
        final response = await _connection.send([0x02, 0x02]);
        // Expect 42 02 HB LB or similar
        if (response.length >= 4 &&
            response[0] == 0x42 &&
            response[1] == 0x02) {
          // Parse DTC: same logic as Mode 03
          // HB = response[2], LB = response[3]
          dtcCode = _parseDtc(response[2], response[3]);
        }
      } catch (e) {
        print("Error fetching Freeze DTC: $e");
      }

      // 2. Fetch other PIDs (Mode 02)
      // We will fetch a standard set of PIDs relevant for snapshot
      final List<Command> snapshotPids = [
        StandardPids.calculatedLoad,
        StandardPids.engineCoolantTemp,
        StandardPids.engineRpm,
        StandardPids.vehicleSpeed,
        StandardPids.shortTermFuelTrim1,
        StandardPids.longTermFuelTrim1,
        // Add more if needed
      ];

      for (var cmd in snapshotPids) {
        try {
          // Convert '010C' to [0x02, 0x0C] for Mode 02 request
          int pidByte = int.parse(cmd.code.substring(2), radix: 16);
          final response = await _connection.send([0x02, pidByte]);

          if (response.length >= 3 &&
              response[0] == 0x42 &&
              response[1] == pidByte) {
            // Parse value
            // Logic same as Mode 01 but response header is 42
            // We can reuse the formula logic if we strip the header
            // Or simplified manual parsing for now
            double val = 0.0;

            // Extract bytes (A, B, C, D)
            int A = response.length > 2 ? response[2] : 0;
            int B = response.length > 3 ? response[3] : 0;

            // Simple hardcoded formula mapping for basic PIDs to avoid complex parser injection
            if (cmd == StandardPids.engineRpm) {
              val = ((A * 256) + B) / 4;
            } else if (cmd == StandardPids.vehicleSpeed) {
              val = A.toDouble();
            } else if (cmd == StandardPids.engineCoolantTemp) {
              val = (A - 40).toDouble();
            } else if (cmd == StandardPids.calculatedLoad) {
              val = (A * 100) / 255;
            } else if (cmd == StandardPids.shortTermFuelTrim1 ||
                cmd == StandardPids.longTermFuelTrim1) {
              val = (A - 128) * 100 / 128;
            }

            results[cmd.name] = val;
          }
        } catch (e) {
          print("Error fetching freeze frame PID ${cmd.name}: $e");
        }
      }

      emit(FreezeFrameLoaded(data: results, dtc: dtcCode));
    } catch (e) {
      emit(FreezeFrameError(e.toString()));
    }
  }

  String _parseDtc(int hb, int lb) {
    // Logic duplicated from DtcParsing for speed (Move to util if reused often)
    // P0123 format
    // First 2 bits of HB determine letter:
    // 00 = P, 01 = C, 10 = B, 11 = U
    final type = (hb & 0xC0) >> 6;
    String prefix = "P";
    if (type == 1) prefix = "C";
    if (type == 2) prefix = "B";
    if (type == 3) prefix = "U";

    final digit1 = (hb & 0x30) >> 4;
    final digit2 = (hb & 0x0F);
    final digit3 = (lb & 0xF0) >> 4;
    final digit4 = (lb & 0x0F);

    return "$prefix$digit1${digit2.toRadixString(16)}${digit3.toRadixString(16)}${digit4.toRadixString(16)}"
        .toUpperCase();
  }
}
