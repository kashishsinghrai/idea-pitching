import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../widgets/auth_button.dart';
import '../widgets/otp_input_field.dart';
import '../providers/auth_provider.dart';

/// 2FA verification screen with OTP input and countdown timer.
class TwoFaScreen extends ConsumerStatefulWidget {
  const TwoFaScreen({super.key});

  @override
  ConsumerState<TwoFaScreen> createState() => _TwoFaScreenState();
}

class _TwoFaScreenState extends ConsumerState<TwoFaScreen> {
  Timer? _timer;
  int _secondsLeft = 45;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 45;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Lock Icon ──
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // ── Heading ──
          Text(
            AppStrings.verificationCode,
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            AppStrings.twoFaSubtitle,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.xxxl),

          // ── OTP Input ──
          OtpInputField(
            onCompleted: (code) {
              ref.read(authProvider.notifier).setOtpCode(code);
            },
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Resend ──
          Text(
            AppStrings.didntReceive,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.sm),
          _canResend
              ? GestureDetector(
                  onTap: () => setState(() => _startTimer()),
                  child: Text(
                    'Resend Code',
                    style: AppTextStyles.link,
                  ),
                )
              : Text(
                  '${AppStrings.resendCode} $_formattedTime',
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.primaryBlue.withAlpha(180),
                  ),
                ),

          const Spacer(flex: 3),

          // ── Verify Button ──
          AuthButton(
            label: AppStrings.verifySecurely,
            showLockIcon: true,
            onPressed: () {
              context.go('/kyc');
            },
          ),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }
}
