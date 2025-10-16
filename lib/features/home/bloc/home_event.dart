part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// Event to trigger loading the initial data for the home screen
class HomeDataLoaded extends HomeEvent {}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoadInProgress extends HomeState {}

class HomeLoadSuccess extends HomeState {
  final String userName;
  // You would have models for topics, promos, etc.
  // final List<Topic> topics;
  // final List<Promo> promos;

  const HomeLoadSuccess({required this.userName});

  @override
  List<Object> get props => [userName];
}

class HomeLoadFailure extends HomeState {
  final String error;

  const HomeLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}
