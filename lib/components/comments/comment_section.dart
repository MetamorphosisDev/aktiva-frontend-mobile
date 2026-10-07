import 'package:flutter/material.dart';

import '../../services/comment_service.dart';
import '../../theme/app_theme.dart';
import '../ui/app_ui.dart';
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

  Future<void> getComments() async {
    try {
      final data = await CommentService.getComments(widget.postId);

      if (!mounted) return;

      setState(() {
        comments = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addComment() async {
    final comment = commentController.text.trim();

    if (comment.isEmpty) return;
    try {
      await CommentService.createComment(widget.postId, comment);
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

  Future<void> deleteComment(int commentId) async {
    try {
      await CommentService.deleteComment(commentId);

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
        // HEADING
        Row(
          children: [
            Text(
              'Comments',
              style: AppText.cardTitle.copyWith(fontSize: 18),
            ),
            if (!isLoading && comments.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              AppTag(label: '${comments.length}'),
            ],
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // COMPOSER
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                style: AppText.body,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton(
              onPressed: addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: const Icon(Icons.send, size: 18),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: AppLoading(),
          )
        else if (comments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text('Belum ada komentar', style: AppText.label),
                const SizedBox(height: 4),
                Text(
                  'Jadilah yang pertama membagikan pendapat.',
                  textAlign: TextAlign.center,
                  style: AppText.caption,
                ),
              ],
            ),
          )
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
