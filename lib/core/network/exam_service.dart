import '../../features/exam_taking/models/exam_question_model.dart';
import '../../features/exam_taking/models/exam_attempt_model.dart';

class ExamDetails {
  final String id;
  final String title;
  final String subject;
  final int durationMinutes;
  final int totalQuestions;
  final int passMark;
  final double price;
  final List<ExamQuestion> questions;

  const ExamDetails({
    required this.id,
    required this.title,
    required this.subject,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.passMark,
    required this.price,
    required this.questions,
  });

  factory ExamDetails.fromJson(Map<String, dynamic> json) {
    return ExamDetails(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      durationMinutes: json['durationMinutes'] as int,
      totalQuestions: json['totalQuestions'] as int,
      passMark: json['passMark'] as int,
      price: (json['price'] as num).toDouble(),
      questions: (json['questions'] as List)
          .map((q) => ExamQuestionJson.fromJson(q))
          .toList(),
    );
  }
}

class ExamService {
  static Future<ExamDetails> fetchExamDetails(
    String examId, {
    int? questionStartIndex,
    int? questionEndIndex,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Determine exam type based on ID prefix
    if (examId.startsWith('bastugat_')) {
      return _getBastugatExamData(examId, questionStartIndex, questionEndIndex);
    } else {
      return _getBishaygatExamData(
        examId,
        questionStartIndex,
        questionEndIndex,
      );
    }
  }

  // Check if user has already attempted this exam
  static Future<ExamAttempt?> checkExistingAttempt(
    String examId,
    String studentId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo purposes, simulate some exams as already attempted
    final attemptedExams = {
      'sub_1': {
        'examId': 'sub_1',
        'examTitle': 'जीव विज्ञान परीक्षा',
        'studentId': studentId,
        'studentName': 'Dipak Shah',
        'studentEmail': 'appdibetu@gmail.com',
        'attemptedAt': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'timeTakenSeconds': 1800, // 30 minutes
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
      'Phy011': {
        'examId': 'Phy011',
        'examTitle': 'भौतिक विज्ञान परीक्षा',
        'studentId': studentId,
        'studentName': 'Dipak Shah',
        'studentEmail': 'appdibetu@gmail.com',
        'attemptedAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'timeTakenSeconds': 1200, // 20 minutes
        'totalQuestions': 5,
        'correctCount': 3,
        'wrongCount': 2,
        'unattemptedCount': 0,
        'finalMarks': 60.0,
        'positiveMark': 3,
        'negativeMark': 0,
        'selectedAnswers': {'0': 0, '1': 1, '2': 2, '3': 1, '4': 0},
        'isPassed': true,
        'passMark': 40,
      },
    };

    final attemptData = attemptedExams[examId];
    if (attemptData != null) {
      return ExamAttempt.fromJson(attemptData);
    }

    return null; // No existing attempt found
  }

  // Save exam attempt (for future use)
  static Future<bool> saveExamAttempt(ExamAttempt attempt) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, this would save to backend
    // For now, just simulate success
    return true;
  }

  static Future<Map<String, dynamic>> getExamAttemptDetails(
    String examId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get exam details first - fetch all questions for attempted exams
    final examDetails = await fetchExamDetails(examId);

    // Get attempt details
    final attempt = await checkExistingAttempt(examId, 'student_123');

    if (attempt == null) {
      throw Exception('No attempt found for this exam');
    }

    return {
      'attempt': attempt.toJson(),
      'questions': examDetails.questions
          .map((q) => ExamQuestionJson.toJson(q))
          .toList(),
      'examDetails': {
        'id': examDetails.id,
        'title': examDetails.title,
        'subject': examDetails.subject,
        'durationMinutes': examDetails.durationMinutes,
        'totalQuestions': examDetails.totalQuestions,
        'passMark': examDetails.passMark,
        'price': examDetails.price,
      },
    };
  }

  static ExamDetails _getBishaygatExamData(
    String examId,
    int? questionStartIndex,
    int? questionEndIndex,
  ) {
    // Map exam IDs to proper titles
    final titleMap = {
      'sub_1': 'जीव विज्ञान परीक्षा',
      'sub_2': 'भौतिक विज्ञान परीक्षा',
      'sub_3': 'रसायन विज्ञान परीक्षा',
      'Phy011': 'भौतिक विज्ञान परीक्षा',
      'Che012': 'रसायन विज्ञान आधारभूत',
      'Bio013': 'जीव विज्ञान परीक्षा',
    };

    final dummyData = {
      'id': examId,
      'title': titleMap[examId] ?? 'विषयगत प्रश्नोत्तर',
      'subject': examId.startsWith('Phy')
          ? 'Physics'
          : examId.startsWith('Che')
          ? 'Chemistry'
          : 'Biology',
      'durationMinutes': examId == 'Phy011'
          ? 30
          : examId == 'Che012'
          ? 45
          : examId == 'Bio013'
          ? 40
          : 60,
      'totalQuestions': 5,
      'passMark': 40,
      'price': examId == 'Phy011'
          ? 25.0
          : examId == 'Che012'
          ? 30.0
          : examId == 'Bio013'
          ? 20.0
          : 20.0,
      'questions': [
        {
          'id': 'q1',
          'questionText': 'जीवविज्ञानमा कोशिका कुन हो?',
          'options': [
            'जीवको सबैभन्दा सानो एकाइ',
            'जीवको सबैभन्दा ठूलो एकाइ',
            'जीवको मध्य एकाइ',
            'जीवको अन्तिम एकाइ',
          ],
          'correctAnswerIndex': 0,
          'explanation': 'कोशिका जीवको सबैभन्दा सानो र मौलिक एकाइ हो।',
        },
        {
          'id': 'q2',
          'questionText': 'प्रकाश संश्लेषण कहाँ हुन्छ?',
          'options': [
            'माइटोकन्ड्रिया',
            'क्लोरोप्लास्ट',
            'न्युक्लियस',
            'राइबोसोम',
          ],
          'correctAnswerIndex': 1,
          'explanation': 'प्रकाश संश्लेषण क्लोरोप्लास्टमा हुन्छ।',
        },
        {
          'id': 'q3',
          'questionText': 'DNA को पूरा नाम के हो?',
          'options': [
            'डिअक्सिराइबोन्युक्लिक एसिड',
            'डिअक्सिराइबोन्युक्लियर एसिड',
            'डिअक्सिराइबोन्युक्लिक एसिड',
            'डिअक्सिराइबोन्युक्लियर एसिड',
          ],
          'correctAnswerIndex': 0,
          'explanation': 'DNA को पूरा नाम डिअक्सिराइबोन्युक्लिक एसिड हो।',
        },
        {
          'id': 'q4',
          'questionText': 'मानव शरीरमा कति हड्डीहरू छन्?',
          'options': ['२०६', '२०८', '२१०', '२१२'],
          'correctAnswerIndex': 0,
          'explanation': 'वयस्क मानव शरीरमा २०६ हड्डीहरू छन्।',
        },
        {
          'id': 'q5',
          'questionText': 'रक्तमा कुन कोशिका ऑक्सिजन ढुवानी गर्छ?',
          'options': [
            'श्वेत रक्त कोशिका',
            'लाल रक्त कोशिका',
            'प्लेटलेट',
            'प्लाज्मा',
          ],
          'correctAnswerIndex': 1,
          'explanation':
              'लाल रक्त कोशिकाले हिमोग्लोबिनको माध्यमबाट ऑक्सिजन ढुवानी गर्छ।',
        },
      ],
    };
    return ExamDetails.fromJson(dummyData);
  }

  static ExamDetails _getBastugatExamData(
    String examId,
    int? questionStartIndex,
    int? questionEndIndex,
  ) {
    // Map exam IDs to proper titles
    final titleMap = {
      'bastugat_1': 'गणित परीक्षा',
      'bastugat_2': 'अंग्रेजी परीक्षा',
      'bastugat_3': 'सामान्य ज्ञान परीक्षा',
    };

    final dummyData = {
      'id': examId,
      'title': titleMap[examId] ?? 'वस्तुगत सेटहरु',
      'subject': 'Mathematics',
      'durationMinutes': 50,
      'totalQuestions': 5,
      'passMark': 30,
      'price': 25.0,
      'questions': [
        {
          'id': 'q1',
          'questionText': '२ + २ = ?',
          'options': ['३', '४', '५', '६'],
          'correctAnswerIndex': 1,
          'explanation': '२ + २ = ४ हो।',
        },
        {
          'id': 'q2',
          'questionText': '१० × ५ = ?',
          'options': ['४०', '५०', '६०', '७०'],
          'correctAnswerIndex': 1,
          'explanation': '१० × ५ = ५० हो।',
        },
        {
          'id': 'q3',
          'questionText': '१०० ÷ ४ = ?',
          'options': ['२०', '२५', '३०', '३५'],
          'correctAnswerIndex': 1,
          'explanation': '१०० ÷ ४ = २५ हो।',
        },
        {
          'id': 'q4',
          'questionText': '√१६ = ?',
          'options': ['२', '४', '८', '१६'],
          'correctAnswerIndex': 1,
          'explanation': '√१६ = ४ हो किनभने ४ × ४ = १६।',
        },
        {
          'id': 'q5',
          'questionText': '२³ = ?',
          'options': ['४', '६', '८', '९'],
          'correctAnswerIndex': 2,
          'explanation': '२³ = २ × २ × २ = ८ हो।',
        },
      ],
    };
    return ExamDetails.fromJson(dummyData);
  }
}

class ExamQuestionJson {
  static ExamQuestion fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }

  static Map<String, dynamic> toJson(ExamQuestion question) {
    return {
      'id': question.id,
      'questionText': question.questionText,
      'options': question.options,
      'correctAnswerIndex': question.correctAnswerIndex,
      'explanation': question.explanation,
    };
  }
}
