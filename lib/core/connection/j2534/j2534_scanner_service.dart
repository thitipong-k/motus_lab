import 'dart:io';

class J2534Device {
  final String name;
  final String vendor;
  final String functionLibrary; // DLL path

  J2534Device({
    required this.name,
    required this.vendor,
    required this.functionLibrary,
  });

  @override
  String toString() {
    return 'J2534Device(name: $name, vendor: $vendor, functionLibrary: $functionLibrary)';
  }
}

class J2534ScannerService {
  /// Scans Windows Registry for installed J2534 devices
  static Future<List<J2534Device>> scanDevices() async {
    if (!Platform.isWindows) {
      return [];
    }

    final List<J2534Device> devices = [];

    try {
      // Run reg query with /s to get all subkeys and values
      final result = await Process.run(
        'reg',
        ['query', r'HKLM\Software\PassThruSupport.04.04', '/s'],
      );

      if (result.exitCode != 0) {
        // Registry key not found, likely no drivers installed.
        return [];
      }

      final String output = result.stdout as String;
      final lines = output.split('\n');

      String currentName = '';
      String currentVendor = '';
      String currentLibrary = '';

      for (String line in lines) {
        line = line.trim();
        if (line.startsWith('HKEY_LOCAL_MACHINE')) {
          // New device block starting, save previous if valid
          if (currentName.isNotEmpty && currentLibrary.isNotEmpty) {
            devices.add(J2534Device(
              name: currentName,
              vendor: currentVendor,
              functionLibrary: currentLibrary,
            ));
          }
          // Reset
          currentName = '';
          currentVendor = '';
          currentLibrary = '';
        } else if (line.isNotEmpty) {
          // Parse values. Format is typically: Name    REG_SZ    Value
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length >= 3) {
            final keyName = parts[0];
            final valueType = parts[1]; // Usually REG_SZ or REG_DWORD

            if (valueType.startsWith('REG_')) {
               final valueStartIndex = line.indexOf(valueType) + valueType.length;
               final value = line.substring(valueStartIndex).trim();

               if (keyName == 'Name') {
                 currentName = value;
               } else if (keyName == 'Vendor') {
                 currentVendor = value;
               } else if (keyName == 'FunctionLibrary') {
                 currentLibrary = value;
               }
            }
          }
        }
      }

      // Add the last one if valid
      if (currentName.isNotEmpty && currentLibrary.isNotEmpty) {
        devices.add(J2534Device(
          name: currentName,
          vendor: currentVendor,
          functionLibrary: currentLibrary,
        ));
      }
    } catch (e) {
      print("Error scanning J2534 registry: $e");
    }

    return devices;
  }
}
