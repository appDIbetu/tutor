part of 'exam_taking_bloc.dart';

abstract class ExamTakingEvent extends Equatable {
  const ExamTakingEvent();

  @override
  List<Object?> get props => [];
}

// Event to start the exam
class ExamStarted extends ExamTakingEvent {
  final String examId;
  final List<ExamQuestion> questions;
  final int durationInSeconds;
  final double positiveMark;
  final double negativeMark;
  const ExamStarted({
    required this.examId,
    required this.questions,
    required this.durationInSeconds,
    required this.positiveMark,
    required this.negativeMark,
  });

  @override
  List<Object?> get props => [
    examId,
    questions,
    durationInSeconds,
    positiveMark,
    negativeMark,
  ];
}

// Event when the user selects an answer for a SPECIFIC question
class AnswerSelected extends ExamTakingEvent {
  final int questionIndex; // <-- ADD THIS
  final int selectedOptionIndex;
  const AnswerSelected({
    required this.questionIndex,
    required this.selectedOptionIndex,
  }); // <-- UPDATE THIS
}

// Event to clear the answer for a specific question
class AnswerCleared extends ExamTakingEvent {
  final int questionIndex;
  const AnswerCleared(this.questionIndex);
}

// Event triggered by the timer every second
class TimerTicked extends ExamTakingEvent {
  final int remainingTime;
  const TimerTicked(this.remainingTime);
}

// Event to end the exam
class ExamSubmitted extends ExamTakingEvent {}
