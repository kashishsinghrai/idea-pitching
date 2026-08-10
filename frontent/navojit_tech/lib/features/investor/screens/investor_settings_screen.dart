import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/auth/providers/auth_provider.dart';
import 'package:navojit_tech/features/investor/repositories/investor_repository.dart';
import 'package:navojit_tech/features/investor/providers/deal_flow_provider.dart'; // for investorRepositoryProvider

// ── Local Settings State ───────────────────────────────────────────────────────

class InvestorSettingsState {
  final String displayName;
  final String firmName;
  final String role;
  final bool notifyNewDeals;
  final bool notifyMessages;
  final bool notifyNdaStatus;
  final String appearance; // 'System', 'Light', 'Dark'

  const InvestorSettingsState({
    this.displayName = 'Investor',
    this.firmName = 'Venture Capital Firm',
    this.role = 'General Partner',
    this.notifyNewDeals = true,
    this.notifyMessages = true,
    this.notifyNdaStatus = true,
    this.appearance = 'System',
  });

  InvestorSettingsState copyWith({
    String? displayName,
    String? firmName,
    String? role,
    bool? notifyNewDeals,
    bool? notifyMessages,
    bool? notifyNdaStatus,
    String? appearance,
  }) {
    return InvestorSettingsState(
      displayName: displayName ?? this.displayName,
      firmName: firmName ?? this.firmName,
      role: role ?? this.role,
      notifyNewDeals: notifyNewDeals ?? this.notifyNewDeals,
      notifyMessages: notifyMessages ?? this.notifyMessages,
      notifyNdaStatus: notifyNdaStatus ?? this.notifyNdaStatus,
      appearance: appearance ?? this.appearance,
    );
  }
}

class InvestorSettingsNotifier extends StateNotifier<InvestorSettingsState> {
  final InvestorRepository _repository;

  InvestorSettingsNotifier(this._repository) : super(const InvestorSettingsState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _repository.getProfile();
      state = state.copyWith(
        displayName: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        firmName: data['firmName'] ?? '',
        role: data['role'] ?? '',
        notifyNewDeals: data['notifyNewDeals'] ?? true,
        notifyMessages: data['notifyMessages'] ?? true,
        notifyNdaStatus: data['notifyNdaStatus'] ?? true,
      );
    } catch (e) {
      // Ignore or handle
    }
  }

  Future<void> updateProfile({required String name, required String firm, required String role}) async {
    final parts = name.split(' ');
    final firstName = parts.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    state = state.copyWith(displayName: name, firmName: firm, role: role);
    
    try {
      await _repository.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'firmName': firm,
        'role': role,
      });
    } catch (e) {
      _loadProfile(); // Revert on failure
    }
  }

  Future<void> toggleNotifyNewDeals(bool val) async {
    state = state.copyWith(notifyNewDeals: val);
    await _repository.updateProfile({'notifyNewDeals': val});
  }
  
  Future<void> toggleNotifyMessages(bool val) async {
    state = state.copyWith(notifyMessages: val);
    await _repository.updateProfile({'notifyMessages': val});
  }
  
  Future<void> toggleNotifyNdaStatus(bool val) async {
    state = state.copyWith(notifyNdaStatus: val);
    await _repository.updateProfile({'notifyNdaStatus': val});
  }
  
  void setAppearance(String val) => state = state.copyWith(appearance: val);
}

final investorSettingsProvider =
    StateNotifierProvider<InvestorSettingsNotifier, InvestorSettingsState>(
  (ref) => InvestorSettingsNotifier(ref.watch(investorRepositoryProvider)),
);

// ── Screen ────────────────────────────────────────────────────────────────────

