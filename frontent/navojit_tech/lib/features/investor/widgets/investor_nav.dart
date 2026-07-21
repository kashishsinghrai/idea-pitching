import 'package:flutter/material.dart';

class InvestorNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const InvestorNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class InvestorNavItems {
  InvestorNavItems._();

  static const List<InvestorNavItem> items = [
    InvestorNavItem(
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt_rounded,
      label: 'Deal Flow',
    ),
    InvestorNavItem(
      icon: Icons.message_outlined,
      selectedIcon: Icons.message_rounded,
      label: 'Messages',
    ),
    InvestorNavItem(
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart_rounded,
      label: 'Portfolio',
    ),
    InvestorNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  static const List<String> routes = [
    '/investor/deals',
    '/investor/messages',
    '/investor/portfolio', // Placeholder routes for future implementation
    '/investor/settings',
  ];
}
