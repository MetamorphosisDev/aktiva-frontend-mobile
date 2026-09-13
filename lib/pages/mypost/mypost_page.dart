import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/bottom_navbar.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  List<dynamic> posts = [];
  List<dynamic> categories = [];

  bool isLoading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    getMyPosts();
  }

  // ================= GET MY POSTS =================

  Future<void> getMyPosts() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final parts = token.split('.');

      if (parts.length != 3) {
        throw Exception('Token tidak valid');
      }

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      currentUserId = payload['id'];

      final data = await ApiService.getPosts();

      final myPosts = data.where((post) {
        return post['userId'] == currentUserId;
      }).toList();

      if (!mounted) return;

      setState(() {
        posts = myPosts;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= GET CATEGORIES =================

  Future<void> getCategories() async {
    try {
      final data = await ApiService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = data;
      });
    } catch (e) {
      print(e);
    }
  }

  // ================= EDIT POST =================

  Future<void> editPost(dynamic post) async {
    await getCategories();

    if (!mounted) return;

    final titleController = TextEditingController(text: post['title'] ?? '');

    final slugController = TextEditingController(text: post['slug'] ?? '');

    final summaryController = TextEditingController(
      text: post['summary'] ?? '',
    );

    final contentController = TextEditingController(
      text: post['content'] ?? '',
    );

    final sourceController = TextEditingController(text: post['source'] ?? '');

    final locationController = TextEditingController(
      text: post['location'] ?? '',
    );

    int? selectedCategoryId = post['categoryId'];

    String selectedStatus = post['status'] ?? 'draft';

    File? selectedImage;

    final picker = ImagePicker();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Postingan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ================= COVER IMAGE =================
                      GestureDetector(
                        onTap: () async {
                          final pickedImage = await picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          if (pickedImage == null) return;

                          setDialogState(() {
                            selectedImage = File(pickedImage.path);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: selectedImage != null
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : post['coverImage'] != null &&
                                    post['coverImage'].toString().isNotEmpty
                              ? Image.network(
                                  post['coverImage'],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tap gambar untuk mengganti cover',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ================= CATEGORY =================
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Text(category['categoryName'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // ================= TITLE =================
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= SLUG =================
                      TextField(
                        controller: slugController,
                        decoration: const InputDecoration(
                          labelText: 'Slug',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= SUMMARY =================
                      TextField(
                        controller: summaryController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Ringkasan',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= CONTENT =================
                      TextField(
                        controller: contentController,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          labelText: 'Isi Postingan',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= SOURCE =================
                      TextField(
                        controller: sourceController,
                        decoration: const InputDecoration(
                          labelText: 'Sumber',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= LOCATION =================
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= STATUS =================
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
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

                          setDialogState(() {
                            selectedStatus = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ================= BUTTON =================
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (selectedCategoryId == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Kategori wajib dipilih')),
                      );
                      return;
                    }

                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Judul wajib diisi')),
                      );
                      return;
                    }

                    if (contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Isi postingan wajib diisi'),
                        ),
                      );
                      return;
                    }

                    try {
                      await ApiService.updatePost(
                        id: post['id'],
                        categoryId: selectedCategoryId!,
                        slug: slugController.text.trim(),
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        summary: summaryController.text.trim(),
                        source: sourceController.text.trim(),
                        location: locationController.text.trim(),
                        status: selectedStatus,
                        image: selectedImage,
                      );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext, true);
                    } catch (e) {
                      print(e);

                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Gagal mengubah postingan: $e')),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    slugController.dispose();
    summaryController.dispose();
    contentController.dispose();
    sourceController.dispose();
    locationController.dispose();

    if (result == true) {
      await getMyPosts();
    }
  }

  // ================= DELETE POST =================

  Future<void> deletePost(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Postingan'),
          content: const Text('Yakin ingin menghapus postingan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deletePost(id);

      await getMyPosts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dihapus')),
      );
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus postingan')),
      );
    }
  }

  // ================= POST CARD =================

  Widget _buildPostCard(dynamic post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              if (post['coverImage'] != null &&
                  post['coverImage'].toString().isNotEmpty)
                Image.network(
                  post['coverImage'],
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _imagePlaceholder();
                  },
                )
              else
                _imagePlaceholder(),

              // ================= MENU =================
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz, color: Colors.black),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 10),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        editPost(post);
                      }

                      if (value == 'delete') {
                        deletePost(post['id']);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // ================= CONTENT =================
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= CATEGORY =================
                if (post['category'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      post['category'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ================= TITLE =================
                Text(
                  post['title'] ?? 'Tanpa judul',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                // ================= SUMMARY =================
                Text(
                  post['summary'] ?? post['content'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 16),

                // ================= AUTHOR =================
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Color(0xFFF0F0F0),
                      child: Icon(
                        Icons.person_outline,
                        size: 17,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author'] ?? 'Saya',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getDate(post['createdAt']),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE PLACEHOLDER =================

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 190,
      color: const Color(0xFFEDEDED),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  // ================= DATE =================

  String _getDate(dynamic createdAt) {
    if (createdAt == null) return '';

    final date = DateTime.tryParse(createdAt.toString())?.toLocal();

    if (date == null) return '';

    return '${date.day}/${date.month}/${date.year}';
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
        title: const Text(
          'Postingan Saya',
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
          : posts.isEmpty
          ? const Center(
              child: Text(
                'Belum ada postingan',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(posts[index]);
              },
            ),

      // ================= BOTTOM NAVBAR =================
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}
