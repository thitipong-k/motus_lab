part of 'live_data_bloc.dart';

class LiveDataState extends Equatable {
  final Map<String, double> currentValues;
  final bool isStreaming;
  final bool isDiscovering;
  final List<String> supportedPidCodes;
  final List<Command> activeCommands;

  const LiveDataState({
    this.currentValues = const {},
    this.isStreaming = false,
    this.isDiscovering = false,
    this.supportedPidCodes = const [],
    this.activeCommands = const [],
    this.isLogging = false,
    this.currentSessionId,
    this.vin,
  });

  final bool isLogging;
  final int? currentSessionId;
  final String? vin;

  LiveDataState copyWith({
    Map<String, double>? currentValues,
    bool? isStreaming,
    bool? isDiscovering,
    List<String>? supportedPidCodes,
    List<Command>? activeCommands,
    bool? isLogging,
    int? currentSessionId,
    String? vin,
  }) {
    return LiveDataState(
      currentValues: currentValues ?? this.currentValues,
      isStreaming: isStreaming ?? this.isStreaming,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      supportedPidCodes: supportedPidCodes ?? this.supportedPidCodes,
      activeCommands: activeCommands ?? this.activeCommands,
      isLogging: isLogging ?? this.isLogging,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      vin: vin ?? this.vin,
    );
  }

  @override
  List<Object?> get props => [
        currentValues,
        isStreaming,
        isDiscovering,
        supportedPidCodes,
        activeCommands,
        isLogging,
        currentSessionId,
        vin,
      ];
}
