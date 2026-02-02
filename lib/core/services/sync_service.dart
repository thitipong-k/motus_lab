import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:motus_lab/core/services/security/auth_service.dart';
import 'package:motus_lab/features/reporting/domain/repositories/report_repository.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';
import 'package:motus_lab/core/utils/logger.dart';

class SyncService {
  final AuthService _auth;
  final ReportRepository _reportRepository;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  SyncService(this._auth, this._reportRepository);

  /// Initialize Sync listeners
  void init() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && _auth.isLoggedIn) {
        Logger.info("Internet connection detected. Auto-Sync triggered.");
        syncAll();
      }
    });

    // Also trigger sync on login
    _auth.userChanges.listen((user) {
      if (user != null) {
        Logger.info("User logged in. Triggering initial sync.");
        syncAll();
      }
    });
  }

  /// Trigger full sync logic
  Future<void> syncAll() async {
    if (!_auth.isLoggedIn) {
      Logger.info("Sync skipped: User not authenticated.");
      return;
    }

    try {
      Logger.info("Starting Sync Cycle for user: ${_auth.currentUser?.uid}");
      // 1. Sync Workshop Branding (Pilot)
      await _syncWorkshopBranding();

      // 2. Sync Vehicle Logs (Future)
      // 3. Sync CRM Data (Future)

      Logger.info("Sync Cycle Completed.");
    } catch (e) {
      Logger.error("Sync Cycle Failed", e);
    }
  }

  Future<void> _syncWorkshopBranding() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('branding');

    try {
      // 1. Get Local Data
      final localConfig = await _reportRepository.getReportConfig();

      // 2. Get Remote Data
      final remoteDoc = await docRef.get();

      if (!remoteDoc.exists) {
        // Initial Upload: User has local settings but nothing on cloud
        Logger.info("No remote branding found. Uploading local settings...");
        await _uploadToCloud(docRef, localConfig);
        return;
      }

      final remoteConfig = ReportConfig.fromMap(remoteDoc.data()!);

      // 3. Last Write Wins (Conflict Resolution)
      // กลยุทธ์แก้ปัญหาข้อมูลชนกัน: "ใครเซฟทีหลัง ชนะ"
      final localTime = localConfig.lastUpdated ?? DateTime(2000);
      final remoteTime = remoteConfig.lastUpdated ?? DateTime(2000);

      if (localTime.isAfter(remoteTime)) {
        Logger.info("Local branding is newer. Pushing to Cloud...");
        await _uploadToCloud(docRef, localConfig);
      } else if (remoteTime.isAfter(localTime)) {
        Logger.info("Cloud branding is newer. Pulling to Local...");
        await _reportRepository.saveReportConfig(remoteConfig);
        // หมายเหตุ: กรณีเป็น URL รูปภาพ ระบบ UI จะโหลดจากเน็ตให้อัตโนมัติในครั้งถัดไป
      } else {
        Logger.info("Branding is already in sync.");
      }
    } catch (e) {
      Logger.error("Workshop Branding Sync Failed", e);
    }
  }

  Future<void> _uploadToCloud(
      DocumentReference docRef, ReportConfig config) async {
    // Handling Logo Upload to Firebase Storage if exists
    String? cloudLogoUrl = config.logoPath;

    // Skip Storage upload on Windows due to plugin thread crash issue
    // หมายเหตุ: ปิดการอัปโหลดรูปบน Windows ชั่วคราว
    // เนื่องจากปัญหา Native Threading ของ Plugin firebase_storage ที่ทำให้แอปปิดตัวเอง
    if (!Platform.isWindows &&
        config.logoPath != null &&
        File(config.logoPath!).existsSync()) {
      try {
        final userId = _auth.currentUser?.uid;
        final file = File(config.logoPath!);
        final storageRef =
            FirebaseStorage.instance.ref().child('logos/$userId/branding.png');
        await storageRef.putFile(file);
        cloudLogoUrl = await storageRef.getDownloadURL();
        Logger.info("Logo uploaded to Cloud Storage: $cloudLogoUrl");
      } catch (e) {
        Logger.error("Logo upload failed", e);
      }
    } else if (Platform.isWindows) {
      Logger.info(
          "Skipping logo upload on Windows (Native threading issue). Syncing metadata only.");
    }

    // บันทึกข้อมูล Metadata ลง Firestore (ชื่อร้าน, ที่อยู่, เบอร์โทร)
    await docRef.set(config.toMap()..['logoUrl'] = cloudLogoUrl);
    Logger.info("Workshop branding metadata pushed to Cloud Firestore.");
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
