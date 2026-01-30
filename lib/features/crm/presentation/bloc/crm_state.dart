part of 'crm_bloc.dart';

abstract class CrmState extends Equatable {
  const CrmState();

  @override
  List<Object> get props => [];
}

class CrmInitial extends CrmState {}

class CrmLoading extends CrmState {}

class CrmLoaded extends CrmState {
  final List<Customer> customers;

  const CrmLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class CrmError extends CrmState {
  final String message;

  const CrmError(this.message);

  @override
  List<Object> get props => [message];
}
