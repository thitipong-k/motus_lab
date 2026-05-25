import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'doip_payload.dart';

class DoipConnection implements ConnectionInterface {
  Socket? _tcpSocket;
  RawDatagramSocket? _udpSocket;
  bool _isConnected = false;

  final _dataController = StreamController<List<int>>.broadcast();

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<List<int>> get onDataReceived => _dataController.stream;

  @override
  Future<void> connect(String ipAddress) async {
    try {
      // 1. TCP Connection for DoIP
      _tcpSocket = await Socket.connect(ipAddress, 13400, timeout: const Duration(seconds: 5));
      _isConnected = true;

      _tcpSocket!.listen(
        (Uint8List data) {
          try {
            final msg = DoipMessage.fromBytes(data);
            if (msg.payloadType == DoipPayloadType.diagnosticMessage) {
              _dataController.add(msg.payload.toList());
            } else if (msg.payloadType == DoipPayloadType.routingActivationResponse) {
              print("DoIP Routing Activation Success.");
            }
          } catch (e) {
            print("DoIP Parse Error: $e");
          }
        },
        onError: (error) {
          print("DoIP TCP Error: $error");
          disconnect();
        },
        onDone: () {
          disconnect();
        },
      );

      // 2. Send Routing Activation Request (SA + Padding)
      final routingReq = DoipMessage(
        payloadType: DoipPayloadType.routingActivationRequest,
        payload: Uint8List.fromList([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 
      );
      _tcpSocket!.add(routingReq.toBytes());

      print("DoIP Connected to $ipAddress");
    } catch (e) {
      _isConnected = false;
      throw Exception("DoIP Connection Failed: $e");
    }
  }

  @override
  Future<ObdResponse> send(ObdRequest request) async {
    if (!_isConnected || _tcpSocket == null) {
      throw Exception("DoIP is not connected");
    }

    // Convert OBD/UDS request to DoIP Diagnostic Message
    // SA (Source Address) and TA (Target Address) are prepended.
    // Example: SA: 0x0E80, TA: 0x10F1
    final bytes = request.command.codeUnits; 
    final payload = Uint8List.fromList([0x0E, 0x80, 0x10, 0xF1, ...bytes]); 

    final msg = DoipMessage(
      payloadType: DoipPayloadType.diagnosticMessage,
      payload: payload,
    );

    _tcpSocket!.add(msg.toBytes());

    // In a real app, we await the specific stream response.
    return ObdResponse(
      rawData: [],
      timestamp: DateTime.now(),
      isSuccess: true,
      errorMessage: "DoIP Read not fully synchronized",
    );
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _tcpSocket?.destroy();
    _tcpSocket = null;
    _udpSocket?.close();
    _udpSocket = null;
    print("DoIP Disconnected.");
  }

  /// Sends a UDP Broadcast to discover vehicles on the network
  Future<void> discoverVehicles() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _udpSocket!.broadcastEnabled = true;

    _udpSocket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = _udpSocket!.receive();
        if (dg != null) {
          try {
            final msg = DoipMessage.fromBytes(dg.data);
            if (msg.payloadType == DoipPayloadType.vehicleAnnouncementMessage) {
              print("Found Vehicle at ${dg.address.address} via DoIP");
            }
          } catch (_) {}
        }
      }
    });

    final req = DoipMessage(
      payloadType: DoipPayloadType.vehicleIdentificationRequest,
      payload: Uint8List(0),
    );

    _udpSocket!.send(req.toBytes(), InternetAddress("255.255.255.255"), 13400);
  }
}
