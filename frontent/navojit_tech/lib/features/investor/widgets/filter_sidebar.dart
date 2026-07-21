import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/investor/models/mock_investor_data.dart';
import 'package:navojit_tech/features/investor/providers/deal_flow_provider.dart';

/// The core filter UI used in both the sidebar (desktop) and bottom sheet (mobile).
class DealFlowFilters extends ConsumerWidget {
  const DealFlowFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dealFlowProvider);
    final notifier = ref.read(dealFlowProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.heading3),
              TextButton(
                onPressed: notifier.clearFilters,
                child: Text(
                  'Clear All',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          
          // Funding Slider
          Text('Funding Required (Ask)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppDimensions.sm),
          RangeSlider(
            values: RangeValues(state.minFunding, state.maxFunding),
            min: 0,
            max: 50,
            divisions: 50,
            activeColor: AppColors.primaryBlue,
            inactiveColor: AppColors.borderLight,
            labels: RangeLabels(
              '\$${state.minFunding.toInt()}M',
              '\$${state.maxFunding.toInt()}M',
            ),
            onChanged: (RangeValues values) {
              notifier.setFundingRange(values.start, values.end);
            },
          ),
          const SizedBox(height: AppDimensions.xl),
          
          // Industry Filter
          Text('Industry', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: MockInvestorData.industries.map((industry) {
              final isSelected = state.selectedIndustries.contains(industry);
              return FilterChip(
                label: Text(industry),
                selected: isSelected,
                onSelected: (_) => notifier.toggleIndustry(industry),
                backgroundColor: AppColors.surfaceLight,
                selectedColor: AppColors.primaryBlue.withAlpha(20),
                checkmarkColor: AppColors.primaryBlue,
                labelStyle: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Stage Filter
          Text('Stage', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: MockInvestorData.stages.map((stage) {
              final isSelected = state.selectedStages.contains(stage);
              return FilterChip(
                label: Text(stage),
                selected: isSelected,
                onSelected: (_) => notifier.toggleStage(stage),
                backgroundColor: AppColors.surfaceLight,
                selectedColor: AppColors.accentTeal.withAlpha(20),
                checkmarkColor: AppColors.accentTeal,
                labelStyle: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.accentTeal : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  side: BorderSide(
                    color: isSelected ? AppColors.accentTeal : AppColors.borderLight,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Desktop sidebar wrapper for filters.
class FilterSidebar extends StatelessWidget {
  const FilterSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const DealFlowFilters(),
    );
  }
}
