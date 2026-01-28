import 'dart:async';
import 'dart:math';
import 'package:motus_lab/domain/entities/vehicle_module.dart';

class TopologyRepository {
  // Simulate a network scan
  Stream<VehicleModule> scanModules() async* {
    final modules = _getMockModules();

    for (var module in modules) {
      // Simulate network delay (50ms - 200ms per module)
      await Future.delayed(Duration(milliseconds: 50 + Random().nextInt(150)));

      // Randomly decide status for simulation effect if needed,
      // but let's stick to the mock data for consistency
      yield module;
    }
  }

  Future<List<VehicleModule>> getModulesSnapshot() async {
    // Simulate full scan time
    await Future.delayed(const Duration(seconds: 2));
    return _getMockModules();
  }

  List<VehicleModule> _getMockModules() {
    return [
      const VehicleModule(
          id: "0x7E0",
          name: "ECM",
          bus: "CAN-HS",
          status: ModuleStatus.ok,
          description: "Engine Control Module"),
      const VehicleModule(
          id: "0x7E1",
          name: "TCM",
          bus: "CAN-HS",
          status: ModuleStatus.ok,
          description: "Transmission Control Module"),
      const VehicleModule(
          id: "0x7E2",
          name: "ABS",
          bus: "CAN-HS",
          status: ModuleStatus.fault,
          dtcCount: 2,
          description: "Anti-Lock Brake System"),
      const VehicleModule(
          id: "0x7E3",
          name: "BCM",
          bus: "CAN-MS",
          status: ModuleStatus.ok,
          description: "Body Control Module"),
      const VehicleModule(
          id: "0x7E4",
          name: "IPC",
          bus: "CAN-MS",
          status: ModuleStatus.ok,
          description: "Instrument Cluster"),
      const VehicleModule(
          id: "0x7E5",
          name: "HVAC",
          bus: "CAN-MS",
          status: ModuleStatus.offline,
          description: "Climate Control"),
      const VehicleModule(
          id: "0x7E6",
          name: "SRS",
          bus: "CAN-HS",
          status: ModuleStatus.ok,
          description: "Airbag System"),
      const VehicleModule(
          id: "0x7E7",
          name: "EPS",
          bus: "CAN-HS",
          status: ModuleStatus.ok,
          description: "Electric Power Steering"),
      const VehicleModule(
          id: "0x7E8",
          name: "TPMS",
          bus: "CAN-MS",
          status: ModuleStatus.fault,
          dtcCount: 1,
          description: "Tire Pressure Monitor"),
      const VehicleModule(
          id: "0x7E9",
          name: "PDM",
          bus: "CAN-MS",
          status: ModuleStatus.ok,
          description: "Passenger Door Module"),
      const VehicleModule(
          id: "0x7EA",
          name: "DDM",
          bus: "CAN-MS",
          status: ModuleStatus.ok,
          description: "Driver Door Module"),
    ];
  }
}
