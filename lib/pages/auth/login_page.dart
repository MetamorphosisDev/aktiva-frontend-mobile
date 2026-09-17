import 'package:flutter/material.dart';
import 'package:mobile/pages/auth/register_page.dart';
import 'package:mobile/pages/posts/posts_page.dart';

import '../../services/auth.service.dart';
import '../../theme/app_theme.dart';
import '../../components/ui/app_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email dan password wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.login(email, password);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PostsPage()),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: AppText.display,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Sign in to continue reading, writing, and saving stories.',
                    textAlign: TextAlign.center,
                    style: AppText.bodySecondary,
                  ),

                  const SizedBox(height: 36),

                  // EMAIL
                  AppTextField(
                    label: 'Email',
                    hint: 'maye@aktiva.co',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // PASSWORD
                  AppTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: passwordController,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
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

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blue,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: AppText.caption.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // LOGIN
                  AppPrimaryButton(
                    label: 'Login',
                    isLoading: isLoading,
                    onPressed: login,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // REGISTER
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('New to AKTIVA?', style: AppText.caption),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
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
                        child: const Text('Register'),
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
