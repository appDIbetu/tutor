import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../../core/helpers/premium_access_helper.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response_models.dart';
import '../../exam_taking/view/exam_taking_screen.dart';

// Old Subject class removed - now using SubjectListResponse from API models

Widget _buildList(
  BuildContext context,
  List<SubjectListResponse> subjects,
  bool userHasPremium,
  String Function(int) formatDuration,
) {
  if (subjects.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No subjects available',
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

  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    itemCount: subjects.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final subject = subjects[index];

      return PremiumAccessHelper.wrapWithAccessControl(
        context,
        item: subject,
        message: subject.isLocked
            ? 'This subject is locked. Upgrade to premium to access.'
            : 'This is a premium subject. Upgrade to access.',
        onUpgrade: () {
          // TODO: Navigate to premium upgrade screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premium upgrade feature coming soon!'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
        child: _SubjectTile(
          subject: subject,
          onAttempt: () {
            // Show question range selection dialog for all subjects
            _showQuestionRangeDialog(context, subject, userHasPremium);
          },
          formatDuration: formatDuration,
        ),
      );
    },
  );
}

void _showQuestionRangeDialog(
  BuildContext context,
  SubjectListResponse subject,
  bool userHasPremium,
) {
  // Always show dialog for all subjects

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return QuestionRangeDialog(
        subject: subject,
        userHasPremium: userHasPremium,
        onStartPractice: (startIndex, endIndex) {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExamTakingScreen(
                examId: subject.subjectId,
                questionStartIndex: startIndex,
                questionEndIndex: endIndex,
              ),
            ),
          );
        },
      );
    },
  );
}

class QuestionRangeDialog extends StatefulWidget {
  final SubjectListResponse subject;
  final bool userHasPremium;
  final Function(int startIndex, int endIndex) onStartPractice;

  const QuestionRangeDialog({
    super.key,
    required this.subject,
    required this.userHasPremium,
    required this.onStartPractice,
  });

  @override
  State<QuestionRangeDialog> createState() => _QuestionRangeDialogState();
}

class _QuestionRangeDialogState extends State<QuestionRangeDialog> {
  late int _startIndex;
  late int _endIndex;

  @override
  void initState() {
    super.initState();
    _startIndex = 1;
    _endIndex = widget.subject.numberOfQuestions;

    // Ensure initial values are valid
    if (_startIndex < 1) _startIndex = 1;
    if (_endIndex < _startIndex) _endIndex = _startIndex;
    if (_endIndex > widget.subject.numberOfQuestions) {
      _endIndex = widget.subject.numberOfQuestions;
    }
    if (_startIndex > widget.subject.numberOfQuestions) {
      _startIndex = widget.subject.numberOfQuestions;
    }

    // Special case: if only 1 question, both start and end should be 1
    if (widget.subject.numberOfQuestions == 1) {
      _startIndex = 1;
      _endIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.quiz_outlined, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${widget.subject.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Questions: ${widget.subject.numberOfQuestions}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select question range to practice:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          // Start Question Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Start Question',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _startIndex.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.subject.numberOfQuestions > 1)
                Slider(
                  value: _startIndex.toDouble(),
                  min: 1.0,
                  max: widget.subject.numberOfQuestions.toDouble(),
                  divisions: widget.subject.numberOfQuestions - 1,
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      _startIndex = value.round();
                      // Ensure start is never greater than end
                      if (_startIndex > _endIndex) {
                        _endIndex = _startIndex;
                      }
                      // Ensure start is never greater than total questions
                      if (_startIndex > widget.subject.numberOfQuestions) {
                        _startIndex = widget.subject.numberOfQuestions;
                      }
                      // Ensure start is never less than 1
                      if (_startIndex < 1) {
                        _startIndex = 1;
                      }
                    });
                  },
                )
              else
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'Only 1 question available',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // End Question Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'End Question',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _endIndex.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.subject.numberOfQuestions > _startIndex)
                Slider(
                  value: _endIndex.toDouble(),
                  min: _startIndex.toDouble(),
                  max: widget.subject.numberOfQuestions.toDouble(),
                  divisions: widget.subject.numberOfQuestions - _startIndex,
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      _endIndex = value.round();
                      // Ensure end is never less than start
                      if (_endIndex < _startIndex) {
                        _endIndex = _startIndex;
                      }
                      // Ensure end is never greater than total questions
                      if (_endIndex > widget.subject.numberOfQuestions) {
                        _endIndex = widget.subject.numberOfQuestions;
                      }
                      // Ensure end is never less than 1
                      if (_endIndex < 1) {
                        _endIndex = 1;
                      }
                    });
                  },
                )
              else
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'End question same as start',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You will practice questions $_startIndex to $_endIndex (${_endIndex - _startIndex + 1} questions)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onStartPractice(
              _startIndex - 1,
              _endIndex - 1,
            ); // Convert to 0-based index
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('अभ्यास सुरु गर्नुहोस्'),
        ),
      ],
    );
  }
}

