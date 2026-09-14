import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/api_service.dart';

class EditPostPage extends StatefulWidget {
  final int postId;

  const EditPostPage({super.key, required this.postId});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  // ================= DATA =================

  Map<String, dynamic>? post;
  List<dynamic> categories = [];

  // ================= STATUS =================

  bool isLoading = true;
  bool isSaving = false;

  // ================= FORM =================

  int? selectedCategoryId;
  String selectedStatus = 'draft';

  XFile? selectedImage;

  final picker = ImagePicker();

  // ================= CONTROLLER =================

  final titleController = TextEditingController();
  final slugController = TextEditingController();
  final summaryController = TextEditingController();
  final contentController = TextEditingController();
  final sourceController = TextEditingController();
  final locationController = TextEditingController();

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    loadData();
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

  // ================= LOAD DATA =================

  Future<void> loadData() async {
    try {
      // GET POST
      final postData = await ApiService.getPostById(widget.postId);

      // GET CATEGORY
      final categoryData = await ApiService.getCategories();

      // MASUKKAN DATA KE FORM
      titleController.text = postData['title'] ?? '';
      slugController.text = postData['slug'] ?? '';
      summaryController.text = postData['summary'] ?? '';
      contentController.text = postData['content'] ?? '';
      sourceController.text = postData['source'] ?? '';
      locationController.text = postData['location'] ?? '';

      if (!mounted) return;

      setState(() {
        post = postData;
        categories = categoryData;

        selectedCategoryId = postData['categoryId'];
        selectedStatus = postData['status'] ?? 'draft';

        isLoading = false;
      });
    } catch (e) {
      print('Gagal mengambil data: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil postingan')),
      );
    }
  }

  // ================= PICK IMAGE =================

  Future<void> pickImage() async {
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      print('Gagal memilih gambar: $e');
    }
  }

  // ================= UPDATE =================

  Future<void> savePost() async {
    // VALIDASI KATEGORI
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori wajib dipilih')));
      return;
    }

    // VALIDASI JUDUL
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul wajib diisi')));
      return;
    }

    // VALIDASI ISI
    if (contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi postingan wajib diisi')),
      );
      return;
    }

    // SLUG
    String slug = slugController.text.trim();

    // Kalau slug kosong, buat dari judul
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

      // XFile -> File
      File? imageFile;

      if (selectedImage != null) {
        imageFile = File(selectedImage!.path);
      }

      // UPDATE POST
      await ApiService.updatePost(
        id: widget.postId,
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
        const SnackBar(content: Text('Postingan berhasil diubah')),
      );

      // BALIK KE MY POST
      Navigator.pop(context, true);
    } catch (e) {
      print('Gagal update: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengubah postingan')));
    }
  }

  // ================= IMAGE PREVIEW =================

  Widget imagePreview() {
    // GAMBAR BARU
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

    // GAMBAR LAMA
    final image = post?['coverImage'];

    if (image != null && image.toString().isNotEmpty) {
      return Image.network(
        image,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return imagePlaceholder();
        },
      );
    }

    return imagePlaceholder();
  }

  // ================= IMAGE PLACEHOLDER =================

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

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Edit Postingan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ================= BODY =================
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= COVER =================
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
                      label: const Text('Ganti Gambar'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= KATEGORI =================
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

                  // ================= JUDUL =================
                  TextField(
                    controller: titleController,
                    decoration: inputDecoration('Judul'),
                  ),

                  const SizedBox(height: 14),

                  // ================= SLUG =================
                  TextField(
                    controller: slugController,
                    decoration: inputDecoration('Slug'),
                  ),

                  const SizedBox(height: 14),

                  // ================= RINGKASAN =================
                  TextField(
                    controller: summaryController,
                    maxLines: 3,
                    decoration: inputDecoration('Ringkasan'),
                  ),

                  const SizedBox(height: 14),

                  // ================= ISI =================
                  TextField(
                    controller: contentController,
                    maxLines: 8,
                    decoration: inputDecoration('Isi Postingan'),
                  ),

                  const SizedBox(height: 14),

                  // ================= SUMBER =================
                  TextField(
                    controller: sourceController,
                    decoration: inputDecoration('Sumber'),
                  ),

                  const SizedBox(height: 14),

                  // ================= LOKASI =================
                  TextField(
                    controller: locationController,
                    decoration: inputDecoration('Lokasi'),
                  ),

                  const SizedBox(height: 14),

                  // ================= STATUS =================
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
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // ================= SAVE =================
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
                              'Simpan Perubahan',
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
