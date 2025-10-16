import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/exam_taking_bloc.dart';
import '../models/exam_question_model.dart';
import '../widgets/question_options.dart';

class ExamTakingScreen extends StatelessWidget {
  const ExamTakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamTakingBloc()
        ..add(
          ExamStarted(
            durationInSeconds: 1800, // e.g., 30 minutes
            questions: _getMockQuestions(),
          ),
        ),
      child: BlocBuilder<ExamTakingBloc, ExamTakingState>(
        builder: (context, state) {
          if (state.status == ExamStatus.completed) {
            return _buildResultScreen(context, state);
          }

          if (state.status == ExamStatus.inProgress &&
              state.questions.isNotEmpty) {
            return const Scaffold(
              // The BottomBar is now part of the _ScrollableQuestionsView
              body: _ScrollableQuestionsView(),
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, ExamTakingState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exam Finished!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: ${state.score} / ${state.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Exams'),
            ),
          ],
        ),
      ),
    );
  }

  List<ExamQuestion> _getMockQuestions() {
    return const [
      ExamQuestion(
        id: '1',
        questionText:
            'How long you want to see preplic to serve you as the best curated exams provider?',
        options: ['100 yrs', '200 yrs', '300 years', '400 years'],
        correctAnswerIndex: 1,
      ),
      ExamQuestion(
        id: '2',
        questionText: 'So do you love preplic?',
        options: ['yes', 'no', 'a bit'],
        correctAnswerIndex: 0,
      ),
      ExamQuestion(
        id: '3',
        questionText: 'What is the capital of France?',
        options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
        correctAnswerIndex: 2,
      ),
      ExamQuestion(
        id: '4',
        questionText: 'Which planet is known as the Red Planet?',
        options: ['Earth', 'Mars', 'Jupiter', 'Venus'],
        correctAnswerIndex: 1,
      ),
    ];
  }
}

// (The top part of the file with ExamTakingScreen remains the same)
// ...

class _ScrollableQuestionsView extends StatefulWidget {
  const _ScrollableQuestionsView();

  @override
  State<_ScrollableQuestionsView> createState() =>
      _ScrollableQuestionsViewState();
}

class _ScrollableQuestionsViewState extends State<_ScrollableQuestionsView> {
  late final ScrollController _scrollController;
  late List<GlobalKey> _questionKeys;

  // lib/features/exam_taking/view/exam_taking_screen.dart
  // Inside the _ScrollableQuestionsViewState class

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
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final questionsLen = context.read<ExamTakingBloc>().state.questions.length;
    _questionKeys = List.generate(questionsLen, (_) => GlobalKey());
  }

  void _ensureKeyCount(int length) {
    if (_questionKeys.length != length) {
      _questionKeys = List.generate(length, (_) => GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch to rebuild for content/state changes
    final questions = context.watch<ExamTakingBloc>().state.questions;
    _ensureKeyCount(questions.length);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    onPressed: () =>
                        _openQuestionBoardSheet(context, _questionKeys),
                    icon: const Icon(Icons.grid_view, size: 16),
                    label: const Text('Question Board'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openInstructionsSheet(context),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('instructions'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.lightGrey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // The Optimized and Restyled Scrollable ListView
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, qIndex) {
                  final q = questions[qIndex];

                  // This Column places the Q.no tag ABOVE the Card
                  return Column(
                    key: _questionKeys[qIndex], // stable key for ensureVisible
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Q.no" Tag - OUTSIDE and ABOVE the Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Q.no.${qIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
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
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    child: const Text('Reset'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Hint logic placeholder
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey,
                                      textStyle: const TextStyle(fontSize: 12),
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
            // Use a BlocBuilder that only rebuilds for the timer
            // This code is already correct and doesn't need to be changed.
            // It will now display the hh:mm:ss format.
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
                      // This now calls the corrected function
                      // _formatDuration(state.remainingTime),
                      "00:30:00",
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
              onPressed: () {
                context.read<ExamTakingBloc>().add(ExamSubmitted());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Submit Test',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Sheet for Question Board
  void _openQuestionBoardSheet(
    BuildContext context,
    List<GlobalKey> questionKeys,
  ) {
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
                        // Defer scrolling until after the sheet is dismissed
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final ctx = questionKeys[index].currentContext;
                          if (ctx != null) {
                            Scrollable.ensureVisible(
                              ctx,
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                              alignment: 0.05, // near top
                            );
                          }
                        });
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

  // Bottom Sheet for Instructions
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.lightGrey,
                  ),
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

  // Helper widget for the legend
  Widget _legendDot({required Color color}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
