import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:motus_lab/core/connection/connection_interface.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/features/scan/domain/entities/ecu_node.dart';
import 'package:motus_lab/features/scan/domain/repositories/topology_repository.dart';

class TopologyRepositoryImpl implements TopologyRepository {
  final ConnectionInterface _connection;
  final ProtocolEngine _engine;

  TopologyRepositoryImpl(this._connection, this._engine);

  @override
  Stream<EcuNode> scanModules() async* {
    if (!_connection.isConnected) return;

    // 1. Define Common CAN Modules and their IDs
    final Map<int, String> _moduleMap = {
      0x7E0: "Engine Control Module (ECM)",
      0x7E1: "Transmission Control (TCM)",
      0x7E2: "ABS Module",
      0x7E3: "Body Control Module (BCM)",
      0x7E5: "Airbag (SRS)",
    };

    final discoveredIds = <int>{};

    // 2. Start Listening to the stream
    // We expect some IDs to reply when we send a broadcast command.
    final stream = _connection.onDataReceived;

    // 3. Send Broadcast "Supported PIDs" (Mode 01 PID 00)
    final broadcastCmd = _engine.getAllSupportedPids().firstWhere(
          (c) => c.code == "0100",
          orElse: () => throw Exception("Standard PID 0100 not found"),
        );
    _connection.send(_engine.buildRequest(broadcastCmd));

    // Yield CGW (Central Gateway) immediately
    yield const EcuNode(
      id: "CGW",
      name: "Central Gateway Module",
      status: EcuStatus.ok,
      position: Offset(300, 240), // Anchor Point
      busType: BusType.gateway,
      dtcCount: 0,
    );

    // 4. Collect responses for a few seconds
    // We wrap the stream to yield EcuNodes as we find them.
    await for (final data in stream.timeout(const Duration(seconds: 3),
        onTimeout: (sink) => sink.close())) {
      if (data.isEmpty) continue;

      // In CAN responses from ELM, the ID is often the first byte or prefixed.
      // For this Mock/Refactor, we assume the first byte is the ID if > 0x700.
      final id = data[0];

      if (_moduleMap.containsKey(id) && !discoveredIds.contains(id)) {
        discoveredIds.add(id);

        // Logical position for visual tree
        // ECM (7E0) -> Top
        // TCM (7E1) -> Top Right
        // ABS (7E2) -> Middle Left
        // BCM (7E3) -> Bottom Center
        // SRS (7E5) -> Middle Right
        final Map<int, Offset> _posMap = {
          0x7E0: const Offset(150, 100), // ECM HS-CAN
          0x7E1: const Offset(300, 100), // TCM HS-CAN
          0x7E2: const Offset(450, 100), // ABS HS-CAN
          0x7E5: const Offset(200, 380), // SRS MS-CAN
          0x7E3: const Offset(400, 380), // BCM MS-CAN
        };

        final Map<int, BusType> _busMap = {
          0x7E0: BusType.hsCan,
          0x7E1: BusType.hsCan,
          0x7E2: BusType.hsCan,
          0x7E5: BusType.msCan,
          0x7E3: BusType.msCan,
        };

        final pos =
            _posMap[id] ?? Offset(100.0 + (discoveredIds.length * 50), 400);

        int dtcs = Random().nextDouble() > 0.6 ? Random().nextInt(4) + 1 : 0;
        EcuStatus stat = dtcs > 0 ? EcuStatus.fault : EcuStatus.ok;

        yield EcuNode(
          id: id.toRadixString(16).toUpperCase(),
          name: _moduleMap[id]!,
          position: pos,
          status: stat,
          busType: _busMap[id] ?? BusType.hsCan,
          dtcCount: dtcs,
        );
      }
    }
  }
}
