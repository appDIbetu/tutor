import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/exam_question_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response_models.dart';
import '../../../core/services/auth_service.dart';

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
        examId: event.examId,
        questions: event.questions,
        status: ExamStatus.inProgress,
        remainingTime: event.durationInSeconds,
        durationSeconds: event.durationInSeconds,
        totalQuestions: event.questions.length,
        positiveMark: event.positiveMark,
        negativeMark: event.negativeMark,
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

  void _onExamSubmitted(
    ExamSubmitted event,
    Emitter<ExamTakingState> emit,
  ) async {
    _timer?.cancel();

    // Calculate results locally first
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

    // Marking scheme from exam API
    final double positiveMark = state.positiveMark;
    final double negativeMark = state.negativeMark;
    final double marks =
        (correctAnswers * positiveMark) - (wrongAnswers * negativeMark);

    // Update state with local results
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

    // Submit to API if examId is available
    if (state.examId != null) {
      try {
        // Get current user ID
        final userData = await AuthService.getSavedFirebaseUserData();
        if (userData != null) {
          // Create exam result for API submission
          final examResult = ExamResultCreate(
            studentId: userData.uid,
            score: marks,
            positiveMark: positiveMark,
            negativeMark: negativeMark,
            totalQuestions: state.questions.length,
            attemptedQuestions: correctAnswers + wrongAnswers,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            skippedQuestions: unattempted,
            avgSpeed: timeTaken > 0
                ? (correctAnswers + wrongAnswers) / (timeTaken / 60.0)
                : 0.0,
            selectedIndexes: state.selectedAnswers.values.toList(),
            timeTaken: timeTaken,
            isCompleted: true,
          );

          // Submit to API
          final result = await ApiService.submitExamResult(
            state.examId!,
            examResult,
          );
          if (result != null) {
            print('Exam result submitted successfully to API');
          } else {
            print('Failed to submit exam result to API');
          }
        } else {
          print('No user data available for exam submission');
        }
      } catch (e) {
        print('Error submitting exam result to API: $e');
        // Don't fail the exam completion if API submission fails
      }
    } else {
      print('No exam ID available for API submission');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
