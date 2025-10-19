import 'package:flutter/material.dart';

class LockStatusButton extends StatelessWidget {
  final bool isLocked;
  final bool isPremium;
  final VoidCallback? onTap;
  final String? tooltip;
  final double? size;
  final bool showText;

  const LockStatusButton({
    super.key,
    required this.isLocked,
    required this.isPremium,
    this.onTap,
    this.tooltip,
    this.size,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 32.0;
    final iconSize = buttonSize * 0.5;

    Widget button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: isLocked ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(buttonSize * 0.2),
        border: Border.all(
          color: isLocked ? Colors.red.shade300 : Colors.green.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(buttonSize * 0.2),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  size: iconSize,
                  color: isLocked ? Colors.red.shade600 : Colors.green.shade600,
                ),
                if (showText) ...[
                  const SizedBox(width: 4),
                  Text(
                    isLocked ? 'लक' : 'खुला',
                    style: TextStyle(
                      fontSize: iconSize * 0.4,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

class LockStatusBadge extends StatelessWidget {
  final bool isLocked;
  final bool isPremium;
  final String? customText;

  const LockStatusBadge({
    super.key,
    required this.isLocked,
    required this.isPremium,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final text = customText ?? (isLocked ? 'लक गरिएको' : 'खुला');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? Colors.red.shade300 : Colors.green.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            size: 12,
            color: isLocked ? Colors.red.shade600 : Colors.green.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isLocked ? Colors.red.shade600 : Colors.green.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
