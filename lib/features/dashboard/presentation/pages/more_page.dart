import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/coding/presentation/pages/adaptation_page.dart';
import 'package:motus_lab/features/crm/presentation/pages/customer_list_page.dart';
import 'package:motus_lab/features/profile/presentation/pages/wallet_page.dart';
import 'package:motus_lab/features/remote/presentation/pages/remote_expert_page.dart';
import 'package:motus_lab/features/scan/presentation/pages/freeze_frame_page.dart';
import 'package:motus_lab/features/settings/presentation/pages/settings_page.dart';
import 'package:motus_lab/features/sniffer/presentation/pages/sniffer_page.dart';

/// หน้า Menu (More) สำหรับรวมฟีเจอร์รองต่างๆ ไว้ในที่เดียว
/// แสดงผลแบบ Grid เพื่อให้เข้าถึงง่ายและประหยัดพื้นที่บน Navigation Bar
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
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
      onTap: () {
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
}
