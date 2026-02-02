import 'package:drift/drift.dart';

/// [VehicleStats]
/// ตารางเก็บสถิติการใช้งานรถยนต์แต่ละรุ่น (Year/Make/Model)
/// ใช้สำหรับระบบ Predictive Caching เพื่อเลือกระดับความสำคัญของข้อมูลที่จะเก็บไว้ในเครื่อง
class VehicleScanStats extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ข้อมูลระบุรุ่นรถ
  TextColumn get make => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();

  // สถิติการใช้งาน
  IntColumn get scanCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastScanned =>
      dateTime().withDefault(currentDateAndTime)();

  // คะแนนความสำคัญ (Calculated Score)
  // ยิ่งสแกนบ่อย คะแนนยิ่งสูง ข้อมูลจะถูกเก็บไว้ในเครื่องเป็นลำดับแรก
  IntColumn get priorityScore => integer().withDefault(const Constant(0))();

  // รองรับการทำงานแบบออฟไลน์และซิงค์ข้อมูล
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {year, make, model}
      ];
}
