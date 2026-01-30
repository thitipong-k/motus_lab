import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/theme/app_style.dart';

enum UnitSystem { metric, imperial }

class Settings extends Equatable {
  final AppStyle theme;
  final String languageCode;
  final bool isAutoConnect;
  final int connectionTimeoutSeconds;
  final UnitSystem unitSystem;

  const Settings({
    required this.theme,
    required this.languageCode,
    required this.isAutoConnect,
    required this.connectionTimeoutSeconds,
    this.unitSystem = UnitSystem.metric,
  });

  // Default Settings
  factory Settings.defaults() {
    return const Settings(
      theme: AppStyle.cyberpunk,
      languageCode: 'en',
      isAutoConnect: false,
      connectionTimeoutSeconds: 10,
      unitSystem: UnitSystem.metric,
    );
  }

  Settings copyWith({
    AppStyle? theme,
    String? languageCode,
    bool? isAutoConnect,
    int? connectionTimeoutSeconds,
    UnitSystem? unitSystem,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      isAutoConnect: isAutoConnect ?? this.isAutoConnect,
      connectionTimeoutSeconds:
          connectionTimeoutSeconds ?? this.connectionTimeoutSeconds,
      unitSystem: unitSystem ?? this.unitSystem,
    );
  }

  @override
  List<Object?> get props => [
        theme,
        languageCode,
        isAutoConnect,
        connectionTimeoutSeconds,
        unitSystem
      ];
}
