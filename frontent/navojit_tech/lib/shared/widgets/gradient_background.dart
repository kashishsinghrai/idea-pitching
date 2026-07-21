import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';

/// Reusable dark gradient background used across splash/welcome screens.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: child,
    );
  }
}

/// Light gradient background for auth screens on light theme.
class LightGradientBackground extends StatelessWidget {
  final Widget child;

  const LightGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceWhite,
            AppColors.primaryBlue.withAlpha(8),
            AppColors.primaryBlue.withAlpha(18),
          ],
        ),
      ),
      child: child,
    );
  }
}
