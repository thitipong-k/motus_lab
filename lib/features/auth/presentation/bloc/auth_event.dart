part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AuthCheckRequested extends AuthEvent {}

final class LoginWithGoogleRequested extends AuthEvent {}

final class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginWithEmailRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

final class LogoutRequested extends AuthEvent {}

final class Verify2FARequested extends AuthEvent {
  final String code;
  const Verify2FARequested(this.code);
  @override
  List<Object?> get props => [code];
}
