import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';

/// หน้าจอประเป๋าเงิน (Wallet) สำหรับจัดการเครดิต
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _credits = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MY WALLET")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // บัตรแสดงยอดเครดิต
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  const Text("CURRENT BALANCE",
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "$_credits Credits",
                    style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("TOP UP CREDITS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _buildTopUpOption("100 Credits", "฿ 99", Icons.flash_on),
            _buildTopUpOption("500 Credits", "฿ 450", Icons.star),
            _buildTopUpOption("1,000 Credits", "฿ 850", Icons.diamond),
            const SizedBox(height: 48),
            // รายการที่ต้องใช้เครดิต
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("SERVICES PRICING",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const ListTile(
              title: Text("DPF Regeneration"),
              trailing:
                  Text("100 Cr", style: TextStyle(color: AppColors.primary)),
            ),
            const ListTile(
              title: Text("BMS Programming"),
              trailing:
                  Text("50 Cr", style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpOption(String title, String price, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: ElevatedButton(
          onPressed: () {},
          child: Text(price),
        ),
      ),
    );
  }
}
