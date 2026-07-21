import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

/// A compact metric card showing a single KPI (views, funding, etc.).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trend; // e.g., '+12%'
  final bool isTrendPositive;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.isTrendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md), // Reduced from lg to prevent overflow
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Takes only needed space
        children: [
          Row(
            children: [
              Container(
                width: 32, // slightly smaller
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightBlue,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(icon, size: 16, color: AppColors.primaryBlue),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isTrendPositive
                        ? AppColors.successGreen.withAlpha(20)
                        : AppColors.errorRed.withAlpha(20),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    trend!,
                    style: AppTextStyles.caption.copyWith(
                      color: isTrendPositive
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
