import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Get user name from Firebase Auth and SharedPreferences
      String userName = 'Guest';

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to get name from Firebase Auth first
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          userName = user.displayName!;
        } else {
          // Fallback to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final savedName = prefs.getString('user_name') ?? '';
          if (savedName.isNotEmpty && savedName != 'NA') {
            userName = savedName;
          }
        }
      }

      emit(HomeLoadSuccess(userName: userName));
    } catch (e) {
      emit(HomeLoadFailure(error: e.toString()));
    }
  }
}
