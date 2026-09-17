import 'package:flutter/material.dart';
import 'package:mobile/pages/auth/login_page.dart';

import '../../services/auth.service.dart';
import '../../theme/app_theme.dart';
import '../../components/ui/app_ui.dart';

class RegisterPasswordPage extends StatefulWidget {
  final String nama;
  final String email;
  final String nomorTelepon;

  const RegisterPasswordPage({
    super.key,
    required this.nama,
    required this.email,
    required this.nomorTelepon,
  });

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> register() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Semua data wajib diisi');
      return;
    }

    if (password.length < 8) {
      showMessage('Password minimal 8 karakter');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Konfirmasi password tidak cocok');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.register(
        widget.nama,
        widget.email,
        password,
        widget.nomorTelepon,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BRAND
                  Text(
                    'AKTIVA',
                    textAlign: TextAlign.center,
                    style: AppText.label.copyWith(
                      fontSize: 15,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // HEADLINE
                  Text(
                    'Create password',
                    textAlign: TextAlign.center,
                    style: AppText.display,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Create a strong password to keep your account secure.',
                    textAlign: TextAlign.center,
                    style: AppText.bodySecondary,
                  ),

                  const SizedBox(height: 36),

                  // PASSWORD
                  AppTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: passwordController,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // CONFIRM PASSWORD
                  AppTextField(
                    label: 'Confirm password',
                    hint: '••••••••',
                    controller: confirmPasswordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!isLoading) {
                        register();
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // REGISTER
                  AppPrimaryButton(
                    label: 'Create account',
                    isLoading: isLoading,
                    onPressed: register,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // BACK TO LOGIN
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Already have an account?', style: AppText.caption),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.only(left: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: AppText.caption.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
