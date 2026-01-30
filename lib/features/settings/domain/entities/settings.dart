import 'package:equatable/equatable.dart';
import 'package:motus_lab/core/theme/app_style.dart';

class Settings extends Equatable {
  final AppStyle theme;
  final String languageCode;
  final bool isAutoConnect;
  final int connectionTimeoutSeconds;

  const Settings({
    required this.theme,
    required this.languageCode,
    required this.isAutoConnect,
    required this.connectionTimeoutSeconds,
  });

  // Default Settings
  factory Settings.defaults() {
    return const Settings(
      theme: AppStyle.cyberpunk,
      languageCode: 'en',
      isAutoConnect: false,
      connectionTimeoutSeconds: 10,
    );
  }

  Settings copyWith({
    AppStyle? theme,
    String? languageCode,
    bool? isAutoConnect,
    int? connectionTimeoutSeconds,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      isAutoConnect: isAutoConnect ?? this.isAutoConnect,
      connectionTimeoutSeconds:
          connectionTimeoutSeconds ?? this.connectionTimeoutSeconds,
    );
  }

  @override
  List<Object?> get props =>
      [theme, languageCode, isAutoConnect, connectionTimeoutSeconds];
}