class InvestorSettingsScreen extends ConsumerWidget {
  const InvestorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(investorSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings', style: AppTextStyles.heading2),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          // Profile Card
          _buildProfileCard(context, ref, settings),
          const SizedBox(height: AppDimensions.xl),

          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Details',
            subtitle: '${settings.displayName} · ${settings.firmName}',
            onTap: () => _showProfileSheet(context, ref, settings),
          ),
          _buildSettingsTile(
            icon: Icons.verified_user_outlined,
            title: 'Accreditation Status',
            subtitle: 'Accredited Investor ✓',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withAlpha(20),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                'Verified',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: AppDimensions.xl),

          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: _notifSummary(settings),
            onTap: () => _showNotificationsSheet(context, ref, settings),
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: settings.appearance,
            onTap: () => _showAppearanceDialog(context, ref, settings),
          ),
          const SizedBox(height: AppDimensions.xl),

          _buildSectionHeader('Security'),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => _showChangePasswordSheet(context),
          ),
          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Enabled',
            trailing: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 18),
            onTap: () {},
          ),
          const SizedBox(height: AppDimensions.xxxl),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/welcome');
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.errorRed),
              label: Text(
                'Log Out',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed.withAlpha(15),
                foregroundColor: AppColors.errorRed,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  side: BorderSide(color: AppColors.errorRed.withAlpha(50)),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  String _notifSummary(InvestorSettingsState s) {
    final on = [
      if (s.notifyNewDeals) 'New Deals',
      if (s.notifyMessages) 'Messages',
      if (s.notifyNdaStatus) 'NDA Updates',
    ];
    return on.isEmpty ? 'All notifications off' : on.join(', ');
  }

  // ── Profile Card ────────────────────────────────────────────────────────────

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, InvestorSettingsState settings) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withAlpha(40),
            child: Text(
              settings.displayName.isNotEmpty ? settings.displayName[0].toUpperCase() : 'I',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(settings.displayName, style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(settings.firmName, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha(200))),
                const SizedBox(height: 2),
                Text(settings.role, style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha(160))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            onPressed: () => _showProfileSheet(context, ref, settings),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.md, bottom: AppDimensions.sm, top: AppDimensions.md),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.xs),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceLightBlue,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 22),
        ),
        title: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.caption) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }

  // ── Dialogs / Sheets ─────────────────────────────────────────────────────────

  void _showProfileSheet(BuildContext context, WidgetRef ref, InvestorSettingsState settings) {
    final nameCtrl = TextEditingController(text: settings.displayName);
    final firmCtrl = TextEditingController(text: settings.firmName);
    final roleCtrl = TextEditingController(text: settings.role);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Text('Edit Profile', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.xl),
                _sheetField(nameCtrl, 'Display Name', Icons.person_outline),
                const SizedBox(height: AppDimensions.base),
                _sheetField(firmCtrl, 'Firm Name', Icons.business_outlined),
                const SizedBox(height: AppDimensions.base),
                _sheetField(roleCtrl, 'Role / Title', Icons.badge_outlined),
                const SizedBox(height: AppDimensions.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(investorSettingsProvider.notifier).updateProfile(
                        name: nameCtrl.text,
                        firm: firmCtrl.text,
                        role: roleCtrl.text,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, WidgetRef ref, InvestorSettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (ctx, ref, _) {
          final s = ref.watch(investorSettingsProvider);
          return Container(
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(AppDimensions.radiusFull)))),
                const SizedBox(height: AppDimensions.lg),
                Text('Notifications', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.xl),
                _notifTile(ref, 'New Deals', s.notifyNewDeals, ref.read(investorSettingsProvider.notifier).toggleNotifyNewDeals),
                _notifTile(ref, 'Messages from Founders', s.notifyMessages, ref.read(investorSettingsProvider.notifier).toggleNotifyMessages),
                _notifTile(ref, 'NDA & VDR Status Updates', s.notifyNdaStatus, ref.read(investorSettingsProvider.notifier).toggleNotifyNdaStatus),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _notifTile(WidgetRef ref, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryBlue,
            activeTrackColor: AppColors.primaryBlue.withAlpha(50),
          ),
        ],
      ),
    );
  }

  void _showAppearanceDialog(BuildContext context, WidgetRef ref, InvestorSettingsState settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Appearance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['System', 'Light', 'Dark'].map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              // ignore: deprecated_member_use
              groupValue: settings.appearance,
              activeColor: AppColors.primaryBlue,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) {
                  ref.read(investorSettingsProvider.notifier).setAppearance(val);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(AppDimensions.radiusFull)))),
              const SizedBox(height: AppDimensions.lg),
              Text('Change Password', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.xl),
              _sheetField(oldCtrl, 'Current Password', Icons.lock_outline),
              const SizedBox(height: AppDimensions.base),
              _sheetField(newCtrl, 'New Password', Icons.lock_outline),
              const SizedBox(height: AppDimensions.base),
              _sheetField(confirmCtrl, 'Confirm New Password', Icons.lock_outline),
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                  ),
                  child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
