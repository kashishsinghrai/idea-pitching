import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/founder/widgets/stat_card.dart';
import 'package:navojit_tech/features/auth/providers/auth_provider.dart';
import 'package:navojit_tech/features/founder/widgets/pitch_status_card.dart';
import 'package:navojit_tech/features/founder/providers/pitch_wizard_provider.dart';
import 'package:navojit_tech/shared/widgets/error_card.dart';

/// Founder home dashboard screen.
/// Mobile: single column stacked. Desktop: single column centered.
class FounderDashboardScreen extends ConsumerWidget {
  const FounderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 22),
            const SizedBox(width: AppDimensions.sm),
            Text('Welcome back!', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: AppDimensions.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.base),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBlue,
              child: Text('F',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.errorRed),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.refresh(myPitchesProvider.future);
        },
        child: isDesktop
            ? _buildDesktopLayout(context, ref)
            : _buildMobileLayout(context, ref),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Dashboard Overview'),
              const SizedBox(height: AppDimensions.base),
              _buildStatGrid(context, ref),
              const SizedBox(height: AppDimensions.xxl),
              _buildSectionHeader('My Pitches'),
              const SizedBox(height: AppDimensions.base),
              _buildPitchesList(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      children: [
        _buildSectionHeader('Dashboard Overview'),
        const SizedBox(height: AppDimensions.base),
        _buildStatGrid(context, ref),
        const SizedBox(height: AppDimensions.xl),
        _buildSectionHeader('My Pitches'),
        const SizedBox(height: AppDimensions.base),
        _buildPitchesList(context, ref),
        const SizedBox(height: AppDimensions.xxl),
      ],
    );
  }

  Widget _buildPitchesList(BuildContext context, WidgetRef ref) {
    final pitchesAsync = ref.watch(myPitchesProvider);

    return pitchesAsync.when(
      data: (pitches) {
        if (pitches.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                const Icon(Icons.rocket_launch_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: AppDimensions.md),
                Text("You haven't submitted any pitches yet", style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimensions.lg),
                ElevatedButton(
                  onPressed: () => context.go('/founder/pitch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.textOnDark,
                  ),
                  child: const Text('Submit a Pitch'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pitches.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: PitchStatusCard(pitch: pitches[index]),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => ErrorCard(
        title: 'Could not load pitches',
        message: 'Check your connection and try again.',
        icon: Icons.rocket_launch_outlined,
        onRetry: () => ref.invalidate(myPitchesProvider),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  Widget _buildStatGrid(BuildContext context, WidgetRef ref) {
    final pitchesAsync = ref.watch(myPitchesProvider);

    return pitchesAsync.when(
      data: (pitches) {
        final totalPitches = pitches.length;
        final pending = pitches.where((p) => p.status == 'PENDING').length;
        final approved = pitches.where((p) => p.status == 'APPROVED').length;
        final askTotal = pitches.fold<double>(0, (sum, p) => sum + p.askAmount);

        return GridView.count(
          crossAxisCount: ResponsiveUtils.isDesktop(context) ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppDimensions.md,
          mainAxisSpacing: AppDimensions.md,
          childAspectRatio: ResponsiveUtils.isDesktop(context) ? 1.8 : 1.4,
          children: [
            StatCard(
              icon: Icons.rocket_launch_outlined,
              label: 'Total Pitches',
              value: totalPitches.toString(),
            ),
            StatCard(
              icon: Icons.hourglass_empty,
              label: 'Pending',
              value: pending.toString(),
            ),
            StatCard(
              icon: Icons.check_circle_outline,
              label: 'Approved',
              value: approved.toString(),
            ),
            StatCard(
              icon: Icons.attach_money,
              label: 'Total Ask',
              value: '\$${(askTotal / 1000000).toStringAsFixed(1)}M',
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => ErrorCard(
        title: 'Could not load stats',
        message: 'Unable to reach the server. Check your connection.',
        icon: Icons.bar_chart_rounded,
        onRetry: () => ref.invalidate(myPitchesProvider),
      ),
    );
  }
}
