class ProtocolPack {
  final ProtocolMeta meta;
  final List<String> initSequence;
  final List<ObdCommandDef> commands;

  ProtocolPack({
    required this.meta,
    required this.initSequence,
    required this.commands,
  });

  factory ProtocolPack.fromJson(Map<String, dynamic> json) {
    return ProtocolPack(
      meta: ProtocolMeta.fromJson(json['meta']),
      initSequence: List<String>.from(json['init_sequence'] ?? []),
      commands: (json['commands'] as List)
          .map((e) => ObdCommandDef.fromJson(e))
          .toList(),
    );
  }
}

class ProtocolMeta {
  final String id;
  final String version;
  final String name;

  ProtocolMeta({
    required this.id,
    required this.version,
    required this.name,
  });

  factory ProtocolMeta.fromJson(Map<String, dynamic> json) {
    return ProtocolMeta(
      id: json['id'],
      version: json['version'],
      name: json['name'],
    );
  }
}

class ObdCommandDef {
  final String pid;
  final String name;
  final String unit;
  final int bytes;
  final String formula;
  final num min;
  final num max;

  ObdCommandDef({
    required this.pid,
    required this.name,
    required this.unit,
    required this.bytes,
    required this.formula,
    required this.min,
    required this.max,
  });

  factory ObdCommandDef.fromJson(Map<String, dynamic> json) {
    return ObdCommandDef(
      pid: json['pid'],
      name: json['name'],
      unit: json['unit'] ?? "",
      bytes: json['bytes'] ?? 1,
      formula: json['formula'] ?? "",
      min: json['min'] ?? 0,
      max: json['max'] ?? 100,
    );
  }
}
