import 'package:equatable/equatable.dart';

class ExamQuestion extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation; // optional explanation shown in review

  const ExamQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  @override
  List<Object?> get props => [
    id,
    questionText,
    options,
    correctAnswerIndex,
    explanation,
  ];
}
