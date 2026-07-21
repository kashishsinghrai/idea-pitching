import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/app_logo.dart';
import '../widgets/auth_button.dart';
import '../widgets/security_badge.dart';

/// Welcome screen with branding, encryption badge, and CTA buttons.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: ResponsiveUtils.constrainForDesktop(
            context,
            _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Logo & Branding ──
          const AppLogo(onDark: true, iconSize: 64),
          const SizedBox(height: AppDimensions.base),
          Text(
            AppStrings.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLargeOnDark.copyWith(height: 1.6),
          ),

          const SizedBox(height: AppDimensions.xxl),

          // ── Fingerprint + Encryption Badge ──
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withAlpha(15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Icon(
              Icons.fingerprint,
              size: 32,
              color: AppColors.textOnDark.withAlpha(180),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
          const SecurityBadge(),

          const Spacer(flex: 3),

          // ── CTA Buttons ──
          AuthButton(
            label: AppStrings.getStarted,
            showArrow: true,
            onPressed: () => context.go('/role-select'),
          ),
          const SizedBox(height: AppDimensions.md),
          AuthButton(
            label: AppStrings.logIn,
            isPrimary: false,
            onDark: true,
            onPressed: () => context.go('/login'),
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Terms of Service ──
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.captionOnDark.copyWith(fontSize: 12),
              children: [
                const TextSpan(text: AppStrings.termsPrefix),
                TextSpan(
                  text: AppStrings.termsOfService,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnDark,
                    decoration: TextDecoration.underline,
                  ),
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
