import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/command.dart';

part 'live_data_event.dart';
part 'live_data_state.dart';

/// Bloc สำหรับจัดการค่าสด (Live Data)
/// ทำหน้าที่ส่งคำสั่งชุดเดิมวนซ้ำ (Round-robin) เพื่อให้ UI อัพเดตตลอดเวลา
class LiveDataBloc extends Bloc<LiveDataEvent, LiveDataState> {
  final ProtocolEngine _engine;
  final ConnectionInterface _connection;
  Timer? _timer;
  List<Command> _activeCommands = [];

  LiveDataBloc({
    required ProtocolEngine engine,
    required ConnectionInterface connection,
  })  : _engine = engine,
        _connection = connection,
        super(const LiveDataState()) {
    on<StartStreaming>(_onStartStreaming);
    on<StopStreaming>(_onStopStreaming);
    on<UpdateActiveCommands>(_onUpdateActiveCommands);
    on<NewDataReceived>(_onNewDataReceived);
  }

  Future<void> _onStartStreaming(
      StartStreaming event, Emitter<LiveDataState> emit) async {
    _activeCommands = event.commands;
    emit(const LiveDataState(isStreaming: true));

    // หยุด Timer เก่าถ้ามี
    _timer?.cancel();

    // เริ่ม Loop การส่งคำสั่งทุก 200ms
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_connection.isConnected) {
        add(StopStreaming());
        return;
      }

      Map<String, double> updatedValues = Map.from(state.currentValues);

      // ใช้ _activeCommands จาก class field เพื่อให้เปลี่ยนค่าได้กลางอากาศ
      for (var cmd in _activeCommands) {
        try {
          // 1. สร้าง Request
          final request = _engine.buildRequest(cmd);
          // 2. ส่งและรับ Response
          final response = await _connection.send(request);
          // 3. แปลผล
          if (response.isNotEmpty) {
            final value = _engine.parseResponse(response, cmd.formula);
            updatedValues[cmd.name] = value;
          }
        } catch (e) {
          // ข้ามถ้าตัวใดตัวหนึ่งเสีย
        }
      }

      add(NewDataReceived(updatedValues));
    });
  }

  void _onUpdateActiveCommands(
      UpdateActiveCommands event, Emitter<LiveDataState> emit) {
    _activeCommands = event.newCommands;
    // ไม่ต้องทำอะไรเพิ่ม Timer รอบถัดไปจะเก็ตค่าใหม่เอง
  }

  void _onStopStreaming(StopStreaming event, Emitter<LiveDataState> emit) {
    _timer?.cancel();
    emit(const LiveDataState(isStreaming: false));
  }

  void _onNewDataReceived(NewDataReceived event, Emitter<LiveDataState> emit) {
    emit(LiveDataState(
        isStreaming: state.isStreaming, currentValues: event.values));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
