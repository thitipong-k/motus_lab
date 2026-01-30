import 'package:flutter/material.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/crm/domain/entities/customer.dart';
import 'package:motus_lab/core/widgets/motus_card.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            const Text("Vehicles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildVehicleList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return MotusCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text("Phone"),
              subtitle: Text(customer.phone ?? "N/A"),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text("Email"),
              subtitle: Text(customer.email ?? "N/A"),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text("Address"),
              subtitle: Text(customer.address ?? "N/A"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    // Placeholder for now. Needs a Vehicle Repository/Bloc call to fetch by customerId.
    // For Phase 5 initial step, we can leave this empty or show a placeholder.
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("No linked vehicles yet.",
            style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