class SubjectListScreen extends StatefulWidget {
  final List<SubjectListResponse> subjects;
  final Future<List<SubjectListResponse>>? futureSubjects;
  final void Function(SubjectListResponse subject)? onAttempt;

  const SubjectListScreen({
    super.key,
    required this.subjects,
    this.futureSubjects,
    this.onAttempt,
  });

  // Convenience constructor to load from network
  SubjectListScreen.network({super.key, this.onAttempt})
    : subjects = const [],
      futureSubjects = ApiService.getSubjectsWithAccess();

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh premium status when screen loads
    context.requestPremiumStatus();
  }

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'विषयगत प्रश्नोत्तर',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<PremiumBloc, PremiumState>(
        builder: (context, premiumState) {
          final userHasPremium = premiumState is PremiumActive;

          return widget.futureSubjects == null
              ? _buildList(
                  context,
                  widget.subjects,
                  userHasPremium,
                  _formatDuration,
                )
              : FutureBuilder<List<SubjectListResponse>>(
                  future: widget.futureSubjects,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading subjects',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    final items = snapshot.data ?? const [];
                    return _buildList(
                      context,
                      items,
                      userHasPremium,
                      _formatDuration,
                    );
                  },
                );
        },
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectListResponse subject;
  final VoidCallback? onAttempt;
  final String Function(int) formatDuration;

  const _SubjectTile({
    required this.subject,
    this.onAttempt,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon, title, and premium badge
            Row(
              children: [
                // Subject icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getSubjectIcon(subject.name, false),
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: subject.subjectId.toUpperCase(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${subject.subjectId.toUpperCase()} copied to clipboard',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            child: Text(
                              subject.subjectId.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ' | संविधान र कानून',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Premium/Free badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: subject.isPremium
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subject.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                    style: TextStyle(
                      color: subject.isPremium
                          ? AppColors.primary
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _StatItem(
                  icon: Icons.quiz_outlined,
                  label: '${subject.numberOfQuestions} प्रश्न',
                ),
                const SizedBox(width: 16),
                _StatItem(
                  icon: Icons.timer_outlined,
                  label: formatDuration(
                    subject.perQsnDuration * subject.numberOfQuestions,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAttempt,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'अभ्यास गर्नुहोस्',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subjectName, bool isSpecial) {
    // More specific icons for different types of legal subjects
    final name = subjectName.toLowerCase();

    if (name.contains('संवैधानिक') || name.contains('constitutional')) {
      return Icons.account_balance; // Supreme Court building
    } else if (name.contains('प्रशासकीय') || name.contains('administrative')) {
      return Icons.admin_panel_settings; // Administrative settings
    } else if (name.contains('अपराध') ||
        name.contains('criminal') ||
        name.contains('फौजदारी')) {
      return Icons.gavel; // Gavel for criminal law
    } else if (name.contains('देवानी') || name.contains('civil')) {
      return Icons.handshake; // Handshake for civil law
    } else if (name.contains('न्याय') || name.contains('justice')) {
      return Icons.balance; // Scales of justice
    } else if (name.contains('प्रमाण') || name.contains('evidence')) {
      return Icons.fact_check; // Evidence/fact check
    } else if (name.contains('विधिशास्त्र') || name.contains('jurisprudence')) {
      return Icons.menu_book; // Book for jurisprudence
    } else if (name.contains('व्याख्या') || name.contains('interpretation')) {
      return Icons.translate; // Translation/interpretation
    } else if (name.contains('अदालत') || name.contains('court')) {
      return Icons.account_balance; // Court building
    } else if (name.contains('नेपालको कानून') || name.contains('nepal law')) {
      return Icons.flag; // Flag for Nepal law system
    } else if (name.contains('कानून व्याख्या') ||
        name.contains('legal interpretation')) {
      return Icons.translate; // Translation/interpretation
    }
    // Specialized subjects
    else if (name.contains('अन्तर्राष्ट्रिय') ||
        name.contains('international')) {
      return Icons.public; // Globe for international law
    } else if (name.contains('मानव अधिकार') || name.contains('human rights')) {
      return Icons.favorite; // Heart for human rights
    } else if (name.contains('कम्पनी') || name.contains('company')) {
      return Icons.business; // Business building
    } else if (name.contains('लैंगिक हिंसा') ||
        name.contains('gender') ||
        name.contains('violence')) {
      return Icons.security; // Security shield
    } else if (name.contains('बाल') || name.contains('child')) {
      return Icons.child_care; // Child care
    } else if (name.contains('संगठित अपराध') ||
        name.contains('organized crime')) {
      return Icons.warning; // Warning sign
    } else if (name.contains('विद्युतीय') ||
        name.contains('electronic') ||
        name.contains('digital')) {
      return Icons.computer; // Computer/electronic
    } else if (name.contains('भ्रष्टाचार') || name.contains('corruption')) {
      return Icons.block; // Block/stop corruption
    } else if (name.contains('विवाद समाधान') ||
        name.contains('dispute resolution')) {
      return Icons.mediation; // Mediation
    } else if (name.contains('बौद्धिक सम्पत्ति') ||
        name.contains('intellectual property')) {
      return Icons.lightbulb; // Lightbulb for ideas/IP
    } else if (name.contains('कर') || name.contains('tax')) {
      return Icons.account_balance_wallet; // Wallet for tax/money
    } else if (name.contains('पीडित') || name.contains('victim')) {
      return Icons.support; // Support for victims
    } else if (name.contains('आचार संहिता') ||
        name.contains('code of conduct')) {
      return Icons.rule; // Rules/conduct
    } else if (name.contains('वातावरण') || name.contains('environmental')) {
      return Icons.eco; // Eco/environment
    } else if (name.contains('बीमा') || name.contains('insurance')) {
      return Icons.security; // Security for insurance
    } else if (name.contains('श्रम') || name.contains('labor')) {
      return Icons.work; // Work for labor
    } else if (name.contains('बैंक') ||
        name.contains('banking') ||
        name.contains('वित्तीय')) {
      return Icons.account_balance_wallet; // Wallet for banking
    } else if (name.contains('अध्यागमन') || name.contains('immigration')) {
      return Icons.flight; // Flight for immigration
    } else if (name.contains('अनुसन्धान') || name.contains('research')) {
      return Icons.search; // Search for research
    } else if (name.contains('कानून') || name.contains('law')) {
      return Icons.library_books; // Law books
    } else {
      return Icons.balance; // Default scales of justice
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Old demo classes and services removed - now using API integration
/*
class DemoSubjectListScreen extends StatelessWidget {
  const DemoSubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubjectListScreen.network(
      onAttempt: (subject) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attempting ${subject.name}...')),
        );
      },
    );
  }
}

// Dummy service that simulates a network call
class SubjectService {
  static Future<List<Subject>> fetchSubjects() async {
    // Example with ApiClient (kept dummy for now)
    // final api = ApiClient(baseUrl: 'https://api.example.com');
    // final json = await api.getJson('/subjects');
    // return (json as List).map((e) => Subject.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    const payload = [
      {
        'id': 'sub_1',
        'name': 'संवैधानिक कानून',
        'numberOfQuestions': 50,
        'durationMinutes': 60,
        'passMark': 40,
        'isPremium': false,
        'isSpecial': false,
        'hasAttempted': true,
        'lastAttempt': {
          'examId': 'sub_1',
          'examTitle': 'संवैधानिक कानून परीक्षा',
          'studentId': 'student_123',
          'studentName': 'Dipak Shah',
          'studentEmail': 'appdibetu@gmail.com',
          'attemptedAt': '2024-01-15T10:30:00Z',
          'timeTakenSeconds': 1800,
          'totalQuestions': 5,
          'correctCount': 4,
          'wrongCount': 1,
          'unattemptedCount': 0,
          'finalMarks': 80.0,
          'positiveMark': 4,
          'negativeMark': 0,
          'selectedAnswers': {'0': 0, '1': 1, '2': 0, '3': 0, '4': 1},
          'isPassed': true,
          'passMark': 40,
        },
      },
      {
        'id': 'sub_2',
        'name': 'प्रशासकीय कानून',
        'numberOfQuestions': 45,
        'durationMinutes': 55,
        'passMark': 35,
        'isPremium': true,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_3',
        'name': 'मुलुकी अपराध संहिता',
        'numberOfQuestions': 60,
        'durationMinutes': 75,
        'passMark': 45,
        'isPremium': false,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_4',
        'name': 'मुलुकी फौजदारी कार्यविधि संहिता',
        'numberOfQuestions': 55,
        'durationMinutes': 70,
        'passMark': 42,
        'isPremium': true,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_5',
        'name': 'मुलुकी देवानी संहिता',
        'numberOfQuestions': 50,
        'durationMinutes': 65,
        'passMark': 40,
        'isPremium': false,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_6',
        'name': 'मुलुकी देवानी कार्यविधि संहिता',
        'numberOfQuestions': 48,
        'durationMinutes': 60,
        'passMark': 38,
        'isPremium': true,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_7',
        'name': 'फौजदारी कसूर (सजाय निर्धारण तथा कार्यान्वयन) ऐन',
        'numberOfQuestions': 42,
        'durationMinutes': 55,
        'passMark': 35,
        'isPremium': false,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_8',
        'name': 'न्याय प्रशासन ऐन र प्रमाण कानून',
        'numberOfQuestions': 40,
        'durationMinutes': 50,
        'passMark': 32,
        'isPremium': true,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_9',
        'name': 'नेपालको कानून प्रणाली',
        'numberOfQuestions': 35,
        'durationMinutes': 45,
        'passMark': 28,
        'isPremium': false,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_10',
        'name': 'विधिशास्त्र (विभिन्न सम्प्रदायको बारेमा मात्र)',
        'numberOfQuestions': 38,
        'durationMinutes': 48,
        'passMark': 30,
        'isPremium': true,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_11',
        'name': 'कानून व्याख्यासम्बन्धी',
        'numberOfQuestions': 33,
        'durationMinutes': 42,
        'passMark': 26,
        'isPremium': false,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_12',
        'name': 'अदालतका नियमावलीहरु',
        'numberOfQuestions': 30,
        'durationMinutes': 40,
        'passMark': 24,
        'isPremium': true,
        'isSpecial': false,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_13',
        'name': 'अन्तर्राष्ट्रिय कानून',
        'numberOfQuestions': 45,
        'durationMinutes': 60,
        'passMark': 36,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_14',
        'name': 'मानव अधिकारकानून',
        'numberOfQuestions': 40,
        'durationMinutes': 55,
        'passMark': 32,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_15',
        'name': 'कम्पनी कानून',
        'numberOfQuestions': 50,
        'durationMinutes': 65,
        'passMark': 40,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_16',
        'name': 'लैंगिक हिंसा नियन्त्रण कानून',
        'numberOfQuestions': 35,
        'durationMinutes': 50,
        'passMark': 28,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_17',
        'name': 'बाल न्याय तथा बालबालिकासम्बन्धी ऐन',
        'numberOfQuestions': 38,
        'durationMinutes': 52,
        'passMark': 30,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_18',
        'name': 'संगठित अपराध (मानव बेचविखन, लागू औषध, सम्पत्ति शुद्धीकरण)',
        'numberOfQuestions': 55,
        'durationMinutes': 70,
        'passMark': 44,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_19',
        'name': 'विद्युतीय कारोवार सम्बन्धी कानून',
        'numberOfQuestions': 42,
        'durationMinutes': 58,
        'passMark': 34,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_20',
        'name': 'भ्रष्टाचार निवारणसम्बन्धी कानून',
        'numberOfQuestions': 48,
        'durationMinutes': 62,
        'passMark': 38,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_21',
        'name': 'विवाद समाधानका वैकल्पिक उपायहरु',
        'numberOfQuestions': 36,
        'durationMinutes': 48,
        'passMark': 29,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_22',
        'name': 'बौद्धिक सम्पत्तिसम्बन्धी कानून',
        'numberOfQuestions': 44,
        'durationMinutes': 56,
        'passMark': 35,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_23',
        'name': 'कर कानून',
        'numberOfQuestions': 46,
        'durationMinutes': 60,
        'passMark': 37,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_24',
        'name': 'अपराध पीडितसम्बन्धी कानून',
        'numberOfQuestions': 32,
        'durationMinutes': 45,
        'passMark': 26,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_25',
        'name': 'व्यावसायिक आचार संहिता',
        'numberOfQuestions': 28,
        'durationMinutes': 40,
        'passMark': 22,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_26',
        'name': 'वातावरण कानून',
        'numberOfQuestions': 40,
        'durationMinutes': 54,
        'passMark': 32,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_27',
        'name': 'बीमा कानून',
        'numberOfQuestions': 38,
        'durationMinutes': 50,
        'passMark': 30,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_28',
        'name': 'श्रम कानून',
        'numberOfQuestions': 42,
        'durationMinutes': 56,
        'passMark': 34,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_29',
        'name': 'वैकिंग कसूर र बैंक तथा वित्तीय संस्थासम्बन्धी कानून',
        'numberOfQuestions': 50,
        'durationMinutes': 65,
        'passMark': 40,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_30',
        'name': 'अध्यागमन सम्बन्धी कानून',
        'numberOfQuestions': 34,
        'durationMinutes': 46,
        'passMark': 27,
        'isPremium': true,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_31',
        'name': 'कानूनी अनुसन्धान',
        'numberOfQuestions': 30,
        'durationMinutes': 42,
        'passMark': 24,
        'isPremium': false,
        'isSpecial': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
    ];
    return payload.map((e) => Subject.fromJson(e)).toList();
  }
}

class QuestionRangeDialog extends StatefulWidget {
  final Subject subject;
  final bool userHasPremium;
  final Function(int startIndex, int endIndex) onStartPractice;

  const QuestionRangeDialog({
    super.key,
    required this.subject,
    required this.userHasPremium,
    required this.onStartPractice,
  });

  @override
  State<QuestionRangeDialog> createState() => _QuestionRangeDialogState();
}

class _QuestionRangeDialogState extends State<QuestionRangeDialog> {
  late int _startIndex;
  late int _endIndex;
  final int _maxQuestionsForPremium = 20; // Maximum for premium subjects

  @override
  void initState() {
    super.initState();
    final totalQuestions = widget.subject.numberOfQuestions;
    // Premium subjects: max 20 questions or actual count (whichever is smaller)
    // Free subjects: actual question count (no restriction)
    final maxAllowed = widget.subject.isPremium
        ? (totalQuestions < _maxQuestionsForPremium
              ? totalQuestions
              : _maxQuestionsForPremium)
        : totalQuestions;

    _startIndex = 1;
    _endIndex = maxAllowed > 10 ? 10 : maxAllowed;

    // Ensure start index doesn't exceed end index
    if (_startIndex > _endIndex) {
      _startIndex = _endIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.subject.numberOfQuestions;
    // Premium subjects: max 20 questions or actual count (whichever is smaller)
    // Free subjects: actual question count (no restriction)
    final maxAllowed = widget.subject.isPremium
        ? (totalQuestions < _maxQuestionsForPremium
              ? totalQuestions
              : _maxQuestionsForPremium)
        : totalQuestions;

    return AlertDialog(
      title: Text('प्रश्नको दायरा छान्नुहोस्'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.subject.name} - कुल ${totalQuestions} प्रश्न',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subject.isPremium
                ? 'प्रीमियम विषय: अधिकतम ${maxAllowed} प्रश्न छान्न सकिन्छ'
                : 'निशुल्क विषय: सबै ${maxAllowed} प्रश्न छान्न सकिन्छ',
            style: TextStyle(
              fontSize: 12,
              color: widget.subject.isPremium
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Start Index
          Row(
            children: [
              const Text('सुरुको प्रश्न: '),
              Expanded(
                child: Slider(
                  value: _startIndex.toDouble(),
                  min: 1,
                  max: maxAllowed.toDouble(),
                  divisions: maxAllowed > 1 ? maxAllowed - 1 : null,
                  label: _startIndex.toString(),
                  onChanged: (value) {
                    setState(() {
                      _startIndex = value.round();
                      // If start index becomes greater than end index, make end index equal to start index
                      if (_startIndex > _endIndex) {
                        _endIndex = _startIndex;
                      }
                    });
                  },
                ),
              ),
              Text('$_startIndex'),
            ],
          ),

          // End Index
          Row(
            children: [
              const Text('अन्तिम प्रश्न: '),
              Expanded(
                child: Slider(
                  value: _endIndex.toDouble(),
                  min: _startIndex.toDouble(),
                  max: maxAllowed.toDouble(),
                  divisions: maxAllowed > _startIndex
                      ? maxAllowed - _startIndex
                      : null,
                  label: _endIndex.toString(),
                  onChanged: (value) {
                    setState(() {
                      _endIndex = value.round();
                      // If end index becomes less than start index, make start index equal to end index
                      if (_endIndex < _startIndex) {
                        _startIndex = _endIndex;
                      }
                    });
                  },
                ),
              ),
              Text('$_endIndex'),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'कुल प्रश्न: ${_endIndex - _startIndex + 1}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          if (totalQuestions > maxAllowed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'अधिकतम $maxAllowed प्रश्न मात्र अभ्यास गर्न सकिन्छ।',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('रद्द गर्नुहोस्'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onStartPractice(
              _startIndex - 1,
              _endIndex - 1,
            ); // Convert to 0-based index
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('अभ्यास सुरु गर्नुहोस्'),
        ),
      ],
    );
  }
}
*/
