import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../exam_taking/models/exam_attempt_model.dart';

part 'exam_event.dart';
part 'exam_state.dart';

// Simple model
class Exam extends Equatable {
  final String id;
  final String name;
  final String description;
  final String duration;
  final int questions;
  final double price;
  final bool isPremium;
  final bool hasAttempted;
  final ExamAttempt? lastAttempt;

  const Exam({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.questions,
    required this.price,
    this.isPremium = false,
    this.hasAttempted = false,
    this.lastAttempt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    duration,
    questions,
    price,
    isPremium,
    hasAttempted,
    lastAttempt,
  ];
}

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  ExamBloc() : super(ExamInitial()) {
    on<ExamsFetched>(_onExamsFetched);
  }

  Future<void> _onExamsFetched(
    ExamsFetched event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoadInProgress());
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate API call

    // Create attempt data for Set001 (already attempted)
    final phyAttempt = ExamAttempt(
      examId: 'Set001',
      examTitle: 'नमुना सेट १',
      studentId: 'student_123',
      studentName: 'Dipak Shah',
      studentEmail: 'appdibetu@gmail.com',
      attemptedAt: DateTime.now().subtract(const Duration(days: 1)),
      timeTakenSeconds: 1200,
      totalQuestions: 5,
      correctCount: 3,
      wrongCount: 2,
      unattemptedCount: 0,
      finalMarks: 60.0,
      positiveMark: 3,
      negativeMark: 0,
      selectedAnswers: {0: 0, 1: 1, 2: 2, 3: 1, 4: 0},
      isPassed: true,
      passMark: 40,
    );

    // Create attempt data for Set002 (already attempted)
    final cheAttempt = ExamAttempt(
      examId: 'Set002',
      examTitle: 'नमुना सेट २',
      studentId: 'student_123',
      studentName: 'Dipak Shah',
      studentEmail: 'appdibetu@gmail.com',
      attemptedAt: DateTime.now().subtract(const Duration(days: 3)),
      timeTakenSeconds: 1800,
      totalQuestions: 5,
      correctCount: 4,
      wrongCount: 1,
      unattemptedCount: 0,
      finalMarks: 80.0,
      positiveMark: 4,
      negativeMark: 0,
      selectedAnswers: {0: 1, 1: 0, 2: 2, 3: 1, 4: 0},
      isPassed: true,
      passMark: 40,
    );

    // Create attempt data for Set004 (already attempted - free exam)
    final matAttempt = ExamAttempt(
      examId: 'Set004',
      examTitle: 'नमुना सेट ४',
      studentId: 'student_123',
      studentName: 'Dipak Shah',
      studentEmail: 'appdibetu@gmail.com',
      attemptedAt: DateTime.now().subtract(const Duration(days: 5)),
      timeTakenSeconds: 1500,
      totalQuestions: 5,
      correctCount: 2,
      wrongCount: 2,
      unattemptedCount: 1,
      finalMarks: 40.0,
      positiveMark: 2,
      negativeMark: 0,
      selectedAnswers: {0: 0, 1: 1, 2: -1, 3: 2, 4: 0}, // -1 means unattempted
      isPassed: true,
      passMark: 40,
    );

    final exams = [
      Exam(
        id: 'Set001',
        name: 'नमुना सेट १',
        description:
            'यो परीक्षाले तपाईंको भौतिक विज्ञानको ज्ञानलाई परख्न मद्दत गर्छ। हाम्रो योग्य टोलीले तयार गरेको।',
        duration: '00:30:00',
        questions: 50,
        price: 25.0,
        isPremium: true,
        hasAttempted: true,
        lastAttempt: phyAttempt,
      ),
      Exam(
        id: 'Set002',
        name: 'नमुना सेट २',
        description: 'रसायन विज्ञानको मौलिक ज्ञानको परीक्षा लिनुहोस्।',
        duration: '00:45:00',
        questions: 60,
        price: 0.0, // Free exam
        isPremium: false,
        hasAttempted: true,
        lastAttempt: cheAttempt,
      ),
      const Exam(
        id: 'Set003',
        name: 'नमुना सेट ३',
        description:
            'जीव विज्ञानको विभिन्न क्षेत्रहरूमा तपाईंको ज्ञानको मूल्याङ्कन गर्नुहोस्।',
        duration: '00:40:00',
        questions: 55,
        price: 20.0,
        isPremium: true,
        hasAttempted: false,
        lastAttempt: null,
      ),
      Exam(
        id: 'Set004',
        name: 'नमुना सेट ४',
        description: 'गणितको आधारभूत सिद्धान्तहरूको परीक्षा।',
        duration: '00:40:00',
        questions: 45,
        price: 0.0, // Free exam
        isPremium: false,
        hasAttempted: true,
        lastAttempt: matAttempt,
      ),
      const Exam(
        id: 'Set005',
        name: 'नमुना सेट ५',
        description: 'अंग्रेजी भाषाको मौलिक ज्ञानको परीक्षा।',
        duration: '00:35:00',
        questions: 40,
        price: 0.0, // Free exam
        isPremium: false,
        hasAttempted: false,
        lastAttempt: null,
      ),
      const Exam(
        id: 'Set006',
        name: 'नमुना सेट ६',
        description: 'नेपाली कानून र न्यायिक प्रणालीको गहन अध्ययन।',
        duration: '01:00:00',
        questions: 80,
        price: 50.0, // Paid exam
        isPremium: true,
        hasAttempted: false,
        lastAttempt: null,
      ),
      const Exam(
        id: 'Set007',
        name: 'नमुना सेट ७',
        description: 'प्रीमियम आवश्यक - उच्च स्तरको परीक्षा।',
        duration: '01:30:00',
        questions: 100,
        price: 100.0, // Premium required exam
        isPremium: true,
        hasAttempted: false,
        lastAttempt: null,
      ),
    ];
    emit(ExamLoadSuccess(exams: exams));
  }
}
