enum ProtocolType {
  can,
  canFd,
  doip,
  kline
}

/// Interface for a Diagnostic Transport Layer.
/// This abstracts the physical connection (Serial, BLE, J2534, DoIP)
/// so the UDSEngine can send/receive standard diagnostic packets seamlessly.
abstract class DiagnosticTransport {
  /// Maximum payload size this transport can handle in a single physical frame.
  /// (e.g., 7 bytes for CAN Single Frame, 64 for CAN-FD, 4095 for ISO-15765, 65535 for DoIP)
  int get maxPayloadSize;

  /// Sets advanced protocol options to prepare for modern vehicle networks.
  void setProtocolOptions({ProtocolType type = ProtocolType.can, int payloadSize = 8});

  /// Sends a diagnostic packet (e.g., UDS request) and waits for the response.
  /// [payload] is the byte array (e.g. [0x22, 0xF1, 0x90] for ReadDataByIdentifier)
  /// [timeout] max duration to wait for ECU response.
  Future<List<int>> sendAndReceive(List<int> payload, {Duration timeout = const Duration(milliseconds: 2000)});
}
