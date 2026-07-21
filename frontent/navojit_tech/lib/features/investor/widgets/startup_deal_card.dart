import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';

class StartupDealCard extends StatefulWidget {
  final StartupDeal deal;
  final VoidCallback onTap;

  const StartupDealCard({
    super.key,
    required this.deal,
    required this.onTap,
  });

  @override
  State<StartupDealCard> createState() => _StartupDealCardState();
}

class _StartupDealCardState extends State<StartupDealCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: _isHovered ? AppColors.primaryBlue.withAlpha(100) : AppColors.borderLight,
            ),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ] : AppColors.subtleShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Logo, Name, Industry, Stage)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLightBlue,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          widget.deal.logoInitial,
                          style: AppTextStyles.heading2.copyWith(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.deal.name,
                            style: AppTextStyles.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Row(
                            children: [
                              _buildChip(widget.deal.industry, AppColors.accentTeal),
                              const SizedBox(width: AppDimensions.sm),
                              _buildChip(widget.deal.stage, AppColors.primaryBlue),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: _isHovered ? AppColors.primaryBlue : AppColors.textTertiary,
                    )
                  ],
                ),
                
                const SizedBox(height: AppDimensions.lg),
                
                // Tagline
                Text(
                  widget.deal.tagline,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: AppDimensions.sm),
                
                // Financials Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ask', style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(
                          '\$${widget.deal.askAmount.toStringAsFixed(1)}M',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Valuation (Pre)', style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(
                          '\$${widget.deal.valuation.toStringAsFixed(1)}M',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
