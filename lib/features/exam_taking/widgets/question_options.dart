import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuestionOptions extends StatelessWidget {
  final List<String> options;
  final int? selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;

  const QuestionOptions({
    super.key,
    required this.options,
    this.selectedOptionIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Using ListView.builder is inefficient for a small, fixed list.
    // A Column is simpler and more performant here.
    return Column(
      children: List.generate(options.length, (index) {
        final BorderRadius radius = BorderRadius.circular(8);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: () => onOptionSelected(index),
              borderRadius: radius,
              splashColor: AppColors.primary.withValues(alpha: 0.04),
              highlightColor: AppColors.primary.withValues(alpha: 0.02),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: radius,
                ),
                child: Row(
                  children: [
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
                    Expanded(
                      child: Text(
                        options[index],
                        style: const TextStyle(fontSize: 14),
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
