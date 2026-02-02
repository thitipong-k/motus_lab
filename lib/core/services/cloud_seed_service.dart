import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:motus_lab/core/utils/logger.dart';
import 'package:motus_lab/core/services/security/auth_service.dart';

/// Top-level function for compute to handle JSON decoding in a separate isolate
List<dynamic> _decodeDtcJson(String jsonString) {
  return jsonDecode(jsonString) as List<dynamic>;
}

/// [CloudSeedService]
/// ทำหน้าที่นำเข้าข้อมูล DTC จากไฟล์ JSON ภายนอก (GitHub) ขึ้นสู่ Cloud Firestore
/// รองรับการทำ Batch Write เพื่อประสิทธิภาพสูงสุด
class CloudSeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth;

  CloudSeedService(this._auth);

  /// นำเข้าข้อมูล DTC แบบอัจฉริยะ
  /// รองรับข้อมูลแบบ Rich Data (มีสาเหตุและวิธีแก้) และการแยกยี่ห้ออัตโนมัติ
  Future<void> seedBrandToCloud(String defaultBrand, String assetPath) async {
    if (!_auth.isLoggedIn) {
      Logger.error("CloudSeed: Failed - User must be logged in to seed data.");
      return;
    }

    try {
      Logger.info(
          "CloudSeed: Starting Smart Import from $assetPath (Default: $defaultBrand)");

      final String jsonString = await rootBundle.loadString(assetPath);

      // ใช้ compute เพื่อประมวลผล JSON ใน Isolate แยกต่างหาก ป้องกัน UI ค้างและแอปหลุด
      final List<dynamic> rawData = await compute(_decodeDtcJson, jsonString);

      const int batchSize = 100; // ลดขนาดลงเพื่อความปลอดภัยบน Windows
      int totalSeeded = 0;

      for (int i = 0; i < rawData.length; i += batchSize) {
        final end =
            (i + batchSize < rawData.length) ? i + batchSize : rawData.length;
        final chunk = rawData.sublist(i, end);
        final batch = _firestore.batch();

        for (var item in chunk) {
          // 1. Normalizing basic fields
          final String code = item['Code'] ?? item['code'] ?? 'UNKNOWN';
          final String description =
              item['Description'] ?? item['description'] ?? item['title'] ?? '';

          // 2. Smart Manufacturer Detection
          final String brand =
              (item['manufacturer'] ?? defaultBrand).toString().toLowerCase();

          // 3. Prepare target path
          final docRef = _firestore
              .collection('knowledge_base')
              .doc('dtcs')
              .collection(brand)
              .doc(code);

          // 4. Data Payload (Rich Data Support)
          final Map<String, dynamic> data = {
            'code': code,
            'description': description,
            'brand': brand,
            'lastUpdated': FieldValue.serverTimestamp(),
            'seededBy': _auth.currentUser?.uid,
            'isVerified': false,
          };

          if (item['causes'] != null) {
            data['causes'] = item['causes'];
          }

          if (item['type'] != null) data['type'] = item['type'];
          if (item['is_generic'] != null)
            data['is_generic'] = item['is_generic'];

          batch.set(docRef, data, SetOptions(merge: true));
        }

        await batch.commit();
        totalSeeded += chunk.length;
        Logger.info("CloudSeed: Progress: $totalSeeded / ${rawData.length}");

        // เพิ่ม Delay ให้มากขึ้นเป็น 500ms เพื่อความเสถียรสูงสุด
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Logger.info(
          "CloudSeed: Successfully seeded $totalSeeded codes from $assetPath");
    } catch (e) {
      Logger.error("CloudSeed: Failed to seed data from $assetPath", e);
      rethrow;
    }
  }

  /// นำเข้าข้อมูลจากไฟล์เดียว
  Future<void> seedSingleFile(String assetPath) async {
    await seedBrandToCloud('standard', assetPath);
  }

  /// นำเข้าข้อมูลจากไฟล์ทั้งหมดที่มีในระบบ
  Future<void> seedAllAvailableAssets() async {
    final List<Map<String, String>> assetsToSeed = [
      {'brand': 'standard', 'path': 'assets/data/codes.json'},
      {'brand': 'standard', 'path': 'assets/data/generic_codes.json'},
      {'brand': 'thailand', 'path': 'assets/data/diagnostic_data_th.json'},
      {'brand': 'auto_detect', 'path': 'assets/data/dtc_definitions.json'},
    ];

    for (var asset in assetsToSeed) {
      try {
        await seedBrandToCloud(asset['brand']!, asset['path']!);
      } catch (e) {
        Logger.error("CloudSeed: Skipping ${asset['path']} due to error: $e");
        continue;
      }
    }
  }

  /// ฟังก์ชันเดิม (ยังคงไว้เพื่อความเข้ากันได้)
  Future<void> seedAllBrands() async {
    await seedAllAvailableAssets();
  }
}
