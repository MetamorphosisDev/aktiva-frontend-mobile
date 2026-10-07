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
    // Simple responsive: use screen width from MediaQuery
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('AKTIVA', style: AppText.title),
      ),

      body: isLoading
          ? const AppLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Posts', style: AppText.headline),
                      const SizedBox(height: 8),
                      Text('Browse all posts', style: AppText.bodySecondary),
                      const SizedBox(height: 16),

                      // SEARCH
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search posts...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.field,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.field,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CATEGORY CHIPS
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: AppText.caption.copyWith(
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
                    ],
                  ),
                ),

                // POSTS GRID
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
                              // RESPONSIVE AJE
                              int crossAxisCount = 2;
                              if (screenWidth > 1200) {
                                crossAxisCount = 5;
                              } else if (screenWidth > 600) {
                                crossAxisCount = 3;
                              }

                              return GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  final post = filteredPosts[index];
                                  return _buildGridTile(post);
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

  // GRID TILE

  Widget _buildGridTile(dynamic post) {
    final title = post['title']?.toString() ?? '';
    final summary = post['summary']?.toString() ?? '';
    final category = post['category']?.toString() ?? '';

    return GridTile(
      child: InkWell(
        onTap: () => openPostDetail(post),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              Expanded(child: _coverImage(post['coverImage'])),
              // Text content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: AppText.eyebrow.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: AppText.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      style: AppText.caption.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
        size: 32,
        color: AppColors.textTertiary,
      ),
    );
  }
}
