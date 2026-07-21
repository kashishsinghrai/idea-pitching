import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

/// Primary & outlined CTA button used across auth screens.
class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool showArrow;
  final bool showLockIcon;
  final bool onDark;

  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.showArrow = false,
    this.showLockIcon = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return _buildPrimary(context);
    }
    return _buildOutlined(context);
  }

  Widget _buildPrimary(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textOnDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
        ),
        child: _buildContent(AppColors.textOnDark),
      ),
    );
  }

  Widget _buildOutlined(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: onDark ? AppColors.textOnDark : AppColors.textPrimary,
          side: BorderSide(
            color: onDark
                ? AppColors.textOnDark.withAlpha(50)
                : AppColors.borderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: _buildContent(
          onDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      );
    }

    final children = <Widget>[
      Text(label, style: AppTextStyles.buttonLarge.copyWith(color: color)),
    ];

    if (showArrow) {
      children.add(const SizedBox(width: AppDimensions.sm));
      children.add(Icon(Icons.arrow_forward, size: 20, color: color));
    }

    if (showLockIcon) {
      children.add(const SizedBox(width: AppDimensions.sm));
      children.add(Icon(Icons.lock_outline, size: 18, color: color));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
