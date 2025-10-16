class ExamAttempt {
  final String examId;
  final String examTitle;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final DateTime attemptedAt;
  final int timeTakenSeconds;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int unattemptedCount;
  final double finalMarks;
  final int positiveMark;
  final int negativeMark;
  final Map<int, int> selectedAnswers;
  final bool isPassed;
  final int passMark;

  const ExamAttempt({
    required this.examId,
    required this.examTitle,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.attemptedAt,
    required this.timeTakenSeconds,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.unattemptedCount,
    required this.finalMarks,
    required this.positiveMark,
    required this.negativeMark,
    required this.selectedAnswers,
    required this.isPassed,
    required this.passMark,
  });

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      examId: json['examId'] as String,
      examTitle: json['examTitle'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      studentEmail: json['studentEmail'] as String,
      attemptedAt: DateTime.parse(json['attemptedAt'] as String),
      timeTakenSeconds: json['timeTakenSeconds'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctCount: json['correctCount'] as int,
      wrongCount: json['wrongCount'] as int,
      unattemptedCount: json['unattemptedCount'] as int,
      finalMarks: (json['finalMarks'] as num).toDouble(),
      positiveMark: json['positiveMark'] as int,
      negativeMark: json['negativeMark'] as int,
      selectedAnswers: Map<int, int>.from(
        (json['selectedAnswers'] as Map).map(
          (key, value) => MapEntry(int.parse(key.toString()), value as int),
        ),
      ),
      isPassed: json['isPassed'] as bool,
      passMark: json['passMark'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'examTitle': examTitle,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'attemptedAt': attemptedAt.toIso8601String(),
      'timeTakenSeconds': timeTakenSeconds,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'unattemptedCount': unattemptedCount,
      'finalMarks': finalMarks,
      'positiveMark': positiveMark,
      'negativeMark': negativeMark,
      'selectedAnswers': selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'isPassed': isPassed,
      'passMark': passMark,
    };
  }
}
