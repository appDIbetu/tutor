import 'package:flutter/material.dart';

class QuestionBoard extends StatelessWidget {
  final int questionIndex;
  final String questionText;

  const QuestionBoard({
    super.key,
    required this.questionIndex,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q.no.${questionIndex + 1}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          questionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
