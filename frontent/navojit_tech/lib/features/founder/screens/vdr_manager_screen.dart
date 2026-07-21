import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/founder/providers/pitch_wizard_provider.dart';
import 'package:navojit_tech/features/founder/widgets/vdr_document_tile.dart';

class VdrManagerScreen extends ConsumerWidget {
  const VdrManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vdrProvider);
    final notifier = ref.read(vdrProvider.notifier);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Virtual Data Room'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due Diligence VDR', style: AppTextStyles.heading2),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            'Manage access to your sensitive documents.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop)
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.textOnDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),
                
                // Category Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: state.categories.map((cat) {
                      final isSelected = (state.selectedCategory ?? 'All') == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppDimensions.sm),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            notifier.setCategory(val ? cat : 'All');
                          },
                          backgroundColor: AppColors.surfaceWhite,
                          selectedColor: AppColors.primaryBlue.withAlpha(20),
                          checkmarkColor: AppColors.primaryBlue,
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.xl),
                
                // Document List
                Expanded(
                  child: state.filteredDocuments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.folder_open_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppDimensions.md),
                              Text(
                                'Your Virtual Data Room is empty.',
                                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.xs),
                              Text(
                                'Upload documents to share with investors.',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.filteredDocuments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.sm),
                          itemBuilder: (context, index) {
                            final doc = state.filteredDocuments[index];
                            return VdrDocumentTile(
                              document: doc,
                              onLockToggled: (unlocked) {
                                notifier.toggleLock(doc.id);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !isDesktop ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.textOnDark),
      ) : null,
    );
  }
}
