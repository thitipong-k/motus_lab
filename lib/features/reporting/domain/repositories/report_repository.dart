import 'dart:io';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';

abstract class ReportRepository {
  /// Generate a PDF file from the report data and configuration
  Future<File> generateReportPdf(DiagnosticReport report, ReportConfig config);

  /// Generates a CSV report file.
  Future<void> generateReportCsv(DiagnosticReport report, ReportConfig config);

  /// Save report metadata to local history (Database)
  Future<void> saveReportHistory(DiagnosticReport report);

  /// Get list of past reports
  Future<List<DiagnosticReport>> getReportHistory();

  /// Save/Load Shop Configuration
  Future<void> saveReportConfig(ReportConfig config);
  Future<ReportConfig> getReportConfig();
}
