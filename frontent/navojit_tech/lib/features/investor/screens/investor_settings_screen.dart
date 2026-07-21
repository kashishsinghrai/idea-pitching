import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/auth/providers/auth_provider.dart';

class InvestorSettingsScreen extends ConsumerWidget {
  const InvestorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings', style: AppTextStyles.heading2),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Details',
            subtitle: 'Update your personal and firm information',
          ),
          _buildSettingsTile(
            icon: Icons.verified_user_outlined,
            title: 'Accreditation Status',
            subtitle: 'Manage your verified investor status',
          ),
          const SizedBox(height: AppDimensions.xl),

          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage email and push alerts',
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: 'System Default',
          ),
          const SizedBox(height: AppDimensions.xl),

          _buildSectionHeader('Security'),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
          ),
          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Enabled',
          ),
          const SizedBox(height: AppDimensions.xxxl),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/welcome');
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.errorRed),
              label: Text(
                'Log Out',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed.withAlpha(15),
                foregroundColor: AppColors.errorRed,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  side: BorderSide(color: AppColors.errorRed.withAlpha(50)),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.md,
        bottom: AppDimensions.sm,
        top: AppDimensions.md,
      ),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceLightBlue,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 22),
        ),
        title: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextStyles.caption)
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: () {},
      ),
    );
  }
}
