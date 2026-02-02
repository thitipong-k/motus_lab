import 'package:motus_lab/core/services/logger.dart';
import 'package:motus_lab/features/scan/data/repositories/diagnostic_repository.dart';

/// [DiagnosticExpertService]
/// ระบบชี้แนะแนวทางการซ่อมแซมเบื้องต้น (Technical Troubleshooting Guidelines)
/// ทำหน้าที่วิเคราะห์รหัส DTC และให้คำแนะนำเชิงเทคนิคแก่ผู้ใช้
class DiagnosticExpertService {
  final DiagnosticRepository _repository;

  DiagnosticExpertService(this._repository);

  /// ฐานข้อมูลคำแนะนำพื้นฐาน (Static Knowledge Base)
  /// ในอนาคตสามารถดึงข้อมูลจาก Database หรือระบบ AI ผ่าน API ได้
  final Map<String, List<String>> _baselineGuidelines = {
    'P0300': [
      'ตรวจสอบหัวเทียน (Check Spark Plugs)',
      'ตรวจสอบคอยล์จุดระเบิด (Check Ignition Coils)',
      'ตรวจสอบระบบจ่ายน้ำมันและท่ออากาศ (Inspect Fuel System and Vacuum Leaks)',
    ],
    'P0171': [
      'ตรวจสอบเซนเซอร์วัดค่าอากาศ MAF (Clean/Check MAF Sensor)',
      'ตรวจสอบท่อรั่วหลังกรองอากาศ (Check for Intake Air Leaks)',
      'ตรวจสอบแรงดันน้ำมันเชื้อเพลิง (Check Fuel Pressure)',
    ],
    'P0420': [
      'ตรวจสอบประสิทธิภาพเครื่องฟอกไอเสีย (Inspect Catalytic Converter)',
      'ตรวจสอบเซนเซอร์ออกซิเจนตัวที่ 2 (Check O2 Sensor B1S2)',
      'ตรวจสอบการรั่วของท่อไอเสีย (Check for Exhaust Leaks)',
    ],
    '7E2': [
      // ตัวอย่างกรณีเป็น Module Error (ABS)
      'ตรวจสอบระดับน้ำมันเบรก (Check Brake Fluid Level)',
      'ตรวจสอบเซนเซอร์ความเร็วล้อ (Inspect Wheel Speed Sensors)',
      'ตรวจสอบปลั๊กและการสื่อสารของกล่อง ABS (Check ABS Module Connector)',
    ]
  };

  /// ดึงรายการขั้นตอนการตรวจสอบเบื้องต้นตามรหัส DTC
  /// ค้นหาจากฐานข้อมูลก่อน หากไม่พบจึงใช้ Baseline ที่เตรียมไว้
  Future<List<String>> getGuidelines(String code, {String? model}) async {
    Logger.info("DiagnosticExpert: Fetching guidelines for code $code");

    // 1. ค้นหาใน Database (Expert Database)
    try {
      final causes = await _repository.getLikelyCauses(code, model ?? "");
      if (causes.isNotEmpty) {
        // ดึง Solution สำหรับเหตุผลแรกที่ลำดับสูงสุด
        final solution = await _repository.getSolution(causes.first.causeId);
        if (solution != null && solution.steps.isNotEmpty) {
          return solution.steps.split("\n");
        }
      }
    } catch (e) {
      Logger.error("DiagnosticExpert: Database lookup failed", e);
    }

    // 2. Fallback ไปยัง Static Baseline
    return _baselineGuidelines[code] ??
        [
          'ทำการ Rescan ระบบอีกครั้ง (Perform System Rescan)',
          'ตรวจสอบสายไฟและขั้วต่อที่เกี่ยวข้อง (Inspect related wiring and connectors)',
          'ปรึกษาผู้เชี่ยวชาญเพื่อใช้เครื่องมือวิเคราะห์ขั้นสูง (Consult professional for advanced scan)',
        ];
  }

  /// ส่วนที่เตรียมไว้สำหรับเชื่อมต่อกับ AI ในอนาคต (AI Integration Placeholder)
  Future<String> getAIAnalysis(String vin, String code) async {
    // ขั้นตอนที่ 1: เตรียมข้อมูลบริบทของรถ
    // ขั้นตอนที่ 2: ส่งคำถามไปยัง LLM API (เช่น Gemini)
    // ขั้นตอนที่ 3: ประมวลผลและส่งคืนคำตอบ
    return "AI Analysis is currently in development mode. Please use baseline guidelines.";
  }
}
