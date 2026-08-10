import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/two_fa_screen.dart';
import '../../features/auth/screens/kyc_verification_screen.dart';

import '../../features/founder/screens/founder_shell.dart';
import '../../features/founder/screens/founder_dashboard_screen.dart';
import '../../features/founder/screens/pitch_wizard_screen.dart';
import '../../features/founder/screens/media_upload_screen.dart';
import '../../features/founder/screens/vdr_manager_screen.dart';
import '../../features/founder/screens/founder_profile_screen.dart';

import '../../features/investor/screens/investor_shell.dart';
import '../../features/investor/screens/deal_flow_screen.dart';
import '../../features/investor/screens/startup_detail_screen.dart';
import '../../features/investor/screens/nda_signature_screen.dart';
import '../../features/investor/screens/investor_messages_screen.dart';
import '../../features/investor/screens/investor_portfolio_screen.dart';
import '../../features/investor/screens/investor_settings_screen.dart';

/// Central route configuration using go_router for deep-linking support.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/role-select',
        name: 'roleSelect',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/2fa',
        name: 'twoFa',
        builder: (context, state) => const TwoFaScreen(),
      ),
      GoRoute(
        path: '/kyc',
        name: 'kyc',
        builder: (context, state) => const KycVerificationScreen(),
      ),

      // ── Founder Portal ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return FounderShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/founder/dashboard',
            builder: (context, state) => const FounderDashboardScreen(),
          ),
          GoRoute(
            path: '/founder/pitch',
            builder: (context, state) => const PitchWizardScreen(),
          ),
          GoRoute(
            path: '/founder/media',
            builder: (context, state) => const MediaUploadScreen(),
          ),
          GoRoute(
            path: '/founder/vdr',
            builder: (context, state) => const VdrManagerScreen(),
          ),
          GoRoute(
            path: '/founder/profile',
            builder: (context, state) => const FounderProfileScreen(),
          ),
        ],
      ),

      // ── Investor Portal ──
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'investor_shell'),
        builder: (context, state, child) {
          return InvestorShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/investor/deals',
            builder: (context, state) => const DealFlowScreen(),
          ),
          GoRoute(
            path: '/investor/messages',
            builder: (context, state) => const InvestorMessagesScreen(),
          ),
          GoRoute(
            path: '/investor/portfolio',
            builder: (context, state) => const InvestorPortfolioScreen(),
          ),
          GoRoute(
            path: '/investor/settings',
            builder: (context, state) => const InvestorSettingsScreen(),
          ),
        ],
      ),

      // ── Full Screen Deep Dives (Outside Shell) ──
      GoRoute(
        path: '/investor/startup/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StartupDetailScreen(startupId: id);
        },
      ),
      GoRoute(
        path: '/investor/nda/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NdaSignatureScreen(startupId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}
