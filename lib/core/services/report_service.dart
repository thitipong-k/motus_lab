import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:motus_lab/domain/repositories/shop_profile_repository.dart';

class ReportService {
  final ShopProfileRepository _shopRepo;

  ReportService(this._shopRepo);

  Future<void> generateHealthReport({
    required String vin,
    required List<String> dtcs,
    required Map<String, double> liveData,
  }) async {
    final shop = await _shopRepo.getShopProfile();
    final pdf = pw.Document();

    // Load Thai Fonts
    final fontDataReg =
        await rootBundle.load("assets/fonts/Sarabun-Regular.ttf");
    final fontDataBold = await rootBundle.load("assets/fonts/Sarabun-Bold.ttf");
    final ttfReg = pw.Font.ttf(fontDataReg);
    final ttfBold = pw.Font.ttf(fontDataBold);

    // Load Logo if exists
    pw.ImageProvider? logoImage;
    if (shop.logoPath != null && shop.logoPath!.isNotEmpty) {
      final logoFile = File(shop.logoPath!);
      if (await logoFile.exists()) {
        logoImage = pw.MemoryImage(await logoFile.readAsBytes());
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: ttfReg,
          bold: ttfBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo and Shop Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 140,
                      height: 140,
                      margin: const pw.EdgeInsets.only(right: 15),
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(shop.name.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 22, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        if (shop.address != null)
                          pw.Text(shop.address!,
                              style: const pw.TextStyle(fontSize: 11)),
                        if (shop.phone != null)
                          pw.Text("Tel: ${shop.phone}",
                              style: const pw.TextStyle(fontSize: 11)),
                        if (shop.email != null)
                          pw.Text("Email: ${shop.email}",
                              style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  if (shop.taxId != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text("Tax ID: ${shop.taxId}",
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text("DIAGNOSTIC HEALTH REPORT",
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),

              // Vehicle Section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("VEHICLE INFORMATION",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Divider(),
                    pw.Row(children: [
                      pw.Expanded(child: pw.Text("VIN:")),
                      pw.Expanded(child: pw.Text(vin)),
                    ]),
                    pw.Row(children: [
                      pw.Expanded(child: pw.Text("Date:")),
                      pw.Expanded(
                          child:
                              pw.Text(DateTime.now().toString().split('.')[0])),
                    ]),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // DTC Section
              pw.Text("DIAGNOSTIC TROUBLE CODES",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              if (dtcs.isEmpty)
                pw.Text("No faults detected. Vehicle status: OK")
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: dtcs.map((code) => pw.Bullet(text: code)).toList(),
                ),
              pw.SizedBox(height: 20),

              // Live Data Section
              pw.Text("LIVE DATA SNAPSHOT",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Parameter",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Value",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...liveData.entries.map((entry) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(entry.key)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(entry.value.toStringAsFixed(2))),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    "Report generated by Motus Lab Intelligent Diagnostics"),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Motus_Report_$vin.pdf',
    );
  }

  /// สร้างไฟล์ CSV รายงานการตรวจเช็ค (Export as CSV)
  /// [WORKFLOW STEP: Data Export]
  /// สร้าง String Buffer เพื่อเก็บข้อมูลแบบ Comma Separated Values
  /// รองรับการนำไปใช้ต่อใน Excel หรือโปรแกรมวิเคราะห์ข้อมูล
  Future<void> generateCsvReport({
    required String vin,
    required List<String> dtcs,
    required Map<String, double> liveData,
  }) async {
    final shop = await _shopRepo.getShopProfile();
    final buffer = StringBuffer();

    // 1. Header Information
    buffer.writeln("MOTUS LAB DIAGNOSTIC REPORT");
    buffer.writeln("Date,${DateTime.now().toString()}");
    buffer.writeln("Shop Name,${shop.name}");
    buffer.writeln("Phone,${shop.phone ?? '-'}");
    buffer.writeln("VIN,$vin");
    buffer.writeln(""); // Empty line

    // 2. DTCs
    buffer.writeln("DIAGNOSTIC TROUBLE CODES");
    if (dtcs.isEmpty) {
      buffer.writeln("Status,OK - No Faults");
    } else {
      for (final code in dtcs) {
        buffer.writeln("DTC,$code");
      }
    }
    buffer.writeln("");

    // 3. Live Data
    buffer.writeln("LIVE DATA SNAPSHOT");
    buffer.writeln("Parameter,Value");
    for (final entry in liveData.entries) {
      buffer.writeln("${entry.key},${entry.value.toStringAsFixed(2)}");
    }

    // 4. Save File
    // Check Platform: Mobile vs Desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV Report',
        fileName: 'Motus_Report_$vin.csv',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(buffer.toString());
      }
    } else {
      // Mobile: Usually share or save to downloads.
      // For simplicity in this step, we might need path_provider or use Printing/Share.
      // But user specifically asked for "Export". FilePicker works on mobile too but behaves differently.
      // Let's assume standard FilePicker for now, or fallback to printing just logs.
      // Note: FilePicker.saveFile is not supported on Android/iOS in the same way.
      // Usually we create a temp file and Share.shareXFiles.
      // For this task, we focus on Desktop first as user is on Windows.
      print("CSV Content Generated:\n$buffer");
    }
  }
}
