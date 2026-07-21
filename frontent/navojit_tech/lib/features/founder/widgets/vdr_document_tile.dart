import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';

class VdrDocumentTile extends StatelessWidget {
  final VdrDocument document;
  final ValueChanged<bool> onLockToggled;

  const VdrDocumentTile({
    super.key,
    required this.document,
    required this.onLockToggled,
  });

  @override
  Widget build(BuildContext context) {
    final fileColor = _getFileColor(document.fileType);
    final fileIcon = _getFileIcon(document.fileType);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: fileColor.withAlpha(20),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(fileIcon, color: fileColor, size: 24),
          ),
          const SizedBox(width: AppDimensions.md),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        document.category,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      '${document.sizeMB} MB • ${_formatDate(document.uploadedAt)}',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppDimensions.md),
          
          // Lock Toggle
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                document.isLocked ? Icons.lock_outline : Icons.lock_open,
                size: 16,
                color: document.isLocked ? AppColors.textTertiary : AppColors.successGreen,
              ),
              const SizedBox(height: 4),
              Switch(
                value: !document.isLocked,
                onChanged: (val) => onLockToggled(!val),
                activeThumbColor: AppColors.successGreen,
                inactiveThumbColor: AppColors.textTertiary,
                inactiveTrackColor: AppColors.surfaceLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return AppColors.errorRed;
      case 'xlsx': return AppColors.successGreen;
      case 'docx': return AppColors.primaryBlue;
      case 'pptx': return AppColors.warningAmber;
      default: return AppColors.textTertiary;
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'xlsx': return Icons.table_chart;
      case 'docx': return Icons.description;
      case 'pptx': return Icons.slideshow;
      default: return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
