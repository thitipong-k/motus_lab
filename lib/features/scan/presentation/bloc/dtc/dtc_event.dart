part of 'dtc_bloc.dart';

abstract class DtcEvent extends Equatable {
  const DtcEvent();

  @override
  List<Object> get props => [];
}

/// อ่านค่าความผิดปกติ (Mode 03)
class ReadDtcCodes extends DtcEvent {}

/// ลบค่าความผิดปกติ (Mode 04)
class ClearDtcCodes extends DtcEvent {}

/// เมื่อได้รับข้อมูล DTC ใหม่
class DtcCodesUpdated extends DtcEvent {
  final List<String> codes;
  const DtcCodesUpdated(this.codes);

  @override
  List<Object> get props => [codes];
}
