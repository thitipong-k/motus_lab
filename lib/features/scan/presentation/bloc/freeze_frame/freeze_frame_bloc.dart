import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/domain/entities/command.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';

part 'freeze_frame_event.dart';
part 'freeze_frame_state.dart';

/// Bloc สำหรับจัดการข้อมูลภาพนิ่งขณะเกิดความผิดปกติ (Freeze Frame)
/// รองรับการอ่าน Mode 02 เพื่อดูค่าเซนเซอร์ ณ วินาทีที่ไฟเครื่องโชว์
class FreezeFrameBloc extends Bloc<FreezeFrameEvent, FreezeFrameState> {
  final ConnectionInterface _connection;

  FreezeFrameBloc({required ConnectionInterface connection})
      : _connection = connection,
        super(FreezeFrameInitial()) {
    on<LoadFreezeFrameData>(_onLoadFreezeFrameData);
  }

  /// ฟังก์ชันโหลดข้อมูล Freeze Frame
  Future<void> _onLoadFreezeFrameData(
      LoadFreezeFrameData event, Emitter<FreezeFrameState> emit) async {
    emit(FreezeFrameLoading());

    try {
      if (!_connection.isConnected) {
        emit(const FreezeFrameError("ยังไม่ได้เชื่อมต่อกับตัวรถ"));
        return;
      }

      final Map<String, dynamic> results = {};
      String dtcCode = "ไม่ระบุ";

      // 1. อ่านรหัสความผิดปกติที่เป็นสาเหตุให้เกิด Freeze Frame (Mode 02 PID 02)
      try {
        final response = await _connection.send(ObdRequest(command: "0202"));
        // รูปแบบที่คาดหวัง: 42 02 [HB] [LB]
        if (response.hasValidData &&
            response.rawData.length >= 4 &&
            response.rawData[0] == 0x42 &&
            response.rawData[1] == 0x02) {
          dtcCode = _parseDtc(response.rawData[2], response.rawData[3]);
        }
      } catch (e) {
        print("Error ดึงรหัส Freeze DTC: $e");
      }

      // 2. ดึงค่าเซนเซอร์อื่นๆ ที่เกี่ยวข้อง ณ ขณะนั้น (สตรีมผ่าน Mode 02)
      final List<Command> snapshotPids = [
        StandardPids.calculatedLoad,
        StandardPids.engineCoolantTemp,
        StandardPids.engineRpm,
        StandardPids.vehicleSpeed,
        StandardPids.shortTermFuelTrim1,
        StandardPids.longTermFuelTrim1,
      ];

      for (var cmd in snapshotPids) {
        try {
          // แปลง PID จาก Mode 01 เป็น Mode 02 (เช่น 010C -> 020C)
          String pidHex = cmd.code.substring(2);
          final response =
              await _connection.send(ObdRequest(command: "02$pidHex"));

          if (response.hasValidData &&
              response.rawData.length >= 3 &&
              response.rawData[0] == 0x42 &&
              response.rawData[1] == int.parse(pidHex, radix: 16)) {
            final raw = response.rawData;
            double val = 0.0;

            // แยกข้อมูลดิบ A, B ไปคำนวณตามประเภทของเซนเซอร์
            int A = raw.length > 2 ? raw[2] : 0;
            int B = raw.length > 3 ? raw[3] : 0;

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
          print("Error ดึงค่า Freeze Frame PID ${cmd.name}: $e");
        }
      }

      emit(FreezeFrameLoaded(data: results, dtc: dtcCode));
    } catch (e) {
      emit(FreezeFrameError("โหลดข้อมูลภาพนิ่งล้มเหลว: ${e.toString()}"));
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
