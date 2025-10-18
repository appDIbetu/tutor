import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../../core/widgets/premium_widgets.dart';

class PremiumDemoScreen extends StatefulWidget {
  const PremiumDemoScreen({super.key});

  @override
  State<PremiumDemoScreen> createState() => _PremiumDemoScreenState();
}

class _PremiumDemoScreenState extends State<PremiumDemoScreen> {
  @override
  void initState() {
    super.initState();
    // Request premium status when screen loads
    context.read<PremiumBloc>().add(PremiumStatusRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Premium Features Demo',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PremiumBloc>().add(PremiumStatusRefreshed());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<PremiumBloc, PremiumState>(
        builder: (context, state) {
          if (state is PremiumLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isPremium = state is PremiumActive;
          final userData = state is PremiumActive ? state.userData : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPremium ? Icons.star : Icons.star_border,
                              color: isPremium ? Colors.amber : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPremium ? 'Premium Active' : 'Free Plan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPremium ? AppColors.primary : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (userData != null) ...[
                          const SizedBox(height: 8),
                          Text('Plan: ${userData.subscriptionPlan ?? 'N/A'}'),
                          if (userData.premiumExpiresAt != null)
                            Text('Expires: ${userData.premiumExpiresAt!.toLocal().toString().split(' ')[0]}'),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Premium Feature Cards
                Text(
                  'Available Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                PremiumFeatureCard(
                  title: 'Advanced Analytics',
                  description: 'Get detailed insights into your performance',
                  icon: Icons.analytics,
                  isPremium: isPremium,
                  onTap: () {
                    if (!isPremium) {
                      _showUpgradeDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Advanced Analytics...')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                PremiumFeatureCard(
                  title: 'Unlimited Practice Tests',
                  description: 'Access to all practice tests without limits',
                  icon: Icons.quiz,
                  isPremium: isPremium,
                  onTap: () {
                    if (!isPremium) {
                      _showUpgradeDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Practice Tests...')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                PremiumFeatureCard(
                  title: 'Priority Support',
                  description: 'Get priority customer support',
                  icon: Icons.support_agent,
                  isPremium: isPremium,
                  onTap: () {
                    if (!isPremium) {
                      _showUpgradeDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Support...')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Premium Lock Widget Example
                Text(
                  'Locked Content Example',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PremiumLockWidget(
                    message: isPremium 
                        ? null 
                        : 'This content is only available for premium users. Upgrade now to unlock!',
                    onUpgrade: isPremium ? null : () => _showUpgradeDialog(context),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_open,
                            size: 48,
                            color: isPremium ? AppColors.primary : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isPremium ? 'Premium Content' : 'Locked Content',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isPremium ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPremium 
                                ? 'This content is unlocked for you!' 
                                : 'This content is locked',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Premium Badge Example
                Text(
                  'Premium Badge Example',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                PremiumBadge(
                  badgeText: isPremium ? 'PREMIUM' : 'FREE',
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'Feature Card',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Premium Button Example
                Text(
                  'Premium Button Example',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    PremiumButton(
                      text: 'Free Feature',
                      isPremium: false,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Free feature activated!')),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    PremiumButton(
                      text: 'Premium Feature',
                      isPremium: true,
                      onPressed: isPremium ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Premium feature activated!')),
                        );
                      } : () => _showUpgradeDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
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
              Icon(
                Icons.star,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Unlock all premium features and get unlimited access to practice tests, advanced analytics, and priority support.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirecting to upgrade page...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }
}
