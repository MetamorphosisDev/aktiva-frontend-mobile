import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'comment_item.dart';

class CommentSection extends StatefulWidget {
  final int postId;
  final int? currentUserId;

  const CommentSection({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<dynamic> comments = [];
  bool isLoading = true;

  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getComments();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // GET COMMENTS
  Future<void> getComments() async {
    try {
      final data = await ApiService.getComments(widget.postId);

      setState(() {
        comments = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  // ADD COMMENT
  Future<void> addComment() async {
    final comment = commentController.text.trim();

    if (comment.isEmpty) return;

    try {
      await ApiService.createComment(widget.postId, comment);

      commentController.clear();

      await getComments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil ditambahkan')),
      );
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan komentar')),
      );
    }
  }

  // DELETE COMMENT
  Future<void> deleteComment(int commentId) async {
    try {
      await ApiService.deleteComment(commentId);

      await getComments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil dihapus')),
      );
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus komentar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // INPUT COMMENT
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(onPressed: addComment, icon: const Icon(Icons.send)),
          ],
        ),

        const SizedBox(height: 20),

        // LIST COMMENT
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          const Text('Belum ada komentar', style: TextStyle(color: Colors.grey))
        else
          Column(
            children: comments.map((comment) {
              return CommentItem(
                comment: comment,
                isMyComment: widget.currentUserId == comment['userId'],
                onDelete: () {
                  deleteComment(comment['id']);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
