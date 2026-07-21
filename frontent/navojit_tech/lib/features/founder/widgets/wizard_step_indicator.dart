import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';

/// Horizontal step progress indicator for the pitch wizard.
class WizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<PitchStep> steps;

  const WizardStepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepBefore = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepBefore < currentStep
                  ? AppColors.primaryBlue
                  : AppColors.borderLight,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final step = steps[stepIndex];
        final isCompleted = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;

        return _buildStepCircle(step, stepIndex, isCompleted, isActive);
      }),
    );
  }

  Widget _buildStepCircle(
      PitchStep step, int index, bool isCompleted, bool isActive) {
    Color bgColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      bgColor = AppColors.accentTeal;
      iconColor = AppColors.textOnDark;
      textColor = AppColors.accentTeal;
    } else if (isActive) {
      bgColor = AppColors.primaryBlue;
      iconColor = AppColors.textOnDark;
      textColor = AppColors.primaryBlue;
    } else {
      bgColor = AppColors.borderLight;
      iconColor = AppColors.textTertiary;
      textColor = AppColors.textTertiary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: AppColors.textOnDark, size: 20)
              : Icon(step.icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          step.title,
          style: AppTextStyles.caption.copyWith(
            color: textColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
