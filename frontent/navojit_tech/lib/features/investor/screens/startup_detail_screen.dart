import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/auth/widgets/auth_button.dart';
import 'package:navojit_tech/features/investor/providers/startup_detail_provider.dart';
import 'package:navojit_tech/features/investor/widgets/founder_bio_card.dart';
import 'package:navojit_tech/features/investor/widgets/metric_summary_row.dart';
import 'package:navojit_tech/features/investor/widgets/video_player_placeholder.dart';

class StartupDetailScreen extends ConsumerStatefulWidget {
  final String startupId;

  const StartupDetailScreen({super.key, required this.startupId});

  @override
  ConsumerState<StartupDetailScreen> createState() => _StartupDetailScreenState();
}

class _StartupDetailScreenState extends ConsumerState<StartupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(startupDetailProvider.notifier).setStartup(widget.startupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupDetailProvider);
    final startup = state.currentStartup;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    if (startup == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(startup.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: isDesktop
                ? _buildDesktopLayout(context, state)
                : _buildMobileLayout(context, state),
          ),
        ),
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomAction(context, state) : null,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, StartupDetailState state) {
    final startup = state.currentStartup!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Main Content)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VideoPlayerPlaceholder(),
                const SizedBox(height: AppDimensions.xl),
                Text(startup.tagline, style: AppTextStyles.heading2),
                const SizedBox(height: AppDimensions.md),
                Text(startup.description, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimensions.xxl),
                Text('The Team', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.md),
                FounderBioCard(founder: startup.founder),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.xxl),
        // Right Column (Sidebar Action)
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
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
                MetricSummaryRow(
                  askAmount: startup.askAmount,
                  valuation: startup.valuation,
                ),
                const SizedBox(height: AppDimensions.xxl),
                Text('Due Diligence', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Access the Virtual Data Room to view pitch decks, financial models, and cap tables.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppDimensions.xl),
                _buildActionButtons(context, state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, StartupDetailState state) {
    final startup = state.currentStartup!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VideoPlayerPlaceholder(),
          const SizedBox(height: AppDimensions.xl),
          Text(startup.tagline, style: AppTextStyles.heading2),
          const SizedBox(height: AppDimensions.md),
          Text(startup.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppDimensions.xxl),
          MetricSummaryRow(
            askAmount: startup.askAmount,
            valuation: startup.valuation,
          ),
          const SizedBox(height: AppDimensions.xxl),
          Text('The Team', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.md),
          FounderBioCard(founder: startup.founder),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, StartupDetailState state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: AppColors.subtleShadow,
        border: const Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: _buildActionButtons(context, state),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, StartupDetailState state) {
    final notifier = ref.read(startupDetailProvider.notifier);
    
    if (state.hasRequestedVdr && !state.hasSignedNda) {
      return AuthButton(
        label: 'Sign NDA',
        onPressed: () => context.push('/investor/nda/${state.currentStartup!.id}'),
      );
    } else if (state.hasSignedNda) {
      return AuthButton(
        label: 'Message Founder',
        onPressed: () => context.push('/investor/messages'), // Or direct to specific chat
      );
    } else {
      return AuthButton(
        label: 'Request VDR Access',
        isLoading: state.isLoading,
        onPressed: () => notifier.requestVdrAccess(),
      );
    }
  }
}
