import 'package:equatable/equatable.dart';
import 'package:github_trending_repos/Model/github_model.dart';

class DashboardState extends Equatable {
  DashboardState init() {
    return DashboardState();
  }

  DashboardState clone() {
    return DashboardState();
  }

  @override
  List<Object?> get props => [];
}

class DashboardLoadedState extends DashboardState {
  final bool isLoadSuccess;
  final List<Items> items;

  DashboardLoadedState(this.isLoadSuccess, this.items);
  @override
  List<Object?> get props => [isLoadSuccess, items];
}

class DashboardItemsLoadFailedState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class InternetGoneState extends DashboardState {
  final List<Items> items;

  InternetGoneState(this.items);
  @override
  List<Object?> get props => [items];
}

class RefreshDashboardState extends DashboardState {
  final List<Items> items;

  RefreshDashboardState(this.items);

  @override
  List<Object?> get props => [items];
}
