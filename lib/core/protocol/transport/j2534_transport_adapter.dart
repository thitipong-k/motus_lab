import 'package:motus_lab/core/connection/j2534_connection.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'diagnostic_transport.dart';

/// Adapter to wrap J2534Connection into the standard DiagnosticTransport interface
class J2534TransportAdapter implements DiagnosticTransport {
  final J2534Connection _connection;

  J2534TransportAdapter(this._connection);

  int _maxPayload = 4095;
  ProtocolType _protocolType = ProtocolType.can;

  @override
  int get maxPayloadSize => _maxPayload;

  @override
  void setProtocolOptions({ProtocolType type = ProtocolType.can, int payloadSize = 4095}) {
    _protocolType = type;
    _maxPayload = payloadSize;
    // In a real J2534 wrapper, we would call PassThruConnect here with the correct protocol ID 
    // (e.g. ISO15765, CAN_FD, DoIP)
  }

  @override
  Future<List<int>> sendAndReceive(List<int> payload, {Duration timeout = const Duration(milliseconds: 2000)}) async {
    if (!_connection.isConnected) {
      throw Exception("J2534 is not connected");
    }

    // Note: In a complete implementation, ObdRequest would natively accept Uint8List.
    // For now, we serialize to a Hex String to conform to the existing interface.
    final hexString = payload.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
    
    final request = ObdRequest(command: hexString);
    final response = await _connection.send(request);
    
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? "J2534 Tx/Rx Failed");
    }

    return response.rawData;
  }
}
