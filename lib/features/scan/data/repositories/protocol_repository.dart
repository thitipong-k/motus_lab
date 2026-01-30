import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:motus_lab/core/protocol/models/protocol_pack.dart';
import 'package:motus_lab/core/protocol/standard_pids.dart';
import 'package:motus_lab/domain/entities/command.dart';

/// Repository for managing OBD2 PID definitions.
/// Combines Standard SAE PIDs with manufacturer-specific PIDs defined in Protocol Packs.
class ProtocolRepository {
  ProtocolPack? _activePack;
  List<Command>? _cachedMergedCommands;

  /// Returns the list of Standard SAE J1979 PIDs.
  List<Command> getStandardPids() {
    return StandardPids.all;
  }

  /// Loads a Protocol Pack from an asset file (e.g., 'assets/protocols/honda_civic.json').
  Future<void> loadProtocolPackFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonMap = jsonDecode(jsonString);
      _activePack = ProtocolPack.fromJson(jsonMap);
      _cachedMergedCommands = null; // Invalidate cache
      print("Loaded Protocol Pack from asset: ${_activePack?.meta.name}");
    } catch (e) {
      print("Error loading protocol pack form asset: $e");
      // Keep previous pack or null if failed? For now, let's keep it safe.
    }
  }

  /// Loads a Protocol Pack from a JSON string (e.g., downloaded from cloud or local file).
  void loadProtocolPackFromJson(String jsonString) {
    try {
      final jsonMap = jsonDecode(jsonString);
      _activePack = ProtocolPack.fromJson(jsonMap);
      _cachedMergedCommands = null; // Invalidate cache
      print("Loaded Protocol Pack from JSON: ${_activePack?.meta.name}");
    } catch (e) {
      print("Error loading protocol pack from JSON: $e");
    }
  }

  /// Clears the currently active Protocol Pack, reverting to only Standard PIDs.
  void clearProtocolPack() {
    _activePack = null;
    _cachedMergedCommands = null;
  }

  /// Returns a merged list of all available PIDs (Standard + Active Pack).
  /// If a PID exists in both, the Pack version takes precedence (overrides standard).
  List<Command> getAllAvailablePids() {
    if (_cachedMergedCommands != null) {
      return _cachedMergedCommands!;
    }

    if (_activePack == null) {
      return StandardPids.all;
    }

    // Start with Standard PIDs
    final Map<String, Command> pidMap = {
      for (var cmd in StandardPids.all) cmd.code: cmd
    };

    // Override/Add from Pack
    for (var cmd in _activePack!.commands) {
      // Map ProtocolPack Command model to Entity Command model
      // Note: Assuming ProtocolPack commands have compatible structure
      // We might need an adapter here if the classes are different.
      // For now, mapping manually or reusing compatible fields.

      final newCmd = Command(
        name: cmd.name,
        code: cmd.pid,
        description: "Extended PID (${cmd.pid})",
        unit: cmd.unit,
        formula: cmd.formula,
        min: cmd.min.toDouble(),
        max: cmd.max.toDouble(),
      );

      pidMap[cmd.pid] = newCmd;
    }

    _cachedMergedCommands = pidMap.values.toList();
    // Sort by PID code for consistency? Optional.
    // _cachedMergedCommands!.sort((a, b) => a.code.compareTo(b.code));

    return _cachedMergedCommands!;
  }

  /// Helper to get specific PID by Code (e.g. "010C")
  Command? getCommandByCode(String code) {
    final all = getAllAvailablePids();
    try {
      return all.firstWhere((cmd) => cmd.code == code);
    } catch (e) {
      return null;
    }
  }
}
