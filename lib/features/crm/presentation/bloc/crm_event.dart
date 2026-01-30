part of 'crm_bloc.dart';

abstract class CrmEvent extends Equatable {
  const CrmEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomers extends CrmEvent {
  final String? query;
  const LoadCustomers({this.query});
}

class AddCustomer extends CrmEvent {
  final Customer customer;
  const AddCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class UpdateCustomer extends CrmEvent {
  final Customer customer;
  const UpdateCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class DeleteCustomer extends CrmEvent {
  final int id;
  const DeleteCustomer(this.id);

  @override
  List<Object> get props => [id];
}
