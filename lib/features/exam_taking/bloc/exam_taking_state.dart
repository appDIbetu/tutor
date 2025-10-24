part of 'exam_taking_bloc.dart';

enum ExamStatus { initial, inProgress, submitting, completed }

class ExamTakingState extends Equatable {
  final ExamStatus status;
  final String? examId; // Add exam ID for API submission
  final List<ExamQuestion> questions;
  final int currentQuestionIndex;
  final Map<int, int>
  selectedAnswers; // Map<questionIndex, selectedOptionIndex>
  final int remainingTime;
  final int score; // raw number of correct answers when simple scoring is used
  final bool
  isSubject; // Add this to distinguish subject practice from exam practice

  // --- Result analytics ---
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int unattemptedCount;
  final int durationSeconds; // total allotted seconds
  final int timeTakenSeconds; // durationSeconds - remainingTime at submit
  final double positiveMark; // marks added per correct
  final double negativeMark; // marks deducted per wrong
  final double finalMarks; // score computed with marking scheme

  const ExamTakingState({
    this.status = ExamStatus.initial,
    this.examId,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.remainingTime = 0,
    this.score = 0,
    this.isSubject = false, // Default to false for backward compatibility
    this.totalQuestions = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.unattemptedCount = 0,
    this.durationSeconds = 0,
    this.timeTakenSeconds = 0,
    this.positiveMark = 1.0,
    this.negativeMark = 0.25,
    this.finalMarks = 0.0,
  });

  // Helper to get the current question
  ExamQuestion? get currentQuestion {
    if (questions.isNotEmpty && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  // Helper to check if it's the last question
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  ExamTakingState copyWith({
    ExamStatus? status,
    String? examId,
    List<ExamQuestion>? questions,
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    int? remainingTime,
    int? score,
    bool? isSubject,
    int? totalQuestions,
    int? correctCount,
    int? wrongCount,
    int? unattemptedCount,
    int? durationSeconds,
    int? timeTakenSeconds,
    double? positiveMark,
    double? negativeMark,
    double? finalMarks,
  }) {
    return ExamTakingState(
      status: status ?? this.status,
      examId: examId ?? this.examId,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingTime: remainingTime ?? this.remainingTime,
      score: score ?? this.score,
      isSubject: isSubject ?? this.isSubject,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      unattemptedCount: unattemptedCount ?? this.unattemptedCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      positiveMark: positiveMark ?? this.positiveMark,
      negativeMark: negativeMark ?? this.negativeMark,
      finalMarks: finalMarks ?? this.finalMarks,
    );
  }

  @override
  List<Object?> get props => [
    status,
    examId,
    questions,
    currentQuestionIndex,
    selectedAnswers,
    remainingTime,
    score,
    isSubject,
    totalQuestions,
    correctCount,
    wrongCount,
    unattemptedCount,
    durationSeconds,
    timeTakenSeconds,
    positiveMark,
    negativeMark,
    finalMarks,
  ];
}
