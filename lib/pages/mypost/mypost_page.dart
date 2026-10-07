import 'package:flutter/material.dart';
import 'package:mobile/services/post_service.dart';

import '../../components/bottom_navbar.dart';
import '../../components/ui/app_ui.dart';
import '../../theme/app_theme.dart';

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

  // GET POSTS

  Future<void> getMyPosts() async {
    try {
      final data = await PostService.getPosts();

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

  // EDIT

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

  // DELETE

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
      await PostService.deletePost(postId);

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

  // STATUS

  Widget _statusTag(dynamic status) {
    final value = status?.toString().toLowerCase() ?? '';

    if (value == 'published') {
      return const AppTag.primary(label: 'PUBLISHED');
    }

    return AppTag(label: 'DRAFT');
  }

  // IMAGE

  Widget _thumbnail(dynamic value) {
    final image = value?.toString() ?? '';

    if (image.isEmpty) {
      return _thumbnailPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.image),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _thumbnailPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.imagePlaceholder,
      child: const Icon(
        Icons.image_outlined,
        size: 20,
        color: AppColors.textTertiary,
      ),
    );
  }

  // DATE

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

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('My Posts', style: AppText.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPostPage(),
                ),
              );

              if (result == true) {
                getMyPosts();
              }
            },
          ),
        ],
      ),

      body: isLoading
          ? const AppLoading()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: getMyPosts,
              child: posts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        AppEmptyState(
                          icon: Icons.article_outlined,
                          title: 'Belum ada postingan',
                          message:
                              'Mulai tulis cerita pertamamu lewat tombol tambah.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: _thumbnail(post['coverImage']),
                                title: Text(
                                  post['title'] ?? 'Tanpa judul',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.label,
                                ),
                                subtitle: Text(
                                  '${post['category'] ?? ''} · ${getDate(post['createdAt'])}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.caption,
                                ),
                                trailing: _statusTag(post['status']),
                                onTap: () {
                                  editPost(post['id']);
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                              ),
                              const Divider(height: 1),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () {
                                        editPost(post['id']);
                                      },
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 16),
                                      label: const Text('Edit'),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.textPrimary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: AppColors.border,
                                  ),
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () {
                                        deletePost(post['id']);
                                      },
                                      icon: const Icon(Icons.delete_outline,
                                          size: 16),
                                      label: const Text('Hapus'),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.textSecondary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}