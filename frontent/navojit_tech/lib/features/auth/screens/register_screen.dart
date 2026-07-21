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

/// Registration screen with name, email, and password fields.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        final role = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
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
          onPressed: () => context.go('/role-select'),
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
            Text(AppStrings.registerTitle, style: AppTextStyles.heading1),
            const SizedBox(height: AppDimensions.xxxl),

            // ── Full Name ──
            AuthTextField(
              label: AppStrings.fullNameLabel,
              hint: AppStrings.fullNameHint,
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Name is required';
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.lg),

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
                if (value.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.xxl),

            // ── Continue Button ──
            AuthButton(
              label: authState.isLoading ? 'Registering...' : AppStrings.continueButton,
              showArrow: !authState.isLoading,
              onPressed: authState.isLoading ? null : _handleRegister,
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Switch to Login ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.haveAccount, style: AppTextStyles.bodyMedium),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(AppStrings.signIn, style: AppTextStyles.link),
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
