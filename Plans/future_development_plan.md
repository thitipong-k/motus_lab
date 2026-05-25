# Motus Lab: Future Development & Implementation Plan

This document outlines the strategic implementation plan for the Motus Lab platform. It is divided into near-term stability requirements (critical infrastructure) and long-term feature expansions (future roadmap).

## Phase 1: Stabilization & Infrastructure (Critical Short-Term)
These are necessary components to ensure the app is robust enough for professional mechanics and consumers before scaling new features.

### 1.1 OBD2 Mock/Simulator Environment
- **Objective:** Allow UI/UX and feature development without requiring a physical vehicle connection.
- **Implementation:**
  - Create a `MockConnectionService` extending the base connection interface in `lib/core/connection`.
  - Simulate periodic CAN bus data and standard OBD2 PID responses (e.g., oscillating RPM, fixed temperatures).
  - Add a "Developer Mode" toggle in the `settings` feature to switch between Real and Mock connection services using `get_it`.

### 1.2 Automated Testing & CI/CD
- **Objective:** Prevent regressions when modifying fragile hardware protocol parsers.
- **Implementation:**
  - **Unit Tests:** Focus on `lib/core/protocol` to ensure HEX to Decimal conversions and UDS/KWP2000 parsing are 100% accurate.
  - **CI/CD:** Add `.github/workflows/flutter.yml` (or use Codemagic) to trigger `flutter test` and `flutter analyze` on every Pull Request.
  - Automate the building of Windows Desktop (`.exe` or `.msix`) and Android (`.aab`/`.apk`) releases.

### 1.3 Error Reporting & Crash Analytics
- **Objective:** Capture unexpected disconnects and protocol errors in the wild.
- **Implementation:**
  - Integrate `firebase_crashlytics` and `sentry_flutter`.
  - Catch unhandled exceptions in the BLoC state transitions, specifically in the `scan` and `sniffer` modules.
  - Log hardware connection states prior to a crash to understand device-specific Bluetooth/Serial issues.

---

## Phase 2: Cloud & Enterprise Integration (Mid-Term)
Leveraging the existing Firebase foundation to cater to B2B clients (repair shops, fleet managers).

### 2.1 Cloud Telemetry & Fleet Management (Roadmap Phase 5)
- **Objective:** Enable remote diagnostics and vehicle history tracking.
- **Implementation:**
  - Expand the `remote` and `crm` features.
  - Stream live PID data to Cloud Firestore or a dedicated time-series database (e.g., InfluxDB) via MQTT.
  - Create a web dashboard (Flutter Web) for fleet managers to view real-time vehicle health from multiple Motus Lab active sessions.

### 2.2 Advanced Desktop Protocols (J2534 Pass-Thru / DoIP)
- **Objective:** Support professional OEM-level diagnostics on Windows.
- **Implementation Tasks (To-Do List):**

  **🛠️ 1. Core Architecture & Abstraction (สิ่งที่ควรมีเพิ่มเติม)**
  - [x] Refactor `lib/core/protocol` to create a generic `DiagnosticTransport` interface.
  - [x] Ensure UDS (Unified Diagnostic Services) engine is transport-agnostic (can run seamlessly over Serial, BLE, J2534, or DoIP).
  - [x] **[NEW] Add Security Access (UDS 0x27) Handler:** Implement an infrastructure to support Seed-Key algorithms. This is strictly required for advanced module coding/flashing when using J2534.

  **🖥️ 2. J2534 Pass-Thru Integration (Windows)**
  - [x] Bind standard SAE J2534 C-API directly to Dart using `dart:ffi` (Bypassed the need for a C++ wrapper).
  - [x] Implement core PassThru initialization methods: `PassThruOpen`, `PassThruConnect`, `PassThruDisconnect`.
  - [x] Implement PassThru data transfer methods: `PassThruReadMsgs`, `PassThruWriteMsgs`.
  - [x] **[NEW] Build a J2534 Device Scanner:** Write a function to read the Windows Registry (`HKLM\Software\PassThruSupport.04.04`) to automatically list installed VCI drivers (e.g., Tactrix OpenPort, Bosch, DrewTech) in the Motus Lab UI.
  - [x] **[NEW] ECU Flashing Engine:** Create a robust state machine in BLoC specifically for ECU flashing, with safety checks to prevent bricking the ECU when writing `.bin`/`.sgo`/`.odx` files.

  **🌐 3. DoIP (Diagnostics over IP)**
  - [x] Implement UDP broadcasting & listener on port 13400 for DoIP Vehicle Identification (Vehicle Announcement Message).
  - [x] Implement TCP socket connection for DoIP Routing Activation.
  - [x] Build a DoIP Payload Formatter (handling Headers, Diagnostic Messages, Alive Check).
  - [ ] Add specific ENET cable connection profiles for European cars (e.g., BMW F/G series, modern Mercedes-Benz).

