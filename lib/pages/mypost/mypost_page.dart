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

  // ================= GET POSTS =================

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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
          ),
          title: Text('Hapus Postingan', style: AppText.cardTitle),
          content: Text(
            'Yakin ingin menghapus postingan ini?',
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
              child: const Text('Batal'),
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

  // ================= POST CARD =================

  Widget postCard(dynamic post) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COVER
          AspectRatio(
            aspectRatio: 16 / 9,
            child: post['coverImage'] != null &&
                    post['coverImage'].toString().isNotEmpty
                ? Image.network(
                    post['coverImage'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return imagePlaceholder();
                    },
                  )
                : imagePlaceholder(),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY + STATUS
                Row(
                  children: [
                    if (post['category'] != null)
                      Flexible(
                        child: AppTag(
                          label: post['category'].toString().toUpperCase(),
                        ),
                      ),

                    if (post['category'] != null)
                      const SizedBox(width: AppSpacing.xs),

                    _statusTag(post['status']),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // TITLE
                Text(
                  post['title'] ?? 'Tanpa judul',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.cardTitle,
                ),

                const SizedBox(height: 8),

                // SUMMARY
                Text(
                  post['summary'] ?? post['content'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),

                const SizedBox(height: AppSpacing.md),

                // AUTHOR
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author'] ?? 'Saya',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.label,
                          ),

                          const SizedBox(height: 2),

                          Text(
                            getDate(post['createdAt']),
                            style: AppText.caption.copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const AppDivider(),

          // ACTIONS
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    editPost(post['id']);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: AppText.label,
                    shape: const RoundedRectangleBorder(),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),

              Container(width: 1, height: 22, color: AppColors.border),

              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    deletePost(post['id']);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: AppText.label,
                    shape: const RoundedRectangleBorder(),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS =================

  Widget _statusTag(dynamic status) {
    final value = status?.toString().toLowerCase() ?? '';

    if (value == 'published') {
      return const AppTag.primary(label: 'PUBLISHED');
    }

    return const AppTag.accent(label: 'DRAFT');
  }

  // ================= IMAGE =================

  Widget imagePlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: AppColors.textTertiary,
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
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 62,
        titleSpacing: AppSpacing.screen,
        title: Text('My Posts', style: AppText.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screen),
            child: Center(
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.button),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'New post',
                          style: AppText.label.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                              'Mulai tulis cerita pertamamu lewat tombol New post.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        4,
                        AppSpacing.screen,
                        AppSpacing.lg,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return postCard(posts[index]);
                      },
                    ),
            ),

      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}
