import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    try {
      final data = await ApiService.getPosts();

      setState(() {
        posts = data;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return ListTile(
                  title: Text(post['title'] ?? ''),
                  subtitle: Text(post['content'] ?? ''),
                );
              },
            ),
    );
  }
}
