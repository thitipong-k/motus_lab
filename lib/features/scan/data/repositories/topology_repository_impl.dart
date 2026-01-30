import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/features/scan/domain/repositories/topology_repository.dart';

class TopologyRepositoryImpl implements TopologyRepository {
  @override
  Stream<EcuNode> scanModules() async* {
    // 1. Define Mock Modules (CAN Bus Topology Layout)
    // Layout: Engine/Trans (High Speed), Body (Low Speed)
    // จำลองตำแหน่ง ECU บน Diagram (ตำแหน่ง x,y) เพื่อวาดลงบนหน้าจอ
    final List<EcuNode> _mockNodes = [
      const EcuNode(
          id: "ECM", name: "Engine Control Module", position: Offset(150, 100)),
      const EcuNode(
          id: "TCM", name: "Transmission Control", position: Offset(300, 100)),
      const EcuNode(
          id: "ABS",
          name: "Anti-Lock Brake System",
          position: Offset(450, 100)),
      const EcuNode(
          id: "BCM", name: "Body Control Module", position: Offset(150, 300)),
      const EcuNode(
          id: "IPC",
          name: "Instrument Panel Cluster",
          position: Offset(300, 300)),
      const EcuNode(
          id: "AC", name: "Air Conditioning", position: Offset(450, 300)),
      const EcuNode(
          id: "GW",
          name: "Gateway",
          position: Offset(300, 200)), // Central Gateway
      const EcuNode(
          id: "SRS", name: "Airbag System", position: Offset(600, 200)),
    ];

    final random = Random();

    // 2. Simulate Scanning Process
    for (var node in _mockNodes) {
      // Simulate network delay (50ms - 400ms)
      await Future.delayed(Duration(milliseconds: 100 + random.nextInt(300)));

      // Simulate status (Randomly Faulty)
      // 10% chance of fault, 5% disconnected, 85% OK
      EcuStatus status = EcuStatus.ok;
      double r = random.nextDouble();
      if (r < 0.1) {
        status = EcuStatus.fault;
      } else if (r < 0.15) {
        status = EcuStatus.disconnected;
      }

      // Yield the node with its discovered status
      yield node.copyWith(status: status);
    }
  }
}
