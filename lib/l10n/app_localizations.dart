import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// ===================================================================
/// AppLocalizations - ระบบแปลภาษาหลักของแอป Motus Lab
/// ===================================================================
///
/// ไฟล์นี้เป็น "Abstract Class" สำหรับระบบแปลภาษา (Localization)
/// โดยจะมีไฟล์ลูกสองไฟล์ที่ implement แตกต่างกันไปตามภาษา:
/// - `app_localizations_en.dart` - ภาษาอังกฤษ
/// - `app_localizations_th.dart` - ภาษาไทย
///
/// วิธีการใช้งานในหน้า Widget:
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// Text(l10n.navConnect); // จะแสดง "Connect" หรือ "เชื่อมต่อ" ตามภาษาที่เลือก
/// ```
///
/// การเพิ่มคำศัพท์ใหม่:
/// 1. เพิ่ม Key ใน `app_en.arb` และ `app_th.arb`
/// 2. เพิ่ม getter ใน Abstract Class นี้
/// 3. Implement getter ใน `app_localizations_en.dart` และ `app_localizations_th.dart`
/// ===================================================================

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Motus Lab'**
  String get appTitle;

  /// No description provided for @titleDeviceSelection.
  ///
  /// In en, this message translates to:
  /// **'Device Selection'**
  String get titleDeviceSelection;

  /// No description provided for @btnConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get btnConnect;

  /// No description provided for @btnConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get btnConnected;

  /// No description provided for @btnDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get btnDisconnect;

  /// No description provided for @btnScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get btnScan;

  /// No description provided for @btnStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get btnStop;

  /// No description provided for @lblScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning for OBDII devices...'**
  String get lblScanning;

  /// No description provided for @lblConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to device...'**
  String get lblConnecting;

  /// No description provided for @lblConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully!'**
  String get lblConnected;

  /// No description provided for @lblError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String lblError(String message);

  /// No description provided for @msgNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices found. Tap refresh to scan.'**
  String get msgNoDevices;

  /// **'Tap refresh to start scanning'**
  String get msgTapToScan;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @lblVisualTheme.
  ///
  /// In en, this message translates to:
  /// **'Visual Theme'**
  String get lblVisualTheme;

  /// No description provided for @lblUnitSystem.
  ///
  /// In en, this message translates to:
  /// **'Unit System'**
  String get lblUnitSystem;

  /// No description provided for @lblLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lblLanguage;

  /// No description provided for @lblImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (mph, °F)'**
  String get lblImperial;

  /// No description provided for @lblMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (km/h, °C)'**
  String get lblMetric;

  /// No description provided for @navConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get navConnect;

  /// No description provided for @navDash.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get navDash;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get navService;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @moreHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get moreHelp;

  /// No description provided for @moreDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get moreDiagnostics;

  /// No description provided for @moreFreezeFrame.
  ///
  /// In en, this message translates to:
  /// **'Freeze Frame'**
  String get moreFreezeFrame;

  /// No description provided for @moreDataLogs.
  ///
  /// In en, this message translates to:
  /// **'Data Logs'**
  String get moreDataLogs;

  /// No description provided for @moreCRM.
  ///
  /// In en, this message translates to:
  /// **'CRM'**
  String get moreCRM;

  /// No description provided for @moreRemoteExpert.
  ///
  /// In en, this message translates to:
  /// **'Remote Expert'**
  String get moreRemoteExpert;

  /// No description provided for @moreWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get moreWallet;

  /// No description provided for @moreCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get moreCoding;

  /// No description provided for @moreSniffer.
  ///
  /// In en, this message translates to:
  /// **'Sniffer'**
  String get moreSniffer;

  /// No description provided for @moreKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get moreKnowledge;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @moreSeedCloud.
  ///
  /// In en, this message translates to:
  /// **'Seed Cloud'**
  String get moreSeedCloud;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
