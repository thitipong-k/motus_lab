import 'package:drift/drift.dart';
import 'package:motus_lab/core/database/app_database.dart';

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
        // Future: Increment score logic here
      ),
    );
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
