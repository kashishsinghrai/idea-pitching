import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../providers/auth_provider.dart';

/// Login screen with email/password fields.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final role = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        // Routing based on returned role
        if (role == 'FOUNDER') {
          context.go('/founder/dashboard');
        } else if (role == 'INVESTOR') {
          context.go('/investor/deals'); // Adjust as necessary based on your investor route
        } else if (role == 'ADMIN') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admins must use the Web Portal')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
        title: const Text(AppStrings.appName),
      ),
      body: SafeArea(
        child: ResponsiveUtils.constrainForDesktop(
          context,
          _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppDimensions.xxl),

            // ── Icon ──
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceLightBlue,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Icon(
                Icons.business_center_outlined,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),

            const SizedBox(height: AppDimensions.xl),
            Text(AppStrings.loginTitle, style: AppTextStyles.heading1),
            const SizedBox(height: AppDimensions.xxxl),

            // ── Email ──
            AuthTextField(
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── Password ──
            AuthTextField(
              label: AppStrings.passwordLabel,
              hint: AppStrings.passwordHint,
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.md),

            // ── Forgot Password ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  AppStrings.forgotPassword,
                  style: AppTextStyles.link.copyWith(fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Continue Button ──
            AuthButton(
              label: authState.isLoading ? 'Logging in...' : AppStrings.continueButton,
              showArrow: !authState.isLoading,
              onPressed: authState.isLoading ? null : _handleLogin,
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Switch to Register ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.noAccount, style: AppTextStyles.bodyMedium),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Text(AppStrings.signUp, style: AppTextStyles.link),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}
