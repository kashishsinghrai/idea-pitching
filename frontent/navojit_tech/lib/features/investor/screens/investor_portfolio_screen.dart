import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/investor/providers/deal_flow_provider.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';

final investmentsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(investorRepositoryProvider);
  return await repo.getInvestments();
});

class InvestorPortfolioScreen extends ConsumerStatefulWidget {
  const InvestorPortfolioScreen({super.key});

  @override
  ConsumerState<InvestorPortfolioScreen> createState() => _InvestorPortfolioScreenState();
}

class _InvestorPortfolioScreenState extends ConsumerState<InvestorPortfolioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dealFlowState = ref.watch(dealFlowProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Portfolio', style: AppTextStyles.heading2),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 2.5,
          labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: [
            const Tab(text: 'Investments'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Watchlist'),
                  if (dealFlowState.savedDealIds.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        '${dealFlowState.savedDealIds.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvestmentsTab(),
          _buildWatchlistTab(dealFlowState),
        ],
      ),
    );
  }

  // ── INVESTMENTS TAB ────────────────────────────────────────────────

  Widget _buildInvestmentsTab() {
    final asyncInvestments = ref.watch(investmentsProvider);

    return asyncInvestments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed to load investments: $e')),
      data: (investments) {
        if (investments.isEmpty) {
          return Center(
            child: Text('No active investments', style: AppTextStyles.heading3),
          );
        }

        // Calculate totals
        double totalInvested = 0;
        for (var inv in investments) {
          totalInvested += (inv['amount'] ?? 0);
        }

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            _buildMetricsGrid(totalInvested, investments.length),
            const SizedBox(height: AppDimensions.xxl),
            Text('Active Investments', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.md),
            ...investments.map((inv) {
              final pitch = inv['pitch'] ?? {};
              return _buildInvestmentCard(
                startupName: pitch['startupName'] ?? 'Unknown',
                industry: pitch['industry'] ?? 'Unknown',
                amountInvested: '\$${inv['amount']}',
                equity: '${inv['equity'] ?? 0}%',
                status: inv['status'] ?? 'COMPLETED',
                statusColor: AppColors.successGreen,
                fundingProgress: 1.0, // Assuming fully funded if invested
              );
            }),
            const SizedBox(height: AppDimensions.xxl),
          ],
        );
      },
    );
  }

  Widget _buildMetricsGrid(double totalInvested, int activeDeals) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimensions.md,
      mainAxisSpacing: AppDimensions.md,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Total Invested',
          value: '\$${totalInvested.toStringAsFixed(0)}',
        ),
        _buildMetricCard(
          icon: Icons.business_center_outlined,
          label: 'Active Deals',
          value: '$activeDeals',
        ),
        _buildMetricCard(
          icon: Icons.trending_up,
          label: 'Est. ROI',
          value: '+0.0%',
          valueColor: AppColors.successGreen,
        ),
        _buildMetricCard(
          icon: Icons.pie_chart_outline,
          label: 'Pending Escrow',
          value: '\$0',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 16, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: AppDimensions.sm),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard({
    required String startupName,
    required String industry,
    required String amountInvested,
    required String equity,
    required String status,
    required Color statusColor,
    required double fundingProgress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceLightBlue,
                child: Text(
                  startupName[0],
                  style: AppTextStyles.heading3.copyWith(color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startupName, style: AppTextStyles.heading3),
                    const SizedBox(height: 2),
                    Text(industry, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppDimensions.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInvestmentStat('Invested', amountInvested),
              _buildInvestmentStat('Equity', equity),
              _buildInvestmentStat('Current Val', '---'),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          // Funding progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Funding Utilization', style: AppTextStyles.caption),
                  Text(
                    '${(fundingProgress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: fundingProgress,
                  minHeight: 6,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── WATCHLIST TAB ──────────────────────────────────────────────────

  Widget _buildWatchlistTab(DealFlowState state) {
    final saved = state.savedDeals;

    if (saved.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightBlue,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: const Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: AppDimensions.xl),
              Text('No saved deals yet', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Bookmark startups from the Deal Flow to save them here for later review.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xxl),
              ElevatedButton.icon(
                onPressed: () {}, // TabBar is in AppBar - user navigates via shell
                icon: const Icon(Icons.diamond_rounded, size: 16),
                label: const Text('Go to Deal Flow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      itemCount: saved.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
      itemBuilder: (context, index) {
        final deal = saved[index];
        return _buildWatchlistTile(context, deal, state);
      },
    );
  }

  Widget _buildWatchlistTile(BuildContext context, StartupDeal deal, DealFlowState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.sm,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Center(
            child: Text(
              deal.logoInitial,
              style: AppTextStyles.heading3.copyWith(color: Colors.white),
            ),
          ),
        ),
        title: Text(deal.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${deal.industry} · ${deal.stage} · Ask: \$${deal.askAmount.toStringAsFixed(1)}M',
          style: AppTextStyles.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.bookmark_rounded, color: AppColors.primaryBlue, size: 20),
              tooltip: 'Remove from watchlist',
              onPressed: () => ref.read(dealFlowProvider.notifier).toggleBookmark(deal.id),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
              onPressed: () => context.push('/investor/startup/${deal.id}'),
            ),
          ],
        ),
        onTap: () => context.push('/investor/startup/${deal.id}'),
      ),
    );
  }
}
