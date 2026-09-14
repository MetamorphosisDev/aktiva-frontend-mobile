import 'package:flutter/material.dart';

import '../../components/bottom_navbar.dart';
import '../../services/api_service.dart';

import 'editpost/editpost_page.dart';
import 'addpost/addpost_page.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  List<dynamic> posts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMyPosts();
  }

  // ================= GET POSTS =================

  Future<void> getMyPosts() async {
    try {
      final data = await ApiService.getPosts();

      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      print('Gagal mengambil postingan: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= EDIT =================

  Future<void> editPost(int postId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditPostPage(postId: postId);
        },
      ),
    );

    if (result == true) {
      getMyPosts();
    }
  }

  // ================= DELETE =================

  Future<void> deletePost(int postId) async {
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

    if (confirm != true) {
      return;
    }

    try {
      await ApiService.deletePost(postId);

      getMyPosts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dihapus')),
      );
    } catch (e) {
      print('Gagal menghapus: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus postingan')),
      );
    }
  }

  // ================= POST CARD =================

  Widget postCard(dynamic post) {
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
          // IMAGE
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
                    return imagePlaceholder();
                  },
                )
              else
                imagePlaceholder(),

              // MENU
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
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20),
                              SizedBox(width: 10),
                              Text('Hapus'),
                            ],
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'edit') {
                        editPost(post['id']);
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

          // CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY
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

                // TITLE
                Text(
                  post['title'] ?? 'Tanpa judul',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                // SUMMARY
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

                // AUTHOR
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

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['author'] ?? 'Saya',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          getDate(post['createdAt']),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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

  // ================= IMAGE =================

  Widget imagePlaceholder() {
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

  String getDate(dynamic date) {
    if (date == null) {
      return '';
    }

    final result = DateTime.tryParse(date.toString());

    if (result == null) {
      return '';
    }

    return '${result.day}/${result.month}/${result.year}';
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

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
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostPage()),
              );

              if (result == true) {
                getMyPosts();
              }
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(
              child: Text(
                'Belum ada postingan',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return postCard(posts[index]);
              },
            ),

      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}
