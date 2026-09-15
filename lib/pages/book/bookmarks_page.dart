import 'package:flutter/material.dart';

import 'package:mobile/services/bookmarks_service.dart';
import 'package:mobile/components/bottom_navbar.dart';
import 'package:mobile/pages/posts/post_detail_page.dart';

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
          'Bookmarks',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarks.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_outline, size: 40, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Save posts you want to read later.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: getBookmarks,
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];

                  return GestureDetector(
                    onTap: () {
                      openPostDetail(bookmark);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Image.network(
                              bookmark['coverImage'] ?? '',
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 130,
                                  width: double.infinity,
                                  color: const Color(0xFFF1F1F1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookmark['category']
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
                                    bookmark['title'] ?? '',
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
                                    bookmark['summary'] ?? '',
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
                                        Icons.bookmark,
                                        size: 11,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          _formatDate(bookmark['createdAt']),
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
                            ),
                          ),
                        ],
                      ),
                    ),
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
