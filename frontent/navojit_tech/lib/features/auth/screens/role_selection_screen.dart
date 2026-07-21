import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../widgets/role_card.dart';
import '../providers/auth_provider.dart';

/// Role selection screen — Choose between Founder or Investor.
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: LightGradientBackground(
        child: SafeArea(
          child: ResponsiveUtils.constrainForDesktop(
            context,
            _buildContent(context, ref, authState),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AuthState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.xxl),

          // ── Top Icon ──
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(
              Icons.swap_vert_circle_outlined,
              color: AppColors.textOnDark,
              size: 28,
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Heading ──
          Text(
            AppStrings.chooseYourPath,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            AppStrings.roleSubtitle,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.xxl),

          // ── Role Cards ──
          RoleCard(
            icon: Icons.rocket_launch_outlined,
            title: AppStrings.founder,
            subtitle: AppStrings.founderDesc,
            isSelected: state.selectedRole == UserRole.founder,
            onTap: () {
              ref.read(authProvider.notifier).selectRole(UserRole.founder);
              Future.delayed(const Duration(milliseconds: 400), () {
                if (context.mounted) context.go('/register');
              });
            },
          ),
          const SizedBox(height: AppDimensions.base),
          RoleCard(
            icon: Icons.search_rounded,
            title: AppStrings.investor,
            subtitle: AppStrings.investorDesc,
            isSelected: state.selectedRole == UserRole.investor,
            onTap: () {
              ref.read(authProvider.notifier).selectRole(UserRole.investor);
              Future.delayed(const Duration(milliseconds: 400), () {
                if (context.mounted) context.go('/register');
              });
            },
          ),

          const Spacer(),

          // ── Sign In Link ──
          TextButton(
            onPressed: () => context.go('/login'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.signInExisting,
                  style: AppTextStyles.link,
                ),
                const SizedBox(width: AppDimensions.xs),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.textLink,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}
