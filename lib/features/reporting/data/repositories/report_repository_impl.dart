import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';
import 'package:motus_lab/features/reporting/domain/repositories/report_repository.dart';
import 'package:motus_lab/features/reporting/data/services/pdf_generator_service.dart';

class ReportRepositoryImpl implements ReportRepository {
  final PdfGeneratorService pdfService;
  final SharedPreferences prefs;

  ReportRepositoryImpl({required this.pdfService, required this.prefs});

  static const String _kShopName = 'shop_name';
  static const String _kShopAddress = 'shop_address';
  static const String _kShopPhone = 'shop_phone';
  static const String _kShopTaxId = 'shop_tax_id';

  @override
  Future<File> generateReportPdf(DiagnosticReport report, ReportConfig config) {
    return pdfService.generate(report, config);
  }

  @override
  Future<List<DiagnosticReport>> getReportHistory() async {
    // TODO: Implement database persistence for reports history
    return [];
  }

  @override
  Future<ReportConfig> getReportConfig() async {
    return ReportConfig(
      shopName: prefs.getString(_kShopName) ?? 'My Auto Shop',
      address: prefs.getString(_kShopAddress) ?? '123 Service Road',
      phone: prefs.getString(_kShopPhone) ?? '081-234-5678',
      taxId: prefs.getString(_kShopTaxId),
    );
  }

  @override
  Future<void> saveReportConfig(ReportConfig config) async {
    await prefs.setString(_kShopName, config.shopName);
    await prefs.setString(_kShopAddress, config.address);
    await prefs.setString(_kShopPhone, config.phone);
    if (config.taxId != null) {
      await prefs.setString(_kShopTaxId, config.taxId!);
    }
  }

  @override
  Future<void> saveReportHistory(DiagnosticReport report) async {
    // TODO: Save to Drift DB
  }
}
