import 'package:flutter/material.dart';

import '../../services/api_service.dart';

import '../../components/bottom_navbar.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  // Semua data dari API
  List<dynamic> posts = [];

  // Data yang sudah di-search / filter
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

      final publishedposts = data
          .where((post) => post['status'] == 'published')
          .toList();

      setState(() {
        posts = publishedposts;
        filteredPosts = publishedposts;
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
    String search = searchController.text.toLowerCase();

    List<dynamic> result = [];

    // Cek semua post satu per satu
    for (var post in posts) {
      String title = post['title'] ?? '';
      String summary = post['summary'] ?? '';
      String category = post['category'] ?? '';

      // SEARCH
      bool searchMatch =
          title.toLowerCase().contains(search) ||
          summary.toLowerCase().contains(search) ||
          category.toLowerCase().contains(search);

      // CATEGORY
      bool categoryMatch =
          selectedCategory == 'Semua' ||
          category.toLowerCase() == selectedCategory.toLowerCase();

      if (searchMatch && categoryMatch) {
        result.add(post);
      }
    }

    // Tampilkan hasil filter
    setState(() {
      filteredPosts = result;
    });
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

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // IMAGE
                                    if (post['coverImage'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          post['coverImage'],
                                          width: double.infinity,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 110,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFEAEAEA,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.image_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),

                                    const SizedBox(height: 7),

                                    // CATEGORY
                                    Text(
                                      (post['category'] ?? 'POST').toString(),
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                        letterSpacing: 0.2,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // TITLE
                                    SizedBox(
                                      height: 32,
                                      child: Text(
                                        post['title'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // SUMMARY
                                    Text(
                                      post['summary'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        color: Colors.grey,
                                        height: 1.3,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    // AUTHOR AND DATE
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
                                            overflow: TextOverflow.ellipsis,
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
    final date = DateTime.parse(post['createdAt'].toString());
    return '$author · ${date.day}/${date.month}/${date.year}';
  }
}
