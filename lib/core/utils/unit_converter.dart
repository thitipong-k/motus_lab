class UnitConverter {
  // Temperature
  static double celsiusToFahrenheit(double c) => (c * 9 / 5) + 32;

  // Speed
  static double kmhToMph(double kmh) => kmh * 0.621371;

  // Pressure
  static double kpaToPsi(double kpa) => kpa * 0.145038;
  static double kpaToBar(double kpa) => kpa * 0.01;

  // Mass Air Flow
  static double gramsPerSecToLbsPerMin(double gps) => gps * 0.132277;

  /// Helper to format value based on system
  /// [value] - Raw value from ECU (usually Metric)
  /// [unit] - Original unit from Command (e.g. "°C", "km/h")
  /// [useImperial] - Whether to convert to Imperial
  static String formatValue(double value, String unit, bool useImperial) {
    if (!useImperial) {
      return "${value.toStringAsFixed(1)} $unit";
    }

    // Convert only known units
    switch (unit) {
      case "°C":
        return "${celsiusToFahrenheit(value).toStringAsFixed(1)} °F";
      case "km/h":
        return "${kmhToMph(value).toStringAsFixed(1)} mph";
      case "kPa":
        return "${kpaToPsi(value).toStringAsFixed(1)} psi";
      case "g/s":
        return "${gramsPerSecToLbsPerMin(value).toStringAsFixed(2)} lb/min";
      default:
        return "${value.toStringAsFixed(1)} $unit";
    }
  }
}
