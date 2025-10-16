import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../exam_taking/view/exam_taking_screen.dart';

class Subject {
  final String id;
  final String name;
  final int numberOfQuestions;
  final int durationMinutes;
  final int passMark;
  final bool isPremium;

  const Subject({
    required this.id,
    required this.name,
    required this.numberOfQuestions,
    required this.durationMinutes,
    required this.passMark,
    required this.isPremium,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      numberOfQuestions: json['numberOfQuestions'] as int,
      durationMinutes: json['durationMinutes'] as int,
      passMark: json['passMark'] as int,
      isPremium: json['isPremium'] as bool,
    );
  }
}

Widget _buildList(BuildContext context, List<Subject> subjects) {
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    itemCount: subjects.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final subject = subjects[index];
      final locked =
          subject.isPremium &&
          !(context
                  .findAncestorWidgetOfExactType<SubjectListScreen>()
                  ?.userHasPremium ??
              false);

      return _SubjectTile(
        subject: subject,
        locked: locked,
        onAttempt: () {
          if (locked) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('प्रीमियम चाहिन्छ।')));
            return;
          }
          // Navigate to exam taking screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExamTakingScreen(examId: subject.id),
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
          ? _buildList(context, subjects)
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
                return _buildList(context, items);
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
                      _InfoChip(
                        icon: Icons.verified_outlined,
                        label: 'उत्तीर्णाङ्क ${subject.passMark}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: onAttempt,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'परीक्षा दिनुहोस्',
                        style: TextStyle(fontWeight: FontWeight.normal),
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
      },
      {
        'id': 'sub_2',
        'name': 'Physics',
        'numberOfQuestions': 60,
        'durationMinutes': 75,
        'passMark': 45,
        'isPremium': true,
      },
      {
        'id': 'sub_3',
        'name': 'Chemistry',
        'numberOfQuestions': 55,
        'durationMinutes': 70,
        'passMark': 42,
        'isPremium': false,
      },
    ];
    return payload.map((e) => Subject.fromJson(e)).toList();
  }
}
