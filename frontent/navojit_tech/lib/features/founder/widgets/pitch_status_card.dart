import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';

class PitchStatusCard extends StatelessWidget {
  final StartupDeal pitch;

  const PitchStatusCard({super.key, required this.pitch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pitch.name,
                style: AppTextStyles.heading3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // We'll just assume 'PENDING' for now since the API defaults to it
                  color: AppColors.warningAmber.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warningAmber),
                ),
                child: Text(
                  'PENDING',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warningAmber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            pitch.tagline,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.lg),
          const Divider(),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask Amount', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  Text('\$${(pitch.askAmount / 1000000).toStringAsFixed(1)}M', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valuation', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  Text('\$${(pitch.valuation / 1000000).toStringAsFixed(1)}M', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
