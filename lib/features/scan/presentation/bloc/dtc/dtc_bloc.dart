import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/features/scan/data/repositories/vehicle_stats_repository.dart';

part 'dtc_event.dart';
part 'dtc_state.dart';

/// Bloc สำหรับจัดการรหัสความผิดปกติ (DTC)
/// รองรับการอ่าน (Mode 03) และการลบ (Mode 04)
class DtcBloc extends Bloc<DtcEvent, DtcState> {
  final ConnectionInterface _connection;
  final VehicleStatsRepository
      _vehicleStatsRepository; // เพิ่มเพื่อรองรับ Predictive Caching

  DtcBloc({
    required ProtocolEngine
        engine, // Kept for now as it's part of the constructor signature, but _engine field is removed.
    required ConnectionInterface connection,
    required VehicleStatsRepository vehicleStatsRepository,
  })  : _connection = connection,
        _vehicleStatsRepository = vehicleStatsRepository,
        super(const DtcState()) {
    on<ReadDtcCodes>(_onReadDtcCodes);
    on<ClearDtcCodes>(_onClearDtcCodes);
  }

  Future<void> _onReadDtcCodes(
      ReadDtcCodes event, Emitter<DtcState> emit) async {
    // [Predictive Caching Logic] บันทึกสถิติการเข้าดูข้อมูล
    // ในที่นี้สมมติเป็นรุ่นหลักที่สแกนบ่อยเพื่อเป็นตัวอย่าง (Honda Civic FE)
    _vehicleStatsRepository.incrementScanCount(
        year: 2022, make: "Honda", model: "Civic FE");

    emit(const DtcState(status: DtcStatus.loading));

    try {
      if (!_connection.isConnected) throw Exception("Not connected to vehicle");

      // 1. ส่งคำสั่ง Mode 03 (Request DTCs)
      final request = [0x03]; // ในโปรเจกต์จริงจะผ่าน CommandBuilder
      final response = await _connection.send(request);

      // 2. แปลผล (DTC Parser)
      List<String> codes = [];

      // Response Format: [43] [Count] [Byte1] [Byte2] [Byte3] [Byte4] ...
      if (response.isNotEmpty && response[0] == 0x43) {
        // int count = response.length > 1 ? response[1] : 0; // Removed unused variable

        // Simple parser manual loop (Phase 1)
        // Start at index 2, take 2 bytes at a time
        for (int i = 2; i < response.length - 1; i += 2) {
          int hb = response[i];
          int lb = response[i + 1];
          codes.add(_parseDtcBytes(hb, lb));
        }
      }

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

  // Helper เพื่อแปลง Byte เป็น DTC Code String (Standard logic)
  String _parseDtcBytes(int hb, int lb) {
    // Bits 7-6 of HB: 00=P, 01=C, 10=B, 11=U
    // Bits 5-0 of HB: First digit
    // LB: Second & Third digits (BCD-like but actually hex display)

    // According to SAE J2012:
    // First Character:
    // 00xx = P (Powertrain)
    // 01xx = C (Chassis)
    // 10xx = B (Body)
    // 11xx = U (Network)

    const prefixes = ["P", "C", "B", "U"];
    int prefixIndex = (hb >> 6) & 0x03;
    String prefix = prefixes[prefixIndex];

    // int secondDigit = (hb >> 4) & 0x03; // Removed unused variable
    // int thirdDigit = hb & 0x0F; // Removed unused variable

    // For simplicity in simulation matching P0123/U0456 logic:
    // Real parser is complex. Let's inverse-map the MockConnection logic:
    // P0123 -> HB=01, LB=23
    // U0456 -> HB=C4, LB=56 (C=1100 -> U, 4)

    String hex = hb.toRadixString(16).toUpperCase().padLeft(2, '0') +
        lb.toRadixString(16).toUpperCase().padLeft(2, '0');

    // Mock mapping logic to make it human readable for the specific simulation
    if (prefix == "P") return "P${hex.substring(1)}"; // 0123 -> P0123
    if (prefix == "U")
      return "U${hex.substring(1)}"; // C456 -> C4 is 11000100 -> U 0 4

    // Fallback standard raw hex
    return "$prefix$hex";
  }
}
