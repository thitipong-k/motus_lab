import 'package:motus_lab/features/settings/domain/entities/settings.dart';
import 'package:motus_lab/features/settings/domain/repositories/settings_repository.dart';
import 'package:motus_lab/features/settings/data/datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource dataSource;

  SettingsRepositoryImpl(this.dataSource);

  @override
  Future<Settings> getSettings() async {
    return await dataSource.getSettings();
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await dataSource
        .saveSettings(settings); // Fire and forget or await? Safe to await.
  }
}
