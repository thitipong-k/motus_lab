import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motus_lab/features/crm/domain/entities/customer.dart';
import 'package:motus_lab/features/crm/domain/repositories/crm_repository.dart';

part 'crm_event.dart';
part 'crm_state.dart';

class CrmBloc extends Bloc<CrmEvent, CrmState> {
  final CrmRepository _repository;

  CrmBloc(this._repository) : super(CrmInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event, Emitter<CrmState> emit) async {
    emit(CrmLoading());
    try {
      final customers =
          await _repository.getCustomers(searchQuery: event.query);
      emit(CrmLoaded(customers));
    } catch (e) {
      emit(CrmError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(AddCustomer event, Emitter<CrmState> emit) async {
    try {
      await _repository.addCustomer(event.customer);
      add(const LoadCustomers()); // Reload after add
    } catch (e) {
      emit(CrmError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<CrmState> emit) async {
    try {
      await _repository.updateCustomer(event.customer);
      add(const LoadCustomers()); // Reload after update
    } catch (e) {
      emit(CrmError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<CrmState> emit) async {
    try {
      await _repository.deleteCustomer(event.id);
      add(const LoadCustomers()); // Reload after delete
    } catch (e) {
      emit(CrmError(e.toString()));
    }
  }
}
