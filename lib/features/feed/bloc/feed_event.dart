// Make sure this is the first and only directive at the top
part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

// Your event classes, e.g.:
class FeedDataLoaded extends FeedEvent {}
