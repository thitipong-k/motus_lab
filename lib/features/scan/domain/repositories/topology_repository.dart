import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';

/// Repository สำหรับจัดการข้อมูล Topology ของรถยนต์
/// [WORKFLOW STEP 3] Topology Simulation: จำลองการแสกนหา ECU ในระบบ CAN Bus
/// ทำหน้าที่เป็น Interface กลางสำหรับดึงข้อมูลโครงสร้างเครือข่ายของรถ
abstract class TopologyRepository {
  /// จำลองการแสกนหา Module ในระบบ (Stream เพื่อให้เห็น Node เด้งขึ้นมาทีละตัว)
  /// Return: Stream ของ EcuNode ที่ค้นพบจากการแสกน
  Stream<EcuNode> scanModules();
}
