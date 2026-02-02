import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/core/utils/logger.dart';

/// [VehicleStatsRepository]
/// จัดการข้อมูลสถิติการสแกนรถยนต์แต่ละรุ่น เพื่อสนับสนุนการทำ Predictive Caching
class VehicleStatsRepository {
  final AppDatabase _db;

  VehicleStatsRepository(this._db);

  /// 1. เพิ่มจำนวนการสแกนสำหรับรถรุ่นนั้นๆ (Increment Scan Count)
  /// จะถูกเรียกใช้เมื่อมีการเริ่มกระบวนการสแกน DTC หรือ Live Data
  Future<void> incrementScanCount({
    required int year,
    required String make,
    required String model,
  }) async {
    try {
      // ตรวจสอบว่ามีข้อมูลรุ่นรถนี้อยู่แล้วหรือไม่
      final query = _db.select(_db.vehicleScanStats)
        ..where((tbl) =>
            tbl.year.equals(year) &
            tbl.make.equals(make) &
            tbl.model.equals(model));

      final existing = await query.getSingleOrNull();

      if (existing == null) {
        // ถ้าเป็นรุ่นใหม่ ให้เพิ่มแถวใหม่
        await _db.into(_db.vehicleScanStats).insert(
              VehicleScanStatsCompanion.insert(
                year: year,
                make: make,
                model: model,
                scanCount: const Value(1),
                priorityScore: const Value(
                    70), // เริ่มต้นด้วย Score สำหรับ Local Scan (ตามแผน Phase 15)
              ),
            );
        Logger.info("VehicleStats: New model tracked: $year $make $model");
      } else {
        // ถ้ามีอยู่แล้ว ให้บวกจำนวนครั้ง และอัปเดตคะแนน
        final newCount = existing.scanCount + 1;
        // สูตรการคำนวณเบื้องต้น: เพิ่มคะแนนตามจำนวนการสแกน
        final newScore = existing.priorityScore + 5;

        await (_db.update(_db.vehicleScanStats)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .write(
          VehicleScanStatsCompanion(
            scanCount: Value(newCount),
            priorityScore: Value(newScore),
            lastScanned: Value(DateTime.now()),
            isSynced: const Value(false),
          ),
        );
        Logger.info(
            "VehicleStats: Incremented $year $make $model (New Count: $newCount)");
      }
    } catch (e) {
      Logger.error("VehicleStats: Failed to increment scan count", e);
    }
  }

  /// 2. ดึงรายการรุ่นรถที่ถูกสแกนบ่อยที่สุด (Get Top Scanned Models)
  /// ใช้สำหรับตัดสินใจว่าจะดึงข้อมูลตัวไหนมาเก็บไว้ใน Cache ก่อน
  Future<List<VehicleScanStat>> getTopScannedModels({int limit = 5}) async {
    final query = _db.select(_db.vehicleScanStats)
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.priorityScore, mode: OrderingMode.desc)
      ])
      ..limit(limit);

    return await query.get();
  }

  /// 3. อัปเดตคะแนนจาก Global Cloud Trend
  /// ใช้เมื่อซิงค์ข้อมูลลงมาจากคลาวด์เพื่อคำนวณ Priority ใหม่
  Future<void> updateGlobalScore(int id, int cloudTrendScore) async {
    // Score = (Local * 0.7) + (Cloud * 0.3)
    final existing = await (_db.select(_db.vehicleScanStats)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return;

    final newPriority =
        (existing.scanCount * 0.7 + cloudTrendScore * 0.3).round();

    await (_db.update(_db.vehicleScanStats)..where((tbl) => tbl.id.equals(id)))
        .write(
      VehicleScanStatsCompanion(priorityScore: Value(newPriority)),
    );
  }
}
