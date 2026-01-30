import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class ReportPreviewPage extends StatelessWidget {
  final File pdfFile;
  final String title;

  const ReportPreviewPage({
    super.key,
    required this.pdfFile,
    this.title = 'Report Preview',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytes(),
        useActions: true, // Allow print/share
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: title.replaceAll(' ', '_') + '.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
