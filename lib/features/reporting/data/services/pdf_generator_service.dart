import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';

class PdfGeneratorService {
  Future<File> generate(DiagnosticReport report, ReportConfig config) async {
    final pdf = pw.Document();

    // Load Fonts (Use standard fonts for now, or load custom if needed)
    // สำหรับการรองรับภาษาไทย จำเป็นต้องใช้ Font ที่รองรับอักขระไทย (เช่น Sarabun)
    // โดยดึงจาก Google Fonts ผ่าน package printing
    final font = await PdfGoogleFonts.sarabunRegular();
    final fontBold = await PdfGoogleFonts.sarabunBold();

    // [WORKFLOW STEP 6] Professional Reporting: สร้างเอกสาร PDF
    // 1. กำหนดฟอนต์ (รองรับภาษาไทย)
    // 2. ออกแบบโครงสร้างหน้า (A4, Header, Vehicle Info, DTC Table, Footer)
    // 3. บันทึกไฟล์ลง Temporary Directory ชั่วคราว
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(config, report),
            pw.Divider(),
            _buildVehicleInfo(report),
            pw.SizedBox(height: 20),
            _buildDtcTable(report),
            pw.SizedBox(height: 20),
            _buildFooter(report),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report_${report.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(ReportConfig config, DiagnosticReport report) {
    // โหลดรูปภาพ Logo (รองรับทั้งแบบ Base64 และ Path ไฟล์ในเครื่อง)
    pw.ImageProvider? logoImage;
    final path = config.logoPath;
    if (path != null) {
      if (path.startsWith('data:image')) {
        try {
          final base64Data = path.split(',').last;
          logoImage = pw.MemoryImage(base64Decode(base64Data));
        } catch (e) {
          // Ignore invalid base64
        }
      } else if (File(path).existsSync()) {
        logoImage = pw.MemoryImage(File(path).readAsBytesSync());
      }
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoImage != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 20),
            child: pw.Container(
              height: 70,
              width: 70,
              child: pw.Image(logoImage),
            ),
          )
        else
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 20),
            child: pw.Container(
              height: 60,
              width: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
              ),
              child: pw.Center(
                  child: pw.Text("MOTUS\nLAB",
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 8))),
            ),
          ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(config.shopName,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text(config.address),
              pw.Text("Phone: ${config.phone}"),
              if (config.taxId != null && config.taxId!.isNotEmpty)
                pw.Text("Tax ID: ${config.taxId}"),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildVehicleInfo(DiagnosticReport report) {
    // Health Color Mapping
    PdfColor healthColor;
    if (report.dtcList.isEmpty) {
      healthColor = PdfColors.green700;
    } else if (report.dtcList.length <= 2) {
      healthColor = PdfColors.orange700;
    } else {
      healthColor = PdfColors.red700;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Diagnostic Report",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(children: [
          pw.Expanded(
              child: _buildInfoRow(
                  "Date", report.timestamp.toString().substring(0, 16))),
          pw.Expanded(child: _buildInfoRow("Report ID", report.id)),
        ]),
        pw.Row(children: [
          pw.Expanded(child: _buildInfoRow("Vehicle", report.vehicleName)),
          pw.Expanded(child: _buildInfoRow("VIN", report.vehicleVin)),
        ]),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text("HEALTH SCORE summary: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(report.healthScore,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: healthColor)),
            ],
          ),
        )
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text("$label: ",
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        pw.Text(value),
      ],
    );
  }

  pw.Widget _buildDtcTable(DiagnosticReport report) {
    if (report.dtcList.isEmpty) {
      return pw.Center(
        child: pw.Text("No Error Codes Found (DTCs)",
            style: const pw.TextStyle(color: PdfColors.green)),
      );
    }

    return pw.Table.fromTextArray(
      headers: ['Code', 'Description', 'Status'],
      data: report.dtcList
          .map((dtc) => [dtc.code, dtc.description, "Active"])
          .toList(),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
    );
  }

  pw.Widget _buildFooter(DiagnosticReport report) {
    return pw.Column(children: [
      pw.Divider(),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Technician: ${report.technicianName}"),
              pw.Text("Note: ${report.note}"),
            ],
          ),
          pw.Column(
            children: [
              pw.Container(
                  height: 40,
                  width: 100,
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide()))),
              pw.Text("Signature"),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Center(
          child: pw.Text("Powered by Motus Lab",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
    ]);
  }
}
