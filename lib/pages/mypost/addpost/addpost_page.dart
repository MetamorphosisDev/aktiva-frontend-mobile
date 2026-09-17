import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/post_service.dart';
import '../../../services/categories_service.dart';
import '../../../components/ui/app_ui.dart';
import '../../../theme/app_theme.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<dynamic> categories = [];

  bool isLoading = true;
  bool isSaving = false;

  int? selectedCategoryId;
  String selectedStatus = 'draft';

  XFile? selectedImage;

  final picker = ImagePicker();

  final titleController = TextEditingController();
  final slugController = TextEditingController();
  final summaryController = TextEditingController();
  final contentController = TextEditingController();
  final sourceController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    slugController.dispose();
    summaryController.dispose();
    contentController.dispose();
    sourceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // ================= GET CATEGORIES =================
  Future<void> loadCategories() async {
    try {
      final data = await CategoryService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      print('Gagal mengambil kategori: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil kategori: $e')));
    }
  }

  // ================= PICK IMAGE =================

  Future<void> pickImage() async {
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      print('Gagal memilih gambar: $e');
    }
  }

  // ================= CREATE POST =================

  Future<void> savePost() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori wajib dipilih')));
      return;
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul wajib diisi')));
      return;
    }

    if (contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi postingan wajib diisi')),
      );
      return;
    }

    String slug = slugController.text.trim();

    if (slug.isEmpty) {
      slug = titleController.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'-+'), '-');
    }

    try {
      setState(() {
        isSaving = true;
      });

      File? imageFile;

      if (selectedImage != null) {
        imageFile = File(selectedImage!.path);
      }

      await PostService.createPost(
        categoryId: selectedCategoryId!,
        slug: slug,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        summary: summaryController.text.trim(),
        source: sourceController.text.trim(),
        location: locationController.text.trim(),
        status: selectedStatus,
        image: imageFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dibuat')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Gagal membuat post: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat postingan: $e')));
    }
  }

  // ================= IMAGE PREVIEW =================

  Widget imagePreview() {
    if (selectedImage != null) {
      return FutureBuilder(
        future: selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            );
          }

          return imagePlaceholder();
        },
      );
    }

    return imagePlaceholder();
  }

  Widget imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.imagePlaceholder,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text('Tambah Postingan', style: AppText.title),
      ),

      body: isLoading
          ? const AppLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                8,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xl,
                children: [
                  // ================= MEDIA =================
                  AppFormSection(
                    title: 'Media',
                    description:
                        'Unggah satu gambar sampul untuk postinganmu.',
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: imagePreview(),
                      ),

                      AppSecondaryButton(
                        label: 'Pilih Gambar',
                        icon: Icons.image_outlined,
                        height: 46,
                        onPressed: pickImage,
                      ),
                    ],
                  ),

                  // ================= ARTICLE INFORMATION =================
                  AppFormSection(
                    title: 'Article information',
                    children: [
                      AppTextField(
                        label: 'Judul',
                        hint: 'Judul postingan',
                        controller: titleController,
                      ),

                      AppTextField(
                        label: 'Slug',
                        hint: 'judul-postingan',
                        controller: slugController,
                      ),

                      AppFieldShell(
                        label: 'Kategori',
                        child: DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          decoration: AppInput.decoration(),
                          items: categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category['id'],
                              child: Text(category['categoryName'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                      ),

                      AppTextField(
                        label: 'Ringkasan',
                        hint: 'Ringkasan singkat postingan',
                        controller: summaryController,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  // ================= CONTENT =================
                  AppFormSection(
                    title: 'Content',
                    children: [
                      AppTextField(
                        label: 'Isi Postingan',
                        hint: 'Tulis isi postingan di sini...',
                        controller: contentController,
                        maxLines: 10,
                      ),
                    ],
                  ),

                  // ================= SOURCE =================
                  AppFormSection(
                    title: 'Source',
                    children: [
                      AppTextField(
                        label: 'Sumber',
                        hint: 'Nama sumber',
                        controller: sourceController,
                      ),

                      AppTextField(
                        label: 'Lokasi',
                        hint: 'Kota atau daerah',
                        controller: locationController,
                      ),
                    ],
                  ),

                  // ================= PUBLISHING =================
                  AppFormSection(
                    title: 'Publishing',
                    description:
                        'Simpan sebagai draft atau terbitkan sekarang.',
                    children: [
                      AppFieldShell(
                        label: 'Status',
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          decoration: AppInput.decoration(),
                          items: const [
                            DropdownMenuItem(
                              value: 'draft',
                              child: Text('Draft'),
                            ),
                            DropdownMenuItem(
                              value: 'published',
                              child: Text('Published'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

      // ================= SAVE =================
      bottomNavigationBar: isLoading ? null : _saveBar(),
    );
  }

  Widget _saveBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            12,
            AppSpacing.screen,
            12,
          ),
          child: AppPrimaryButton(
            label: 'Tambahkan',
            isLoading: isSaving,
            onPressed: savePost,
          ),
        ),
      ),
    );
  }
}
