import 'package:motus_lab/domain/entities/command.dart';

/// Standard SAE J1979 PIDs
/// อ้างอิง: https://en.wikipedia.org/wiki/OBD-II_PIDs
class StandardPids {
  // --- Engine & Load ---
  static const Command calculatedLoad = Command(
      name: "Calculated Load",
      code: "0104",
      description: "Calculated Engine Load",
      unit: "%",
      formula: "A*100/255");

  static const Command engineCoolantTemp = Command(
      name: "Coolant Temp",
      code: "0105",
      description: "Engine Coolant Temperature",
      unit: "°C",
      formula: "A-40",
      priority: CommandPriority.low);

  static const Command shortTermFuelTrim1 = Command(
      name: "Short Term Fuel Trim B1",
      code: "0106",
      description: "Short Term Fuel Trim - Bank 1",
      unit: "%",
      formula: "(A-128)*100/128");

  static const Command longTermFuelTrim1 = Command(
      name: "Long Term Fuel Trim B1",
      code: "0107",
      description: "Long Term Fuel Trim - Bank 1",
      unit: "%",
      formula: "(A-128)*100/128");

  static const Command intakeManifoldPressure = Command(
      name: "Intake Manifold Pressure",
      code: "010B",
      description: "Intake Manifold Absolute Pressure",
      unit: "kPa",
      formula: "A");

  static const Command engineRpm = Command(
      name: "Engine RPM",
      code: "010C",
      description: "Engine Revolutions Per Minute",
      unit: "rpm",
      formula: "((A*256)+B)/4",
      priority: CommandPriority.high);

  static const Command vehicleSpeed = Command(
      name: "Vehicle Speed",
      code: "010D",
      description: "Vehicle Speed",
      unit: "km/h",
      formula: "A",
      priority: CommandPriority.high);

  static const Command timingAdvance = Command(
      name: "Timing Advance",
      code: "010E",
      description: "Timing Advance for Cylinder 1",
      unit: "°",
      formula: "(A/2)-64",
      priority: CommandPriority.high);

  static const Command intakeAirTemp = Command(
      name: "Intake Air Temp",
      code: "010F",
      description: "Intake Air Temperature",
      unit: "°C",
      formula: "A-40");

  static const Command mafAirFlow = Command(
      name: "MAF Air Flow",
      code: "0110",
      description: "Mass Air Flow Rate",
      unit: "g/s",
      formula: "((A*256)+B)/100");

  static const Command throttlePosition = Command(
      name: "Throttle Position",
      code: "0111",
      description: "Throttle Position",
      unit: "%",
      formula: "A*100/255",
      priority: CommandPriority.high);

  static const Command runtimeSinceStart = Command(
      name: "Run Time",
      code: "011F",
      description: "Run time since engine start",
      unit: "sec",
      formula: "(A*256)+B");

  static const Command fuelRailPressure = Command(
      name: "Fuel Rail Pressure",
      code: "0123",
      description: "Fuel Rail Gauge Pressure",
      unit: "kPa",
      formula: "((A*256)+B)*10");

  static const Command fuelLevel = Command(
      name: "Fuel Level",
      code: "012F",
      description: "Fuel Tank Level Input",
      unit: "%",
      formula: "A*100/255",
      priority: CommandPriority.low);

  static const Command controlModuleVoltage = Command(
      name: "Module Voltage",
      code: "0142",
      description: "Control Module Voltage",
      unit: "V",
      formula: "((A*256)+B)/1000");

  static const Command absoluteLoad = Command(
      name: "Absolute Load",
      code: "0143",
      description: "Absolute Load Value",
      unit: "%",
      formula: "((A*256)+B)*100/255");

  static const Command ambientAirTemp = Command(
      name: "Ambient Air Temp",
      code: "0146",
      description: "Ambient Air Temperature",
      unit: "°C",
      formula: "A-40",
      priority: CommandPriority.low);

  // --- Supported PIDs Check ---
  static const Command pidsSupported00 = Command(
      name: "Supported PIDs [01-20]",
      code: "0100",
      description: "PIDs supported [01 - 20]",
      unit: "Bitmask",
      formula: "");

  static const Command pidsSupported20 = Command(
      name: "Supported PIDs [21-40]",
      code: "0120",
      description: "PIDs supported [21 - 40]",
      unit: "Bitmask",
      formula: "");

  static const Command pidsSupported40 = Command(
      name: "Supported PIDs [41-60]",
      code: "0140",
      description: "PIDs supported [41 - 60]",
      unit: "Bitmask",
      formula: "");

  static const Command pidsSupported60 = Command(
      name: "Supported PIDs [61-80]",
      code: "0160",
      description: "PIDs supported [61 - 80]",
      unit: "Bitmask",
      formula: "");

  /// รายการ PIDs ทั้งหมดที่รองรับ
  static List<Command> get all => [
        pidsSupported00, // Important: Check this first
        pidsSupported20,
        pidsSupported40,
        pidsSupported60,
        calculatedLoad,
        engineCoolantTemp,
        shortTermFuelTrim1,
        longTermFuelTrim1,
        intakeManifoldPressure,
        engineRpm,
        vehicleSpeed,
        timingAdvance,
        intakeAirTemp,
        mafAirFlow,
        throttlePosition,
        runtimeSinceStart,
        fuelRailPressure,
        fuelLevel,
        controlModuleVoltage,
        absoluteLoad,
        ambientAirTemp,
      ];
}
