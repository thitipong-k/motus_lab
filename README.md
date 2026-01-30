# Motus Lab 🚗💻

**The Ultimate Professional Automotive Diagnostic Platform**

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0-blue?logo=dart)
![Version](https://img.shields.io/badge/Version-0.6.0-green)
![License](https://img.shields.io/badge/License-Proprietary-orange)

Motus Lab is a high-performance cross-platform application (Android, iOS, Windows, Linux) designed for automotive enthusiasts and professionals. It communicates with vehicle ECUs via OBD-II protocols to perform diagnostics, real-time monitoring, and performance tuning.

---

## ✨ Key Features (ฟีเจอร์หลัก)

### 1. 🔌 Universal Connectivity

Connect to any OBD2 adapter seamlessly:

- **Bluetooth Low Energy (BLE)**: iOS/Android support.
- **Bluetooth Classic**: High-speed data for Android.
- **WiFi**: For high-bandwidth adapters.
- **USB Serial**: Ultra-low latency for desktop/laptop use.

### 2. 📊 Live Data & Adaptive Discovery

- **Smart PID Scanning**: Automatically detects supported sensors from the vehicle.
- **Real-time Graphing**: Visualize RPM, Speed, Fuel Trims, and more with zero lag.
- **Adaptive Pruning**: Automatically disables unresponsive sensors to maximize update rate.

### 3. 🎨 Dynamic Visual System (New in v0.6.0)

Choose from 5 distinct visual themes to match your style or environment:

- 🟣 **Cyberpunk Neon**: High-contrast dark mode with neon accents (Default).
- 🔵 **Clean Professional**: Trustworthy, bright OEM-style interface.
- 🔮 **Modern Glassmorphism**: Premium iOS-style translucency.
- 🟠 **Dark Tactical**: Rugged, military-grade industrial look.
- 🌿 **Minimalist Eco**: Clean white/green aesthetic for sustainability focus.

### 4. 🛠️ Smart Diagnostics

- **DTC Reader**: Read and Clear Diagnostic Trouble Codes.
- **Expert Database**: Built-in library of fault codes with descriptions and potential solutions.
- **Topology View**: Visual network map of vehicle modules (CAN Bus simulation).

### 5. 🌍 Localization

- **Multi-language Support**: Fully localized for **Thai (th)** and **English (en)**.
- **Auto-detection**: Adapts to system language or user preference.

---

## 🏗️ Architecture

The project follows **Clean Architecture** combined with a **Feature-First** folder structure to ensure scalability and maintainability.

```
lib/
├── core/                # Shared utilities, themes, and base logic
│   ├── theme/           # Dynamic Theme System (Cubit + Enum)
│   ├── protocol/        # OBD Protocol Engine
│   └── services/        # Service Locator (GetIt)
├── features/            # Feature modules
│   ├── dashboard/       # Gauges and Live Data UI
│   ├── scan/            # Connection and PID Discovery
│   └── reports/         # Settings and PDF Generation
└── main.dart            # App entry point
```

**Tech Stack:**

- **State Management**: `flutter_bloc`
- **Dependency Injection**: `get_it`
- **Database**: `drift` (SQLite)
- **Bluetooth**: `flutter_blue_plus`
- **Localization**: `flutter_localizations`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Android Studio / VS Code
- Windows/Linux/macOS for desktop builds

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/motus-lab/project.git
   cd motus_lab
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   # Run on Windows (Desktop)
   flutter run -d windows

   # Run on Android (Emulator/Device)
   flutter run -d android
   ```

---

## 📅 Roadmap Status

| Phase | Module | Status |
|-------|--------|--------|
| **1** | Core Architecture | ✅ Complete |
| **2** | Connection Module | ✅ Complete |
| **3** | Live Data Engine | ✅ Complete |
| **4** | Theme System (5 Styles) | ✅ Complete (v0.6.0) |
| **5** | Cloud Sync | ⏳ Pending |
| **6** | AI Predictions | ⏳ Pending |

---

## 👥 Authors

- **Motus Lab Team** - *Lead Developers*

---

*Verified for deployment on Windows 11 & Android 14.*
