import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:motus_lab/features/reporting/domain/entities/report_entities.dart';

class PdfGeneratorService {
  Future<File> generate(DiagnosticReport report, ReportConfig config) async {
    final pdf = pw.Document();

    // Load Fonts (Use standard fonts for now, or load custom if needed)
    // For Thai support, we need a font that supports Thai characters.
    // Assuming we have Sarabun font in assets, we would load it here.
    // For MVP, we will use standard font and English content primarily,
    // or try to load built-in font if possible.
    final font = await PdfGoogleFonts.sarabunRegular();
    final fontBold = await PdfGoogleFonts.sarabunBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(config),
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

  pw.Widget _buildHeader(ReportConfig config) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(config.shopName,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text(config.address),
            pw.Text("Phone: ${config.phone}"),
            if (config.taxId != null) pw.Text("Tax ID: ${config.taxId}"),
          ],
        ),
        // Logo placeholder (Load image logic would go here)
        pw.Container(
          height: 60,
          width: 60,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          child: pw.Center(child: pw.Text("LOGO")),
        ),
      ],
    );
  }

  pw.Widget _buildVehicleInfo(DiagnosticReport report) {
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
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color:
                report.dtcList.isEmpty ? PdfColors.green100 : PdfColors.red100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              pw.Text("Health Status: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(report.healthScore),
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
