import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'diagnostic_transport.dart';

/// Adapter to wrap the MockConnection into the DiagnosticTransport interface.
/// This enables testing advanced UDS functionalities (like ECU Flashing) 
/// without needing physical hardware connected.
class MockTransportAdapter implements DiagnosticTransport {
  final ConnectionInterface _connection;

  MockTransportAdapter(this._connection);

  int _maxPayload = 8;
  ProtocolType _protocolType = ProtocolType.can;

  @override
  int get maxPayloadSize => _maxPayload;

  @override
  void setProtocolOptions({ProtocolType type = ProtocolType.can, int payloadSize = 8}) {
    _protocolType = type;
    _maxPayload = payloadSize;
  }

  @override
  Future<List<int>> sendAndReceive(List<int> payload, {Duration timeout = const Duration(milliseconds: 2000)}) async {
    if (!_connection.isConnected) {
      throw Exception("Mock Simulator is not connected. Please connect first.");
    }

    // Convert raw byte array to Hex String so MockConnection can parse it back
    // (Simulating the String-based stream we currently have)
    final hexString = payload.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
    
    final request = ObdRequest(command: hexString);
    final response = await _connection.send(request);
    
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? "Mock Tx/Rx Failed");
    }

    return response.rawData;
  }
}
