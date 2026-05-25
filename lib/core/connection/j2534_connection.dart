import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/domain/entities/obd_communication.dart';
import 'j2534/j2534_ffi.dart';

/// การเชื่อมต่อผ่านมาตรฐาน J2534 PassThru (Windows Only)
/// ตอนนี้ได้เชื่อมต่อกับ J2534 C-API ผ่าน dart:ffi เรียบร้อยแล้ว
class J2534Connection implements ConnectionInterface {
  ffi.DynamicLibrary? _dll;
  int _deviceId = 0;
  int _channelId = 0;

  PassThruOpenDart? _passThruOpen;
  PassThruCloseDart? _passThruClose;
  PassThruConnectDart? _passThruConnect;
  PassThruDisconnectDart? _passThruDisconnect;
  PassThruReadMsgsDart? _passThruReadMsgs;
  PassThruWriteMsgsDart? _passThruWriteMsgs;

  bool _isConnected = false;

  @override
  bool get isConnected => _isConnected;

  final _dataController = StreamController<List<int>>.broadcast();

  @override
  Stream<List<int>> get onDataReceived => _dataController.stream;

  @override
  Future<void> connect(String dllPath) async {
    try {
      // 1. โหลดไฟล์ DLL ของ J2534 Vendor (เช่น tactrix.dll)
      _dll = ffi.DynamicLibrary.open(dllPath);

      // 2. Map Functions
      _passThruOpen = _dll!.lookupFunction<PassThruOpenNative, PassThruOpenDart>("PassThruOpen");
      _passThruClose = _dll!.lookupFunction<PassThruCloseNative, PassThruCloseDart>("PassThruClose");
      _passThruConnect = _dll!.lookupFunction<PassThruConnectNative, PassThruConnectDart>("PassThruConnect");
      _passThruDisconnect = _dll!.lookupFunction<PassThruDisconnectNative, PassThruDisconnectDart>("PassThruDisconnect");
      _passThruReadMsgs = _dll!.lookupFunction<PassThruReadMsgsNative, PassThruReadMsgsDart>("PassThruReadMsgs");
      _passThruWriteMsgs = _dll!.lookupFunction<PassThruWriteMsgsNative, PassThruWriteMsgsDart>("PassThruWriteMsgs");

      final pDeviceID = calloc<ffi.Uint32>();
      
      // 3. PassThruOpen
      int status = _passThruOpen!(ffi.nullptr, pDeviceID);
      if (status != 0) {
        calloc.free(pDeviceID);
        throw Exception("PassThruOpen failed with status: $status");
      }
      _deviceId = pDeviceID.value;
      
      // 4. PassThruConnect (ตั้งค่าเริ่มต้นให้เป็น ISO15765/CAN 500kbps)
      final pChannelID = calloc<ffi.Uint32>();
      status = _passThruConnect!(_deviceId, ISO15765, 0, 500000, pChannelID);
      if (status != 0) {
        _passThruClose!(_deviceId);
        calloc.free(pDeviceID);
        calloc.free(pChannelID);
        throw Exception("PassThruConnect failed with status: $status");
      }
      
      _channelId = pChannelID.value;
      _isConnected = true;
      
      calloc.free(pDeviceID);
      calloc.free(pChannelID);
      
      print("J2534 Connected successfully on Channel: $_channelId");
    } catch (e) {
      _isConnected = false;
      throw Exception("J2534 Initialization Error: $e");
    }
  }

  @override
  Future<ObdResponse> send(ObdRequest request) async {
    if (!_isConnected || _passThruWriteMsgs == null || _passThruReadMsgs == null) {
      throw Exception("J2534 is not connected");
    }
    
    // Allocate PassThruMsg for Tx
    final pTxMsg = calloc<PassThruMsg>();
    pTxMsg.ref.protocolId = ISO15765;
    
    // We assume request.command contains the hex string to be sent
    // For simplicity, we convert string characters to bytes directly
    final bytes = request.command.codeUnits;
    pTxMsg.ref.dataSize = bytes.length;
    for (int i = 0; i < bytes.length && i < 4128; i++) {
      pTxMsg.ref.data[i] = bytes[i];
    }

    final pNumMsgs = calloc<ffi.Uint32>();
    pNumMsgs.value = 1;

    // Write to J2534
    int status = _passThruWriteMsgs!(_channelId, pTxMsg, pNumMsgs, 2000);
    if (status != 0) {
      calloc.free(pTxMsg);
      calloc.free(pNumMsgs);
      throw Exception("PassThruWriteMsgs failed: $status");
    }

    // Read from J2534
    final pRxMsg = calloc<PassThruMsg>();
    pNumMsgs.value = 1;
    status = _passThruReadMsgs!(_channelId, pRxMsg, pNumMsgs, 2000);

    List<int> rawData = [];
    if (status == 0 && pNumMsgs.value > 0) {
      for (int i = 0; i < pRxMsg.ref.dataSize; i++) {
        rawData.add(pRxMsg.ref.data[i]);
      }
      _dataController.add(rawData);
    }

    calloc.free(pTxMsg);
    calloc.free(pRxMsg);
    calloc.free(pNumMsgs);

    return ObdResponse(
      rawData: rawData,
      timestamp: DateTime.now(),
      isSuccess: status == 0,
      errorMessage: status != 0 ? "PassThruReadMsgs failed: $status" : null,
    );
  }

  @override
  Future<void> disconnect() async {
    if (_isConnected) {
      if (_passThruDisconnect != null && _channelId != 0) {
        _passThruDisconnect!(_channelId);
      }
      if (_passThruClose != null && _deviceId != 0) {
        _passThruClose!(_deviceId);
      }
      _isConnected = false;
      print("J2534 Bridge Closed.");
    }
  }
}
