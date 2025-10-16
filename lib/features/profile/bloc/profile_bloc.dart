import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

// Simple model for user data
class UserProfile extends Equatable {
  final String name;
  final String email;
  final String mobile;
  final String dob;
  final String address;

  const UserProfile({
    required this.name,
    required this.email,
    required this.mobile,
    required this.dob,
    required this.address,
  });

  @override
  List<Object> get props => [name, email, mobile, dob, address];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileDataLoaded>(_onProfileDataLoaded);
  }

  Future<void> _onProfileDataLoaded(
    ProfileDataLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadInProgress());
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      const userProfile = UserProfile(
        name: 'Shivam Chaudhary',
        email: 'shivamc1010@gmail.com',
        mobile: '+977-0000000000',
        dob: 'DD/MM/YYYY',
        address: 'Not Available',
      );
      emit(const ProfileLoadSuccess(userProfile: userProfile));
    } catch (e) {
      emit(ProfileLoadFailure(error: e.toString()));
    }
  }
}
