import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  final dynamic comment;
  final bool isMyComment;
  final VoidCallback onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.isMyComment,
    required this.onDelete,
  });

  String getDate() {
    final createdAt = comment['createdAt'];

    if (createdAt == null) return '';

    final date = DateTime.tryParse(createdAt.toString())?.toLocal();

    if (date == null) return '';

    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['userName'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(comment['comment'] ?? ''),

                const SizedBox(height: 4),

                Text(
                  getDate(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          if (isMyComment)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}
