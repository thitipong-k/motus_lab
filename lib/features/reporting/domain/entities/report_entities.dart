import 'package:motus_lab/features/scan/domain/entities/dtc_result.dart'; // Adjust import if needed

class ReportConfig {
  final String shopName;
  final String address;
  final String phone;
  final String? taxId;
  final String? logoPath;

  const ReportConfig({
    required this.shopName,
    required this.address,
    required this.phone,
    this.taxId,
    this.logoPath,
  });
}

class DiagnosticReport {
  final String id;
  final String vehicleVin;
  final String vehicleName; // e.g. "Toyota Vios 2018"
  final DateTime timestamp;
  final List<DtcResult> dtcList; // List of found error codes
  final String technicianName;
  final String note;

  const DiagnosticReport({
    required this.id,
    required this.vehicleVin,
    required this.vehicleName,
    required this.timestamp,
    required this.dtcList,
    required this.technicianName,
    this.note = '',
  });

  // Helper to calculate health score (Simple logic)
  String get healthScore {
    if (dtcList.isEmpty) return 'A (Excellent)';
    if (dtcList.length <= 2) return 'B (Good)';
    if (dtcList.length <= 5) return 'C (Fair)';
    return 'D (Attention Needed)';
  }
}
