import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';

/// Banner card showing the current pitch status with an "Active" badge.
class PitchStatusBanner extends StatelessWidget {
  final PitchStatus status;
  final VoidCallback? onTap;

  const PitchStatusBanner({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withAlpha(40),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        status.status,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppColors.textOnDark.withAlpha(150),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Your Pitch Status is ${status.status}',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              status.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnDark.withAlpha(180),
              ),
            ),
            const SizedBox(height: AppDimensions.base),
            // ── Progress bar ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Funding Progress',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDark.withAlpha(160),
                      ),
                    ),
                    Text(
                      '\$${(status.fundingRaised / 1000000).toStringAsFixed(1)}M / \$${(status.fundingGoal / 1000000).toStringAsFixed(0)}M',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: status.fundingRaised / status.fundingGoal,
                    minHeight: 6,
                    backgroundColor: AppColors.textOnDark.withAlpha(30),
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.accentTeal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
