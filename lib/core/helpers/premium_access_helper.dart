import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../premium/premium_bloc.dart';
import '../widgets/premium_widgets.dart';
import '../models/api_response_models.dart';

class PremiumAccessHelper {
  // Check if user has premium access
  static bool hasPremiumAccess(BuildContext context) {
    final premiumState = context.read<PremiumBloc>().state;
    return premiumState is PremiumActive;
  }

  // Get premium status from context
  static PremiumState getPremiumState(BuildContext context) {
    return context.read<PremiumBloc>().state;
  }

  // Check if user has access to a specific item based on is_locked and is_premium
  static bool hasAccessToItem(BuildContext context, LockableItem item) {
    final userIsPremium = hasPremiumAccess(context);
    return item.hasAccess(userIsPremium);
  }

  // Wrap content with premium lock if user doesn't have access
  static Widget wrapWithPremiumLock(
    BuildContext context, {
    required Widget child,
    String? message,
    VoidCallback? onUpgrade,
  }) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        if (state is PremiumActive) {
          return child;
        } else {
          return PremiumLockWidget(
            message: message,
            onUpgrade: onUpgrade,
            child: child,
          );
        }
      },
    );
  }

  // Wrap content with access control based on item's locked status
  static Widget wrapWithAccessControl(
    BuildContext context, {
    required LockableItem item,
    required Widget child,
    String? message,
    VoidCallback? onUpgrade,
  }) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        final userIsPremium = state is PremiumActive;
        final hasAccess = item.hasAccess(userIsPremium);

        if (hasAccess) {
          return child;
        } else {
          return PremiumLockWidget(
            message: message ?? _getDefaultLockMessage(item),
            onUpgrade: onUpgrade,
            child: child,
          );
        }
      },
    );
  }

  // Get appropriate lock message based on item type
  static String _getDefaultLockMessage(LockableItem item) {
    if (item.isLocked) {
      return 'This content is locked. Upgrade to premium to access.';
    } else if (item.isPremium) {
      return 'This is a premium feature. Upgrade to access.';
    }
    return 'Access denied. Please upgrade to premium.';
  }

  // Show premium badge if user has premium
  static Widget wrapWithPremiumBadge(
    BuildContext context, {
    required Widget child,
    String? badgeText,
  }) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        if (state is PremiumActive) {
          return PremiumBadge(badgeText: badgeText, child: child);
        } else {
          return child;
        }
      },
    );
  }

  // Create premium button with appropriate state
  static Widget createPremiumButton(
    BuildContext context, {
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
  }) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        final isPremium = state is PremiumActive;
        return PremiumButton(
          text: text,
          isPremium: isPremium,
          onPressed: onPressed,
          icon: icon,
        );
      },
    );
  }

  // Create premium feature card with appropriate state
  static Widget createPremiumFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        final isPremium = state is PremiumActive;
        return PremiumFeatureCard(
          title: title,
          description: description,
          icon: icon,
          isPremium: isPremium,
          onTap: onTap,
        );
      },
    );
  }

  // Refresh premium status
  static void refreshPremiumStatus(BuildContext context) {
    context.read<PremiumBloc>().add(PremiumStatusRefreshed());
  }

  // Request premium status
  static void requestPremiumStatus(BuildContext context) {
    context.read<PremiumBloc>().add(PremiumStatusRequested());
  }
}

// Extension for easy premium access checking
extension PremiumAccess on BuildContext {
  bool get hasPremiumAccess => PremiumAccessHelper.hasPremiumAccess(this);

  PremiumState get premiumState => PremiumAccessHelper.getPremiumState(this);

  void refreshPremiumStatus() => PremiumAccessHelper.refreshPremiumStatus(this);

  void requestPremiumStatus() => PremiumAccessHelper.requestPremiumStatus(this);
}
