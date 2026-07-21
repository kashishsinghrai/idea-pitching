import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

/// Enum representing the user's selected role.
enum UserRole { none, founder, investor }

/// Simple auth state for Phase 1 — local state only, no API calls.
class AuthState {
  final UserRole selectedRole;
  final bool isLoading;
  final String? otpCode;
  final int resendTimerSeconds;
  final int selectedDocType; // 0 = ID Card, 1 = Passport

  const AuthState({
    this.selectedRole = UserRole.none,
    this.isLoading = false,
    this.otpCode,
    this.resendTimerSeconds = 45,
    this.selectedDocType = 0,
  });

  AuthState copyWith({
    UserRole? selectedRole,
    bool? isLoading,
    String? otpCode,
    int? resendTimerSeconds,
    int? selectedDocType,
  }) {
    return AuthState(
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      otpCode: otpCode ?? this.otpCode,
      resendTimerSeconds: resendTimerSeconds ?? this.resendTimerSeconds,
      selectedDocType: selectedDocType ?? this.selectedDocType,
    );
  }
}

/// Notifier managing auth-related local state.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setOtpCode(String code) {
    state = state.copyWith(otpCode: code);
  }

  void setResendTimer(int seconds) {
    state = state.copyWith(resendTimerSeconds: seconds);
  }

  void selectDocType(int type) {
    state = state.copyWith(selectedDocType: type);
  }

  void reset() {
    state = const AuthState();
  }

  /// Logs in the user via the API and returns the role
  Future<String> login(String email, String password) async {
    setLoading(true);
    try {
      final response = await _authRepository.login(email: email, password: password);
      setLoading(false);
      return response['user']['role']; // Returns 'FOUNDER', 'INVESTOR', or 'ADMIN'
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  /// Registers the user via the API and returns the role
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    setLoading(true);
    try {
      // Determine the role string from current state
      String roleString = 'INVESTOR';
      if (state.selectedRole == UserRole.founder) {
        roleString = 'FOUNDER';
      }

      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: roleString,
      );
      setLoading(false);
      return response['user']['role'];
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  /// Logs out the user and clears state
  Future<void> logout() async {
    await _authRepository.logout();
    reset(); // Clear local state
  }
}

/// Global repository provider
final authRepositoryProvider = Provider((ref) => AuthRepository());

/// Global auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
