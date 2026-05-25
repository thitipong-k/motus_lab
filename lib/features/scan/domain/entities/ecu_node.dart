import 'package:flutter/material.dart';

enum EcuStatus { ok, fault, disconnected }

enum BusType { hsCan, msCan, flexRay, lin, gateway }

class EcuNode {
  final String id;
  final String name;
  final EcuStatus status;
  final Offset position; // สำหรับวาดบน Canvas
  final BusType busType;
  final int dtcCount;

  const EcuNode({
    required this.id,
    required this.name,
    this.status = EcuStatus.disconnected,
    this.position = Offset.zero,
    this.busType = BusType.hsCan,
    this.dtcCount = 0,
  });

  EcuNode copyWith({
    EcuStatus? status,
    Offset? position,
    BusType? busType,
    int? dtcCount,
  }) {
    return EcuNode(
      id: id,
      name: name,
      status: status ?? this.status,
      position: position ?? this.position,
      busType: busType ?? this.busType,
      dtcCount: dtcCount ?? this.dtcCount,
    );
  }
}
