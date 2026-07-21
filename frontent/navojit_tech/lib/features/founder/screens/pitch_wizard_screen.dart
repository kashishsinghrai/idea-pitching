import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/auth/widgets/auth_button.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';
import 'package:navojit_tech/features/founder/providers/pitch_wizard_provider.dart';
import 'package:navojit_tech/features/founder/widgets/wizard_step_form.dart';
import 'package:navojit_tech/features/founder/widgets/wizard_step_indicator.dart';

const List<PitchStep> _pitchSteps = [
  PitchStep(index: 0, title: 'Problem', subtitle: 'Define the Problem', icon: Icons.error_outline),
  PitchStep(index: 1, title: 'Solution', subtitle: 'Your Solution', icon: Icons.lightbulb_outline),
  PitchStep(index: 2, title: 'Market', subtitle: 'Market Opportunity', icon: Icons.trending_up),
  PitchStep(index: 3, title: 'Ask', subtitle: 'The Ask', icon: Icons.account_balance_wallet_outlined),
];

class PitchWizardScreen extends ConsumerWidget {
  const PitchWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pitchWizardProvider);
    final notifier = ref.read(pitchWizardProvider.notifier);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Pitch Submission Wizard'),
        automaticallyImplyLeading: false, // Shell handles navigation if needed
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? AppDimensions.xxl : AppDimensions.screenPadding),
            child: Column(
              children: [
                // Step Indicator
                WizardStepIndicator(
                  currentStep: state.currentStep,
                  steps: _pitchSteps,
                ),
                const SizedBox(height: AppDimensions.xxl),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppColors.subtleShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pitchSteps[state.currentStep].title,
                            style: AppTextStyles.heading2,
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            _pitchSteps[state.currentStep].subtitle,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          WizardStepForm(stepIndex: state.currentStep),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.lg),

                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!state.isFirstStep)
                      SizedBox(
                        width: 120,
                        child: AuthButton(
                          label: 'Back',
                          isPrimary: false,
                          onPressed: notifier.prevStep,
                        ),
                      )
                    else
                      const SizedBox(width: 120), // Placeholder for alignment

                    SizedBox(
                      width: 140,
                      child: AuthButton(
                        label: state.isLastStep ? 'Submit' : 'Next',
                        isLoading: state.isSubmitting,
                        onPressed: state.isLastStep
                            ? () async {
                                try {
                                  final mediaState = ref.read(mediaUploadProvider);
                                  await notifier.submit(mediaState.videoUrl ?? '', mediaState.files);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Pitch submitted successfully!'),
                                        backgroundColor: AppColors.successGreen,
                                      ),
                                    );
                                    context.go('/founder/dashboard');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString().replaceAll('Exception: ', '')),
                                        backgroundColor: AppColors.errorRed,
                                      ),
                                    );
                                  }
                                }
                              }
                            : notifier.nextStep,
                      ),
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
}
