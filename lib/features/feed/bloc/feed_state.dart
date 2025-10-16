// Make sure this is the first and only directive at the top
part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

// Your state classes, e.g.:
class FeedInitial extends FeedState {}

class FeedLoadInProgress extends FeedState {}

class FeedLoadSuccess extends FeedState {
  final List<FeedItem> items;

  // This is a NAMED constructor. Note the curly braces {}
  // and the 'required' keyword.
  const FeedLoadSuccess({required this.items});

  @override
  List<Object> get props => [items];
}

// lib/features/feed/bloc/feed_state.dart

class FeedLoadFailure extends FeedState {
  final String error;

  // This is a NAMED constructor.
  const FeedLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}
