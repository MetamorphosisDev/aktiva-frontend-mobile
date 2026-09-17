import 'package:flutter/material.dart';

import '../../components/bottom_navbar.dart';
import '../../components/ui/app_ui.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // GET PROFILE
  Future<void> loadProfile() async {
    try {
      final data = await ProfileService.getProfile();

      if (!mounted) return;

      setState(() {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengambil profile')));
    }
  }

  // UPDATE PROFILE
  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name dan email wajib diisi')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ProfileService.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profile')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
          ),
          title: Text('Delete Account', style: AppText.cardTitle),
          content: Text(
            'Are you sure you want to delete your account?',
            style: AppText.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                textStyle: AppText.label,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                textStyle: AppText.label,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ProfileService.deleteProfile();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus akun')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 58,
        titleSpacing: AppSpacing.screen,
        title: Text('Profile', style: AppText.title),
      ),

      body: isLoading
          ? const AppLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                4,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.xl,
                children: [
                  // IDENTITY
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          nameController.text.isEmpty
                              ? 'Tanpa nama'
                              : nameController.text,
                          textAlign: TextAlign.center,
                          style: AppText.cardTitle.copyWith(fontSize: 18),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          emailController.text,
                          textAlign: TextAlign.center,
                          style: AppText.caption,
                        ),

                        if (phoneController.text.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            phoneController.text,
                            textAlign: TextAlign.center,
                            style: AppText.caption,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ACCOUNT DETAILS
                  AppFormSection(
                    title: 'Account details',
                    description: 'Perbarui informasi akunmu di sini.',
                    children: [
                      AppTextField(
                        label: 'Name',
                        hint: 'Enter your name',
                        controller: nameController,
                      ),

                      AppTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      AppTextField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  // ACTIONS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.sm,
                    children: [
                      AppPrimaryButton(
                        label: 'Save Changes',
                        isLoading: isSaving,
                        onPressed: saveProfile,
                      ),

                      AppSecondaryButton.danger(
                        label: 'Delete Account',
                        icon: Icons.delete_outline,
                        onPressed: deleteAccount,
                      ),
                    ],
                  ),
                ],
              ),
            ),

      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }
}
