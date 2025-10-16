import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/exam_service.dart';
import '../bloc/exam_taking_bloc.dart';
import '../models/exam_attempt_model.dart';
import 'exam_result_screen.dart';
import '../widgets/question_options.dart';

class ExamTakingScreen extends StatelessWidget {
  final String examId;

  const ExamTakingScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExamDetails>(
      future: ExamService.fetchExamDetails(examId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final examDetails = snapshot.data!;

        // Check for existing attempt
        return FutureBuilder<ExamAttempt?>(
          future: ExamService.checkExistingAttempt(
            examId,
            'student_123',
          ), // Replace with actual student ID
          builder: (context, attemptSnapshot) {
            if (attemptSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If user has already attempted this exam, show result screen
            if (attemptSnapshot.hasData && attemptSnapshot.data != null) {
              final existingAttempt = attemptSnapshot.data!;
              return ExamResultScreen(
                resultState: _convertAttemptToState(existingAttempt),
                examTitle: existingAttempt.examTitle,
                candidateName: existingAttempt.studentName,
                candidateEmail: existingAttempt.studentEmail,
                showRetakeButton: true,
                onRetake: () => _startNewAttempt(context, examDetails),
              );
            }

            // No existing attempt, start new exam
            return BlocProvider(
              create: (context) => ExamTakingBloc()
                ..add(
                  ExamStarted(
                    durationInSeconds: examDetails.durationMinutes * 60,
                    questions: examDetails.questions,
                  ),
                ),
              child: BlocBuilder<ExamTakingBloc, ExamTakingState>(
                builder: (context, state) {
                  if (state.status == ExamStatus.completed) {
                    return ExamResultScreen(resultState: state);
                  }

                  if (state.status == ExamStatus.inProgress &&
                      state.questions.isNotEmpty) {
                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        iconTheme: const IconThemeData(color: Colors.white),
                        title: Text(
                          examDetails.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      body: const _ScrollableQuestionsView(),
                    );
                  }

                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // Convert ExamAttempt to ExamTakingState for result screen
  ExamTakingState _convertAttemptToState(ExamAttempt attempt) {
    return ExamTakingState(
      status: ExamStatus.completed,
      questions: [], // We don't need questions for result display
      selectedAnswers: attempt.selectedAnswers,
      remainingTime: 0,
      timeTakenSeconds: attempt.timeTakenSeconds,
      correctCount: attempt.correctCount,
      wrongCount: attempt.wrongCount,
      unattemptedCount: attempt.unattemptedCount,
      finalMarks: attempt.finalMarks,
      positiveMark: attempt.positiveMark.toDouble(),
      negativeMark: attempt.negativeMark.toDouble(),
      totalQuestions: attempt.totalQuestions,
    );
  }

  // Start new attempt (retake exam)
  void _startNewAttempt(BuildContext context, ExamDetails examDetails) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ExamTakingBloc()
            ..add(
              ExamStarted(
                durationInSeconds: examDetails.durationMinutes * 60,
                questions: examDetails.questions,
              ),
            ),
          child: BlocBuilder<ExamTakingBloc, ExamTakingState>(
            builder: (context, state) {
              if (state.status == ExamStatus.completed) {
                return ExamResultScreen(resultState: state);
              }

              if (state.status == ExamStatus.inProgress &&
                  state.questions.isNotEmpty) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    title: Text(
                      examDetails.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  body: const _ScrollableQuestionsView(),
                );
              }

              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScrollableQuestionsView extends StatefulWidget {
  const _ScrollableQuestionsView();

  @override
  State<_ScrollableQuestionsView> createState() =>
      _ScrollableQuestionsViewState();
}

class _ScrollableQuestionsViewState extends State<_ScrollableQuestionsView> {
  // --- CONTROLLERS FOR THE SCROLLABLE_POSITIONED_LIST ---
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  String _formatDuration(int totalSeconds) {
    final String hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');

    final String minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(
      2,
      '0',
    );

    final String seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final questions = context.read<ExamTakingBloc>().state.questions;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Header: Question Board & Instructions buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openQuestionBoardSheet(context),
                      icon: const Icon(Icons.grid_view, size: 16),
                      label: const Text('Question Board'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openInstructionsSheet(context),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('instructions'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- USE SCROLLABLEPOSITIONEDLIST INSTEAD OF LISTVIEW ---
              Expanded(
                child: ScrollablePositionedList.separated(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, qIndex) {
                    final q = questions[qIndex];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Replace with this:
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            // color: AppColors.lightGrey,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Q.no.${qIndex + 1}',
                            style: const TextStyle(
                              color: AppColors.lightGrey,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // The Question Card
                        Card(
                          elevation: 2,
                          color: Colors.white, // force neutral background
                          surfaceTintColor:
                              Colors.white, // disable Material3 tint
                          margin: EdgeInsets.zero, // Remove default card margin
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.questionText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // --- PERFORMANCE OPTIMIZATION ---
                                // This BlocBuilder ensures ONLY the options for this
                                // specific question rebuild when an answer changes.
                                BlocBuilder<ExamTakingBloc, ExamTakingState>(
                                  buildWhen: (previous, current) {
                                    return previous.selectedAnswers[qIndex] !=
                                        current.selectedAnswers[qIndex];
                                  },
                                  builder: (context, state) {
                                    return QuestionOptions(
                                      options: q.options,
                                      selectedOptionIndex:
                                          state.selectedAnswers[qIndex],
                                      onOptionSelected: (optIndex) {
                                        context.read<ExamTakingBloc>().add(
                                          AnswerSelected(
                                            questionIndex: qIndex,
                                            selectedOptionIndex: optIndex,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context.read<ExamTakingBloc>().add(
                                          AnswerCleared(qIndex),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      child: const Text('Reset'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Hint logic placeholder
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      child: const Text('Hint?'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
              BlocBuilder<ExamTakingBloc, ExamTakingState>(
                buildWhen: (p, c) => p.remainingTime != c.remainingTime,
                builder: (context, state) {
                  return Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.grey.shade600,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(state.remainingTime),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => _showSubmitConfirmationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Submit Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQuestionBoardSheet(BuildContext context) {
    final state = context.read<ExamTakingBloc>().state;
    final attempted = state.selectedAnswers.length;
    final total = state.questions.length;
    final unattempted = total - attempted;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.grid_view, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Question Board',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _legendDot(color: Colors.green),
                    const SizedBox(width: 6),
                    Text('Attempted ($attempted)'),
                    const SizedBox(width: 16),
                    _legendDot(color: Colors.grey.shade300),
                    const SizedBox(width: 6),
                    Text('Unattempted ($unattempted)'),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final isAttempted = state.selectedAnswers.containsKey(
                      index,
                    );
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        // --- USE THE ITEMSCROLLCONTROLLER ---
                        _itemScrollController.scrollTo(
                          index: index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAttempted
                              ? Colors.green
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isAttempted ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openInstructionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                Text('1. Read each question carefully.'),
                Text('2. Select the most appropriate option.'),
                Text('3. Use the Question Board to jump across questions.'),
                Text('4. Submit the test when you are done.'),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _legendDot({required Color color}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Exam'),
          content: const Text(
            'Are you sure you want to exit the exam? Your progress will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit exam
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitConfirmationDialog(BuildContext context) {
    final state = context.read<ExamTakingBloc>().state;
    final attempted = state.selectedAnswers.length;
    final total = state.questions.length;
    final unattempted = total - attempted;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to submit the exam?'),
              const SizedBox(height: 12),
              Text('Total Questions: $total'),
              Text('Attempted: $attempted'),
              Text('Unattempted: $unattempted'),
              if (unattempted > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'You have $unattempted unattempted questions.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.read<ExamTakingBloc>().add(ExamSubmitted());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
