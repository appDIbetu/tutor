import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- CORRECT RELATIVE IMPORTS ---
import '../../features/calendar/bloc/calendar_bloc.dart';
import '../../features/exam/bloc/exam_bloc.dart';
import '../../features/feed/bloc/feed_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/auth/auth_bloc.dart';
import '../../core/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => HomeBloc()..add(HomeDataLoaded())),
        BlocProvider(
          create: (context) => ProfileBloc()..add(ProfileDataLoaded()),
        ),
        BlocProvider(create: (context) => ExamBloc()..add(ExamsFetched())),
        BlocProvider(
          create: (context) => CalendarBloc()..add(CalendarDataLoaded()),
        ),
        BlocProvider(create: (context) => FeedBloc()..add(FeedDataLoaded())),
      ],
      child: MaterialApp(
        title: 'Legal Practice App',
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
              .copyWith(
                primary: AppColors.primary,
                secondary: AppColors.accent,
                surface: Colors.white,
                onPrimary: Colors.white,
                onSurface: AppColors.textDark,
              ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              overlayColor: Colors.grey.withValues(alpha: 0.1),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: const BorderSide(color: Colors.grey),
              overlayColor: Colors.grey.withValues(alpha: 0.08),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
