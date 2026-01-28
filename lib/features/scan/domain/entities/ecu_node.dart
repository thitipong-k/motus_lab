import 'package:flutter/material.dart';

enum EcuStatus { ok, fault, disconnected }

class EcuNode {
  final String id;
  final String name;
  final EcuStatus status;
  final Offset position; // สำหรับวาดบน Canvas

  const EcuNode({
    required this.id,
    required this.name,
    this.status = EcuStatus.disconnected,
    this.position = Offset.zero,
  });

  EcuNode copyWith({
    EcuStatus? status,
    Offset? position,
  }) {
    return EcuNode(
      id: id,
      name: name,
      status: status ?? this.status,
      position: position ?? this.position,
    );
  }
}
