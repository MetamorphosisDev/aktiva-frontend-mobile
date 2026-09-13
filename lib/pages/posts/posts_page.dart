import 'package:flutter/material.dart';

import '../../services/api_service.dart';

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

  final List<String> categories = ['All', 'Teknologi', 'Culture', 'Work'];

  String selectedCategory = 'All';

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

      setState(() {
        posts = data;
        filteredPosts = data;
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

    for (var post in posts) {
      String title = post['title'] ?? '';
      String summary = post['summary'] ?? '';
      String category = post['category'] ?? '';

      bool searchMatch =
          title.toLowerCase().contains(search) ||
          summary.toLowerCase().contains(search) ||
          category.toLowerCase().contains(search);

      bool categoryMatch =
          selectedCategory == 'All' ||
          category.toLowerCase() == selectedCategory.toLowerCase();

      if (searchMatch && categoryMatch) {
        result.add(post);
      }
    }

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
                                mainAxisSpacing: 22,
                                childAspectRatio: 0.68,
                              ),
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];

                            return Column(
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
                                                color: const Color(0xFFEAEAEA),
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                  (post['category'] ?? 'POST')
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // TITLE
                                Text(
                                  post['title'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 5),

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

                                // AUTHOR + DATE
                                Text(
                                  _postMeta(post),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _postMeta(dynamic post) {
    final author = post['author'] ?? post['authorName'];
    final date = post['createdAt'] ?? post['date'];

    if (author != null && date != null) {
      return '$author · $date';
    }

    if (author != null) {
      return author.toString();
    }

    if (date != null) {
      return date.toString();
    }

    return '';
  }
}
