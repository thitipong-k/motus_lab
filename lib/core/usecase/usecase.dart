import 'package:equatable/equatable.dart';
import 'dart:async';

/// Abstract class for all UseCases.
/// [Type] is the return type of the UseCase.
/// [Params] is the parameter type passed to the UseCase.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Helper class when no parameters are needed.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
