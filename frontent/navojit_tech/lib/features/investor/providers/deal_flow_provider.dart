import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';
import 'package:navojit_tech/features/investor/repositories/deal_flow_repository.dart';

final dealFlowRepositoryProvider = Provider((ref) => DealFlowRepository());

class DealFlowState {
  final List<StartupDeal> startups;
  final List<String> selectedIndustries;
  final List<String> selectedStages;
  final double minFunding;
  final double maxFunding;
  final bool isLoading;
  final String? errorMessage;

  const DealFlowState({
    this.startups = const [],
    this.selectedIndustries = const [],
    this.selectedStages = const [],
    this.minFunding = 0.0,
    this.maxFunding = 50.0, // Default max slider value in millions
    this.isLoading = false,
    this.errorMessage,
  });

  DealFlowState copyWith({
    List<StartupDeal>? startups,
    List<String>? selectedIndustries,
    List<String>? selectedStages,
    double? minFunding,
    double? maxFunding,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DealFlowState(
      startups: startups ?? this.startups,
      selectedIndustries: selectedIndustries ?? this.selectedIndustries,
      selectedStages: selectedStages ?? this.selectedStages,
      minFunding: minFunding ?? this.minFunding,
      maxFunding: maxFunding ?? this.maxFunding,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Getter for the filtered list of startups based on current filter state.
  List<StartupDeal> get filteredStartups {
    return startups.where((deal) {
      final industryMatch = selectedIndustries.isEmpty || selectedIndustries.contains(deal.industry);
      final stageMatch = selectedStages.isEmpty || selectedStages.contains(deal.stage);
      final fundingMatch = deal.askAmount >= minFunding && deal.askAmount <= maxFunding;

      return industryMatch && stageMatch && fundingMatch;
    }).toList();
  }
}

class DealFlowNotifier extends StateNotifier<DealFlowState> {
  final DealFlowRepository _repository;

  DealFlowNotifier(this._repository) : super(const DealFlowState(isLoading: true)) {
    fetchStartups();
  }

  Future<void> fetchStartups() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final startups = await _repository.fetchDealFlow();
      state = state.copyWith(startups: startups, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void toggleIndustry(String industry) {
    final List<String> updated = List.from(state.selectedIndustries);
    if (updated.contains(industry)) {
      updated.remove(industry);
    } else {
      updated.add(industry);
    }
    state = state.copyWith(selectedIndustries: updated);
  }

  void toggleStage(String stage) {
    final List<String> updated = List.from(state.selectedStages);
    if (updated.contains(stage)) {
      updated.remove(stage);
    } else {
      updated.add(stage);
    }
    state = state.copyWith(selectedStages: updated);
  }

  void setFundingRange(double min, double max) {
    state = state.copyWith(minFunding: min, maxFunding: max);
  }

  void clearFilters() {
    state = state.copyWith(
      selectedIndustries: [],
      selectedStages: [],
      minFunding: 0.0,
      maxFunding: 50.0,
    );
  }
}

final dealFlowProvider = StateNotifierProvider<DealFlowNotifier, DealFlowState>((ref) {
  final repository = ref.watch(dealFlowRepositoryProvider);
  return DealFlowNotifier(repository);
});
