part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

final class SecondFactorRequired extends AuthState {
  final String hint;
  const SecondFactorRequired({this.hint = "Enter TOTP Code"});
  @override
  List<Object?> get props => [hint];
}
