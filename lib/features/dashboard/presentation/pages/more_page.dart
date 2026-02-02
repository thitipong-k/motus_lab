import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/coding/presentation/pages/adaptation_page.dart';
import 'package:motus_lab/features/crm/presentation/pages/customer_list_page.dart';
import 'package:motus_lab/features/profile/presentation/pages/wallet_page.dart';
import 'package:motus_lab/features/remote/presentation/pages/remote_expert_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/freeze_frame_page.dart';
import 'package:motus_lab/features/settings/presentation/pages/settings_page.dart';
import 'package:motus_lab/features/sniffer/presentation/pages/sniffer_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/services/security/biometric_service.dart';
import 'package:motus_lab/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:motus_lab/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:motus_lab/features/auth/presentation/pages/login_page.dart';
import 'package:motus_lab/shared/pages/help_center_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/dtc_result_page.dart';

/// หน้า Menu (More) สำหรับรวมฟีเจอร์รองต่างๆ ไว้ในที่เดียว
/// แสดงผลแบบ Grid เพื่อให้เข้าถึงง่ายและประหยัดพื้นที่บน Navigation Bar
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': 'Help Center',
        'icon': Icons.help_outline,
        'page': const HelpCenterPage(),
        'color': AppColors.primary,
      },
      {
        'label': 'Diagnostics',
        'icon': Icons.troubleshoot,
        'page': const DtcResultPage(),
        'color': AppColors.error,
      },
      {
        'label': 'Freeze Frame',
        'icon': Icons.backup_table,
        'page': const FreezeFramePage(),
        'color': AppColors.secondary,
      },
      {
        'label': 'CRM',
        'icon': Icons.people,
        'page': const CustomerListPage(),
        'color': AppColors.primary,
      },
      {
        'label': 'Remote Expert',
        'icon': Icons.hub,
        'page': const RemoteExpertPage(),
        'color': AppColors.warning,
      },
      {
        'label': 'Wallet',
        'icon': Icons.account_balance_wallet,
        'page': const WalletPage(),
        'color': AppColors.success,
      },
      {
        'label': 'Coding',
        'icon': Icons.edit_note,
        'page': const AdaptationPage(),
        'color': AppColors.secondary,
      },
      {
        'label': 'Sniffer',
        'icon': Icons.terminal,
        'page': const SnifferPage(),
        'color': AppColors.error,
      },
      {
        'label': 'Settings',
        'icon': Icons.settings,
        'page': const SettingsPage(),
        'color': AppColors.surface,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: const Icon(Icons.account_circle,
                      color: AppColors.primary),
                  onPressed: () {
                    // Show Profile / Logout Dialog
                    _showProfileDialog(context, state.user);
                  },
                );
              }
              return TextButton.icon(
                icon: const Icon(Icons.cloud_sync, size: 18),
                label: const Text("LOGIN"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return _buildMenuItem(context, item);
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () async {
        if (item['label'] == 'CRM') {
          // 1. Check if App Lock is enabled
          final settingsState = context.read<SettingsBloc>().state;
          if (settingsState.settings.isAppLockEnabled) {
            // 2. Trigger Biometric Auth
            final biometricService = locator<BiometricService>();
            final isAuthenticated = await biometricService.authenticate(
                reason: 'Release the lock to access Customer Data');

            if (!isAuthenticated) {
              // Auth Failed or Cancelled
              if (context.mounted) {
                // Check if widget still active
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Authentication Failed: Access Denied'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              return; // Stop navigation
            }
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item['page']),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                size: 32,
                color: item['color'],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['label'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Account Settings",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(user.email ?? "No Email",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.primary),
              title: const Text("2FA Settings",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                // Future: Navigate to 2FA Setup
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context);
            },
            child: const Text("LOGOUT"),
          ),
        ],
      ),
    );
  }
}
