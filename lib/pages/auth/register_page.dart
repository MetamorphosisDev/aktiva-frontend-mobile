import 'package:flutter/material.dart';
import 'package:mobile/pages/auth/login_page.dart';
import 'package:mobile/pages/auth/register_password.dart';

import '../../theme/app_theme.dart';
import '../../components/ui/app_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final nomorTeleponController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    nomorTeleponController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void lanjutRegister() {
    final nama = namaController.text.trim();
    final email = emailController.text.trim();
    final nomorTelepon = nomorTeleponController.text.trim();

    if (nama.isEmpty || email.isEmpty || nomorTelepon.isEmpty) {
      showMessage('Semua data wajib diisi');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPasswordPage(
          nama: nama,
          email: email,
          nomorTelepon: nomorTelepon,
        ),
      ),
    );
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
                      fontSize: 14,
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // HEADLINE
                  Text(
                    'Create account',
                    textAlign: TextAlign.center,
                    style: AppText.display,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Join to start reading and writing',
                    textAlign: TextAlign.center,
                    style: AppText.bodySecondary,
                  ),

                  const SizedBox(height: 32),

                  // NAMA
                  AppTextField(
                    label: 'Full name',
                    hint: 'Nama lengkap',
                    controller: namaController,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // EMAIL
                  AppTextField(
                    label: 'Email',
                    hint: 'email@example.com',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // NOMOR TELEPON
                  AppTextField(
                    label: 'Phone number',
                    hint: '08xxxxxxxxxx',
                    controller: nomorTeleponController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 28),

                  // NEXT
                  AppPrimaryButton(
                    label: 'Continue',
                    onPressed: lanjutRegister,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // LOGIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: AppText.caption),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.only(left: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: AppText.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
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