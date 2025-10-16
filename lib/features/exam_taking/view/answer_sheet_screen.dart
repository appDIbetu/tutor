import 'package:flutter/material.dart';
import '../models/exam_attempt_model.dart';
import '../models/exam_question_model.dart';

class AnswerSheetScreen extends StatelessWidget {
  final ExamAttempt attempt;
  final List<ExamQuestion> questions;

  const AnswerSheetScreen({
    super.key,
    required this.attempt,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(attempt.examTitle),
        backgroundColor: const Color(0xFFF8D7DA),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      'कुल प्रश्न',
                      '${attempt.totalQuestions}',
                    ),
                    _buildSummaryItem('सही', '${attempt.correctCount}'),
                    _buildSummaryItem('गलत', '${attempt.wrongCount}'),
                    _buildSummaryItem(
                      'अनुत्तरित',
                      '${attempt.unattemptedCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      'अन्तिम अङ्क',
                      '${attempt.finalMarks.toStringAsFixed(1)}',
                    ),
                    _buildSummaryItem(
                      'समय लाग्यो',
                      '${_formatTime(attempt.timeTakenSeconds)}',
                    ),
                    _buildSummaryItem(
                      'स्थिति',
                      attempt.isPassed ? 'उत्तीर्ण' : 'अनुत्तीर्ण',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswer = attempt.selectedAnswers[index];
                final correctAnswer = question.correctAnswerIndex;
                final isCorrect = userAnswer == correctAnswer;

                return _buildQuestionCard(
                  context,
                  question,
                  index + 1,
                  userAnswer,
                  isCorrect,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8D7DA),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    ExamQuestion question,
    int questionNumber,
    int? userAnswer,
    bool isCorrect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'प्रश्न $questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Question Text
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value;
            final isUserAnswer = userAnswer == optionIndex;
            final isCorrectAnswer = question.correctAnswerIndex == optionIndex;

            Color backgroundColor;
            Color textColor;
            IconData? icon;

            if (isCorrectAnswer) {
              backgroundColor = Colors.green.withValues(alpha: 0.1);
              textColor = Colors.green.shade700;
              icon = Icons.check_circle;
            } else if (isUserAnswer && !isCorrectAnswer) {
              backgroundColor = Colors.red.withValues(alpha: 0.1);
              textColor = Colors.red.shade700;
              icon = Icons.cancel;
            } else {
              backgroundColor = Colors.grey.withValues(alpha: 0.1);
              textColor = Colors.grey.shade700;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrectAnswer || isUserAnswer
                      ? textColor
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${String.fromCharCode(65 + optionIndex)}. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Expanded(
                    child: Text(optionText, style: TextStyle(color: textColor)),
                  ),
                  if (icon != null) Icon(icon, color: textColor, size: 16),
                ],
              ),
            );
          }).toList(),

          // Answer Summary
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'तपाईंको उत्तर: ${String.fromCharCode(65 + (userAnswer ?? -1))} ${userAnswer != null ? question.options[userAnswer] : 'अनुत्तरित'}',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
