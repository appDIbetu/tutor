import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String mobile;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.mobile,
  });

  @override
  List<Object> get props => [email, password, name, mobile];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final String name;
  final String mobile;

  const AuthProfileUpdateRequested({required this.name, required this.mobile});

  @override
  List<Object> get props => [name, mobile];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isProfileComplete;

  const AuthAuthenticated({
    required this.user,
    required this.isProfileComplete,
  });

  @override
  List<Object> get props => [user, isProfileComplete];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);

    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? user) {
      if (user != null) {
        _checkProfileCompleteness(user);
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = AuthService.currentUser;
    if (user != null) {
      await _checkProfileCompleteness(user);
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await AuthService.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      if (result?.user != null) {
        await _checkProfileCompleteness(result!.user!);
      } else {
        emit(const AuthError(message: 'Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await AuthService.signUpWithEmailPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        mobile: event.mobile,
      );

      if (result?.user != null) {
        emit(AuthAuthenticated(user: result!.user!, isProfileComplete: true));
      } else {
        emit(const AuthError(message: 'Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await AuthService.signInWithGoogle();

      if (result?.user != null) {
        await _checkProfileCompleteness(result!.user!);
      } else {
        emit(const AuthError(message: 'Google sign in failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await AuthService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await AuthService.updateProfile(name: event.name, mobile: event.mobile);

      final user = AuthService.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user: user, isProfileComplete: true));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _checkProfileCompleteness(User user) async {
    final isComplete = await AuthService.isProfileComplete();
    emit(AuthAuthenticated(user: user, isProfileComplete: isComplete));
  }
}
