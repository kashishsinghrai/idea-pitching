import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/auth/providers/auth_provider.dart';
import 'package:navojit_tech/features/founder/repositories/founder_repository.dart';

// ── State & Notifier ────────────────────────────────────────────────────────

class FounderProfileState {
  final String displayName;
  final String startupName;
  final String role;
  final bool notifyNewMessages;
  final bool notifyVdrAccess;

  const FounderProfileState({
    this.displayName = '',
    this.startupName = '',
    this.role = '',
    this.notifyNewMessages = true,
    this.notifyVdrAccess = true,
  });

  FounderProfileState copyWith({
    String? displayName,
    String? startupName,
    String? role,
    bool? notifyNewMessages,
    bool? notifyVdrAccess,
  }) {
    return FounderProfileState(
      displayName: displayName ?? this.displayName,
      startupName: startupName ?? this.startupName,
      role: role ?? this.role,
      notifyNewMessages: notifyNewMessages ?? this.notifyNewMessages,
      notifyVdrAccess: notifyVdrAccess ?? this.notifyVdrAccess,
    );
  }
}

class FounderProfileNotifier extends StateNotifier<FounderProfileState> {
  final FounderRepository _repository;

  FounderProfileNotifier(this._repository) : super(const FounderProfileState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _repository.getProfile();
      state = state.copyWith(
        displayName: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        startupName: data['firmName'] ?? '',
        role: data['role'] ?? '',
        notifyNewMessages: data['notifyMessages'] ?? true,
        notifyVdrAccess: data['notifyNdaStatus'] ?? true, // Re-using nda status field
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> updateProfile({required String name, required String startup, required String role}) async {
    final parts = name.split(' ');
    final firstName = parts.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    state = state.copyWith(displayName: name, startupName: startup, role: role);
    
    try {
      await _repository.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'firmName': startup,
        'role': role,
      });
    } catch (e) {
      _loadProfile();
    }
  }

  Future<void> toggleNotifyMessages(bool val) async {
    state = state.copyWith(notifyNewMessages: val);
    await _repository.updateProfile({'notifyMessages': val});
  }
  
  Future<void> toggleNotifyVdrAccess(bool val) async {
    state = state.copyWith(notifyVdrAccess: val);
    await _repository.updateProfile({'notifyNdaStatus': val});
  }
}

final founderProfileProvider = StateNotifierProvider<FounderProfileNotifier, FounderProfileState>(
  (ref) => FounderProfileNotifier(ref.watch(founderRepositoryProvider)),
);

// ── Screen ──────────────────────────────────────────────────────────────────

class FounderProfileScreen extends ConsumerStatefulWidget {
  const FounderProfileScreen({super.key});

  @override
  ConsumerState<FounderProfileScreen> createState() => _FounderProfileScreenState();
}

class _FounderProfileScreenState extends ConsumerState<FounderProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _startupCtrl;
  late TextEditingController _roleCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _startupCtrl = TextEditingController();
    _roleCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startupCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  void _onSave(FounderProfileNotifier notifier) {
    notifier.updateProfile(
      name: _nameCtrl.text,
      startup: _startupCtrl.text,
      role: _roleCtrl.text,
    );
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(founderProfileProvider);
    final notifier = ref.read(founderProfileProvider.notifier);

    if (!_isEditing) {
      _nameCtrl.text = state.displayName.isEmpty ? 'Founder' : state.displayName;
      _startupCtrl.text = state.startupName;
      _roleCtrl.text = state.role;
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile Settings', style: AppTextStyles.heading2),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          _buildProfileHeader(state, notifier),
          const SizedBox(height: AppDimensions.xxl),
          Text('Preferences', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.md),
          _buildPreferencesCard(state, notifier),
          const SizedBox(height: AppDimensions.xxl),
          _buildLogoutButton(ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(FounderProfileState state, FounderProfileNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Personal Information', style: AppTextStyles.heading3),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit, color: AppColors.primaryBlue),
                onPressed: () {
                  if (_isEditing) {
                    _onSave(notifier);
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          _isEditing ? _buildEditForm() : _buildViewProfile(state),
        ],
      ),
    );
  }

  Widget _buildViewProfile(FounderProfileState state) {
    return Column(
      children: [
        _buildInfoRow(Icons.person_outline, 'Full Name', state.displayName.isEmpty ? 'Not set' : state.displayName),
        const Divider(height: 24, color: AppColors.borderLight),
        _buildInfoRow(Icons.business_outlined, 'Startup Name', state.startupName.isEmpty ? 'Not set' : state.startupName),
        const Divider(height: 24, color: AppColors.borderLight),
        _buildInfoRow(Icons.badge_outlined, 'Role', state.role.isEmpty ? 'Not set' : state.role),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: AppDimensions.md),
        TextField(
          controller: _startupCtrl,
          decoration: const InputDecoration(labelText: 'Startup Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: AppDimensions.md),
        TextField(
          controller: _roleCtrl,
          decoration: const InputDecoration(labelText: 'Role (e.g. CEO)', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 20),
        const SizedBox(width: AppDimensions.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesCard(FounderProfileState state, FounderProfileNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: state.notifyNewMessages,
            onChanged: notifier.toggleNotifyMessages,
            title: Text('New Messages', style: AppTextStyles.bodyLarge),
            subtitle: Text('Get notified when investors message you', style: AppTextStyles.caption),
            activeThumbColor: AppColors.primaryBlue,
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          SwitchListTile(
            value: state.notifyVdrAccess,
            onChanged: notifier.toggleNotifyVdrAccess,
            title: Text('VDR Access Requests', style: AppTextStyles.bodyLarge),
            subtitle: Text('Get notified when an investor requests data room access', style: AppTextStyles.caption),
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(authProvider.notifier).logout();
        },
        icon: const Icon(Icons.logout, color: AppColors.errorRed),
        label: const Text('Log Out', style: TextStyle(color: AppColors.errorRed)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          side: const BorderSide(color: AppColors.errorRed),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
        ),
      ),
    );
  }
}
