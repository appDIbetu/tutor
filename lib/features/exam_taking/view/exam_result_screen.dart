import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pwc;
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/api_response_models.dart';
import '../bloc/exam_taking_bloc.dart';
import '../models/exam_question_model.dart';

class ExamResultScreen extends StatefulWidget {
  final ExamTakingState resultState;
  final String examTitle;
  final bool showRetakeButton;
  final VoidCallback? onRetake;
  final ExamResponse? examDetails;
  final List<ExamQuestion>? questions;

  const ExamResultScreen({
    super.key,
    required this.resultState,
    this.examTitle = 'Mollusca',
    this.showRetakeButton = false,
    this.onRetake,
    this.examDetails,
    this.questions,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  // This controller is used programmatically, not in the widget tree.
  final ScreenshotController _screenshotController = ScreenshotController();

  String candidateName = 'Loading...';
  String candidateEmail = 'Loading...';
  String examDate = 'Loading...';
  double positiveMark = 1.0;
  double negativeMark = 0.25;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadExamData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      candidateName = prefs.getString('user_name') ?? 'User';
      candidateEmail = prefs.getString('user_email') ?? 'user@example.com';
    });
  }

  Future<void> _loadExamData() async {
    // Get exam date and marking from exam API response
    setState(() {
      // Use exam date from API if available, otherwise use current date
      if (widget.examDetails != null) {
        try {
          // Check if examDetails has createdAt field (from API)
          if (widget.examDetails!.createdAt != null) {
            examDate = DateFormat(
              'MMM dd, yyyy',
            ).format(widget.examDetails!.createdAt!);
          } else {
            examDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
          }

          // Get marking from exam API response
          positiveMark = widget.examDetails!.posMarking;
          negativeMark = widget.examDetails!.negMarking;
        } catch (e) {
          // Fallback to current date and default marking
          examDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
          positiveMark = 1.0;
          negativeMark = 0.25;
        }
      } else {
        // Fallback if no exam details available
        examDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
        positiveMark = 1.0;
        negativeMark = 0.25;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8D7DA),
        elevation: 0,
        actions: [
          if (widget.showRetakeButton && widget.onRetake != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: widget.onRetake,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retake'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: () async {
              final mq = MediaQuery.of(context);
              final theme = Theme.of(context);

              // Render a clean, white summary off-screen at a higher resolution
              final bytes = await _screenshotController.captureFromWidget(
                MediaQuery(
                  data: mq,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: theme,
                    home: Scaffold(
                      backgroundColor: Colors.white,
                      body: SafeArea(
                        child: Container(
                          color: Colors.white,
                          child: _printableSummary(context),
                        ),
                      ),
                    ),
                  ),
                ),
                pixelRatio: 3.0,
                delay: const Duration(milliseconds: 250),
              );

              final doc = pw.Document();
              final image = pw.MemoryImage(bytes);

              // Create an edge-to-edge page (no extra margins)
              doc.addPage(
                pw.Page(
                  pageFormat: pwc.PdfPageFormat.a4,
                  margin: pw.EdgeInsets.zero,
                  build: (_) => pw.Container(
                    color: pwc.PdfColors.white,
                    child: pw.Center(
                      child: pw.Image(image, fit: pw.BoxFit.contain),
                    ),
                  ),
                ),
              );

              // Offer both print preview and share/save
              await Printing.layoutPdf(onLayout: (_) async => doc.save());
              await Printing.sharePdf(
                bytes: await doc.save(),
                filename: 'exam_summary.pdf',
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      // The body shown on screen remains a SingleChildScrollView with smooth scrolling
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: _printableBody(context),
      ),
    );
  }

  // --- ALL YOUR UI-BUILDING METHODS ARE PRESERVED BELOW ---

  String _averageSpeedLabel() {
    if (widget.resultState.totalQuestions == 0 ||
        widget.resultState.timeTakenSeconds <= 0) {
      return '-';
    }
    final secondsPerQuestion =
        widget.resultState.timeTakenSeconds / widget.resultState.totalQuestions;
    return '${secondsPerQuestion.toStringAsFixed(1)}s/q';
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8D7DA),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            widget.examTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            candidateName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "candidate's name",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(candidateEmail, style: const TextStyle(fontSize: 16)),
          const Text(
            "candidate's email",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // The exact body used both for screen and the off-screen screenshot
  Widget _printableBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Important for off-screen rendering
      children: [
        _buildHeader(),
        _buildStatCards(),
        _buildDonutChart(),
        _legendRow(),
        _buildDateCards(),
        _buildAnswerReview(),
      ],
    );
  }

  // Summary-only version (no questions) for compact PDF screenshots
  Widget _printableSummary(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildStatCards(),
        _buildDonutChart(),
        _legendRow(),
        _buildDateCards(),
      ],
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('positive marking', '$positiveMark'),
              const SizedBox(width: 16),
              _buildStatCard('negative marking', '$negativeMark'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'score',
                widget.resultState.finalMarks.toStringAsFixed(2),
              ),
              const SizedBox(width: 16),
              _buildStatCard('average speed', _averageSpeedLabel()),
            ],
          ),
          const SizedBox(height: 16),
          // Full-width card for total time taken
          _buildTimeCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    final totalSeconds = widget.resultState.timeTakenSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String timeString;
    if (hours > 0) {
      timeString = '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      timeString = '${minutes}m ${seconds}s';
    } else {
      timeString = '${seconds}s';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            timeString,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Total Time Taken',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    final correct = widget.resultState.correctCount.toDouble();
    final wrong = widget.resultState.wrongCount.toDouble();
    final unattempted = widget.resultState.unattemptedCount.toDouble();

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: correct,
                  color: Colors.green,
                  radius: 20,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: wrong,
                  color: Colors.red,
                  radius: 20,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: unattempted,
                  color: Colors.grey,
                  radius: 20,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Text(
            widget.resultState.finalMarks.toStringAsFixed(2),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildStatCard('exam date', examDate),
          const SizedBox(width: 16),
          _buildStatCard('attempted date', examDate),
        ],
      ),
    );
  }

  Widget _legendRow() {
    Widget item(Color color, String label) => Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item(Colors.green, 'Correct'),
          const SizedBox(width: 16),
          item(Colors.red, 'Wrong'),
          const SizedBox(width: 16),
          item(Colors.grey, 'Unattempted'),
        ],
      ),
    );
  }

  Widget _buildAnswerReview() {
    final questionsList = widget.questions ?? widget.resultState.questions;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Answer Sheet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Use ListView.builder for better performance with many questions
          SizedBox(
            height:
                questionsList.length *
                180.0, // More accurate height per question
            child: ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Disable internal scrolling
              itemCount: questionsList.length,
              itemBuilder: (context, index) {
                final question = questionsList[index];
                final selectedAnswerIndex =
                    widget.resultState.selectedAnswers[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question number badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Q.no.${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Question Card (improved but simpler)
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question text at the top
                              Text(
                                question.questionText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Options below the question (simplified and cleaner)
                              ...List.generate(question.options.length, (
                                optIndex,
                              ) {
                                final optionText = question.options[optIndex];
                                final isSelected =
                                    selectedAnswerIndex == optIndex;
                                final isCorrectAnswer =
                                    optIndex == question.correctAnswerIndex;

                                Color? tileColor;
                                Color? textColor;
                                IconData? icon;

                                if (isCorrectAnswer) {
                                  tileColor = Colors.green.withValues(
                                    alpha: 0.15,
                                  );
                                  textColor = Colors.green.shade800;
                                  icon = Icons.check_circle;
                                } else if (isSelected && !isCorrectAnswer) {
                                  tileColor = Colors.red.withValues(
                                    alpha: 0.15,
                                  );
                                  textColor = Colors.red.shade800;
                                  icon = Icons.cancel;
                                } else {
                                  tileColor = Colors.grey.withValues(
                                    alpha: 0.1,
                                  );
                                  textColor = Colors.black87;
                                  icon = null;
                                }

                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tileColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCorrectAnswer
                                          ? Colors.green.shade300
                                          : isSelected
                                          ? Colors.red.shade300
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (icon != null) ...[
                                        Icon(icon, size: 20, color: textColor),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Text(
                                          optionText,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight:
                                                isSelected || isCorrectAnswer
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              // This part for 'explanation' will work if your model has it
                              if (question.explanation != null &&
                                  question.explanation!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Explanation',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(question.explanation!),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
