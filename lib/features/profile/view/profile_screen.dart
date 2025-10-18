import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> userData = {};
  bool isLoading = true;
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Request premium status when screen loads
    context.read<PremiumBloc>().add(PremiumStatusRequested());
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();

      // Migrate any existing empty strings to "NA"
      await AuthService.migrateEmptyStringsToNA();

      setState(() {
        final savedName = prefs.getString('user_name') ?? '';
        final savedEmail = prefs.getString('user_email') ?? '';
        final savedMobile = prefs.getString('user_mobile') ?? '';

        userData = {
          'name': user?.displayName ?? (savedName.isEmpty ? 'NA' : savedName),
          'email': user?.email ?? (savedEmail.isEmpty ? 'NA' : savedEmail),
          'mobile': savedMobile.isEmpty ? 'NA' : savedMobile,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userData = {'name': 'NA', 'email': 'NA', 'mobile': 'NA'};
        isLoading = false;
      });
    }
  }

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

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate directly to auth screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
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
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = userData['name'] ?? 'NA';
    final email = userData['email'] ?? 'NA';
    final initials = name.isNotEmpty && name != 'NA'
        ? name
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join('')
              .toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 70, bottom: 0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              initials,
              style: const TextStyle(fontSize: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          BlocBuilder<PremiumBloc, PremiumState>(
            builder: (context, premiumState) {
              final isPremium = premiumState is PremiumActive;
              final planName = isPremium ? 'Premium Plan' : 'Basic Plan';

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    planName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showUpgradeDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Upgrade',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
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

  Widget _buildInfoCard() {
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
          _buildInfoRow(
            Icons.person,
            'Name',
            userData['name'] ?? 'NA',
            isEditable: false,
          ),
          _buildInfoRow(
            Icons.email,
            'Email',
            userData['email'] ?? 'NA',
            isEditable: false,
          ),
          _buildInfoRow(
            Icons.phone,
            'Mobile',
            userData['mobile'] ?? 'NA',
            hasDivider: false,
            isEditable: true,
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
    bool isEditable = true,
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
            if (isEditable)
              IconButton(
                onPressed: () {
                  if (label == 'Mobile') {
                    _showEditMobileDialog(context);
                  }
                },
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
              ),
          ],
        ),
        if (hasDivider) const Divider(height: 16),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Upgrade to Premium',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Unlock all premium features including unlimited practice tests, advanced analytics, and priority support.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthLoading) {
                  // Show loading indicator
                } else if (state is AuthAuthenticated) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully upgraded to Premium!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Refresh premium status
                  context.read<PremiumBloc>().add(PremiumStatusRefreshed());
                } else if (state is AuthError) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Upgrade failed: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthUpgradeToPremiumRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Upgrade Now'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditMobileDialog(BuildContext context) {
    _mobileController.text = userData['mobile'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.phone, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Edit Mobile Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'Enter your mobile number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthLoading) {
                  // Show loading indicator
                } else if (state is AuthAuthenticated) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mobile number updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload user data to reflect changes
                  _loadUserData();
                } else if (state is AuthError) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update failed: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: ElevatedButton(
                onPressed: () {
                  final newMobile = _mobileController.text.trim();
                  if (newMobile.isNotEmpty && newMobile.length >= 10) {
                    context.read<AuthBloc>().add(
                      AuthProfileUpdateRequested(
                        name: userData['name'] ?? '',
                        mobile: newMobile,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid mobile number'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Update'),
              ),
            ),
          ],
        );
      },
    );
  }
}
