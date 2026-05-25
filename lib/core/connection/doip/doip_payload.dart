import 'dart:typed_data';

/// ประเภทของ Payload ที่วิ่งบน DoIP (Diagnostics over IP)
enum DoipPayloadType {
  genericHeaderNegativeAcknowledge(0x0000),
  vehicleIdentificationRequest(0x0001),
  vehicleIdentificationRequestEID(0x0002),
  vehicleIdentificationRequestVIN(0x0003),
  vehicleAnnouncementMessage(0x0004),
  routingActivationRequest(0x0005),
  routingActivationResponse(0x0006),
  aliveCheckRequest(0x0007),
  aliveCheckResponse(0x0008),
  diagnosticMessage(0x8001),
  diagnosticMessagePositiveAcknowledge(0x8002),
  diagnosticMessageNegativeAcknowledge(0x8003);

  final int value;
  const DoipPayloadType(this.value);

  static DoipPayloadType? fromValue(int value) {
    for (var type in DoipPayloadType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

class DoipMessage {
  final int protocolVersion;
  final int inverseVersion;
  final DoipPayloadType payloadType;
  final int payloadLength;
  final Uint8List payload;

  DoipMessage({
    this.protocolVersion = 0x02, // ISO 13400-2:2012
    this.inverseVersion = 0xFD,
    required this.payloadType,
    required this.payload,
  }) : payloadLength = payload.length;

  /// สร้าง DoipMessage จาก Byte Array ที่รับมาจาก Socket
  factory DoipMessage.fromBytes(Uint8List bytes) {
    if (bytes.length < 8) {
      throw const FormatException("Invalid DoIP message length (less than header size)");
    }

    final protocolVersion = bytes[0];
    final inverseVersion = bytes[1];
    
    // Payload Type (2 bytes)
    final typeValue = (bytes[2] << 8) | bytes[3];
    final payloadType = DoipPayloadType.fromValue(typeValue);
    if (payloadType == null) {
      throw FormatException("Unknown DoIP Payload Type: 0x${typeValue.toRadixString(16)}");
    }

    // Payload Length (4 bytes)
    final payloadLength = (bytes[4] << 24) | (bytes[5] << 16) | (bytes[6] << 8) | bytes[7];

    if (bytes.length < 8 + payloadLength) {
      throw const FormatException("Incomplete DoIP message payload");
    }

    final payload = bytes.sublist(8, 8 + payloadLength);

    return DoipMessage(
      protocolVersion: protocolVersion,
      inverseVersion: inverseVersion,
      payloadType: payloadType,
      payload: payload,
    );
  }

  /// แปลง DoipMessage เป็น Byte Array เพื่อส่งไปยัง Socket
  Uint8List toBytes() {
    final buffer = BytesBuilder();
    
    // Header (8 bytes)
    buffer.addByte(protocolVersion);
    buffer.addByte(inverseVersion);
    buffer.addByte((payloadType.value >> 8) & 0xFF);
    buffer.addByte(payloadType.value & 0xFF);
    buffer.addByte((payloadLength >> 24) & 0xFF);
    buffer.addByte((payloadLength >> 16) & 0xFF);
    buffer.addByte((payloadLength >> 8) & 0xFF);
    buffer.addByte(payloadLength & 0xFF);
    
    // Payload
    buffer.add(payload);
    
    return buffer.toBytes();
  }
}
