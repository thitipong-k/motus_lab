import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/core/utils/logger.dart';

class DiagnosticRepository {
  final AppDatabase _db;

  DiagnosticRepository(this._db);

  /// 1. Get Likely Causes (Ranked by Score)
  /// Returns a list of causes for a given [dtcCode] and [vehicleModel], sorted by likelihood.
  Future<List<DiagnosticResult>> getLikelyCauses(
      String dtcCode, String vehicleModel) async {
    // Join DiagnosticIntelligence -> PossibleCauses
    final query = _db.select(_db.diagnosticIntelligence).join([
      innerJoin(
        _db.possibleCauses,
        _db.possibleCauses.id.equalsExp(_db.diagnosticIntelligence.causeId),
      ),
    ]);

    query.where(_db.diagnosticIntelligence.dtcCode.equals(dtcCode));
    // Simple logic for now: exact model match or universal (null)
    // In a real app, this would be fuzzy matching
    query.where(_db.diagnosticIntelligence.vehicleModel.equals(vehicleModel) |
        _db.diagnosticIntelligence.vehicleModel.isNull());

    // Sort by Score DESC
    query.orderBy([
      OrderingTerm(
          expression: _db.diagnosticIntelligence.likelihoodScore,
          mode: OrderingMode.desc)
    ]);

    final rows = await query.get();

    return rows.map((row) {
      final intelligence = row.readTable(_db.diagnosticIntelligence);
      final cause = row.readTable(_db.possibleCauses);

      return DiagnosticResult(
        causeTitle: cause.title,
        causeDescription: cause.description ?? "",
        likelihoodScore: intelligence.likelihoodScore,
        difficultyLevel: cause.difficultyLevel,
        causeId: cause.id,
      );
    }).toList();
  }

  /// 2. Get Solution Steps
  Future<SolutionData?> getSolution(int causeId) async {
    final query = _db.select(_db.solutions)
      ..where((tbl) => tbl.causeId.equals(causeId));

    final result = await query.getSingleOrNull();

    if (result == null) return null;

    return SolutionData(
      steps: result.steps,
      estimatedCost: result.estimatedCost,
    );
  }

  /// 3. Verify Cause (Feedback Loop)
  Future<void> verifyCause(int intelligenceId) async {
    await (_db.update(_db.diagnosticIntelligence)
          ..where((tbl) => tbl.id.equals(intelligenceId)))
        .write(
      const DiagnosticIntelligenceCompanion(
        verifiedByMechanic: Value(true),
      ),
    );
  }

  /// 4. CRUD Operations สำหรับ Knowledge Base (Phase 14.2)

  /// ดึงข้อมูลทั้งหมดเพื่อแสดงในรายการ Knowledge Base
  Future<List<DiagnosticIntelligenceData>> getAllIntelligence() async {
    return await _db.select(_db.diagnosticIntelligence).get();
  }

  /// เพิ่มหรือแก้ไขข้อมูล DTC
  Future<void> upsertDtcKnowledge({
    required String code,
    required String title,
    String? description,
    required List<String> steps,
    String? vehicleModel,
  }) async {
    await _db.transaction(() async {
      // 1. บันทึก PossibleCauses
      final causeId = await _db.into(_db.possibleCauses).insert(
            PossibleCausesCompanion.insert(
              title: title,
              description: Value(description),
              difficultyLevel: const Value(3),
            ),
          );

      // 2. บันทึก Solutions
      await _db.into(_db.solutions).insert(
            SolutionsCompanion.insert(
              causeId: causeId,
              steps: steps.join("\n"),
            ),
          );

      // 3. เชื่อมโยงกับ DiagnosticIntelligence
      await _db.into(_db.diagnosticIntelligence).insert(
            DiagnosticIntelligenceCompanion.insert(
              dtcCode: code,
              vehicleModel: Value(vehicleModel),
              causeId: causeId,
              likelihoodScore: const Value(100), // แมนนวลแอดให้ความสำคัญสูงสุด
            ),
          );
    });
  }

  /// 5. Seeding Logic (นำเข้าข้อมูลชุดใหญ่จาก Assets)
  Future<void> seedFromAssets(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> data = jsonDecode(jsonString);

      for (var item in data) {
        final String code = item['code'];
        final String mainDesc = item['description'];
        final List<dynamic> causes = item['causes'];

        for (var cause in causes) {
          await upsertDtcKnowledge(
            code: code,
            title: cause['title'],
            description: mainDesc,
            steps: List<String>.from(cause['steps']),
          );
        }
      }
      Logger.info("DiagnosticRepository: Seeded data from $assetPath");
    } catch (e) {
      Logger.error("DiagnosticRepository: Seeding failed", e);
    }
  }
}

// Helper Models for UI
class DiagnosticResult {
  final int causeId;
  final String causeTitle;
  final String causeDescription;
  final int likelihoodScore;
  final int difficultyLevel;

  DiagnosticResult({
    required this.causeId,
    required this.causeTitle,
    required this.causeDescription,
    required this.likelihoodScore,
    required this.difficultyLevel,
  });
}

class SolutionData {
  final String steps;
  final double? estimatedCost;

  SolutionData({required this.steps, this.estimatedCost});
}
