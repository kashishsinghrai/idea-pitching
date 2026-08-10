import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/founder/providers/pitch_wizard_provider.dart';
import 'package:navojit_tech/features/founder/widgets/add_document_dialog.dart';
import 'package:navojit_tech/features/founder/widgets/vdr_document_tile.dart';

class VdrManagerScreen extends ConsumerWidget {
  const VdrManagerScreen({super.key});

  Future<void> _showAddDocumentDialog(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddDocumentDialog(),
    );

    if (result != null && context.mounted) {
      ref.read(vdrProvider.notifier).addDocument(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Document added to VDR', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vdrProvider);
    final notifier = ref.read(vdrProvider.notifier);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: const Text('Virtual Data Room'),
        automaticallyImplyLeading: false,
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.base),
              child: ElevatedButton.icon(
                onPressed: () => _showAddDocumentDialog(context, ref),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textOnDark,
                  minimumSize: Size.zero, // Override global theme's double.infinity
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.base,
                    vertical: AppDimensions.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Info Row ──────────────────────────────────
                Row(
                  children: [
                    // Icon badge
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: const Icon(Icons.folder_special_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due Diligence VDR', style: AppTextStyles.heading2),
                          Text(
                            'Manage access to your sensitive documents',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    // Stats pill
                    if (state.documents.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLightBlue,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: AppColors.primaryBlue.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.insert_drive_file_rounded, size: 13, color: AppColors.primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              '${state.documents.length} doc${state.documents.length == 1 ? '' : 's'}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),

                // ── Category Filter Chips ─────────────────────────────
                if (state.documents.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.categories.map((cat) {
                        final isSelected = (state.selectedCategory ?? 'All') == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppDimensions.sm),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (val) => notifier.setCategory(val ? cat : 'All'),
                              backgroundColor: AppColors.surfaceWhite,
                              selectedColor: AppColors.primaryBlue.withAlpha(18),
                              checkmarkColor: AppColors.primaryBlue,
                              side: BorderSide(
                                color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                              ),
                              labelStyle: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.base),
                ],

                // ── Document List / Empty State ────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.filteredDocuments.isEmpty
                          ? _buildEmptyState(context, state.documents.isEmpty, ref)
                          : ListView.separated(
                              itemCount: state.filteredDocuments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
                              itemBuilder: (context, index) {
                                final doc = state.filteredDocuments[index];
                                return VdrDocumentTile(
                                  document: doc,
                                  onLockToggled: (_) => notifier.toggleLock(doc.id),
                                  onDelete: () => notifier.deleteDocument(doc.id),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !isDesktop
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDocumentDialog(context, ref),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textOnDark,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Document', style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isGloballyEmpty, WidgetRef ref) {
    final isFilterEmpty = !isGloballyEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceLightBlue,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),

            Text(
              isFilterEmpty ? 'No documents in this category' : 'Your VDR is empty',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),

            Text(
              isFilterEmpty
                  ? 'No documents match the selected filter.\nTry selecting a different category.'
                  : 'Upload sensitive documents to securely share\nwith investors during due diligence.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xxl),

            if (isGloballyEmpty) ...[
              // Feature pills
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeaturePill(Icons.lock_rounded, 'Investor-gated access'),
                  _buildFeaturePill(Icons.visibility_rounded, 'View tracking'),
                  _buildFeaturePill(Icons.category_rounded, 'Organized by category'),
                ],
              ),
              const SizedBox(height: AppDimensions.xxl),
              ElevatedButton.icon(
                onPressed: () => _showAddDocumentDialog(context, ref),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload First Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textOnDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.xxl,
                    vertical: AppDimensions.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.accentTeal),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
