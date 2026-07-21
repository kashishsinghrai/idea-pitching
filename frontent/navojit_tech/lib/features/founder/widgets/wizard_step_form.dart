import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/features/auth/widgets/auth_text_field.dart';
import 'package:navojit_tech/features/founder/providers/pitch_wizard_provider.dart';

/// Form content for each step of the pitch wizard.
class WizardStepForm extends ConsumerStatefulWidget {
  final int stepIndex;

  const WizardStepForm({super.key, required this.stepIndex});

  @override
  ConsumerState<WizardStepForm> createState() => _WizardStepFormState();
}

class _WizardStepFormState extends ConsumerState<WizardStepForm> {
  final Map<String, TextEditingController> _controllers = {};

  final List<String> _allKeys = [
    'problemTitle',
    'problemDescription',
    'targetAudience',
    'solutionOverview',
    'keyDifferentiators',
    'marketSize',
    'tam',
    'fundingAmount',
    'equityOffered',
    'useOfFunds',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data from provider if any
    final formData = ref.read(pitchWizardProvider).formData;
    for (final key in _allKeys) {
      _controllers[key] = TextEditingController(text: formData[key] ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.stepIndex) {
      case 0:
        return _buildProblemStep();
      case 1:
        return _buildSolutionStep();
      case 2:
        return _buildMarketStep();
      case 3:
        return _buildAskStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProblemStep() {
    return _AnimatedStepForm(
      stepIndex: widget.stepIndex,
      children: [
        _buildTextField(
          key: 'problemTitle',
          label: 'Startup Name',
          hint: 'e.g., NexusPay',
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTextField(
          key: 'problemDescription',
          label: 'Industry',
          hint: 'e.g., FinTech, HealthTech...',
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTextField(
          key: 'targetAudience',
          label: 'Stage',
          hint: 'e.g., Seed, Series A...',
        ),
      ],
    );
  }

  Widget _buildSolutionStep() {
    return _AnimatedStepForm(
      stepIndex: widget.stepIndex,
      children: [
        _buildTextField(
          key: 'solutionOverview',
          label: 'Tagline',
          hint: 'A one sentence pitch...',
          maxLines: 2,
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTextField(
          key: 'keyDifferentiators',
          label: 'Description',
          hint: 'Detailed description of your startup...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildMarketStep() {
    return _AnimatedStepForm(
      stepIndex: widget.stepIndex,
      children: [
        _buildTextField(
          key: 'marketSize',
          label: 'Ask Amount',
          hint: 'e.g., 1500000',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTextField(
          key: 'tam',
          label: 'Valuation',
          hint: 'e.g., 10000000',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildAskStep() {
    return _AnimatedStepForm(
      stepIndex: widget.stepIndex,
      children: [
        _buildTextField(
          key: 'fundingAmount',
          label: 'Funding Amount Raised / Asked',
          hint: 'e.g., \$1,500,000',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTextField(
          key: 'equityOffered',
          label: 'Equity Offered (%)',
          hint: 'e.g., 10%',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildTextField(
          key: 'useOfFunds',
          label: 'Use of Funds',
          hint: 'e.g., 40% R&D, 30% Marketing...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String key,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Only watch validation errors to prevent full rebuilds on every keystroke
    final errorText = ref.watch(pitchWizardProvider.select((state) => state.validationErrors[key]));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _controllers[key],
          label: label,
          hint: hint,
          keyboardType: keyboardType,
          onChanged: (val) {
            // Read instead of watch so we don't rebuild
            ref.read(pitchWizardProvider.notifier).updateField(key, val);
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
               errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _AnimatedStepForm extends StatelessWidget {
  final List<Widget> children;
  final int stepIndex;
  
  const _AnimatedStepForm({required this.children, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        // Use ValueKey based on stepIndex instead of UniqueKey to prevent focus loss during rebuilds
        key: ValueKey(stepIndex),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
