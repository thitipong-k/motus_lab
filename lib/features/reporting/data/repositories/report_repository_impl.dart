import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
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
  static const String _kShopLogo = 'shop_logo_path';

  @override
  Future<File> generateReportPdf(DiagnosticReport report, ReportConfig config) {
    return pdfService.generate(report, config);
  }

  @override
  Future<void> generateReportCsv(
      DiagnosticReport report, ReportConfig config) async {
    final buffer = StringBuffer();

    // 1. Header Information
    buffer.writeln("MOTUS LAB DIAGNOSTIC REPORT");
    buffer.writeln("Date,${DateTime.now().toString()}");
    buffer.writeln("Shop Name,${config.shopName}");
    buffer.writeln("Address,${config.address}");
    buffer.writeln("Phone,${config.phone}");
    buffer.writeln("VIN,${report.vehicleVin}");
    buffer.writeln(""); // Empty line

    // 2. DTCs
    buffer.writeln("DIAGNOSTIC TROUBLE CODES");
    if (report.dtcList.isEmpty) {
      buffer.writeln("Status,OK - No Faults");
    } else {
      buffer.writeln("Code,Description,Status");
      for (final dtc in report.dtcList) {
        buffer.writeln("${dtc.code},${dtc.description},Active");
      }
    }
    buffer.writeln("");

    // 3. Save File
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV Report',
        fileName: 'Motus_Report_${report.vehicleVin}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(buffer.toString());
      }
    } else {
      print("CSV Content Generated:\n$buffer");
    }
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
      logoPath: prefs.getString(_kShopLogo),
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
    if (config.logoPath != null) {
      await prefs.setString(_kShopLogo, config.logoPath!);
    } else {
      await prefs.remove(_kShopLogo);
    }
  }

  @override
  Future<void> saveReportHistory(DiagnosticReport report) async {
    // TODO: Save to Drift DB
  }
}
