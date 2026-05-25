import 'package:flutter/material.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/services/security/sgw_auth_service.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

class SgwUnlockDialog extends StatefulWidget {
  const SgwUnlockDialog({super.key});

  @override
  State<SgwUnlockDialog> createState() => _SgwUnlockDialogState();
}

class _SgwUnlockDialogState extends State<SgwUnlockDialog> {
  final _usernameCtrl = TextEditingController(text: "mechanic_pro");
  final _passwordCtrl = TextEditingController(text: "password123");
  bool _isLoading = false;

  void _authenticate() async {
    setState(() => _isLoading = true);
    
    final authService = locator<SgwAuthService>();
    final success = await authService.authenticate(_usernameCtrl.text, _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true); // Return true for success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication Failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            const Text(
              "SGW Locked",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Security Gateway has blocked this command.\nPlease log in to AutoAuth / SFD to unlock.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: "OEM Username",
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password / Token",
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _authenticate,
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Unlock Network", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            )
          ],
        ),
      ),
    );
  }
}
