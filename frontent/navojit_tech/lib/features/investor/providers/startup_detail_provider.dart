import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';
import 'package:navojit_tech/features/investor/providers/deal_flow_provider.dart';
import 'package:navojit_tech/features/investor/repositories/investor_repository.dart';

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
  final InvestorRepository _repository;

  StartupDetailNotifier(this._availableStartups, this._repository) : super(const StartupDetailState());

  Future<void> setStartup(String id) async {
    if (_availableStartups.isEmpty) return;
    
    final deal = _availableStartups.firstWhere(
      (s) => s.id == id,
      orElse: () => _availableStartups.first,
    );
    
    state = StartupDetailState(currentStartup: deal, isLoading: true);
    
    try {
      final ndaSigned = await _repository.getNdaStatus(deal.id);
      state = state.copyWith(hasSignedNda: ndaSigned, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> requestVdrAccess() async {
    state = state.copyWith(isLoading: true);
    // VDR Access is a future feature on backend, simulating for now
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(hasRequestedVdr: true, isLoading: false);
  }

  Future<void> signNda() async {
    final dealId = state.currentStartup?.id;
    if (dealId == null) return;

    state = state.copyWith(isLoading: true);
    
    try {
      await _repository.signNda(dealId);
      state = state.copyWith(hasSignedNda: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final startupDetailProvider = StateNotifierProvider<StartupDetailNotifier, StartupDetailState>((ref) {
  final dealFlowState = ref.watch(dealFlowProvider);
  final repo = ref.watch(investorRepositoryProvider);
  return StartupDetailNotifier(dealFlowState.startups, repo);
});
