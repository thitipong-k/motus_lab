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

  @override
  String get menuSettings => 'Settings';

  @override
  String get lblVisualTheme => 'Visual Theme';

  @override
  String get lblUnitSystem => 'Unit System';

  @override
  String get lblLanguage => 'Language';

  @override
  String get lblImperial => 'Imperial (mph, °F)';

  @override
  String get lblMetric => 'Metric (km/h, °C)';

  @override
  String get navConnect => 'Connect';

  @override
  String get navDash => 'Dash';

  @override
  String get navMap => 'Map';

  @override
  String get navService => 'Service';

  @override
  String get navMenu => 'Menu';

  @override
  String get moreHelp => 'Help Center';

  @override
  String get moreDiagnostics => 'Diagnostics';

  @override
  String get moreFreezeFrame => 'Freeze Frame';

  @override
  String get moreDataLogs => 'Data Logs';

  @override
  String get moreCRM => 'CRM';

  @override
  String get moreRemoteExpert => 'Remote Expert';

  @override
  String get moreWallet => 'Wallet';

  @override
  String get moreCoding => 'Coding';

  @override
  String get moreSniffer => 'Sniffer';

  @override
  String get moreKnowledge => 'Knowledge';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreSeedCloud => 'Seed Cloud';
}
