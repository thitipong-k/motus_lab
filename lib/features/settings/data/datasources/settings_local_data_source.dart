import 'package:shared_preferences/shared_preferences.dart';
import 'package:motus_lab/core/theme/app_style.dart';
import 'package:motus_lab/features/settings/domain/entities/settings.dart';

abstract class SettingsLocalDataSource {
  Future<Settings> getSettings();
  Future<void> saveSettings(Settings settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  static const _keyTheme = 'settings_theme';
  static const _keyLanguage = 'settings_language';
  static const _keyAutoConnect = 'settings_auto_connect';
  static const _keyTimeout = 'settings_timeout';
  static const _keyUnitSystem = 'settings_unit_system';

  @override
  Future<Settings> getSettings() async {
    final themeIndex = sharedPreferences.getInt(_keyTheme) ?? 0;
    final theme = AppStyle.values[themeIndex];

    final language = sharedPreferences.getString(_keyLanguage) ?? 'en';
    final autoConnect = sharedPreferences.getBool(_keyAutoConnect) ?? false;
    final timeout = sharedPreferences.getInt(_keyTimeout) ?? 10;

    final unitIndex =
        sharedPreferences.getInt(_keyUnitSystem) ?? 0; // Metric default
    final unitSystem = UnitSystem.values[unitIndex];

    return Settings(
      theme: theme,
      languageCode: language,
      isAutoConnect: autoConnect,
      connectionTimeoutSeconds: timeout,
      unitSystem: unitSystem,
    );
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await sharedPreferences.setInt(_keyTheme, settings.theme.index);
    await sharedPreferences.setString(_keyLanguage, settings.languageCode);
    await sharedPreferences.setBool(_keyAutoConnect, settings.isAutoConnect);
    await sharedPreferences.setInt(
        _keyTimeout, settings.connectionTimeoutSeconds);
    await sharedPreferences.setInt(_keyUnitSystem, settings.unitSystem.index);
  }
}
