import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/exam_taking_bloc.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  // Helper to format time
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ExamTakingBloc>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              BlocBuilder<ExamTakingBloc, ExamTakingState>(
                // buildWhen is an optimization to only rebuild when time changes
                buildWhen: (previous, current) =>
                    previous.remainingTime != current.remainingTime,
                builder: (context, state) {
                  return Text(
                    _formatDuration(state.remainingTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          TextButton(onPressed: () {}, child: const Text('Reset')),
          ElevatedButton(
            onPressed: () {
              bloc.add(ExamSubmitted());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('End Test'),
          ),
        ],
      ),
    );
  }
}
