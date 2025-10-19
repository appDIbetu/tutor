import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response_models.dart';
import '../../exam_taking/view/exam_taking_screen.dart';
import '../../exam_taking/view/exam_result_screen.dart';
import '../../exam_taking/bloc/exam_taking_bloc.dart';
import '../../exam_taking/models/exam_question_model.dart';

class AvailableExamsScreen extends StatefulWidget {
  const AvailableExamsScreen({super.key});

  @override
  State<AvailableExamsScreen> createState() => _AvailableExamsScreenState();
}

class _AvailableExamsScreenState extends State<AvailableExamsScreen> {
  List<ExamListResponse> _exams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final exams = await ApiService.getExamsWithAccess();
      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading exams',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExams,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No exams available',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _exams.length,
      itemBuilder: (context, index) {
        final exam = _exams[index];
        return _buildExamCard(context, exam);
      },
    );
  }

  Widget _buildExamCard(BuildContext context, ExamListResponse exam) {
    return _buildExamCardContent(context, exam);
  }

  Widget _buildExamCardContent(BuildContext context, ExamListResponse exam) {
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
                    color: exam.isLocked ? Colors.grey : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Exam title with exam code
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: exam.examId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${exam.examId} क्लिपबोर्डमा कपी भयो'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${exam.examId.toUpperCase()} | ',
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
                    color: exam.attempted
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: exam.attempted
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exam.attempted ? Icons.check_circle : Icons.schedule,
                        size: 12,
                        color: exam.attempted
                            ? AppColors.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        exam.attempted ? 'Attempted' : 'Unattempted',
                        style: TextStyle(
                          color: exam.attempted
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailColumn(
                    'अवधि',
                    _formatDuration(
                      exam.perQsnDuration * exam.numberOfQuestions,
                    ),
                    icon: Icons.access_time,
                  ),
                  _buildDetailColumn(
                    'प्रश्नहरू',
                    '${exam.numberOfQuestions}',
                    icon: Icons.quiz,
                  ),
                  if (exam.passPercent != null)
                    _buildDetailColumn(
                      'उत्तीर्णांक',
                      '${(exam.passPercent! * exam.numberOfQuestions * exam.posMarking / 100).toInt()}',
                      icon: Icons.flag,
                    ),
                ],
              ),
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
                      if (exam.isLocked) {
                        _showUpgradeDialog(context, exam.name);
                        return;
                      }
                      if (exam.attempted) {
                        // Navigate to result screen for attempted exams
                        _navigateToResultScreen(context, exam);
                      } else {
                        // Navigate to exam taking screen for new exams
                        _navigateToExamTakingScreen(context, exam);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            exam.isLocked
                                ? Icons.lock_outline
                                : (exam.attempted
                                      ? Icons.assessment_outlined
                                      : Icons.play_arrow_rounded),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            exam.isLocked
                                ? 'प्रीमियम लिनुहोस्'
                                : (exam.attempted
                                      ? 'परीक्षाफल'
                                      : 'परीक्षा दिनुहोस्'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
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

  Widget _buildDetailColumn(String title, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _navigateToResultScreen(
    BuildContext context,
    ExamListResponse exam,
  ) async {
    bool isLoadingDialogOpen = false;

    try {
      // Show loading indicator with better error handling
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading exam result...',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fetching exam details and results',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        isLoadingDialogOpen = true;
      }

      // Fetch exam details and result concurrently to avoid progress bar stuck
      final results =
          await Future.wait([
            ApiService.getExam(exam.examId),
            ApiService.getMyExamResult(exam.examId),
          ]).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Please check your internet connection.',
              );
            },
          );

      final examDetails = results[0] as ExamResponse?;
      final examResult = results[1] as ExamResultResponse?;

      // Close loading dialog
      if (context.mounted && isLoadingDialogOpen) {
        Navigator.of(context).pop();
        isLoadingDialogOpen = false;
      }

      if (examDetails == null) {
        throw Exception('Failed to load exam details');
      }

      // Convert API questions to ExamQuestion models
      final questions = examDetails.questions
          .map(
            (q) => ExamQuestion(
              id: q.id,
              questionText: q.questionText,
              options: q.options,
              correctAnswerIndex: q.correctAnswerIndex,
              explanation: q.explanation,
            ),
          )
          .toList();

      // Convert selected_indexes to selectedAnswers map
      final selectedAnswers = <int, int>{};
      if (examResult != null && examResult.selectedIndexes.isNotEmpty) {
        for (int i = 0; i < examResult.selectedIndexes.length; i++) {
          selectedAnswers[i] = examResult.selectedIndexes[i];
        }
      }

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(
              resultState: _createRealResultState(
                exam,
                examResult,
                selectedAnswers,
              ),
              examTitle: exam.name,
              showRetakeButton: true,
              onRetake: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExamTakingScreen(examId: exam.examId),
                  ),
                );
              },
              examDetails: examDetails,
              questions: questions,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted && isLoadingDialogOpen) {
        Navigator.of(context).pop();
        isLoadingDialogOpen = false;
      }

      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading exam result: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _navigateToExamTakingScreen(
    BuildContext context,
    ExamListResponse exam,
  ) async {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamTakingScreen(examId: exam.examId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting exam: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  ExamTakingState _createRealResultState(
    ExamListResponse exam,
    ExamResultResponse? examResult,
    Map<int, int> selectedAnswers,
  ) {
    if (examResult == null) {
      // Fallback to dummy state if no result found
      return _createDummyResultState(exam);
    }

    return ExamTakingState(
      status: ExamStatus.completed,
      examId: exam.examId,
      questions: [], // Will be populated by the result screen
      currentQuestionIndex: 0,
      selectedAnswers: selectedAnswers,
      remainingTime: 0,
      score: examResult.correctAnswers,
      totalQuestions: examResult.totalQuestions,
      correctCount: examResult.correctAnswers,
      wrongCount: examResult.wrongAnswers,
      unattemptedCount: examResult.skippedQuestions,
      durationSeconds: exam.perQsnDuration * exam.numberOfQuestions,
      timeTakenSeconds: examResult.timeTaken,
      positiveMark: examResult.positiveMark,
      negativeMark: examResult.negativeMark,
      finalMarks: examResult.score,
    );
  }

  ExamTakingState _createDummyResultState(ExamListResponse exam) {
    return ExamTakingState(
      status: ExamStatus.completed,
      examId: exam.examId,
      questions: [],
      currentQuestionIndex: 0,
      selectedAnswers: {},
      remainingTime: 0,
      score: 0,
      totalQuestions: exam.numberOfQuestions,
      correctCount: 0,
      wrongCount: 0,
      unattemptedCount: exam.numberOfQuestions,
      durationSeconds: exam.perQsnDuration * exam.numberOfQuestions,
      timeTakenSeconds: 1800,
      positiveMark: exam.posMarking, // Use API value
      negativeMark: exam.negMarking, // Use API value instead of hardcoded 0.25
      finalMarks: 0.0,
    );
  }

  void _showUpgradeDialog(BuildContext context, String examTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Lock icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'प्रीमियम अपग्रेड आवश्यक',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              '$examTitle पहुँच गर्न प्रीमियम सदस्यता आवश्यक छ।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('प्रीमियम अपग्रेड सुविधा जल्दै आउँदैछ!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'प्रीमियम अपग्रेड गर्नुहोस्',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'रद्द गर्नुहोस्',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
