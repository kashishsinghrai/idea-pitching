import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/auth/widgets/auth_button.dart';
import 'package:navojit_tech/features/investor/providers/startup_detail_provider.dart';
import 'package:navojit_tech/features/investor/widgets/signature_pad_placeholder.dart';

class NdaSignatureScreen extends ConsumerStatefulWidget {
  final String startupId;

  const NdaSignatureScreen({super.key, required this.startupId});

  @override
  ConsumerState<NdaSignatureScreen> createState() => _NdaSignatureScreenState();
}

class _NdaSignatureScreenState extends ConsumerState<NdaSignatureScreen> {
  bool _hasSigned = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupDetailProvider);
    final notifier = ref.read(startupDetailProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Sign Non-Disclosure Agreement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mutual Non-Disclosure Agreement', style: AppTextStyles.heading3),
                      const SizedBox(height: AppDimensions.md),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            'This Non-Disclosure Agreement ("Agreement") is entered into by and between the undersigned Investor and ${state.currentStartup?.name ?? 'the Startup'}. \n\n'
                            '1. Confidential Information: "Confidential Information" shall mean all information disclosed by the Startup to the Investor... \n\n'
                            '2. Obligations: The Investor agrees to hold the Confidential Information in strict confidence... \n\n'
                            '3. Term: This Agreement shall remain in effect for a period of two (2) years...',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      Text('Draw your signature', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppDimensions.sm),
                      SignaturePadPlaceholder(
                        onSigned: (hasDrawn) {
                          setState(() {
                            _hasSigned = hasDrawn;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AuthButton(
                  label: 'Sign & Agree',
                  isLoading: state.isLoading,
                  // Button is disabled if the user hasn't drawn anything
                  onPressed: _hasSigned ? () async {
                    await notifier.signNda();
                    if (context.mounted) {
                      context.pop(); // Return to Detail Screen which will now show "Message Founder"
                    }
                  } : null,
                ),
                const SizedBox(height: AppDimensions.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
