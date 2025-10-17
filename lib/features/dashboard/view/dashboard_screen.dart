import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../calendar/view/calendar_screen.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../feed/view/feed_screen.dart';
import '../../home/view/home_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(), // Events
    FeedScreen(), // Notices
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(),
      child: BlocBuilder<DashboardCubit, int>(
        builder: (context, selectedIndex) {
          return Scaffold(
            body: IndexedStack(index: selectedIndex, children: _screens),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 8,
                  ),
                  child: GNav(
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: Colors.white,
                    tabs: const [
                      GButton(icon: Icons.home_outlined, text: 'Home'),
                      GButton(icon: Icons.event_outlined, text: 'Events'),
                      GButton(
                        icon: Icons.notifications_outlined,
                        text: 'Notices',
                      ),
                      GButton(icon: Icons.person_outline, text: 'Profile'),
                    ],
                    selectedIndex: selectedIndex,
                    onTabChange: (index) =>
                        context.read<DashboardCubit>().changeTab(index),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
