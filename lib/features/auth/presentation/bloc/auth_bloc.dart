import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motus_lab/core/services/security/auth_service.dart';
import 'package:motus_lab/core/utils/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc สำหรับจัดการ Authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
    on<LoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<Verify2FARequested>(_onVerify2FARequested);
  }

  // ตรวจสอบสถานะการเข้าสู่ระบบปัจจุบัน (AuthCheckRequested)
  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      Logger.error("AuthBloc: AuthCheck failed", e);
      emit(AuthFailure("Firebase not initialized: $e"));
    }
  }

  Future<void> _onLoginWithGoogleRequested(
      LoginWithGoogleRequested event, Emitter<AuthState> emit) async {
    Logger.info("AuthBloc: Google Login Requested");
    emit(AuthLoading());
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && credential.user != null) {
        emit(Authenticated(credential.user!));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      Logger.error("AuthBloc: Google Login failed", e);
      emit(AuthFailure(e.toString()));
    }
  }

  // เข้าสู่ระบบด้วย Email และ Password (LoginWithEmailRequested)
  Future<void> _onLoginWithEmailRequested(
      LoginWithEmailRequested event, Emitter<AuthState> emit) async {
    Logger.info("AuthBloc: Email Login Requested for ${event.email}");
    emit(AuthLoading());
    try {
      final credential =
          await _authService.signInWithEmail(event.email, event.password);
      if (credential != null && credential.user != null) {
        emit(Authenticated(credential.user!));
      } else {
        emit(const AuthFailure("Login Failed"));
      }
    } catch (e) {
      Logger.error("AuthBloc: Email Login failed", e);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    Logger.info("AuthBloc: Logout Requested");
    await _authService.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onVerify2FARequested(
      Verify2FARequested event, Emitter<AuthState> emit) async {
    Logger.info("AuthBloc: 2FA Verification Requested");
    emit(AuthLoading());
    // Mocking success for architecture demo
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const AuthFailure("2FA Verification Failed"));
    }
  }
}
