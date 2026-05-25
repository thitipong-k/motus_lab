import 'package:motus_lab/core/connection/doip/doip_connection.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'diagnostic_transport.dart';

/// Adapter to wrap DoipConnection into the standard DiagnosticTransport interface
class DoipTransportAdapter implements DiagnosticTransport {
  final DoipConnection _connection;

  DoipTransportAdapter(this._connection);

  @override
  // DoIP allows extremely large payloads (up to ~4GB theoretically, practically 64KB+)
  int get maxPayloadSize => 65535; 

  @override
  Future<List<int>> sendAndReceive(List<int> payload, {Duration timeout = const Duration(milliseconds: 2000)}) async {
    if (!_connection.isConnected) {
      throw Exception("DoIP is not connected");
    }

    // Convert bytes to hex string for the legacy ObdRequest interface
    final hexString = payload.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
    
    final request = ObdRequest(command: hexString);
    final response = await _connection.send(request);
    
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? "DoIP Tx/Rx Failed");
    }

    return response.rawData;
  }
}
