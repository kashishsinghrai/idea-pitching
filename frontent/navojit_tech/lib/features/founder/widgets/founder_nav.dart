import 'package:flutter/material.dart';

/// Shared navigation destination data used by both BottomNavigationBar and NavigationRail.
class FounderNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const FounderNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class FounderNavItems {
  FounderNavItems._();

  static const List<FounderNavItem> items = [
    FounderNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    FounderNavItem(
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note_rounded,
      label: 'Pitch',
    ),
    FounderNavItem(
      icon: Icons.cloud_upload_outlined,
      selectedIcon: Icons.cloud_upload_rounded,
      label: 'Media',
    ),
    FounderNavItem(
      icon: Icons.folder_special_outlined,
      selectedIcon: Icons.folder_special_rounded,
      label: 'VDR',
    ),
    FounderNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const List<String> routes = [
    '/founder/dashboard',
    '/founder/pitch',
    '/founder/media',
    '/founder/vdr',
    '/founder/profile',
  ];
}
