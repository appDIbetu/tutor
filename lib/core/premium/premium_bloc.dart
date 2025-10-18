import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/auth_service.dart';
import '../models/firebase_user_response.dart';

// Events
abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object?> get props => [];
}

class PremiumStatusRequested extends PremiumEvent {}

class PremiumStatusRefreshed extends PremiumEvent {}

// States
abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumActive extends PremiumState {
  final FirebaseUserResponse userData;

  const PremiumActive({required this.userData});

  @override
  List<Object> get props => [userData];
}

class PremiumInactive extends PremiumState {
  final FirebaseUserResponse? userData;

  const PremiumInactive({this.userData});

  @override
  List<Object?> get props => [userData];
}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  PremiumBloc() : super(PremiumInitial()) {
    on<PremiumStatusRequested>(_onPremiumStatusRequested);
    on<PremiumStatusRefreshed>(_onPremiumStatusRefreshed);
  }

  Future<void> _onPremiumStatusRequested(
    PremiumStatusRequested event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumLoading());
    try {
      // Always validate with backend first
      final userData = await AuthService.validateUserWithBackend();
      if (userData != null) {
        await AuthService.saveFirebaseUserData(userData);
        if (userData.isPremium) {
          emit(PremiumActive(userData: userData));
        } else {
          emit(PremiumInactive(userData: userData));
        }
      } else {
        // Fallback to local data if backend fails
        final localUserData = await AuthService.getSavedFirebaseUserData();
        if (localUserData != null) {
          if (localUserData.isPremium) {
            emit(PremiumActive(userData: localUserData));
          } else {
            emit(PremiumInactive(userData: localUserData));
          }
        } else {
          emit(const PremiumInactive());
        }
      }
    } catch (e) {
      // Fallback to local data if backend fails
      try {
        final localUserData = await AuthService.getSavedFirebaseUserData();
        if (localUserData != null) {
          if (localUserData.isPremium) {
            emit(PremiumActive(userData: localUserData));
          } else {
            emit(PremiumInactive(userData: localUserData));
          }
        } else {
          emit(const PremiumInactive());
        }
      } catch (localError) {
        emit(PremiumError(message: e.toString()));
      }
    }
  }

  Future<void> _onPremiumStatusRefreshed(
    PremiumStatusRefreshed event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final userData = await AuthService.validateUserWithBackend();
      if (userData != null) {
        await AuthService.saveFirebaseUserData(userData);
        if (userData.isPremium) {
          emit(PremiumActive(userData: userData));
        } else {
          emit(PremiumInactive(userData: userData));
        }
      }
    } catch (e) {
      emit(PremiumError(message: e.toString()));
    }
  }
}
