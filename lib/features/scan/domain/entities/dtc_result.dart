class DtcResult {
  final String code;
  final String description;
  final String system; // e.g., Engine, Transmission

  const DtcResult({
    required this.code,
    this.description = 'Unknown DTC',
    this.system = 'Engine',
  });
}
