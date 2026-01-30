import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/widgets/loading_indicator.dart';
import 'package:motus_lab/core/widgets/motus_card.dart';
import 'package:motus_lab/core/widgets/empty_state.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/crm/presentation/bloc/crm_bloc.dart';
import 'package:motus_lab/features/crm/presentation/pages/customer_detail_page.dart';
import 'package:motus_lab/features/crm/presentation/widgets/customer_form_dialog.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // [WORKFLOW] CRM: เริ่มต้นโหลดข้อมูลลูกค้าเมื่อเข้ามาหน้านี้
    // ใช้ BlocProvider เพื่อ inject CrmBloc เข้าสู่ Widget Tree
    return BlocProvider(
      create: (context) => locator<CrmBloc>()..add(const LoadCustomers()),
      child: const _CustomerListView(),
    );
  }
}

class _CustomerListView extends StatelessWidget {
  const _CustomerListView();

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomerFormDialog(),
    ).then((result) {
      if (result == true) {
        // Bloc handles reload internally on AddCustomer event success in dialog
        // or we can trigger reload here if needed.
        // Actually, the dialog should add the event to the bloc.
        // But the dialog needs access to the Bloc.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CUSTOMERS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement Search
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: BlocBuilder<CrmBloc, CrmState>(
        builder: (context, state) {
          if (state is CrmLoading) {
            return const LoadingIndicator(message: "Loading Customers...");
          } else if (state is CrmError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is CrmLoaded) {
            if (state.customers.isEmpty) {
              return const EmptyState(
                icon: Icons.people_outline,
                message: "No customers found. Add a new customer.",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.customers.length,
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return MotusCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerDetailPage(customer: customer),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.phone ?? "No phone"),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
