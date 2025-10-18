import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// This relative path goes up one folder from 'view' to 'exam', then down into 'bloc'
import '../bloc/exam_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../exam_taking/view/exam_taking_screen.dart';
import '../../exam_taking/view/exam_result_screen.dart';
import '../../exam_taking/bloc/exam_taking_bloc.dart';
import '../../exam_taking/models/exam_attempt_model.dart';
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Status indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDisabled ? Colors.grey : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Exam title with exam code
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: exam.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${exam.id} क्लिपबोर्डमा कपी भयो'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${exam.id.toUpperCase()} | ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextSpan(
                            text: exam.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Price badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: exam.isPremium
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exam.isPremium ? 'रु. ${exam.price.toInt()}' : 'रु. ०',
                    style: TextStyle(
                      color: exam.isPremium
                          ? AppColors.primary
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Premium/Non-premium icon
                Icon(
                  exam.isPremium ? Icons.lock : Icons.lock_open,
                  size: 12,
                  color: exam.isPremium
                      ? AppColors.primary
                      : Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Attempt status and Premium/Free status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: exam.hasAttempted
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: exam.hasAttempted
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exam.hasAttempted ? Icons.check_circle : Icons.schedule,
                        size: 12,
                        color: exam.hasAttempted
                            ? AppColors.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        exam.hasAttempted ? 'Attempted' : 'Unattempted',
                        style: TextStyle(
                          color: exam.hasAttempted
                              ? AppColors.primary
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: exam.isPremium
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: exam.isPremium
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exam.isPremium ? Icons.lock : Icons.lock_open,
                        size: 12,
                        color: exam.isPremium
                            ? AppColors.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        exam.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                        style: TextStyle(
                          color: exam.isPremium
                              ? AppColors.primary
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('अवधि', exam.duration),
                _buildDetailColumn('प्रश्नहरू', '${exam.questions}'),
              ],
            ),
            const SizedBox(height: 16),
            // Single action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (exam.hasAttempted) {
                        if (exam.isPremium && !userHasPremium) {
                          // Show premium upgrade dialog for attempted premium exams
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'प्रीमियम सदस्यता आवश्यक - रु. ${exam.price.toInt()}',
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          // Navigate to result screen for attempted exams
                          _navigateToResultScreen(context, exam);
                        }
                      } else if (exam.isPremium && !userHasPremium) {
                        // Show premium upgrade dialog or navigate to premium page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'प्रीमियम सदस्यता आवश्यक - रु. ${exam.price.toInt()}',
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        // Navigate to exam taking screen for new exams
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExamTakingScreen(examId: exam.id),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Text(
                        exam.hasAttempted
                            ? (exam.isPremium ? 'प्रीमियम आवश्यक' : 'परीक्षाफल')
                            : (exam.isPremium && !userHasPremium)
                            ? 'प्रीमियम आवश्यक'
                            : 'परीक्षा दिनुहोस्',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