---

### 2.3 Professional OEM-Level Diagnostics (Market Leadership Features)
- **Objective:** Match and exceed industry leaders (e.g., Autel, Snap-on) by supporting complex service functions and securing access to modern 2018+ vehicles.
- **Implementation Tasks:**

  **⚡ 1. Bi-Directional Control (Actuation Tests)**
  - [x] Implement UDS `0x31` (Routine Control) and `0x2F` (InputOutputControlByIdentifier) to allow mechanics to command vehicle components (e.g., turn on cooling fan, cylinder drop test).
  - [x] Build a dynamic UI framework in `AdaptationPage` to generate toggle buttons/sliders based on the selected vehicle's capabilities.

  **🔧 2. Adaptation & Basic Settings**
  - [x] Create specialized BLoCs for common maintenance tasks: Battery Registration, Throttle Body Alignment (TBA), Steering Angle Sensor (SAS) Calibration, and DPF Regeneration.
  - [x] Integrate step-by-step wizard UIs for mechanics to safely execute these routines.

  **🔐 3. Security Gateway (SGW) & SFD Unlock**
  - [x] Implement UDS `0x27` (Security Access) with modern 29-bit CAN extensions and generic authentication interfaces (e.g. FCA AutoAuth, VAG SFD).
  - [x] Handle "Access Denied" UDS responses (`0x33`) gracefully by prompting the user to authenticate via the Cloud Seed Service.

  **🔌 4. Next-Gen Hardware Support & Topology**
  - [x] **CAN-FD Support:** Ensure the `ProtocolEngine` can parse payloads larger than 8 bytes per frame (up to 64 bytes) specifically for CAN-FD hardware adapters.
  - [x] **Advanced Topology Mapping:** Upgrade the `TopologyPage` to render interactive Tree/Bus architectures (e.g., PT-CAN, FlexRay) with color-coded health statuses (Green = OK, Red = DTC present).

---

## Phase 3: AI Diagnostics & Monetization (Long-Term)
Creating unique value propositions to stand out from generic OBD2 scanners.

### 3.1 AI Diagnostics (Predictive Maintenance) (Roadmap Phase 6)
- **Objective:** Move beyond raw DTCs (Diagnostic Trouble Codes) to actionable repair advice.
- **Implementation:**
  - Integrate an LLM API (e.g., Gemini or OpenAI).
  - When a DTC (e.g., P0171) is pulled, send the code along with the Vehicle Make/Model to the AI prompt.
  - Return a structured JSON response displaying: "Most Likely Cause", "DIY Fix Feasibility", and "Required Tools".

### 3.2 Subscription Model (In-App Purchases)
- **Objective:** Establish recurring revenue.
- **Implementation:**
  - Integrate `in_app_purchase` for App Stores and Stripe for Web/Desktop.
  - **Free Tier:** Basic OBD2 scanning and live data.
  - **Pro Tier (Motus+):** Unlock Module Coding, CAN Sniffer, PDF Reporting, and AI Diagnostics.

### 3.3 Hardware Integration (OTA Updates)
- **Objective:** Support proprietary Motus Lab hardware dongles.
- **Implementation:**
  - Build a DFU (Device Firmware Update) engine over Bluetooth Low Energy using `flutter_blue_plus`.
  - Allow users to flash new firmware directly to the adapter from the `settings` menu to support new vehicle protocols.
