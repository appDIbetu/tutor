import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/auth/auth_bloc.dart';
import '../core/premium/premium_bloc.dart';
import '../features/dashboard/view/dashboard_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh premium status when app comes to foreground
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PremiumBloc>().add(PremiumStatusRefreshed());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh premium status when app comes to foreground
      context.read<PremiumBloc>().add(PremiumStatusRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // User signed out, navigate to auth screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/auth', (route) => false);
        }
      },
      child: const DashboardScreen(),
    );
  }
}
