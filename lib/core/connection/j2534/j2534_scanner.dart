import 'dart:io';

class J2534Device {
  final String vendor;
  final String name;
  final String dllPath;

  J2534Device({
    required this.vendor,
    required this.name,
    required this.dllPath,
  });

  @override
  String toString() => 'J2534Device(vendor: $vendor, name: $name, dllPath: $dllPath)';
}

class J2534Scanner {
  /// Scans the Windows Registry for installed J2534 PassThru drivers.
  /// Uses the 'reg' command for safety, avoiding raw FFI registry crashes.
  static Future<List<J2534Device>> scanDevices() async {
    final devices = <J2534Device>[];

    if (!Platform.isWindows) {
      return devices; // J2534 is a Windows-only standard
    }

    try {
      // HKLM\Software\PassThruSupport.04.04 is the standard registry key for J2534-1
      final result = await Process.run('reg', ['query', r'HKLM\Software\PassThruSupport.04.04', '/s']);
      
      if (result.exitCode != 0) {
        // Registry key not found, meaning no J2534 drivers are installed
        return devices;
      }

      final output = result.stdout.toString();
      final blocks = output.split(r'HKEY_LOCAL_MACHINE\Software\PassThruSupport.04.04\');
      
      for (final block in blocks) {
        if (block.trim().isEmpty) continue;
        
        String vendor = "Unknown Vendor";
        String name = "Unknown Device";
        String dllPath = "";

        final lines = block.split('\n');
        for (final line in lines) {
          if (line.contains('Vendor')) {
            vendor = _extractRegValue(line);
          } else if (line.contains('Name')) {
            name = _extractRegValue(line);
          } else if (line.contains('FunctionLibrary')) {
            dllPath = _extractRegValue(line);
          }
        }

        if (dllPath.isNotEmpty) {
          devices.add(J2534Device(
            vendor: vendor,
            name: name,
            dllPath: dllPath,
          ));
        }
      }
    } catch (e) {
      print('Error scanning for J2534 devices: $e');
    }

    return devices;
  }

  static String _extractRegValue(String line) {
    // A standard reg query line looks like:
    //     Vendor    REG_SZ    Drew Technologies, Inc.
    final parts = line.split(RegExp(r'\s{2,}'));
    if (parts.length >= 3) {
      return parts.sublist(2).join(' ').trim();
    }
    return '';
  }
}
