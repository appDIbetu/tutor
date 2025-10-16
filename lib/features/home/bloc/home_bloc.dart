import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // You would inject your repositories here, e.g., UserRepository
  HomeBloc() : super(HomeInitial()) {
    on<HomeDataLoaded>(_onHomeDataLoaded);
  }

  Future<void> _onHomeDataLoaded(
    HomeDataLoaded event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadInProgress());
    try {
      // --- FAKE API CALL ---
      // In a real app, you would fetch data from a repository:
      // final user = await _userRepository.getUser();
      // final topics = await _topicRepository.getTopics();
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay

      emit(const HomeLoadSuccess(userName: 'Shivam Chaudhary'));
    } catch (e) {
      emit(HomeLoadFailure(error: e.toString()));
    }
  }
}
