enum ModuleStatus { ok, fault, offline, scanning }

class VehicleModule {
  final String id;
  final String name;
  final String bus; // e.g. "CAN-C", "CAN-B"
  final ModuleStatus status;
  final int dtcCount;
  final String description;

  const VehicleModule({
    required this.id,
    required this.name,
    required this.bus,
    required this.status,
    this.dtcCount = 0,
    this.description = "",
  });

  VehicleModule copyWith({
    String? id,
    String? name,
    String? bus,
    ModuleStatus? status,
    int? dtcCount,
    String? description,
  }) {
    return VehicleModule(
      id: id ?? this.id,
      name: name ?? this.name,
      bus: bus ?? this.bus,
      status: status ?? this.status,
      dtcCount: dtcCount ?? this.dtcCount,
      description: description ?? this.description,
    );
  }
}
