// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Motus Lab';

  @override
  String get titleDeviceSelection => 'Device Selection';

  @override
  String get btnConnect => 'Connect';

  @override
  String get btnConnected => 'Connected';

  @override
  String get btnDisconnect => 'Disconnect';

  @override
  String get btnScan => 'Scan';

  @override
  String get btnStop => 'Stop';

  @override
  String get lblScanning => 'Scanning for OBDII devices...';

  @override
  String get lblConnecting => 'Connecting to device...';

  @override
  String get lblConnected => 'Connected successfully!';

  @override
  String lblError(String message) {
    return 'Error: $message';
  }

  @override
  String get msgNoDevices => 'No devices found. Tap refresh to scan.';

  @override
  String get msgTapToScan => 'Tap refresh to start scanning';
}
