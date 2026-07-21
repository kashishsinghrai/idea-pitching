import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';

/// A file upload zone that looks like a drag-and-drop area on desktop
/// and a tap-to-pick area on mobile.
class MediaUploadZone extends StatefulWidget {
  final String title;
  final String description;
  final String? selectedFileName;
  final bool isUploaded;
  final double uploadProgress;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const MediaUploadZone({
    super.key,
    required this.title,
    required this.description,
    this.selectedFileName,
    this.isUploaded = false,
    this.uploadProgress = 0.0,
    required this.onTap,
    this.onRemove,
  });

  @override
  State<MediaUploadZone> createState() => _MediaUploadZoneState();
}

class _MediaUploadZoneState extends State<MediaUploadZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final hasFile = widget.selectedFileName != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: hasFile ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? AppDimensions.xxl : AppDimensions.xl),
          decoration: BoxDecoration(
            color: hasFile
                ? AppColors.successGreen.withAlpha(15)
                : (_isHovering ? AppColors.surfaceLightBlue.withAlpha(100) : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: hasFile
                  ? AppColors.successGreen
                  : (_isHovering ? AppColors.primaryBlue : AppColors.borderLight),
              width: _isHovering || hasFile ? 2.0 : 1.5,
              style: hasFile ? BorderStyle.solid : BorderStyle.solid, // Could use dashed package later
            ),
          ),
          child: hasFile ? _buildFileState() : _buildEmptyState(isDesktop),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.textTertiary,
            size: 28,
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        Text(
          widget.title,
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          isDesktop
              ? 'Drag & drop your file here, or click to browse'
              : 'Tap to browse your files',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          widget.description,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFileState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.successGreen.withAlpha(100), width: 2),
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.successGreen,
            size: 32,
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        Text(
          widget.selectedFileName!,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          'Ready to upload',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.successGreen),
        ),
        if (widget.onRemove != null) ...[
          const SizedBox(height: AppDimensions.xl),
          TextButton.icon(
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Remove File'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            onPressed: widget.onRemove,
          ),
        ]
      ],
    );
  }
}
