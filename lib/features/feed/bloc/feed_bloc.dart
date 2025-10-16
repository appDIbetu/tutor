import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'feed_event.dart';
part 'feed_state.dart';

// Simple model for a feed item
class FeedItem extends Equatable {
  final String title;
  final String summary;
  final String author;
  final DateTime postDate;

  const FeedItem({
    required this.title,
    required this.summary,
    required this.author,
    required this.postDate,
  });

  @override
  List<Object> get props => [title, summary, author, postDate];
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedInitial()) {
    on<FeedDataLoaded>(_onFeedDataLoaded);
  }

  Future<void> _onFeedDataLoaded(
    FeedDataLoaded event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoadInProgress());
    try {
      // --- FAKE API CALL ---
      await Future.delayed(const Duration(milliseconds: 700));

      final mockItems = [
        FeedItem(
          title: 'New Exam Series for Engineering Available!',
          summary:
              'We have just launched a new series of exams curated by experts to help you ace your entrance tests.',
          author: 'Prepotic Team',
          postDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        FeedItem(
          title: 'Top 5 Tips for Time Management During Exams',
          summary:
              'Learn how to manage your time effectively to maximize your score and reduce stress.',
          author: 'Expert Counsellor',
          postDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      emit(FeedLoadSuccess(items: mockItems));
    } catch (e) {
      emit(FeedLoadFailure(error: e.toString()));
    }
  }
}
