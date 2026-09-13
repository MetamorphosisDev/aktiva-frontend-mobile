import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PostDetailPage extends StatefulWidget {
  final int id;

  const PostDetailPage({super.key, required this.id});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<String, dynamic>? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPostDetail();
  }

  Future<void> getPostDetail() async {
    try {
      final data = await ApiService.getPostById(widget.id);

      setState(() {
        post = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (post == null) {
      return const Scaffold(body: Center(child: Text('Post not found')));
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Post Detail',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COVER IMAGE
            if (post!['coverImage'] != null &&
                post!['coverImage'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post!['coverImage'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            // CATEGORY
            Text(
              post!['category']?.toString().toUpperCase() ?? 'POST',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // TITLE
            Text(
              post!['title'] ?? '',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // AUTHOR + DATE
            Text(
              _postMeta(),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // SUMMARY
            if (post!['summary'] != null &&
                post!['summary'].toString().isNotEmpty)
              Text(
                post!['summary'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 20),

            // CONTENT
            Text(
              post!['content'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _postMeta() {
    final author = post!['author'] ?? 'Unknown';
    final createdAt = post!['createdAt'];

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
