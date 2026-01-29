import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/vehicle_module.dart';
import '../../core/topology/broadcast_scanner.dart';

class TopologyRepository {
  final BroadcastScanner _scanner = BroadcastScanner();
  Map<String, dynamic>? _moduleDatabase;

  /// Loads the static JSON database into memory
  Future<void> initialize() async {
    if (_moduleDatabase != null) return;
    try {
      final jsonString = await rootBundle.loadString('assets/modules_db.json');
      _moduleDatabase = json.decode(jsonString);
    } catch (e) {
      print("Error loading module database: $e");
      // Fallback to empty if file fails, so we don't crash
      _moduleDatabase = {};
    }
  }

  /// Broadcasts a query and resolves responding IDs to full Module objects
  Stream<VehicleModule> scanModules() async* {
    // Ensure DB is loaded
    await initialize();

    await for (final id in _scanner.scan()) {
      if (_moduleDatabase!.containsKey(id)) {
        final info = _moduleDatabase![id];

        // Simulating some status logic (normally we'd parse this from the reply bytes)
        // For now, let's mark ABS and TPMS as having faults to keep the UI interesting
        ModuleStatus status = ModuleStatus.ok;
        int dtcCount = 0;

        if (info['name'] == 'ABS') {
          status = ModuleStatus.fault;
          dtcCount = 2;
        } else if (info['name'] == 'TPMS') {
          status = ModuleStatus.warning;
          dtcCount = 1;
        }

        yield VehicleModule(
          id: id,
          name: info['name'] ?? 'Unknown',
          bus: info['bus'] ?? 'Unknown',
          status: status,
          dtcCount: dtcCount,
          description: info['desc'] ?? '',
        );
      } else {
        // Handle unknown module response
        yield VehicleModule(
          id: id,
          name: "Unknown ($id)",
          bus: "Unknown",
          status: ModuleStatus.warning,
          description: "Unrecognized Module",
        );
      }
    }
  }

  Future<List<VehicleModule>> getModulesSnapshot() async {
    final List<VehicleModule> modules = [];
    await for (final module in scanModules()) {
      modules.add(module);
    }
    return modules;
  }
}
