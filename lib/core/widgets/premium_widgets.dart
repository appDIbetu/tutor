import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PremiumLockWidget extends StatelessWidget {
  final Widget child;
  final String? message;
  final VoidCallback? onUpgrade;

  const PremiumLockWidget({
    super.key,
    required this.child,
    this.message,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Premium Feature',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message ??
                          'This feature is available for premium users only.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          onUpgrade ??
                          () {
                            // Default upgrade action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Upgrade to premium to unlock this feature',
                                ),
                              ),
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Upgrade to Premium'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PremiumBadge extends StatelessWidget {
  final Widget child;
  final String? badgeText;

  const PremiumBadge({super.key, required this.child, this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText ?? 'PREMIUM',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPremium;
  final Widget? icon;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPremium = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPremium ? AppColors.primary : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(text),
          if (isPremium) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 16),
          ],
        ],
      ),
    );
  }
}

class PremiumFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isPremium;
  final VoidCallback? onTap;

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isPremium = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPremium
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isPremium ? AppColors.primary : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? AppColors.primary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isPremium)
                Icon(Icons.star, color: AppColors.primary, size: 20)
              else
                Icon(Icons.lock, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
