import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuestionOptions extends StatelessWidget {
  final List<String> options;
  final int? selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;
  final int? correctAnswerIndex;
  final bool isAnswerMode;

  const QuestionOptions({
    super.key,
    required this.options,
    this.selectedOptionIndex,
    required this.onOptionSelected,
    this.correctAnswerIndex,
    this.isAnswerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Using ListView.builder is inefficient for a small, fixed list.
    // A Column is simpler and more performant here.
    return Column(
      children: List.generate(options.length, (index) {
        final BorderRadius radius = BorderRadius.circular(8);
        final bool isCorrect = correctAnswerIndex == index;
        final bool isSelected = selectedOptionIndex == index;

        // Determine colors based on mode
        Color borderColor = Colors.grey.shade300;
        Color backgroundColor = Colors.transparent;
        Color textColor = Colors.black;

        if (isAnswerMode) {
          if (isCorrect) {
            borderColor = Colors.green;
            backgroundColor = Colors.green.withValues(alpha: 0.1);
            textColor = Colors.green.shade700;
          }
        } else {
          if (isSelected) {
            borderColor = AppColors.primary;
            backgroundColor = AppColors.primary.withValues(alpha: 0.1);
            textColor = AppColors.primary;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: isAnswerMode ? null : () => onOptionSelected(index),
              borderRadius: radius,
              splashColor: isAnswerMode
                  ? Colors.transparent
                  : AppColors.primary.withValues(alpha: 0.04),
              highlightColor: isAnswerMode
                  ? Colors.transparent
                  : AppColors.primary.withValues(alpha: 0.02),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: isAnswerMode && isCorrect ? 2 : 1,
                  ),
                  borderRadius: radius,
                  color: backgroundColor,
                ),
                child: Row(
                  children: [
                    if (isAnswerMode) ...[
                      // Show checkmark for correct answer in answer mode
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                        child: isCorrect
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Radio<int>(
                        value: index,
                        groupValue: selectedOptionIndex,
                        onChanged: (value) {
                          if (value != null) {
                            onOptionSelected(value);
                          }
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                    Expanded(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: isAnswerMode && isCorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
