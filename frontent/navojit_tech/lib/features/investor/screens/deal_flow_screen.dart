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
import 'package:navojit_tech/shared/widgets/error_card.dart';

class DealFlowScreen extends ConsumerStatefulWidget {
  const DealFlowScreen({super.key});

  @override
  ConsumerState<DealFlowScreen> createState() => _DealFlowScreenState();
}

class _DealFlowScreenState extends ConsumerState<DealFlowScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      ref.read(dealFlowProvider.notifier).setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dealFlowProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text('Deal Flow', style: AppTextStyles.heading2),
          ],
        ),
        actions: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryBlue),
              onPressed: () => showFilterBottomSheet(context),
              tooltip: 'Filters',
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textTertiary),
            onPressed: () => ref.read(dealFlowProvider.notifier).fetchStartups(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: AppDimensions.xs),
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Search startups by name, industry, tagline…',
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref.read(dealFlowProvider.notifier).setSearchQuery('');
                },
                child: const Icon(Icons.close, color: AppColors.textTertiary, size: 18),
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DealFlowState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSidebar(),
        const SizedBox(width: AppDimensions.xxl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Text(
                    state.isLoading
                        ? 'Loading deals…'
                        : 'Showing ${state.filteredStartups.length} of ${state.startups.length} startups',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                  const Spacer(),
                  if (state.selectedIndustries.isNotEmpty ||
                      state.selectedStages.isNotEmpty ||
                      state.searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(dealFlowProvider.notifier).clearFilters();
                      },
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 14),
                      label: const Text('Clear all filters'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Expanded(child: _buildContent(context, state)),
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
        _buildSearchBar(),
        const SizedBox(height: AppDimensions.md),
        Text(
          state.isLoading
              ? 'Loading deals…'
              : 'Showing ${state.filteredStartups.length} startups',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppDimensions.md),
        Expanded(child: _buildContent(context, state)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, DealFlowState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ErrorCard(
            title: 'Could not load deals',
            message: state.errorMessage!,
            icon: Icons.diamond_outlined,
            onRetry: () => ref.read(dealFlowProvider.notifier).fetchStartups(),
          ),
        ),
      );
    }

    if (state.filteredStartups.isEmpty) {
      return _buildEmptyState(state);
    }

    final isDesktop = ResponsiveUtils.isDesktop(context);

    if (isDesktop) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          crossAxisSpacing: AppDimensions.lg,
          mainAxisSpacing: AppDimensions.lg,
          childAspectRatio: 1.3,
        ),
        itemCount: state.filteredStartups.length,
        itemBuilder: (context, index) {
          final deal = state.filteredStartups[index];
          return StartupDealCard(
            deal: deal,
            isBookmarked: state.savedDealIds.contains(deal.id),
            onBookmark: () => ref.read(dealFlowProvider.notifier).toggleBookmark(deal.id),
            onTap: () => context.push('/investor/startup/${deal.id}'),
          );
        },
      );
    }

    return ListView.separated(
      itemCount: state.filteredStartups.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.lg),
      itemBuilder: (context, index) {
        final deal = state.filteredStartups[index];
        return SizedBox(
          height: 240,
          child: StartupDealCard(
            deal: deal,
            isBookmarked: state.savedDealIds.contains(deal.id),
            onBookmark: () => ref.read(dealFlowProvider.notifier).toggleBookmark(deal.id),
            onTap: () => context.push('/investor/startup/${deal.id}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(DealFlowState state) {
    final hasFilters = state.selectedIndustries.isNotEmpty ||
        state.selectedStages.isNotEmpty ||
        state.searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Icon(
              hasFilters ? Icons.search_off_rounded : Icons.inbox_rounded,
              size: 48,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            hasFilters ? 'No startups match your search' : 'No approved deals yet',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search term.'
                : 'Check back later for new investment opportunities.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: AppDimensions.xl),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(dealFlowProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Clear Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
