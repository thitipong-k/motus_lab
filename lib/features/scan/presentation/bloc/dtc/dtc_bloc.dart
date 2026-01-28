import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';

part 'dtc_event.dart';
part 'dtc_state.dart';

/// Bloc สำหรับจัดการรหัสความผิดปกติ (DTC)
/// รองรับการอ่าน (Mode 03) และการลบ (Mode 04)
class DtcBloc extends Bloc<DtcEvent, DtcState> {
  final ProtocolEngine _engine;
  final ConnectionInterface _connection;

  DtcBloc({
    required ProtocolEngine engine,
    required ConnectionInterface connection,
  })  : _engine = engine,
        _connection = connection,
        super(const DtcState()) {
    on<ReadDtcCodes>(_onReadDtcCodes);
    on<ClearDtcCodes>(_onClearDtcCodes);
  }

  Future<void> _onReadDtcCodes(
      ReadDtcCodes event, Emitter<DtcState> emit) async {
    emit(const DtcState(status: DtcStatus.loading));

    try {
      if (!_connection.isConnected) throw Exception("Not connected to vehicle");

      // 1. ส่งคำสั่ง Mode 03 (Request DTCs)
      final request = [0x03]; // ในโปรเจกต์จริงจะผ่าน CommandBuilder
      final response = await _connection.send(request);

      // 2. แปลผล (DTC Parser)
      // ตัวอย่างจำลอง: คืนค่า P0101, P0300
      // ใน Phase 1 เรายังไม่ได้ทำ DTC Parser ขั้นสูง
      // จึงขอจำลองข้อมูลตามโครงสร้าง Protocol
      List<String> codes = _mockParseDtc(response);

      emit(DtcState(status: DtcStatus.success, codes: codes));
    } catch (e) {
      emit(DtcState(status: DtcStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearDtcCodes(
      ClearDtcCodes event, Emitter<DtcState> emit) async {
    emit(DtcState(status: DtcStatus.clearing, codes: state.codes));

    try {
      if (!_connection.isConnected) throw Exception("Not connected to vehicle");

      // 1. ส่งคำสั่ง Mode 04 (Clear DTCs)
      final request = [0x04];
      await _connection.send(request);

      // 2. แจ้งผลสำเร็จและล้างรายการในแอป
      emit(const DtcState(status: DtcStatus.success, codes: []));
    } catch (e) {
      emit(DtcState(
          status: DtcStatus.error,
          errorMessage: e.toString(),
          codes: state.codes));
    }
  }

  List<String> _mockParseDtc(List<int> data) {
    // จำลองการดึงค่าจาก Protocol Mode 03
    return ["P0101", "P0300", "B1234"];
  }
}
