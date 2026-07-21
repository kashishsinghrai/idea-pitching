import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';
import 'package:navojit_tech/features/investor/providers/deal_flow_provider.dart';

class StartupDetailState {
  final StartupDeal? currentStartup;
  final bool hasRequestedVdr;
  final bool hasSignedNda;
  final bool isLoading;

  const StartupDetailState({
    this.currentStartup,
    this.hasRequestedVdr = false,
    this.hasSignedNda = false,
    this.isLoading = false,
  });

  StartupDetailState copyWith({
    StartupDeal? currentStartup,
    bool? hasRequestedVdr,
    bool? hasSignedNda,
    bool? isLoading,
  }) {
    return StartupDetailState(
      currentStartup: currentStartup ?? this.currentStartup,
      hasRequestedVdr: hasRequestedVdr ?? this.hasRequestedVdr,
      hasSignedNda: hasSignedNda ?? this.hasSignedNda,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StartupDetailNotifier extends StateNotifier<StartupDetailState> {
  final List<StartupDeal> _availableStartups;

  StartupDetailNotifier(this._availableStartups) : super(const StartupDetailState());

  void setStartup(String id) {
    if (_availableStartups.isEmpty) return;
    
    // Look up the startup from the live deal flow data
    final deal = _availableStartups.firstWhere(
      (s) => s.id == id,
      orElse: () => _availableStartups.first,
    );
    // Reset state for the new startup
    state = StartupDetailState(currentStartup: deal);
  }

  Future<void> requestVdrAccess() async {
    state = state.copyWith(isLoading: true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(hasRequestedVdr: true, isLoading: false);
  }

  Future<void> signNda() async {
    state = state.copyWith(isLoading: true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(hasSignedNda: true, isLoading: false);
  }
}

final startupDetailProvider = StateNotifierProvider<StartupDetailNotifier, StartupDetailState>((ref) {
  final dealFlowState = ref.watch(dealFlowProvider);
  return StartupDetailNotifier(dealFlowState.startups);
});
