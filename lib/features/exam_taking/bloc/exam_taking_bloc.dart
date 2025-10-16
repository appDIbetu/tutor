import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/exam_question_model.dart';

part 'exam_taking_event.dart';
part 'exam_taking_state.dart';

class ExamTakingBloc extends Bloc<ExamTakingEvent, ExamTakingState> {
  Timer? _timer;

  ExamTakingBloc() : super(const ExamTakingState()) {
    on<ExamStarted>(_onExamStarted);
    on<AnswerSelected>(_onAnswerSelected);
    on<AnswerCleared>(_onAnswerCleared); // <-- ADD THIS HANDLER
    on<TimerTicked>(_onTimerTicked);
    on<ExamSubmitted>(_onExamSubmitted);
  }

  void _onExamStarted(ExamStarted event, Emitter<ExamTakingState> emit) {
    emit(
      state.copyWith(
        questions: event.questions,
        status: ExamStatus.inProgress,
        remainingTime: event.durationInSeconds,
        durationSeconds: event.durationInSeconds,
        totalQuestions: event.questions.length,
      ),
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime > 0) {
        add(TimerTicked(state.remainingTime - 1));
      } else {
        add(ExamSubmitted());
      }
    });
  }

  // --- MODIFIED HANDLER ---
  void _onAnswerSelected(AnswerSelected event, Emitter<ExamTakingState> emit) {
    final newSelectedAnswers = Map<int, int>.from(state.selectedAnswers);
    newSelectedAnswers[event.questionIndex] =
        event.selectedOptionIndex; // Use event.questionIndex
    emit(state.copyWith(selectedAnswers: newSelectedAnswers));
  }

  // --- NEW HANDLER ---
  void _onAnswerCleared(AnswerCleared event, Emitter<ExamTakingState> emit) {
    final newSelectedAnswers = Map<int, int>.from(state.selectedAnswers);
    newSelectedAnswers.remove(event.questionIndex);
    emit(state.copyWith(selectedAnswers: newSelectedAnswers));
  }

  void _onTimerTicked(TimerTicked event, Emitter<ExamTakingState> emit) {
    emit(state.copyWith(remainingTime: event.remainingTime));
  }

  void _onExamSubmitted(ExamSubmitted event, Emitter<ExamTakingState> emit) {
    _timer?.cancel();
    int correctAnswers = 0;
    int wrongAnswers = 0;
    for (int i = 0; i < state.questions.length; i++) {
      final selected = state.selectedAnswers[i];
      if (selected == null) continue;
      if (selected == state.questions[i].correctAnswerIndex) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    }
    final int unattempted =
        state.questions.length - (correctAnswers + wrongAnswers);
    final int timeTaken = state.durationSeconds - state.remainingTime;

    // Marking scheme (can be made dynamic later)
    const double positiveMark = 1.0;
    const double negativeMark = 0.25;
    final double marks =
        (correctAnswers * positiveMark) - (wrongAnswers * negativeMark);

    emit(
      state.copyWith(
        status: ExamStatus.completed,
        score: correctAnswers,
        correctCount: correctAnswers,
        wrongCount: wrongAnswers,
        unattemptedCount: unattempted,
        timeTakenSeconds: timeTaken,
        positiveMark: positiveMark,
        negativeMark: negativeMark,
        finalMarks: marks,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
