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
    // Using engine to build request for future-proofing
    final broadcastCmd =
        _engine.getAllSupportedPids().firstWhere((c) => c.code == "0100");
    _connection.send(_engine.buildRequest(broadcastCmd));

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
          0x7E0: const Offset(200, 80),
          0x7E1: const Offset(400, 80),
          0x7E2: const Offset(100, 220),
          0x7E5: const Offset(500, 220),
          0x7E3: const Offset(300, 360),
        };

        final pos =
            _posMap[id] ?? Offset(100.0 + (discoveredIds.length * 50), 400);

        yield EcuNode(
          id: id.toRadixString(16).toUpperCase(),
          name: _moduleMap[id]!,
          position: pos,
          status: Random().nextDouble() > 0.9 ? EcuStatus.fault : EcuStatus.ok,
        );
      }
    }
  }
}
