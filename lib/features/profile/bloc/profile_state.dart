part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoadInProgress extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final UserProfile userProfile;
  const ProfileLoadSuccess({required this.userProfile});
  @override
  List<Object> get props => [userProfile];
}

class ProfileLoadFailure extends ProfileState {
  final String error;
  const ProfileLoadFailure({required this.error});
  @override
  List<Object> get props => [error];
}
