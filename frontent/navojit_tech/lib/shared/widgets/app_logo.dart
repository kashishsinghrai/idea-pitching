import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

/// The Navojit Tech shield logo + text branding widget.
class AppLogo extends StatelessWidget {
  final bool onDark;
  final double iconSize;

  const AppLogo({
    super.key,
    this.onDark = true,
    this.iconSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withAlpha(30),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Icon(
            Icons.shield_rounded,
            size: iconSize * 0.6,
            color: AppColors.accentTeal,
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        Text(
          'Navojit Tech',
          style: onDark
              ? AppTextStyles.heading1OnDark
              : AppTextStyles.heading1,
        ),
      ],
    );
  }
}
