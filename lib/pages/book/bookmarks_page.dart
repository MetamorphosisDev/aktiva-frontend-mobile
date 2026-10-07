import 'package:flutter/material.dart';

import 'package:mobile/services/bookmarks_service.dart';
import 'package:mobile/components/bottom_navbar.dart';
import 'package:mobile/components/ui/app_ui.dart';
import 'package:mobile/pages/posts/post_detail_page.dart';
import 'package:mobile/theme/app_theme.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<dynamic> bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  Future<void> getBookmarks() async {
    try {
      final data = await BookmarkService.getBookmarks();

      setState(() {
        bookmarks = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  void openPostDetail(dynamic bookmark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(id: bookmark['postId']),
      ),
    );
  }

  Future<void> removeBookmark(int postId) async {
    try {
      await BookmarkService.deleteBookmark(postId);

      await getBookmarks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark berhasil dihapus')),
      );
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus bookmark')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Bookmarks', style: AppText.title),
      ),

      body: isLoading
          ? const AppLoading()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: getBookmarks,
              child: bookmarks.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        AppEmptyState(
                          icon: Icons.bookmark_outline,
                          title: 'No bookmarks yet',
                          message: 'Save posts you want to read later.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];

                        return _BookmarkTile(
                          bookmark: bookmark,
                          date: _formatDate(bookmark['createdAt']),
                          onTap: () {
                            openPostDetail(bookmark);
                          },
                          onRemove: () {
                            removeBookmark(bookmark['postId']);
                          },
                        );
                      },
                    ),
            ),

      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return '';

    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Standard ListTile-style bookmark row.
class _BookmarkTile extends StatelessWidget {
  final dynamic bookmark;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkTile({
    required this.bookmark,
    required this.date,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title = bookmark['title']?.toString() ?? 'No title';
    final category = bookmark['category']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: _thumbnail(bookmark['coverImage']),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.label,
        ),
        subtitle: Text(
          category.isEmpty ? date : '$category · $date',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption,
        ),
        trailing: IconButton(
          onPressed: onRemove,
          tooltip: 'Hapus bookmark',
          icon: const Icon(
            Icons.bookmark_remove_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

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
}