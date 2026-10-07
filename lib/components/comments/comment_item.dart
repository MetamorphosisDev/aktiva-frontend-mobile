import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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

  String getUserName() {
    final name = comment['userName']?.toString().trim() ?? '';
    return name.isEmpty ? 'Unknown' : name;
  }

  String getInitial() {
    final name = getUserName();
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.subtleFill,
        foregroundColor: AppColors.textPrimary,
        child: Text(
          getInitial(),
          style: AppText.label,
        ),
      ),
      title: Text(
        getUserName(),
        style: AppText.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            comment['comment'] ?? '',
            style: AppText.body,
          ),
          const SizedBox(height: 4),
          Text(
            getDate(),
            style: AppText.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
      trailing: isMyComment
          ? IconButton(
              onPressed: onDelete,
              tooltip: 'Hapus komentar',
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}