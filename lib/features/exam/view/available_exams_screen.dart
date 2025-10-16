import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// This relative path goes up one folder from 'view' to 'exam', then down into 'bloc'
import '../bloc/exam_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../exam_taking/view/exam_taking_screen.dart';
import '../../exam_taking/view/exam_result_screen.dart';
import '../../exam_taking/bloc/exam_taking_bloc.dart';
import '../../exam_taking/models/exam_attempt_model.dart';
import '../../exam_taking/models/exam_question_model.dart';
import '../../../core/network/exam_service.dart';

class AvailableExamsScreen extends StatelessWidget {
  const AvailableExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamBloc()..add(ExamsFetched()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'उपलब्ध परीक्षाहरू',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          ],
        ),
        body: BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state is ExamLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExamLoadSuccess) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.exams.length,
                itemBuilder: (context, index) {
                  final exam = state.exams[index];
                  return _buildExamCard(context, exam);
                },
              );
            }
            return const Center(child: Text('परीक्षाहरू लोड गर्न असफल।'));
          },
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
    // Assume user is non-premium for now (you can get this from user state)
    const bool userHasPremium = false;
    final bool isDisabled = exam.isPremium && !userHasPremium;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDisabled ? Colors.grey : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exam.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                // Premium/Non-premium tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: exam.isPremium
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: exam.isPremium
                          ? Colors.red.withValues(alpha: 0.4)
                          : Colors.green.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exam.isPremium ? Icons.lock : Icons.lock_open,
                        size: 12,
                        color: exam.isPremium
                            ? Colors.red.withValues(alpha: 0.4)
                            : Colors.green.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exam.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: exam.isPremium
                              ? Colors.red.withValues(alpha: 0.4)
                              : Colors.green.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exam.description,
              style: TextStyle(
                color: isDisabled ? Colors.grey : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('अवधि', exam.duration),
                _buildDetailColumn('प्रश्नहरू', '${exam.questions}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: exam.isPremium
                        ? () {
                            // Handle payment for premium exams
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Payment for ${exam.name} - रु. ${exam.price.toInt()}',
                                ),
                              ),
                            );
                          }
                        : null, // Disabled for free exams
                    style: OutlinedButton.styleFrom(
                      foregroundColor: exam.isPremium
                          ? Colors
                                .orange // Always orange for premium exams
                          : Colors.grey, // Grey for free exams
                      side: BorderSide(
                        color: exam.isPremium
                            ? Colors
                                  .orange // Always orange border for premium exams
                            : Colors.grey, // Grey border for free exams
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      exam.isPremium ? 'रु. ${exam.price.toInt()}' : 'रु. ०',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isDisabled
                        ? null
                        : () {
                            if (exam.hasAttempted) {
                              // Navigate to result screen for attempted exams
                              _navigateToResultScreen(context, exam);
                            } else {
                              // Navigate to exam taking screen for new exams
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExamTakingScreen(examId: exam.id),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDisabled
                          ? Colors.grey
                          : exam.hasAttempted
                          ? Colors.blue
                          : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      exam.hasAttempted ? 'परीक्षाफल' : 'परीक्षा दिनुहोस्',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

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

  Future<void> _navigateToResultScreen(BuildContext context, Exam exam) async {
    try {
      // Fetch exam details with questions
      final examDetails = await ExamService.fetchExamDetails(exam.id);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            resultState: _convertAttemptToState(exam.lastAttempt!),
            examTitle: exam.lastAttempt!.examTitle,
            candidateName: exam.lastAttempt!.studentName,
            candidateEmail: exam.lastAttempt!.studentEmail,
            showRetakeButton: true,
            onRetake: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExamTakingScreen(examId: exam.id),
                ),
              );
            },
            examDetails: {
              'id': examDetails.id,
              'title': examDetails.title,
              'subject': examDetails.subject,
              'durationMinutes': examDetails.durationMinutes,
              'totalQuestions': examDetails.totalQuestions,
              'passMark': examDetails.passMark,
              'price': examDetails.price,
            },
            questions: examDetails.questions,
          ),
        ),
      );
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading exam details: $e')));
    }
  }
}
