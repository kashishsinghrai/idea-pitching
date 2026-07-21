import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

/// A row tile for investor views or notifications in the activity feed.
class ActivityTile extends StatelessWidget {
  final String avatarInitial;
  final Color avatarColor;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isUnread;
  final VoidCallback? onTap;

  const ActivityTile({
    super.key,
    required this.avatarInitial,
    required this.avatarColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.base,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.surfaceLightBlue.withAlpha(100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: avatarColor.withAlpha(30),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(
                  avatarInitial,
                  style: AppTextStyles.heading3.copyWith(
                    color: avatarColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            // Time
            Text(
              timeAgo,
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
            if (isUnread) ...[
              const SizedBox(width: AppDimensions.sm),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
