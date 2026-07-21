import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

/// "END-TO-END ENCRYPTED" pill badge with shield icon.
class SecurityBadge extends StatelessWidget {
  final String text;

  const SecurityBadge({
    super.key,
    this.text = 'END-TO-END ENCRYPTED',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.base,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withAlpha(25),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.accentTeal.withAlpha(60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: AppColors.accentTeal,
          ),
          const SizedBox(width: AppDimensions.sm),
          Text(
            text,
            style: AppTextStyles.label.copyWith(
              color: AppColors.accentTeal,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
