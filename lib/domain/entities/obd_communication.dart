/// รูปแบบคำสั่ง OBDII (Standardized Request)
/// ใช้ห่อหุ้มคำสั่งที่ต้องการส่งไปยังกล่อง ECU ของรถ
class ObdRequest {
  /// คำสั่งที่เป็นตัวอักษร เช่น "010C" (RPM) หรือ "ATZ" (Reset)
  final String command;

  /// ระยะเวลาที่อนุญาตให้รอรับข้อมูลก่อนจะ Timeout
  final Duration timeout;

  /// ระบุว่าคาดหวังข้อมูลหลายบรรทัดหรือไม่ (เช่น การอ่าน VIN หรือ DTC)
  final bool expectMultipleLines;

  const ObdRequest({
    required this.command,
    this.timeout = const Duration(seconds: 2),
    this.expectMultipleLines = false,
  });

  /// แปลงคำสั่ง String เป็น Byte List พร้อมใส่รหัสจบท้าย (CR - \r)
  /// เพื่อให้ Adapter (ELM327) เข้าใจว่าจบคำสั่งแล้ว
  List<int> toBytes() {
    return (command + "\r").codeUnits;
  }
}

/// รูปแบบการตอบกลับจาก OBDII (Standardized Response)
/// ใช้ห่อหุ้มข้อมูลที่ได้จากการประมวลผลของ Hardware Adapter
class ObdResponse {
  /// ข้อมูลดิบที่ได้รับในรูปแบบ Byte List
  final List<int> rawData;

  /// วันที่และเวลาที่ได้รับข้อมูล
  final DateTime timestamp;

  /// สถานะความสำเร็จของการสื่อสารในระดับ Hardware
  final bool isSuccess;

  /// ข้อความแสดงข้อผิดพลาด (ถ้ามี)
  final String? errorMessage;

  ObdResponse({
    required this.rawData,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  /// แปลงข้อมูลดิบกลับมาเป็นตัวอักษรเพื่อให้มนุษย์อ่านง่ายหรือทำ Regex
  String get rawString => String.fromCharCodes(rawData).trim();

  /// ตรวจสอบว่าผลลัพธ์มีข้อมูลจริงที่นำไปใช้ต่อได้หรือไม่
  /// จะคืนค่า false หากรถตอบกลับว่า "NO DATA", "ERROR" หรือการเชื่อมต่อล้มเหลว
  bool get hasValidData {
    final s = rawString.toUpperCase();
    return isSuccess && !s.contains("NO DATA") && !s.contains("ERROR");
  }
}
