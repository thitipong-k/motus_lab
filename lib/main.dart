import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:motus_lab/core/config/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motus_lab/core/utils/logger.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Logger.info("Main: Widgets initialized.");

  // Initialize Firebase (Safe Init)
  try {
    if (kIsWeb || Platform.isWindows) {
      Logger.info("Main: Initializing Firebase for Windows/Web...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Logger.info("Main: Initializing Firebase for Mobile...");
      await Firebase.initializeApp();
    }
    Logger.info("💡 Firebase Initialized Successfully.");
  } catch (e) {
    Logger.error("⛔ Firebase Initialization Failed", e);
  }

  // Initialization: เริ่มต้นระบบและลงทะเบียน Dependencies
  Logger.info("Main: Setting up Service Locator...");
  await setupLocator();
  Logger.info("Main: Service Locator Ready.");

  // --- 1. Mobile: Immersive Mode ---
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // --- 2. Desktop: Setup Window ---
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    Logger.info("Main: Configuring Window Manager...");
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor:
          Colors.black, // Change from transparent to avoid some GPU issues
      skipTaskbar: false,
      titleBarStyle:
          TitleBarStyle.normal, // Show title bar initially for safety
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      Logger.info("Main: Window Visible and Focused.");
    });
  }

  Logger.info("Main: Running App...");
  runApp(const MotusApp());
}
