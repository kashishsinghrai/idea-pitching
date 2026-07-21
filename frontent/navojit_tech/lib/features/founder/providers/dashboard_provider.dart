import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';

/// Dashboard state holding all data for the founder home screen.
class DashboardState {
  final PitchStatus pitchStatus;
  final List<InvestorView> investorViews;
  final List<AppNotification> notifications;
  final bool isLoading;

  const DashboardState({
    required this.pitchStatus,
    required this.investorViews,
    required this.notifications,
    this.isLoading = false,
  });

  DashboardState copyWith({
    PitchStatus? pitchStatus,
    List<InvestorView>? investorViews,
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return DashboardState(
      pitchStatus: pitchStatus ?? this.pitchStatus,
      investorViews: investorViews ?? this.investorViews,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier()
      : super(const DashboardState(
          pitchStatus: PitchStatus(
            title: '',
            status: '',
            totalViews: 0,
            uniqueInvestors: 0,
            fundingRaised: 0,
            fundingGoal: 0,
            engagementRate: 0,
          ),
          investorViews: [],
          notifications: [],
        ));

  void toggleNotificationRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          time: n.time,
          isRead: !n.isRead,
          icon: n.icon,
        );
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllRead() {
    final updated = state.notifications
        .map((n) => AppNotification(
              id: n.id,
              title: n.title,
              body: n.body,
              time: n.time,
              isRead: true,
              icon: n.icon,
            ))
        .toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
