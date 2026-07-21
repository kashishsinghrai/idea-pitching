import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

/// Responsive layout helper utilities.
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Returns true if the current viewport is mobile-sized.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppDimensions.mobileMax;

  /// Returns true if the current viewport is desktop-sized.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppDimensions.desktopMin;

  /// Wraps [child] in a centered, max-width constrained container
  /// on desktop viewports. On mobile, returns [child] as-is.
  static Widget constrainForDesktop(BuildContext context, Widget child) {
    if (!isDesktop(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
