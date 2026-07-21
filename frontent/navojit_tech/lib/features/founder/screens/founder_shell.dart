import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/founder/widgets/founder_nav.dart';

/// Responsive shell scaffold for the Founder section.
/// Mobile: BottomNavigationBar | Desktop: NavigationRail on the left.
class FounderShell extends StatelessWidget {
  final Widget child;

  const FounderShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < FounderNavItems.routes.length; i++) {
      if (location.startsWith(FounderNavItems.routes[i])) return i;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    context.go(FounderNavItems.routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final currentIdx = _currentIndex(context);

    if (isDesktop) {
      return _buildDesktopLayout(context, currentIdx);
    }
    return _buildMobileLayout(context, currentIdx);
  }

  Widget _buildDesktopLayout(BuildContext context, int currentIdx) {
    return Scaffold(
      body: Row(
        children: [
          // ── Navigation Rail ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(
                right: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: NavigationRail(
              selectedIndex: currentIdx,
              onDestinationSelected: (i) => _onTap(context, i),
              backgroundColor: AppColors.surfaceWhite,
              minWidth: AppDimensions.sideNavWidth,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primaryBlue,
                size: 24,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.textTertiary,
                size: 22,
              ),
              selectedLabelTextStyle: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              unselectedLabelTextStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
              indicatorColor: AppColors.surfaceLightBlue,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: AppColors.accentTeal,
                    size: 22,
                  ),
                ),
              ),
              destinations: FounderNavItems.items
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
          ),
          // ── Content Area ──
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, int currentIdx) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIdx,
          onTap: (i) => _onTap(context, i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceWhite,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textTertiary,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: FounderNavItems.items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
