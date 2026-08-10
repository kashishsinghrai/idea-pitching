import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';

/// Premium document tile for the VDR list.
/// Supports lock toggle, view count display, and swipe-to-delete.
class VdrDocumentTile extends StatelessWidget {
  final VdrDocument document;
  final ValueChanged<bool> onLockToggled;
  final VoidCallback onDelete;

  const VdrDocumentTile({
    super.key,
    required this.document,
    required this.onLockToggled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fileColor = _getFileColor(document.fileType);
    final fileIcon = _getFileIcon(document.fileType);

    return Dismissible(
      key: ValueKey(document.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withAlpha(20),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 22),
            const SizedBox(height: 2),
            Text(
              'Delete',
              style: AppTextStyles.caption.copyWith(color: AppColors.errorRed, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text('Remove "${document.name}" from the VDR?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppColors.subtleShadow,
        ),
        child: Row(
          children: [
            // File Type Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: fileColor.withAlpha(18),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(fileIcon, color: fileColor, size: 26),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: fileColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        document.fileType.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
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
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLightBlue,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          document.category,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        '${document.sizeMB.toStringAsFixed(1)} MB',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        '• ${_formatDate(document.uploadedAt)}',
                        style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  // View Count
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        '${document.viewCount} view${document.viewCount == 1 ? '' : 's'}',
                        style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),

            // Lock Toggle Column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: document.isLocked ? 'Locked — tap to share' : 'Shared with investors',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      document.isLocked ? Icons.lock_outline : Icons.lock_open_rounded,
                      key: ValueKey(document.isLocked),
                      size: 16,
                      color: document.isLocked ? AppColors.textTertiary : AppColors.successGreen,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: !document.isLocked,
                    onChanged: (val) => onLockToggled(!val),
                    activeThumbColor: AppColors.successGreen,
                    inactiveThumbColor: AppColors.textTertiary,
                    inactiveTrackColor: AppColors.borderLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':  return AppColors.errorRed;
      case 'xlsx': return AppColors.successGreen;
      case 'docx': return AppColors.primaryBlue;
      case 'pptx': return AppColors.warningAmber;
      default:     return AppColors.textTertiary;
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':  return Icons.picture_as_pdf_rounded;
      case 'xlsx': return Icons.table_chart_rounded;
      case 'docx': return Icons.description_rounded;
      case 'pptx': return Icons.slideshow_rounded;
      default:     return Icons.insert_drive_file_rounded;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
