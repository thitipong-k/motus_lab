import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_style.dart';
import 'package:motus_lab/features/settings/domain/entities/settings.dart';
import 'package:motus_lab/features/settings/domain/repositories/settings_repository.dart';

// --- Events ---
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateTheme extends SettingsEvent {
  final AppStyle theme;
  const UpdateTheme(this.theme);
}

class UpdateAutoConnect extends SettingsEvent {
  final bool isEnabled;
  const UpdateAutoConnect(this.isEnabled);
}

class UpdateConnectionTimeout extends SettingsEvent {
  final int seconds;
  const UpdateConnectionTimeout(this.seconds);
}

class UpdateUnitSystem extends SettingsEvent {
  final UnitSystem unitSystem;
  const UpdateUnitSystem(this.unitSystem);
}

class SettingsState extends Equatable {
  final Settings settings;
  final bool isLoading;

  const SettingsState({
    required this.settings,
    this.isLoading = true,
  });

  factory SettingsState.initial() {
    return SettingsState(settings: Settings.defaults());
  }

  SettingsState copyWith({
    Settings? settings,
    bool? isLoading,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [settings, isLoading];
}

// --- Bloc ---
/// Bloc สำหรับจัดการการตั้งค่าของแอป (Theme, Connection, Language)
/// [WORKFLOW STEP: Settings Management]
/// 1. LoadSettings: อ่านค่าจาก SharedPreferences เมื่อเริ่มแอป
/// 2. Update*: รับ Event จาก UI และบันทึกลง Persistence ทันที
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
        super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateAutoConnect>(_onUpdateAutoConnect);
    on<UpdateConnectionTimeout>(_onUpdateConnectionTimeout);
    on<UpdateUnitSystem>(_onUpdateUnitSystem);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final settings = await _repository.getSettings();
    emit(state.copyWith(settings: settings, isLoading: false));
  }

  Future<void> _onUpdateTheme(
      UpdateTheme event, Emitter<SettingsState> emit) async {
    final newSettings = state.settings.copyWith(theme: event.theme);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> _onUpdateAutoConnect(
      UpdateAutoConnect event, Emitter<SettingsState> emit) async {
    final newSettings = state.settings.copyWith(isAutoConnect: event.isEnabled);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> _onUpdateConnectionTimeout(
      UpdateConnectionTimeout event, Emitter<SettingsState> emit) async {
    final newSettings =
        state.settings.copyWith(connectionTimeoutSeconds: event.seconds);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> _onUpdateUnitSystem(
      UpdateUnitSystem event, Emitter<SettingsState> emit) async {
    final newSettings = state.settings.copyWith(unitSystem: event.unitSystem);
    await _repository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }
}
