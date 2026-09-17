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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AVATAR
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              getInitial(),
              style: AppText.label.copyWith(color: AppColors.primary),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        getUserName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label,
                      ),
                    ),

                    if (isMyComment)
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Hapus komentar',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.danger,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  comment['comment'] ?? '',
                  style: AppText.body.copyWith(color: AppColors.textPrimary),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  getDate(),
                  style: AppText.caption.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
