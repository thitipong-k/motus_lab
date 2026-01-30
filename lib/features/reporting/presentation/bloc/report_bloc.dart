import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';
import 'package:motus_lab/features/reporting/domain/repositories/report_repository.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object> get props => [];
}

class LoadReportConfig extends ReportEvent {}

class UpdateReportConfig extends ReportEvent {
  final ReportConfig config;
  const UpdateReportConfig(this.config);
}

class GenerateReportPdf extends ReportEvent {
  final DiagnosticReport reportData;
  const GenerateReportPdf(this.reportData);
}

// States
enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  final ReportStatus status;
  final ReportConfig? config;
  final File? generatedPdf;
  final String? error;

  const ReportState({
    this.status = ReportStatus.initial,
    this.config,
    this.generatedPdf,
    this.error,
  });

  ReportState copyWith({
    ReportStatus? status,
    ReportConfig? config,
    File? generatedPdf,
    String? error,
  }) {
    return ReportState(
      status: status ?? this.status,
      config: config ?? this.config,
      generatedPdf: generatedPdf ?? this.generatedPdf,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, config, generatedPdf, error];
}

// Bloc
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc(this.repository) : super(const ReportState()) {
    on<LoadReportConfig>(_onLoadConfig);
    on<UpdateReportConfig>(_onUpdateConfig);
    on<GenerateReportPdf>(_onGeneratePdf);
  }

  Future<void> _onLoadConfig(
      LoadReportConfig event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final config = await repository.getReportConfig();
      emit(state.copyWith(status: ReportStatus.success, config: config));
    } catch (e) {
      emit(state.copyWith(status: ReportStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onUpdateConfig(
      UpdateReportConfig event, Emitter<ReportState> emit) async {
    try {
      await repository.saveReportConfig(event.config);
      emit(state.copyWith(config: event.config));
    } catch (e) {
      emit(state.copyWith(status: ReportStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onGeneratePdf(
      GenerateReportPdf event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      // Ensure config is loaded
      final config = state.config ?? await repository.getReportConfig();

      final file = await repository.generateReportPdf(event.reportData, config);
      emit(state.copyWith(
        status: ReportStatus.success,
        generatedPdf: file,
        config: config, // Update config in state if it was null
      ));
    } catch (e) {
      emit(state.copyWith(status: ReportStatus.failure, error: e.toString()));
    }
  }
}
