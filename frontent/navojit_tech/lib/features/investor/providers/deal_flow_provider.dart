import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';
import 'package:navojit_tech/features/investor/repositories/deal_flow_repository.dart';
import 'package:navojit_tech/features/investor/repositories/investor_repository.dart';

final dealFlowRepositoryProvider = Provider((ref) => DealFlowRepository());
final investorRepositoryProvider = Provider((ref) => InvestorRepository());

class DealFlowState {
  final List<StartupDeal> startups;
  final List<String> selectedIndustries;
  final List<String> selectedStages;
  final double minFunding;
  final double maxFunding;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final Set<String> savedDealIds; // bookmarked deals

  const DealFlowState({
    this.startups = const [],
    this.selectedIndustries = const [],
    this.selectedStages = const [],
    this.minFunding = 0.0,
    this.maxFunding = 50.0,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.savedDealIds = const {},
  });

  DealFlowState copyWith({
    List<StartupDeal>? startups,
    List<String>? selectedIndustries,
    List<String>? selectedStages,
    double? minFunding,
    double? maxFunding,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    Set<String>? savedDealIds,
  }) {
    return DealFlowState(
      startups: startups ?? this.startups,
      selectedIndustries: selectedIndustries ?? this.selectedIndustries,
      selectedStages: selectedStages ?? this.selectedStages,
      minFunding: minFunding ?? this.minFunding,
      maxFunding: maxFunding ?? this.maxFunding,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      savedDealIds: savedDealIds ?? this.savedDealIds,
    );
  }

  List<StartupDeal> get filteredStartups {
    final q = searchQuery.toLowerCase().trim();
    return startups.where((deal) {
      final industryMatch = selectedIndustries.isEmpty || selectedIndustries.contains(deal.industry);
      final stageMatch = selectedStages.isEmpty || selectedStages.contains(deal.stage);
      final fundingMatch = deal.askAmount >= minFunding && deal.askAmount <= maxFunding;
      final searchMatch = q.isEmpty ||
          deal.name.toLowerCase().contains(q) ||
          deal.tagline.toLowerCase().contains(q) ||
          deal.industry.toLowerCase().contains(q);
      return industryMatch && stageMatch && fundingMatch && searchMatch;
    }).toList();
  }

  List<StartupDeal> get savedDeals =>
      startups.where((d) => savedDealIds.contains(d.id)).toList();
}

class DealFlowNotifier extends StateNotifier<DealFlowState> {
  final DealFlowRepository _repository;
  final InvestorRepository _investorRepository;

  DealFlowNotifier(this._repository, this._investorRepository) : super(const DealFlowState(isLoading: true)) {
    fetchStartups();
  }

  Future<void> fetchStartups() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final startups = await _repository.fetchDealFlow();
      final watchlist = await _investorRepository.getWatchlist();
      final savedIds = watchlist.map((d) => d.id).toSet();
      
      state = state.copyWith(
        startups: startups, 
        savedDealIds: savedIds,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
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

  Future<void> toggleBookmark(String dealId) async {
    final updated = Set<String>.from(state.savedDealIds);
    if (updated.contains(dealId)) {
      updated.remove(dealId);
    } else {
      updated.add(dealId);
    }
    // Optimistic UI update
    state = state.copyWith(savedDealIds: updated);
    
    try {
      await _investorRepository.toggleWatchlist(dealId);
    } catch (e) {
      // Revert if failed
      fetchStartups();
    }
  }

  void clearFilters() {
    state = state.copyWith(
      selectedIndustries: [],
      selectedStages: [],
      minFunding: 0.0,
      maxFunding: 50.0,
      searchQuery: '',
    );
  }
}

final dealFlowProvider = StateNotifierProvider<DealFlowNotifier, DealFlowState>((ref) {
  final repository = ref.watch(dealFlowRepositoryProvider);
  final investorRepository = ref.watch(investorRepositoryProvider);
  return DealFlowNotifier(repository, investorRepository);
});
