import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../exam_taking/view/exam_taking_screen.dart';
import '../../exam_taking/models/exam_attempt_model.dart';

class Subject {
  final String id;
  final String name;
  final int numberOfQuestions;
  final int durationMinutes;
  final int passMark;
  final bool isPremium;
  final bool hasAttempted;
  final ExamAttempt? lastAttempt;

  const Subject({
    required this.id,
    required this.name,
    required this.numberOfQuestions,
    required this.durationMinutes,
    required this.passMark,
    required this.isPremium,
    this.hasAttempted = false,
    this.lastAttempt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      numberOfQuestions: json['numberOfQuestions'] as int,
      durationMinutes: json['durationMinutes'] as int,
      passMark: json['passMark'] as int,
      isPremium: json['isPremium'] as bool,
      hasAttempted: json['hasAttempted'] as bool? ?? false,
      lastAttempt: json['lastAttempt'] != null
          ? ExamAttempt.fromJson(json['lastAttempt'] as Map<String, dynamic>)
          : null,
    );
  }
}

Widget _buildList(
  BuildContext context,
  List<Subject> subjects,
  bool userHasPremium,
) {
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    itemCount: subjects.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final subject = subjects[index];

      return _SubjectTile(
        subject: subject,
        locked:
            subject.isPremium &&
            !userHasPremium, // Lock premium subjects for non-premium users
        onAttempt: () {
          // Show question range selection dialog for all subjects
          _showQuestionRangeDialog(context, subject, userHasPremium);
        },
      );
    },
  );
}

void _showQuestionRangeDialog(
  BuildContext context,
  Subject subject,
  bool userHasPremium,
) {
  // Don't show dialog for premium subjects if user doesn't have premium
  if (subject.isPremium && !userHasPremium) {
    return;
  }

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
                examId: subject.id,
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

class SubjectListScreen extends StatelessWidget {
  final List<Subject> subjects;
  final Future<List<Subject>>? futureSubjects;
  final bool userHasPremium;
  final void Function(Subject subject)? onAttempt;

  const SubjectListScreen({
    super.key,
    required this.subjects,
    this.futureSubjects,
    this.userHasPremium = false,
    this.onAttempt,
  });

  // Convenience constructor to load from network
  SubjectListScreen.network({
    super.key,
    this.userHasPremium = false,
    this.onAttempt,
  }) : subjects = const [],
       futureSubjects = SubjectService.fetchSubjects();

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
      body: futureSubjects == null
          ? _buildList(context, subjects, userHasPremium)
          : FutureBuilder<List<Subject>>(
              future: futureSubjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = snapshot.data ?? const [];
                return _buildList(context, items, userHasPremium);
              },
            ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final Subject subject;
  final bool locked;
  final VoidCallback onAttempt;

  const _SubjectTile({
    required this.subject,
    required this.locked,
    required this.onAttempt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LockedBadge(locked: locked, isPremium: subject.isPremium),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: subject.isPremium
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subject.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                          style: TextStyle(
                            color: subject.isPremium
                                ? AppColors.primary.withValues(alpha: 0.7)
                                : Colors.green.withValues(alpha: 0.7),
                            fontWeight: FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.help_outline,
                        label: '${subject.numberOfQuestions} प्रश्न',
                      ),
                      _InfoChip(
                        icon: Icons.schedule,
                        label: '${subject.durationMinutes} मिनेट',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: onAttempt,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        locked ? 'प्रीमियम आवश्यक' : 'अभ्यास गर्नुहोस्',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: locked
                            ? Colors.grey
                            : const Color(0xFFF8D7DA),
                        foregroundColor: locked
                            ? Colors.white
                            : Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedBadge extends StatelessWidget {
  final bool locked;
  final bool isPremium;

  const _LockedBadge({required this.locked, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final bg = locked
        ? Colors.red.withOpacity(0.1)
        : Colors.green.withOpacity(0.1);
    final icon = locked ? Icons.lock_outline : Icons.lock_open_outlined;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: 16,
        color: isPremium
            ? AppColors.primary.withValues(alpha: 0.4)
            : Colors.grey.shade700,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Example usage with mock data:
class DemoSubjectListScreen extends StatelessWidget {
  const DemoSubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubjectListScreen.network(
      userHasPremium: false,
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
        'name': 'Biology',
        'numberOfQuestions': 50,
        'durationMinutes': 60,
        'passMark': 40,
        'isPremium': false,
        'hasAttempted': true,
        'lastAttempt': {
          'examId': 'sub_1',
          'examTitle': 'जीव विज्ञान परीक्षा',
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
        'name': 'Physics',
        'numberOfQuestions': 60,
        'durationMinutes': 75,
        'passMark': 45,
        'isPremium': true,
        'hasAttempted': false,
        'lastAttempt': null,
      },
      {
        'id': 'sub_3',
        'name': 'Chemistry',
        'numberOfQuestions': 55,
        'durationMinutes': 70,
        'passMark': 42,
        'isPremium': false,
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
  final int _maxQuestionsForAll = 20; // Maximum for all users

  @override
  void initState() {
    super.initState();
    final maxAllowed = _maxQuestionsForAll; // All users limited to 20

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
    final maxAllowed = _maxQuestionsForAll; // All users limited to 20

    return AlertDialog(
      title: Text('प्रश्नको दायरा छान्नुहोस्'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.subject.name} - कुल ${totalQuestions} प्रश्न',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

          if (totalQuestions > _maxQuestionsForAll) ...[
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
                      'अधिकतम $_maxQuestionsForAll प्रश्न मात्र अभ्यास गर्न सकिन्छ।',
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
