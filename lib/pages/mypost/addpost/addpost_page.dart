import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/api_service.dart';

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
      final data = await ApiService.getCategories();

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

      await ApiService.createPost(
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
      color: const Color(0xFFEDEDED),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 45, color: Colors.grey),
      ),
    );
  }

  // ================= INPUT =================

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Tambah Postingan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cover',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imagePreview(),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Pilih Gambar'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CATEGORY
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: inputDecoration('Kategori'),
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

                  const SizedBox(height: 14),

                  // TITLE
                  TextField(
                    controller: titleController,
                    decoration: inputDecoration('Judul'),
                  ),

                  const SizedBox(height: 14),

                  // SLUG
                  TextField(
                    controller: slugController,
                    decoration: inputDecoration('Slug'),
                  ),

                  const SizedBox(height: 14),

                  // SUMMARY
                  TextField(
                    controller: summaryController,
                    maxLines: 3,
                    decoration: inputDecoration('Ringkasan'),
                  ),

                  const SizedBox(height: 14),

                  // CONTENT
                  TextField(
                    controller: contentController,
                    maxLines: 8,
                    decoration: inputDecoration('Isi Postingan'),
                  ),

                  const SizedBox(height: 14),

                  // SOURCE
                  TextField(
                    controller: sourceController,
                    decoration: inputDecoration('Sumber'),
                  ),

                  const SizedBox(height: 14),

                  // LOCATION
                  TextField(
                    controller: locationController,
                    decoration: inputDecoration('Lokasi'),
                  ),

                  const SizedBox(height: 14),

                  // STATUS
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: inputDecoration('Status'),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
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

                  const SizedBox(height: 25),

                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : savePost,
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Tambahkan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
