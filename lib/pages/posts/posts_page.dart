import 'package:flutter/material.dart';

import '../../services/post_service.dart';
import '../../components/bottom_navbar.dart';
import '../../components/ui/app_ui.dart';
import '../../theme/app_theme.dart';
import './post_detail_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<dynamic> posts = [];
  List<dynamic> filteredPosts = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'Semua',
    'Teknologi',
    'Pertanian',
    'Pendidikan',
    'Kesehatan',
    'Bisnis',
  ];

  String selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();

    getPosts();

    searchController.addListener(() {
      filterPosts();
    });
  }

  Future<void> getPosts() async {
    try {
      final data = await PostService.getPosts();

      final publishedPosts = data
          .where((post) => post['status'] == 'published')
          .toList();

      setState(() {
        posts = publishedPosts;
        filteredPosts = publishedPosts;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPosts() {
    final search = searchController.text.toLowerCase();

    final result = posts.where((post) {
      final title = post['title']?.toString().toLowerCase() ?? '';
      final summary = post['summary']?.toString().toLowerCase() ?? '';
      final category = post['category']?.toString().toLowerCase() ?? '';

      final searchMatch =
          title.contains(search) ||
          summary.contains(search) ||
          category.contains(search);

      final categoryMatch =
          selectedCategory == 'Semua' ||
          category == selectedCategory.toLowerCase();

      return searchMatch && categoryMatch;
    }).toList();

    setState(() {
      filteredPosts = result;
    });
  }

  void openPostDetail(dynamic post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailPage(id: post['id'])),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        title: Text(
          'AKTIVA',
          style: AppText.label.copyWith(
            fontSize: 14,
            letterSpacing: 3.5,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      body: isLoading
          ? const AppLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    4,
                    AppSpacing.screen,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ideas worth your time.',
                        style: AppText.display,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        'Independent stories for considered living.',
                        style: AppText.bodySecondary,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // SEARCH
                      TextField(
                        controller: searchController,
                        cursorColor: AppColors.primary,
                        style: AppText.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: AppInput.decoration(
                          hint: 'Search posts, people, topics',
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // CATEGORY
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 8);
                          },
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = selectedCategory == category;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });

                                filterPosts();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.subtleFill,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: AppText.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),

                // POSTS
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: getPosts,
                    child: filteredPosts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              AppEmptyState(
                                icon: Icons.search_off_outlined,
                                title: 'No posts found',
                                message:
                                    'Try another keyword or pick a different category.',
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              // Card height follows the cover ratio so cards never
                              // overflow on any screen width.
                              const spacing = 14.0;
                              const contentHeight = 176.0;
                              final cardWidth =
                                  (constraints.maxWidth -
                                      (AppSpacing.screen * 2) -
                                      spacing) /
                                  2;
                              final extent =
                                  (cardWidth * 10 / 16) + contentHeight;

                              return GridView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.screen,
                                  4,
                                  AppSpacing.screen,
                                  AppSpacing.lg,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: 18,
                                      mainAxisExtent: extent,
                                    ),
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  final post = filteredPosts[index];

                                  return _PostCard(
                                    post: post,
                                    meta: _postMeta(post),
                                    onTap: () {
                                      openPostDetail(post);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),

      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }

  String _postMeta(dynamic post) {
    final author = post['author'] ?? 'Unknown';
    final createdAt = post['createdAt'];

    if (createdAt == null) {
      return author.toString();
    }

    final date = DateTime.tryParse(createdAt.toString());

    if (date == null) {
      return author.toString();
    }

    return '$author · ${date.day}/${date.month}/${date.year}';
  }
}

/// Editorial post card: cover first, then category, title, summary, metadata.
class _PostCard extends StatelessWidget {
  final dynamic post;
  final String meta;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = post['category']?.toString() ?? 'POST';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COVER
              AspectRatio(
                aspectRatio: 16 / 10,
                child: _coverImage(post['coverImage']),
              ),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                        post['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(
                          fontSize: 14.5,
                          height: 1.32,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Flexible(
                        child: Text(
                          post['summary'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption.copyWith(fontSize: 12),
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meta,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverImage(dynamic value) {
    final image = value?.toString() ?? '';

    if (image.isEmpty) {
      return _coverPlaceholder();
    }

    return Image.network(
      image,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _coverPlaceholder();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _coverPlaceholder();
      },
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 26,
        color: AppColors.textTertiary,
      ),
    );
  }
}
