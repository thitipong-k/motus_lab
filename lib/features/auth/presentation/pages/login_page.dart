import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/shared/widgets/motus_button.dart';
import 'package:motus_lab/features/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pop(); // Go back or proceed to dashboard
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  Colors.black,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo with Glow
                    _buildGlowLogo(),
                    const SizedBox(height: 48),

                    if (state is SecondFactorRequired)
                      _build2FAChallenge(context, state.hint)
                    else ...[
                      _buildTextField("Email", _emailController, Icons.email),
                      const SizedBox(height: 16),
                      _buildTextField(
                          "Password", _passwordController, Icons.lock,
                          isPassword: true),
                      const SizedBox(height: 32),
                      if (state is AuthLoading)
                        const CircularProgressIndicator(
                            color: AppColors.primary)
                      else ...[
                        MotusButton(
                          label: "LOGIN",
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  LoginWithEmailRequested(
                                    _emailController.text,
                                    _passwordController.text,
                                  ),
                                );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildGoogleButton(context),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowLogo() {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.bolt, size: 60, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          "MOTUS LAB",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const Text(
          "SECURE CLOUD SYNC",
          style: TextStyle(
              color: AppColors.primary, fontSize: 12, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.g_mobiledata, size: 30),
      label: const Text("CONTINUE WITH GOOGLE"),
      onPressed: () => context.read<AuthBloc>().add(LoginWithGoogleRequested()),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _build2FAChallenge(BuildContext context, String hint) {
    final codeController = TextEditingController();
    return Column(
      children: [
        Text(hint, style: const TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 24),
        _buildTextField("TOTP Code", codeController, Icons.security),
        const SizedBox(height: 24),
        MotusButton(
          label: "VERIFY",
          onPressed: () => context
              .read<AuthBloc>()
              .add(Verify2FARequested(codeController.text)),
        ),
      ],
    );
  }
}
