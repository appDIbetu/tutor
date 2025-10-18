import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../../core/helpers/premium_access_helper.dart';

/// Example screen showing how to implement premium access across all screens
class PremiumAccessExampleScreen extends StatefulWidget {
  const PremiumAccessExampleScreen({super.key});

  @override
  State<PremiumAccessExampleScreen> createState() =>
      _PremiumAccessExampleScreenState();
}

class _PremiumAccessExampleScreenState
    extends State<PremiumAccessExampleScreen> {
  @override
  void initState() {
    super.initState();
    // Always refresh premium status when screen loads
    context.requestPremiumStatus();
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
          'Premium Access Example',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => context.refreshPremiumStatus(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Method 1: Using BlocBuilder directly
            _buildMethod1Example(),

            const SizedBox(height: 20),

            // Method 2: Using PremiumAccessHelper
            _buildMethod2Example(),

            const SizedBox(height: 20),

            // Method 3: Using context extension
            _buildMethod3Example(),

            const SizedBox(height: 20),

            // Method 4: Premium locked content
            _buildMethod4Example(),

            const SizedBox(height: 20),

            // Method 5: Premium buttons and cards
            _buildMethod5Example(),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod1Example() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Method 1: BlocBuilder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<PremiumBloc, PremiumState>(
              builder: (context, state) {
                if (state is PremiumActive) {
                  return const Text(
                    '✅ Premium Active - Full Access',
                    style: TextStyle(color: Colors.green),
                  );
                } else if (state is PremiumInactive) {
                  return const Text(
                    '❌ Free Plan - Limited Access',
                    style: TextStyle(color: Colors.orange),
                  );
                } else {
                  return const Text(
                    '⏳ Loading...',
                    style: TextStyle(color: Colors.grey),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod2Example() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Method 2: PremiumAccessHelper',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              PremiumAccessHelper.hasPremiumAccess(context)
                  ? '✅ Premium Access Available'
                  : '❌ Premium Access Required',
              style: TextStyle(
                color: PremiumAccessHelper.hasPremiumAccess(context)
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod3Example() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Method 3: Context Extension',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.hasPremiumAccess
                  ? '✅ Premium Access via Extension'
                  : '❌ No Premium Access via Extension',
              style: TextStyle(
                color: context.hasPremiumAccess ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod4Example() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Method 4: Premium Locked Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PremiumAccessHelper.wrapWithPremiumLock(
              context,
              message: 'This is premium content. Upgrade to access!',
              onUpgrade: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirecting to upgrade...')),
                );
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Premium Content Here')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethod5Example() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Method 5: Premium UI Components',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Premium Badge
            PremiumAccessHelper.wrapWithPremiumBadge(
              context,
              badgeText: 'PREMIUM',
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(child: Text('Feature with Premium Badge')),
              ),
            ),

            const SizedBox(height: 16),

            // Premium Button
            PremiumAccessHelper.createPremiumButton(
              context,
              text: 'Premium Feature',
              icon: const Icon(Icons.star),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium feature activated!')),
                );
              },
            ),

            const SizedBox(height: 16),

            // Premium Feature Card
            PremiumAccessHelper.createPremiumFeatureCard(
              context,
              title: 'Advanced Analytics',
              description: 'Get detailed insights into your performance',
              icon: Icons.analytics,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Advanced Analytics...'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
