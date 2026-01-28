part of 'dtc_bloc.dart';

enum DtcStatus { initial, loading, success, error, clearing }

class DtcState extends Equatable {
  final DtcStatus status;
  final List<String> codes;
  final String? errorMessage;

  const DtcState({
    this.status = DtcStatus.initial,
    this.codes = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, codes, errorMessage];
}
