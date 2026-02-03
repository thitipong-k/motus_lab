# Changelog

## [1.0.5] - 2026-02-03

### Added

- **Professional Security (Phase 11)**:
  - **Biometric App Lock**: Integrated `local_auth` to protect sensitive modules (CRM, Reports, Logs).
  - **Security Settings**: New toggle in Settings page to manage App Lock/Biometric access.
  - **Authentication Guard**: Centralized Auth-check logic in `MorePage` for professional privacy.
- **Thai System Documentation**: Detailed Thai comments added to core security, database, and protocol engine modules for transparent operation explanation.

### Changed

- **Database Architecture**: Implemented `SecurityRepository` for unified encryption key management.
- **Windows Compatibility (Developer Bypass)**:
  - Bypassed `sqlcipher_flutter_libs` and `flutter_secure_storage` on Windows to resolve OpenSSL and ATL build blockers.
  - Implemented `SharedPreferences` fallback for security keys during Windows local development.
- **Protocol Engine Stability**: Resolved compilation issues with `ObdCommandDef.script` and refined Thai documentation for data decoding logic.

### Fixed

- **Manual Localization Sync**: Resolved missing getters in `AppLocalizations` hierarchy for security-related strings.

## [1.0.4] - 2026-02-02

### Added

- **Multi-language Support (Phase 17)**: Full localization infrastructure for EN/TH.
  - Language Selector in Settings page with bottom sheet UI.
  - Localized Navigation Bar (Connect, Dash, Map, Service, Menu).
  - Localized Menu Grid (12 feature tiles with Thai translations).
  - Persistent language setting via SharedPreferences.
- **Thai Documentation**: Added comprehensive Thai comments to localization files.
- **Cloud Seeding Script**: External Python script for bulk Firestore uploads.

### Changed

- **SettingsBloc**: Added `UpdateLanguage` event for dynamic locale switching.
- **MotusApp**: `MaterialApp.locale` now dynamically updates from `SettingsState`.

### Fixed

- **Manual l10n Sync**: Resolved code generator lag by manually syncing AppLocalizations classes.

## [1.0.0] - 2026-01-30

### Added

- **Final Gold Master**: All core modules (Connection, Live Data, Diagnostics, Reporting, CRM, Remote Expert) are now 100% complete.
- **Improved UI Stability**: Resolved GlobalKey conflicts and ListTile layout overflows across all pages.
- **Unified Bloc Management**: All Blocs now operate as Singletons via Service Locator for consistent state management.
- **Thai Comments**: Exhaustive Thai documentation added to core system files for easier maintenance.
- **Platform Optimization**: Enhanced Immersive Mode for Mobile and Full Screen for Desktop.

## [0.8.2] - 2026-01-30

### Added

- **Professional Reporting**: Generate PDF reports with DTCs, Vehicle Info, and Shop Branding.
- **Shop Settings**: Configure shop name, address, and logo for reports.
- **PDF Preview**: View, print, and share diagnostic reports directly from the app.

## [2.6.0] - 2025-01-31

### Added

- **Vehicle Topology (Phase 10)**:
  - Dynamic CAN Bus scanning simulation.
  - Interactive network map with node status (OK, Fault, Offline).
  - Detailed ECU information dialog.
- **Live Data Pro (Phase 7)**:
  - Multi-series graphing support.
  - Log recording with CSV export.
  - Unit conversion system.

## [2.5.1] - 2025-01-2930

### Added

- **Remote Expert**: Real-time chat interface with mock certified mechanics.
- **ChatWidget**: Custom bubble chat UI with support for text messages.

## [0.8.1] - 2026-01-30

### Added

- **Remote Expert**: Real-time chat interface with mock certified mechanics.
- **ChatWidget**: Custom bubble chat UI with support for text messages.
- **Mock Connection**: Simulated server connection and auto-replies.

## [0.8.0] - 2026-01-30

### Added

- **CRM Module**: Complete Customer Relationship Management system (Database, Domain, UI).
- **Customers Table**: Drift database table for storing customer info.
- **Vehicle Linking**: Ability to associate vehicles with customers.
- **Web Support Fix**: Resolved platform crash on web by adding kIsWeb checks.

### Changed

- **MotusButton**: Fixed parameter error (removed width/height).
- **Documentation**: Added Thai comments to core workflow files.

## [0.7.1] - 2026-01-30

### Documentation

- **Workflow Comments**: Added Thai comments to `scan_bloc.dart` and `live_data_bloc.dart` explaining system internals.
- **Roadmap Update**: Updated Phase 7 status for PID library and persistence.

## [0.7.3] - 2026-01-30

### Added

- **Maintenance Module**: Added Service Reminders feature to track vehicle maintenance (mileage/date).
- **Data Export**: Support for exporting reports as CSV files for external analysis.
- **Settings UI**: Improved export dialog to select between PDF and CSV formats.
- **Settings Module**: New feature for managing app preferences.
- **Connection Preferences**: Added auto-connect toggle and adjustable connection timeout.
- **Dependency Injection**: Fixed runtime crash by registering `SharedPreferences` in `ServiceLocator`.

## [0.7.2] - 2026-01-30

### Refactor

- **Frontend Architecture**:
  - Implemented **Clean Architecture** (Data, Domain, Presentation layers).
  - Adopted **Feature-First** structure (features/scan, features/dashboard).
  - Decoupled BLoCs using **UseCases** (`ReadVinUseCase`, `ConnectToDeviceUseCase`).
- **Data Layer**: Moved repositories to feature directories.
- **UI Components**: Extracted Core Widgets (`MotusCard`, `MotusButton`, `EmptyState`) for consistent design.

### Fixed

- **Demo Mode**: Fixed unresponsive "Enter Demo Mode" button by bypassing Bluetooth stopScan check.

## [0.7.0] - 2026-01-30

### Added

- **Full Screen / Immersive Mode**: Automatically hides system bars on Mobile and launches full screen on Desktop.
- **Improved Dashboard Navigation**: Implemented `IndexedStack` to preserve state between tabs (fixed crashes).
- **Freeze Frame UI**: New responsive layout for viewing DTC snapshot data.
- **Enhanced Themes**: Major upgrade to "Cyberpunk Neon" theme (Glowing text, Orbitron font).

### Changed

- **Live Data Refactor**: Removed "List View" to focus on "Gauge" and "Graph" modes.
- **Graphing Engine**: Optimized `fl_chart` integration for real-time history (50 points buffer).

### Fixed

- **App Crash**: Resolves `RenderFlex overflow` in Freeze Frame page.
- **Demo Mode**: Fixed "Enter Demo Mode" button not connecting to mock device.
- **Layout Stability**: Fixed "GlobalKey" collision errors by refactoring navigation.

## [0.6.0] - 2026-01-30

### Added

- **Dynamic Theme System**: 5 selectable visual styles (Cyberpunk, Professional, Glass, Tactical, Eco).
- **Settings Page**: New UI for changing themes and checking reports.
- **Thai Localization**: Added detailed Thai comments in code for better maintenance.

### Fixed

- Fixed `AppTheme` dependency on `google_fonts`.
- Resolved `shared_preferences` missing from pubspec.
