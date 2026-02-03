part of 'live_data_bloc.dart';

abstract class LiveDataEvent extends Equatable {
  const LiveDataEvent();

  @override
  List<Object> get props => [];
}

/// เริ่มดึงข้อมูลค่าสด
class StartStreaming extends LiveDataEvent {
  final List<Command> commands;
  const StartStreaming(this.commands);

  @override
  List<Object> get props => [commands];
}

/// หยุดดึงข้อมูล
class StopStreaming extends LiveDataEvent {}

/// เปลี่ยนรายการคำสั่งที่ต้องการดึง
class UpdateActiveCommands extends LiveDataEvent {
  final List<Command> newCommands;
  const UpdateActiveCommands(this.newCommands);

  @override
  List<Object> get props => [newCommands];
}

/// อัพเดตค่าที่ได้รับมาใหม่
class NewDataReceived extends LiveDataEvent {
  final Map<String, double>? values; // For batch updates
  final String? cmdName; // For single updates from isolate
  final double? value;

  const NewDataReceived({this.values, this.cmdName, this.value});

  @override
  List<Object> get props => [values ?? {}, cmdName ?? '', value ?? 0.0];
}

/// Start logging session
class StartLogging extends LiveDataEvent {}

/// Stop logging session
class StopLogging extends LiveDataEvent {}

/// โหลด Protocol Pack จาก Asset (สำหรับการทดสอบ)
class LoadProtocol extends LiveDataEvent {
  final String assetPath;
  const LoadProtocol(this.assetPath);

  @override
  List<Object> get props => [assetPath];
}
