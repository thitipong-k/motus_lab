part of 'live_data_bloc.dart';

class LiveDataState extends Equatable {
  final Map<String, double> currentValues;
  final bool isStreaming;

  const LiveDataState({
    this.currentValues = const {},
    this.isStreaming = false,
  });

  @override
  List<Object> get props => [currentValues, isStreaming];
}
