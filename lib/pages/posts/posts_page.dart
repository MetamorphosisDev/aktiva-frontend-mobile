import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../components/bottom_navbar.dart';
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
      final data = await ApiService.getPosts();

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
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: const Text(
          'All posts',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ideas worth your time.',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Independent stories for considered living.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      // SEARCH
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0DE)),
                        ),
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(fontSize: 11),
                          decoration: const InputDecoration(
                            hintText: 'Search posts, people, topics',
                            hintStyle: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 16,
                              color: Colors.black54,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // CATEGORY
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 6);
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFFD8D8D6),
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // POSTS
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: getPosts,
                    child: filteredPosts.isEmpty
                        ? const Center(
                            child: Text(
                              'No posts found',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = filteredPosts[index];

                              return GestureDetector(
                                onTap: () {
                                  openPostDetail(post);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // IMAGE
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child: Image.network(
                                          post['coverImage'] ?? '',
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 130,
                                                  width: double.infinity,
                                                  color: const Color(
                                                    0xFFF1F1F1,
                                                  ),
                                                  child: const Icon(
                                                    Icons.image_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),

                                      // CONTENT
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['category']
                                                        ?.toString()
                                                        .toUpperCase() ??
                                                    'POST',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Text(
                                                post['title'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  height: 1.2,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Text(
                                                post['summary'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.grey,
                                                  height: 1.3,
                                                ),
                                              ),

                                              const Spacer(),

                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person_outline,
                                                    size: 11,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Expanded(
                                                    child: Text(
                                                      _postMeta(post),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.grey,
                                                      ),
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
