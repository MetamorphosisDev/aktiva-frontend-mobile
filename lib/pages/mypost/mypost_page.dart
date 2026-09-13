import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/token_storage.dart';

import '../../components/bottom_navbar.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  List<dynamic> posts = [];
  bool isLoading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    getMyPosts();
  }

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

  Future<void> editPost(dynamic post) async {
    final titleController = TextEditingController(text: post['title'] ?? '');

    final contentController = TextEditingController(
      text: post['content'] ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Postingan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Isi postingan'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.updatePost(
                    post['id'],
                    titleController.text.trim(),
                    contentController.text.trim(),
                  );

                  if (!context.mounted) return;

                  Navigator.pop(context, true);
                } catch (e) {
                  print(e);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal mengubah postingan')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    contentController.dispose();

    if (result == true) {
      await getMyPosts();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postingan Saya')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(child: Text('Belum ada postingan'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(post['title'] ?? 'Tanpa judul'),
                    subtitle: Text(
                      post['summary'] ?? post['content'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 8),
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
                );
              },
            ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}
