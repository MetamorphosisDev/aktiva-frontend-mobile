import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/post_service.dart';

import '../../components/comments/comment_section.dart';
import '../../components/ui/app_ui.dart';
import '../../services/bookmarks_service.dart';
import '../../services/token_storage.dart';
import '../../theme/app_theme.dart';

class PostDetailPage extends StatefulWidget {
  final int id;

  const PostDetailPage({super.key, required this.id});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<String, dynamic>? post;

  bool isLoading = true;
  bool isBookmarked = false;
  bool isBookmarkLoading = false;

  int? currentUserId;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    getPostDetail();
  }

  Future<void> getCurrentUser() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null) return;

      final parts = token.split('.');

      if (parts.length != 3) return;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      if (!mounted) return;

      setState(() {
        currentUserId = payload['id'];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPostDetail() async {
    try {
      final data = await PostService.getPostById(widget.id);

      if (!mounted) return;

      setState(() {
        post = data;
        isLoading = false;
      });

      checkBookmark();
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkBookmark() async {
    try {
      final bookmarks = await BookmarkService.getBookmarks();

      for (final bookmark in bookmarks) {
        if (bookmark['postId'] == widget.id) {
          if (!mounted) return;

          setState(() {
            isBookmarked = true;
          });

          break;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleBookmark() async {
    if (isBookmarkLoading) return;

    setState(() {
      isBookmarkLoading = true;
    });

    try {
      if (isBookmarked) {
        await BookmarkService.deleteBookmark(widget.id);
      } else {
        await BookmarkService.createBookmark(widget.id);
      }

      if (!mounted) return;

      setState(() {
        isBookmarked = !isBookmarked;
        isBookmarkLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isBookmarkLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengubah bookmark')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoading(),
      );
    }

    if (post == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const AppEmptyState(
          icon: Icons.article_outlined,
          title: 'Post tidak ditemukan',
          message: 'Konten ini mungkin sudah dihapus atau tidak tersedia.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: _circleAction(
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: _circleAction(
                    onPressed: toggleBookmark,
                    child: isBookmarkLoading
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 20,
                            color: isBookmarked
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _buildCover()),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                28,
                AppSpacing.screen,
                48,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY
                  AppTag.primary(
                    label: post!['category']?.toString().toUpperCase() ?? 'POST',
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // TITLE
                  Text(
                    post!['title'] ?? '',
                    style: AppText.display.copyWith(fontSize: 28, height: 1.24),
                  ),

                  const SizedBox(height: 22),

                  // METADATA
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post!['author'] ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.label,
                            ),
                            const SizedBox(height: 2),
                            Text(_getDate(), style: AppText.caption),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const AppDivider(),

                  const SizedBox(height: 24),

                  // SUMMARY
                  if (_hasText(post!['summary']))
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.primary, width: 3),
                        ),
                      ),
                      child: Text(
                        post!['summary'],
                        style: AppText.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // CONTENT
                  if (_hasText(post!['content']))
                    Text(
                      post!['content'],
                      style: AppText.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // INFORMATION
                  if (_hasText(post!['location']) || _hasText(post!['source']))
                    _buildInformation(),

                  ..._buildGallery(),

                  const SizedBox(height: AppSpacing.lg),

                  const AppDivider(),

                  const SizedBox(height: AppSpacing.lg),

                  CommentSection(
                    postId: widget.id,
                    currentUserId: currentUserId,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating action rendered on the cover image (and on the pinned bar).
  Widget _circleAction({
    IconData? icon,
    VoidCallback? onPressed,
    Widget? child,
  }) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child:
                child ??
                Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (!_hasImage(post!['coverImage'])) {
      return Container(
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

    return Image.network(
      post!['coverImage'],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.imagePlaceholder,
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle('Article details'),

        const SizedBox(height: 14),

        if (_hasText(post!['location']))
          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            post!['location'],
          ),

        if (_hasText(post!['source']))
          _buildInfoRow(Icons.link, 'Source', post!['source']),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.subtleFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.caption),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGallery() {
    final data = post!['images'];

    if (data == null) return [];

    List<dynamic> images = [];

    try {
      if (data is List) {
        images = data;
      } else if (data is String && data.isNotEmpty) {
        final result = jsonDecode(data);

        if (result is List) {
          images = result;
        }
      }
    } catch (e) {
      print(e);
    }

    if (images.isEmpty) return [];

    return [
      const AppSectionTitle('Gallery'),

      const SizedBox(height: 14),

      ...images.map((image) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Image.network(
              image.toString(),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _imageError();
              },
            ),
          ),
        );
      }),

      const SizedBox(height: AppSpacing.sm),
    ];
  }

  Widget _imageError() {
    return Container(
      width: double.infinity,
      height: 220,
      color: AppColors.imagePlaceholder,
      child: const Icon(
        Icons.image_outlined,
        size: 30,
        color: AppColors.textTertiary,
      ),
    );
  }

  bool _hasText(dynamic value) {
    return value != null && value.toString().trim().isNotEmpty;
  }

  bool _hasImage(dynamic value) {
    return _hasText(value);
  }

  String _getDate() {
    final createdAt = post!['createdAt'];
    if (createdAt == null) return '';
    final date = DateTime.tryParse(createdAt.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
