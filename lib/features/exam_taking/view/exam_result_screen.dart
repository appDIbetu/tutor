import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pwc;
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import '../bloc/exam_taking_bloc.dart';
import '../models/exam_question_model.dart';

class ExamResultScreen extends StatelessWidget {
  final ExamTakingState resultState;
  final String examTitle;
  final String candidateName;
  final String candidateEmail;
  final bool showRetakeButton;
  final VoidCallback? onRetake;
  final Map<String, dynamic>? examDetails;
  final List<ExamQuestion>? questions;

  ExamResultScreen({
    super.key,
    required this.resultState,
    this.examTitle = 'Mollusca',
    this.candidateName = 'Dipak Shah',
    this.candidateEmail = 'appdibetu@gmail.com',
    this.showRetakeButton = false,
    this.onRetake,
    this.examDetails,
    this.questions,
  });

  // This controller is used programmatically, not in the widget tree.
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8D7DA),
        elevation: 0,
        actions: [
          if (showRetakeButton && onRetake != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: onRetake,
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
      // The body shown on screen remains a SingleChildScrollView
      body: SingleChildScrollView(child: _printableBody(context)),
    );
  }

  // --- ALL YOUR UI-BUILDING METHODS ARE PRESERVED BELOW ---

  String _averageSpeedLabel() {
    if (resultState.totalQuestions == 0 || resultState.timeTakenSeconds <= 0) {
      return '-';
    }
    final attemptedCount =
        resultState.totalQuestions - resultState.unattemptedCount;
    if (attemptedCount == 0) return '0s/q';
    final secondsPerQuestion = resultState.timeTakenSeconds / attemptedCount;
    return '${secondsPerQuestion.toStringAsFixed(0)}s/q';
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8D7DA),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            examTitle,
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
              _buildStatCard('positive marking', '${resultState.positiveMark}'),
              const SizedBox(width: 16),
              _buildStatCard('negative marking', '${resultState.negativeMark}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'score',
                resultState.finalMarks.toStringAsFixed(2),
              ),
              const SizedBox(width: 16),
              _buildStatCard('average speed', _averageSpeedLabel()),
            ],
          ),
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

  Widget _buildDonutChart() {
    final correct = resultState.correctCount.toDouble();
    final wrong = resultState.wrongCount.toDouble();
    final unattempted = resultState.unattemptedCount.toDouble();

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
            resultState.finalMarks.toStringAsFixed(2),
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
          _buildStatCard('exam date', '2022/08/17'),
          const SizedBox(width: 16),
          _buildStatCard(
            'attempted date',
            DateFormat('d/M/y').format(DateTime.now()),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Answer Sheet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...List.generate((questions ?? resultState.questions).length, (
            index,
          ) {
            final question = (questions ?? resultState.questions)[index];
            final selectedAnswerIndex = resultState.selectedAnswers[index];
            final isCorrect =
                selectedAnswerIndex == question.correctAnswerIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: _badgeColor(isCorrect, selectedAnswerIndex != null),
                    child: Text(
                      'Q.no.${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(question.options.length, (optIndex) {
                            final optionText = question.options[optIndex];
                            Color? tileColor;

                            if (optIndex == question.correctAnswerIndex) {
                              tileColor = Colors.green.withValues(alpha: 0.15);
                            }
                            if (selectedAnswerIndex != null &&
                                selectedAnswerIndex == optIndex &&
                                !isCorrect) {
                              tileColor = Colors.red.withValues(alpha: 0.15);
                            }

                            return Container(
                              color: tileColor,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Text(optionText),
                            );
                          }),
                          const SizedBox(height: 12),
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
          }),
        ],
      ),
    );
  }

  Color _badgeColor(bool isCorrect, bool attempted) {
    if (!attempted) return Colors.grey.shade300;
    return isCorrect ? Colors.green.shade200 : Colors.red.shade200;
  }
}
