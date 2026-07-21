import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';

class MetricSummaryRow extends StatelessWidget {
  final double askAmount;
  final double valuation;

  const MetricSummaryRow({
    super.key,
    required this.askAmount,
    required this.valuation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Ask Amount', '\$${askAmount.toStringAsFixed(1)}M')),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _buildMetricCard('Valuation (Pre)', '\$${valuation.toStringAsFixed(1)}M')),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _buildMetricCard('Equity Offered', '${((askAmount / valuation) * 100).toStringAsFixed(1)}%')),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.base, horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightBlue.withAlpha(50),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primaryBlue.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: AppColors.primaryBlue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
