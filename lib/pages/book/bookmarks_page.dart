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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 58,
        titleSpacing: AppSpacing.screen,
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
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        4,
                        AppSpacing.screen,
                        AppSpacing.lg,
                      ),
                      itemCount: bookmarks.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];

                        return _BookmarkRow(
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

/// Saved story row: thumbnail, category, title, metadata and remove action.
class _BookmarkRow extends StatelessWidget {
  final dynamic bookmark;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkRow({
    required this.bookmark,
    required this.date,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final category = bookmark['category']?.toString() ?? 'POST';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // THUMBNAIL
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.image),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: _thumbnail(bookmark['coverImage']),
                  ),
                ),

                const SizedBox(width: 14),

                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.eyebrow.copyWith(fontSize: 10),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        bookmark['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.cardTitle.copyWith(fontSize: 14.5),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption.copyWith(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // REMOVE
                const SizedBox(width: 4),

                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Hapus bookmark',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: const Icon(
                    Icons.bookmark_remove_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(dynamic value) {
    final image = value?.toString() ?? '';

    if (image.isEmpty) {
      return _thumbnailPlaceholder();
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _thumbnailPlaceholder();
      },
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 22,
        color: AppColors.textTertiary,
      ),
    );
  }
}
