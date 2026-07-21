import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

class InvestorPortfolioScreen extends StatelessWidget {
  const InvestorPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Portfolio Overview', style: AppTextStyles.heading2),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          _buildMetricsGrid(),
          const SizedBox(height: AppDimensions.xxl),
          
          Text('Active Investments', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.md),
          
          _buildInvestmentCard(
            startupName: 'FinTech AI Inc.',
            industry: 'Artificial Intelligence',
            amountInvested: '\$450,000',
            equity: '3.5%',
            status: 'Performing Well',
            statusColor: AppColors.successGreen,
          ),
          _buildInvestmentCard(
            startupName: 'Osmium Technologies',
            industry: 'Enterprise SaaS',
            amountInvested: '\$200,000',
            equity: '1.2%',
            status: 'On Track',
            statusColor: AppColors.primaryBlue,
          ),
          _buildInvestmentCard(
            startupName: 'Navchetna Health',
            industry: 'HealthTech',
            amountInvested: '\$550,000',
            equity: '4.0%',
            status: 'High Growth',
            statusColor: AppColors.accentTeal,
          ),
          
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
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
          value: '\$1.2M',
        ),
        _buildMetricCard(
          icon: Icons.business_center_outlined,
          label: 'Active Deals',
          value: '4',
        ),
        _buildMetricCard(
          icon: Icons.trending_up,
          label: 'Est. ROI',
          value: '+14.5%',
          valueColor: AppColors.successGreen,
        ),
        _buildMetricCard(
          icon: Icons.pie_chart_outline,
          label: 'Pending Escrow',
          value: '\$150K',
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
            child: Text(
              label,
              style: AppTextStyles.caption,
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 4,
                ),
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
              _buildInvestmentStat('Current Val', '---'), // Placeholder for real-time val
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
}
