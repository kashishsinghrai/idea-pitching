import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/constants/app_strings.dart';

/// Dashed file upload area for KYC document uploads.
class FileUploadArea extends StatelessWidget {
  final VoidCallback onTap;
  final String? selectedFileName;

  const FileUploadArea({
    super.key,
    required this.onTap,
    this.selectedFileName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.xxl,
          horizontal: AppDimensions.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Icon(
                selectedFileName != null
                    ? Icons.check_circle_outline
                    : Icons.upload_file_outlined,
                color: selectedFileName != null
                    ? AppColors.successGreen
                    : AppColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              selectedFileName ?? AppStrings.tapToSelect,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selectedFileName != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              AppStrings.fileTypes,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
