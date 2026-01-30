import 'package:motus_lab/features/crm/domain/entities/customer.dart';
import 'package:motus_lab/core/database/app_database.dart'; // For vehicle references if needed

abstract class CrmRepository {
  Future<List<Customer>> getCustomers({String? searchQuery});
  Future<int> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int id);

  // Future methods for vehicle linking could go here
  // Future<List<Vehicle>> getCustomerVehicles(int customerId);
}
