import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/investor/providers/deal_flow_provider.dart';
import 'package:navojit_tech/features/investor/widgets/filter_sidebar.dart';
import 'package:navojit_tech/features/investor/widgets/filter_bottom_sheet.dart';
import 'package:navojit_tech/features/investor/widgets/startup_deal_card.dart';

class DealFlowScreen extends ConsumerWidget {
  const DealFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dealFlowProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.diamond_rounded, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: AppDimensions.sm),
            Text('Deal Flow', style: AppTextStyles.heading2),
          ],
        ),
        actions: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryBlue),
              onPressed: () => showFilterBottomSheet(context),
            ),
          const SizedBox(width: AppDimensions.base),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: isDesktop
            ? _buildDesktopLayout(context, state)
            : _buildMobileLayout(context, state),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DealFlowState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Filters
        const FilterSidebar(),
        const SizedBox(width: AppDimensions.xxl),
        // Feed Grid
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showing ${state.filteredStartups.length} startups',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppDimensions.md),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.errorMessage != null
                        ? Center(child: Text(state.errorMessage!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed)))
                        : state.filteredStartups.isEmpty
                            ? _buildEmptyState()
                            : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          crossAxisSpacing: AppDimensions.lg,
                          mainAxisSpacing: AppDimensions.lg,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: state.filteredStartups.length,
                        itemBuilder: (context, index) {
                          return StartupDealCard(
                            deal: state.filteredStartups[index],
                            onTap: () => context.push('/investor/startup/${state.filteredStartups[index].id}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, DealFlowState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Showing ${state.filteredStartups.length} startups',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppDimensions.md),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
                  ? Center(child: Text(state.errorMessage!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed)))
                  : state.filteredStartups.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                  itemCount: state.filteredStartups.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.lg),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 240, // Fixed height for consistent mobile cards
                      child: StartupDealCard(
                        deal: state.filteredStartups[index],
                        onTap: () => context.push('/investor/startup/${state.filteredStartups[index].id}'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary.withAlpha(100)),
          const SizedBox(height: AppDimensions.md),
          Text('No startups found matching your filters.', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
