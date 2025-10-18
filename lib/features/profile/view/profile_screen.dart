import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// This is a relative path. It goes "up" one level from the 'view' folder
// and then "down" into the 'bloc' folder.
import '../bloc/profile_bloc.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar to white text/icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadInProgress || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileLoadFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state is ProfileLoadSuccess) {
            final user = state.userProfile;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 20),
                  _buildInfoCard(user),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('SIGN OUT'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('About us | Privacy'),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile user) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 70, bottom: 0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              'S',
              style: TextStyle(fontSize: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Text(
            'Basic Plan',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.contact_mail, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Contact us', style: TextStyle(color: AppColors.primary)),
                SizedBox(width: 10),
                Text('|', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 10),
                Icon(Icons.share, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Share us', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person, 'Name', user.name),
          _buildInfoRow(Icons.phone, 'Mobile', user.mobile),
          _buildInfoRow(Icons.email, 'Email', user.email),
          _buildInfoRow(Icons.calendar_today, 'DOB', user.dob),
          _buildInfoRow(
            Icons.location_on,
            'Address',
            user.address,
            hasDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool hasDivider = true,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
            ),
          ],
        ),
        if (hasDivider) const Divider(height: 16),
      ],
    );
  }
}
