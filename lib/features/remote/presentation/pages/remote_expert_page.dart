import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

/// หน้าจอสำหรับเริ่มเซสชัน Remote Expert
class RemoteExpertPage extends StatefulWidget {
  const RemoteExpertPage({super.key});

  @override
  State<RemoteExpertPage> createState() => _RemoteExpertPageState();
}

class _RemoteExpertPageState extends State<RemoteExpertPage> {
  bool _isConnecting = false;
  String _sessionCode = "MOTUS-889-X";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REMOTE EXPERT")),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              "SmartLink Technology",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "แบ่งปันข้อมูล CAN Bus ของคุณให้ผู้เชี่ยวชาญช่วยวิเคราะห์แบบ Real-time",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text("YOUR SESSION CODE",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(_sessionCode,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                setState(() => _isConnecting = !_isConnecting);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnecting ? Colors.red : AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _isConnecting ? "STOP SHARING" : "START SMARTLINK",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (_isConnecting)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text("Master Technician is viewing your Bus...",
                        style: TextStyle(color: AppColors.success)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
