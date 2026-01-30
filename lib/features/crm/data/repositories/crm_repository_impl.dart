import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/features/crm/domain/entities/customer.dart';
import 'package:motus_lab/features/crm/domain/repositories/crm_repository.dart';
import 'package:drift/drift.dart';

class CrmRepositoryImpl implements CrmRepository {
  final AppDatabase db;

  CrmRepositoryImpl(this.db);

  @override
  Future<List<Customer>> getCustomers({String? searchQuery}) async {
    final query = db.select(db.customers);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(
          (t) => t.name.contains(searchQuery) | t.phone.contains(searchQuery));
    }

    final results = await query.get();

    return results.map(_mapToEntity).toList();
  }

  @override
  Future<int> addCustomer(Customer customer) async {
    final companion = CustomersCompanion(
      name: Value(customer.name),
      phone: Value(customer.phone),
      email: Value(customer.email),
      address: Value(customer.address),
      createdAt: Value(customer.createdAt),
    );
    return await db.into(db.customers).insert(companion);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final companion = CustomersCompanion(
      id: Value(customer.id),
      name: Value(customer.name),
      phone: Value(customer.phone),
      email: Value(customer.email),
      address: Value(customer.address),
      createdAt: Value(customer.createdAt),
    );
    await db.update(db.customers).replace(companion);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await (db.delete(db.customers)..where((t) => t.id.equals(id))).go();
  }

  Customer _mapToEntity(CustomerData data) {
    return Customer(
      id: data.id,
      name: data.name,
      phone: data.phone,
      email: data.email,
      address: data.address,
      createdAt: data.createdAt,
    );
  }
}
