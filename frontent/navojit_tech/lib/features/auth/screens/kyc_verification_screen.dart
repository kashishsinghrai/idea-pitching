import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../widgets/auth_button.dart';
import '../widgets/document_type_chip.dart';
import '../widgets/file_upload_area.dart';
import '../providers/auth_provider.dart';

/// KYC Identity Verification screen — Step 1 of 3.
class KycVerificationScreen extends ConsumerWidget {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.identityVerification),
      ),
      body: SafeArea(
        child: ResponsiveUtils.constrainForDesktop(
          context,
          _buildContent(context, ref, authState),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress Bar ──
          const SizedBox(height: AppDimensions.base),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: 0.33,
              minHeight: 4,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Step Label ──
          Text(
            AppStrings.stepOf,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // ── Heading ──
          Text(AppStrings.verifyIdentity, style: AppTextStyles.heading2),
          const SizedBox(height: AppDimensions.md),
          Text(AppStrings.kycDescription, style: AppTextStyles.bodyMedium),

          const SizedBox(height: AppDimensions.xl),

          // ── Security Info Banner ──
          Container(
            padding: const EdgeInsets.all(AppDimensions.base),
            decoration: BoxDecoration(
              color: AppColors.infoBlueBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: AppColors.primaryBlue.withAlpha(30),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    AppStrings.securityNote,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xxl),

          // ── Upload Document Section ──
          Text(
            AppStrings.uploadDocument,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppDimensions.base),

          // ── Document Type Chips ──
          Row(
            children: [
              Expanded(
                child: DocumentTypeChip(
                  icon: Icons.credit_card_outlined,
                  label: AppStrings.idCard,
                  isSelected: state.selectedDocType == 0,
                  onTap: () =>
                      ref.read(authProvider.notifier).selectDocType(0),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: DocumentTypeChip(
                  icon: Icons.menu_book_outlined,
                  label: AppStrings.passport,
                  isSelected: state.selectedDocType == 1,
                  onTap: () =>
                      ref.read(authProvider.notifier).selectDocType(1),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── File Upload Area ──
          FileUploadArea(
            onTap: () {
              // File picker would go here in a real implementation
            },
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Document Requirements ──
          Text(
            AppStrings.docRequirements,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          _buildRequirement(AppStrings.reqValid),
          const SizedBox(height: AppDimensions.sm),
          _buildRequirement(AppStrings.reqCorners),
          const SizedBox(height: AppDimensions.sm),
          _buildRequirement(AppStrings.reqClear),

          const SizedBox(height: AppDimensions.xxl),

          // ── Continue Button ──
          AuthButton(
            label: AppStrings.continueButton,
            showArrow: true,
            onPressed: () {
              if (state.selectedRole == UserRole.investor) {
                context.go('/investor/deals');
              } else {
                context.go('/founder/dashboard');
              }
            },
          ),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          size: 18,
          color: AppColors.successGreen,
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(text, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}
