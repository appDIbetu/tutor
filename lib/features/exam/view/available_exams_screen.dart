import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response_models.dart';
import '../../../core/helpers/premium_access_helper.dart';
import '../../exam_taking/view/exam_taking_screen.dart';
import '../../exam_taking/view/exam_result_screen.dart';
import '../../exam_taking/bloc/exam_taking_bloc.dart';

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
    return PremiumAccessHelper.wrapWithAccessControl(
      context,
      item: exam,
      message: exam.isLocked
          ? 'This exam is locked. Upgrade to premium to access.'
          : 'This is a premium exam. Upgrade to access.',
      onUpgrade: () {
        // TODO: Navigate to premium upgrade screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium upgrade feature coming soon!'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: _buildExamCardContent(context, exam),
    );
  }

  Widget _buildExamCardContent(BuildContext context, ExamListResponse exam) {
    final bool userHasAccess = PremiumAccessHelper.hasAccessToItem(
      context,
      exam,
    );

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
                    color: !userHasAccess ? Colors.grey : AppColors.primary,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn(
                  'अवधि',
                  '${exam.perQsnDuration} सेकेन्ड प्रति प्रश्न',
                ),
                _buildDetailColumn('प्रश्नहरू', '${exam.numberOfQuestions}'),
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
                      child: Text(
                        exam.attempted ? 'परीक्षाफल' : 'परीक्षा दिनुहोस्',
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

  Future<void> _navigateToResultScreen(
    BuildContext context,
    ExamListResponse exam,
  ) async {
    try {
      // Fetch exam details with questions
      final examDetails = await ApiService.getExam(exam.examId);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            resultState: _createDummyResultState(exam),
            examTitle: exam.name,
            candidateName: 'User', // TODO: Get from user data
            candidateEmail: 'user@example.com', // TODO: Get from user data
            showRetakeButton: true,
            onRetake: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExamTakingScreen(examId: exam.examId),
                ),
              );
            },
            examDetails: {
              'id': examDetails?.examId ?? exam.examId,
              'title': examDetails?.name ?? exam.name,
              'subject': 'General', // TODO: Add subject to API model
              'durationMinutes':
                  examDetails?.perQsnDuration ?? exam.perQsnDuration,
              'totalQuestions':
                  examDetails?.numberOfQuestions ?? exam.numberOfQuestions,
              'passMark': 50, // TODO: Add passMark to API model
              'price': examDetails?.price ?? exam.price,
            },
            questions: [], // TODO: Add questions to API model
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

  ExamTakingState _createDummyResultState(ExamListResponse exam) {
    return ExamTakingState(
      status: ExamStatus.completed,
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
      positiveMark: 1.0,
      negativeMark: 0.25,
      finalMarks: 0.0,
    );
  }
}
