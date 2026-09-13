import 'dart:convert';

import 'package:flutter/material.dart';

import '../../components/comments/comment_section.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

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
      final data = await ApiService.getPostById(widget.id);

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
      final bookmarks = await ApiService.getBookmarks();

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
        await ApiService.deleteBookmark(widget.id);
      } else {
        await ApiService.createBookmark(widget.id);
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
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (post == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Post tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 17,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: toggleBookmark,
                    icon: isBookmarkLoading
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 21,
                            color: Colors.black,
                          ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _buildCover()),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 45),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      post!['category']?.toString().toUpperCase() ?? 'POST',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    post!['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: Color(0xFFF0F0F0),
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post!['author'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getDate(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  if (_hasText(post!['summary']))
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      child: Text(
                        post!['summary'],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  if (_hasText(post!['content']))
                    Text(
                      post!['content'],
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.9,
                        color: Color(0xFF333333),
                      ),
                    ),

                  const SizedBox(height: 32),

                  if (_hasText(post!['location']) || _hasText(post!['source']))
                    _buildInformation(),

                  ..._buildGallery(),

                  const SizedBox(height: 30),

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

  Widget _buildCover() {
    if (!_hasImage(post!['coverImage'])) {
      return Container(
        color: const Color(0xFFEDEDED),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          post!['coverImage'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFEDEDED),
              child: const Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.35),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Information',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 12),

        if (_hasText(post!['location']))
          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            post!['location'],
          ),

        if (_hasText(post!['source']))
          _buildInfoRow(Icons.link, 'Source', post!['source']),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
      const SizedBox(height: 25),

      const Text(
        'Gallery',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),

      const SizedBox(height: 14),

      ...images.map((image) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
    ];
  }

  Widget _imageError() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFFF1F1F1),
      child: const Icon(Icons.image_outlined, size: 30, color: Colors.grey),
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
