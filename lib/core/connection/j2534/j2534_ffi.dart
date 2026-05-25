import 'dart:ffi' as ffi;

/// SAE J2534 PassThru Message Structure
final class PassThruMsg extends ffi.Struct {
  @ffi.Uint32()
  external int protocolId;

  @ffi.Uint32()
  external int rxStatus;

  @ffi.Uint32()
  external int txFlags;

  @ffi.Uint32()
  external int timestamp;

  @ffi.Uint32()
  external int dataSize;

  @ffi.Uint32()
  external int extraDataIndex;

  @ffi.Array.multi([4128])
  external ffi.Array<ffi.Uint8> data;
}

// --- FFI Typedefs for SAE J2534 API ---

// 1. PassThruOpen
typedef PassThruOpenNative = ffi.Int32 Function(
    ffi.Pointer<ffi.Void> pName, ffi.Pointer<ffi.Uint32> pDeviceID);
typedef PassThruOpenDart = int Function(
    ffi.Pointer<ffi.Void> pName, ffi.Pointer<ffi.Uint32> pDeviceID);

// 2. PassThruClose
typedef PassThruCloseNative = ffi.Int32 Function(ffi.Uint32 deviceID);
typedef PassThruCloseDart = int Function(int deviceID);

// 3. PassThruConnect
typedef PassThruConnectNative = ffi.Int32 Function(
    ffi.Uint32 deviceID,
    ffi.Uint32 protocolID,
    ffi.Uint32 flags,
    ffi.Uint32 baudRate,
    ffi.Pointer<ffi.Uint32> pChannelID);
typedef PassThruConnectDart = int Function(
    int deviceID,
    int protocolID,
    int flags,
    int baudRate,
    ffi.Pointer<ffi.Uint32> pChannelID);

// 4. PassThruDisconnect
typedef PassThruDisconnectNative = ffi.Int32 Function(ffi.Uint32 channelID);
typedef PassThruDisconnectDart = int Function(int channelID);

// 5. PassThruReadMsgs
typedef PassThruReadMsgsNative = ffi.Int32 Function(
    ffi.Uint32 channelID,
    ffi.Pointer<PassThruMsg> pMsg,
    ffi.Pointer<ffi.Uint32> pNumMsgs,
    ffi.Uint32 timeout);
typedef PassThruReadMsgsDart = int Function(
    int channelID,
    ffi.Pointer<PassThruMsg> pMsg,
    ffi.Pointer<ffi.Uint32> pNumMsgs,
    int timeout);

// 6. PassThruWriteMsgs
typedef PassThruWriteMsgsNative = ffi.Int32 Function(
    ffi.Uint32 channelID,
    ffi.Pointer<PassThruMsg> pMsg,
    ffi.Pointer<ffi.Uint32> pNumMsgs,
    ffi.Uint32 timeout);
typedef PassThruWriteMsgsDart = int Function(
    int channelID,
    ffi.Pointer<PassThruMsg> pMsg,
    ffi.Pointer<ffi.Uint32> pNumMsgs,
    int timeout);

// Constants (Protocol IDs)
const int ISO15765 = 0x06; // CAN UDS
const int ISO14230 = 0x03; // KWP2000
