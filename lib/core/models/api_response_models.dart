import 'package:equatable/equatable.dart';

// Base model for all API responses that have locking and premium features
abstract class LockableItem extends Equatable {
  final bool isPremium;
  final bool isLocked;

  const LockableItem({required this.isPremium, this.isLocked = false});

  // Helper method to check if user has access
  bool hasAccess(bool userIsPremium) {
    if (!isLocked) return true; // Not locked, always accessible
    return userIsPremium; // Locked, only accessible if user is premium
  }

  @override
  List<Object?> get props => [isPremium, isLocked];
}

// Subject models
class SubjectListResponse extends LockableItem {
  final String subjectId;
  final String categoryName;
  final String name;
  final int numberOfQuestions;
  final double posMarking;
  final double negMarking;
  final int perQsnDuration;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubjectListResponse({
    required this.subjectId,
    required this.categoryName,
    required this.name,
    required this.numberOfQuestions,
    required this.posMarking,
    required this.negMarking,
    required this.perQsnDuration,
    required this.price,
    required bool isPremium,
    bool isLocked = false,
    this.createdAt,
    this.updatedAt,
  }) : super(isPremium: isPremium, isLocked: isLocked);

  factory SubjectListResponse.fromJson(Map<String, dynamic> json) {
    return SubjectListResponse(
      subjectId: json['subject_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      name: json['name'] ?? '',
      numberOfQuestions: json['number_of_questions'] ?? 0,
      posMarking: (json['pos_marking'] ?? 1.0).toDouble(),
      negMarking: (json['neg_marking'] ?? 0.0).toDouble(),
      perQsnDuration: json['per_qsn_duration'] ?? 60,
      price: (json['price'] ?? 0.0).toDouble(),
      isPremium: json['is_premium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    subjectId,
    categoryName,
    name,
    numberOfQuestions,
    posMarking,
    negMarking,
    perQsnDuration,
    price,
    createdAt,
    updatedAt,
  ];
}

class SubjectResponse extends SubjectListResponse {
  final List<Question> questions;

  const SubjectResponse({
    required super.subjectId,
    required super.categoryName,
    required super.name,
    required super.numberOfQuestions,
    required super.posMarking,
    required super.negMarking,
    required super.perQsnDuration,
    required super.price,
    required super.isPremium,
    super.isLocked = false,
    super.createdAt,
    super.updatedAt,
    required this.questions,
  });

  factory SubjectResponse.fromJson(Map<String, dynamic> json) {
    return SubjectResponse(
      subjectId: json['subject_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      name: json['name'] ?? '',
      numberOfQuestions: json['number_of_questions'] ?? 0,
      posMarking: (json['pos_marking'] ?? 1.0).toDouble(),
      negMarking: (json['neg_marking'] ?? 0.0).toDouble(),
      perQsnDuration: json['per_qsn_duration'] ?? 60,
      price: (json['price'] ?? 0.0).toDouble(),
      isPremium: json['is_premium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [...super.props, questions];
}

// Exam models
class ExamListResponse extends LockableItem {
  final String examId;
  final String categoryName;
  final String name;
  final int numberOfQuestions;
  final double posMarking;
  final double negMarking;
  final int perQsnDuration;
  final double price;
  final int totalAttempts;
  final bool attempted;
  final ExamResultResponse? studentResult;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExamListResponse({
    required this.examId,
    required this.categoryName,
    required this.name,
    required this.numberOfQuestions,
    required this.posMarking,
    required this.negMarking,
    required this.perQsnDuration,
    required this.price,
    required bool isPremium,
    bool isLocked = false,
    this.totalAttempts = 0,
    this.attempted = false,
    this.studentResult,
    this.createdAt,
    this.updatedAt,
  }) : super(isPremium: isPremium, isLocked: isLocked);

  factory ExamListResponse.fromJson(Map<String, dynamic> json) {
    return ExamListResponse(
      examId: json['exam_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      name: json['name'] ?? '',
      numberOfQuestions: json['number_of_questions'] ?? 0,
      posMarking: (json['pos_marking'] ?? 1.0).toDouble(),
      negMarking: (json['neg_marking'] ?? 0.0).toDouble(),
      perQsnDuration: json['per_qsn_duration'] ?? 60,
      price: (json['price'] ?? 0.0).toDouble(),
      isPremium: json['is_premium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      totalAttempts: json['total_attempts'] ?? 0,
      attempted: json['attempted'] ?? false,
      studentResult: json['student_result'] != null
          ? ExamResultResponse.fromJson(json['student_result'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    examId,
    categoryName,
    name,
    numberOfQuestions,
    posMarking,
    negMarking,
    perQsnDuration,
    price,
    totalAttempts,
    attempted,
    studentResult,
    createdAt,
    updatedAt,
  ];
}

class ExamResponse extends ExamListResponse {
  final List<Question> questions;

  const ExamResponse({
    required super.examId,
    required super.categoryName,
    required super.name,
    required super.numberOfQuestions,
    required super.posMarking,
    required super.negMarking,
    required super.perQsnDuration,
    required super.price,
    required super.isPremium,
    super.isLocked = false,
    super.totalAttempts = 0,
    super.attempted = false,
    super.studentResult,
    super.createdAt,
    super.updatedAt,
    required this.questions,
  });

  factory ExamResponse.fromJson(Map<String, dynamic> json) {
    return ExamResponse(
      examId: json['exam_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      name: json['name'] ?? '',
      numberOfQuestions: json['number_of_questions'] ?? 0,
      posMarking: (json['pos_marking'] ?? 1.0).toDouble(),
      negMarking: (json['neg_marking'] ?? 0.0).toDouble(),
      perQsnDuration: json['per_qsn_duration'] ?? 60,
      price: (json['price'] ?? 0.0).toDouble(),
      isPremium: json['is_premium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      totalAttempts: json['total_attempts'] ?? 0,
      attempted: json['attempted'] ?? false,
      studentResult: json['student_result'] != null
          ? ExamResultResponse.fromJson(json['student_result'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [...super.props, questions];
}

// Notes models
class NotesResponse extends LockableItem {
  final String id;
  final String name;
  final int pdfCount;
  final double price;
  final String category;
  final List<PDFResponse> pdfs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotesResponse({
    required this.id,
    required this.name,
    required this.pdfCount,
    required this.price,
    required this.category,
    required this.pdfs,
    required bool isPremium,
    bool isLocked = false,
    this.createdAt,
    this.updatedAt,
  }) : super(isPremium: isPremium, isLocked: isLocked);

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pdfCount: json['pdfCount'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'General',
      isPremium: json['isPremium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      pdfs:
          (json['pdfs'] as List<dynamic>?)
              ?.map((pdf) => PDFResponse.fromJson(pdf))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    id,
    name,
    pdfCount,
    price,
    category,
    pdfs,
    createdAt,
    updatedAt,
  ];
}

// Drafting models (Masyauda Lekhan)
class DraftingResponse extends LockableItem {
  final String id;
  final String name;
  final int pdfCount;
  final double price;
  final String category;
  final List<PDFResponse> pdfs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DraftingResponse({
    required this.id,
    required this.name,
    required this.pdfCount,
    required this.price,
    required this.category,
    required this.pdfs,
    required bool isPremium,
    bool isLocked = false,
    this.createdAt,
    this.updatedAt,
  }) : super(isPremium: isPremium, isLocked: isLocked);

  factory DraftingResponse.fromJson(Map<String, dynamic> json) {
    return DraftingResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pdfCount: json['pdfCount'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'General',
      isPremium: json['isPremium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      pdfs:
          (json['pdfs'] as List<dynamic>?)
              ?.map((pdf) => PDFResponse.fromJson(pdf))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    id,
    name,
    pdfCount,
    price,
    category,
    pdfs,
    createdAt,
    updatedAt,
  ];
}

// PDF models
class PDFResponse extends LockableItem {
  final String id;
  final String name;
  final int pageCount;
  final String downloadUrl;

  const PDFResponse({
    required this.id,
    required this.name,
    required this.pageCount,
    required this.downloadUrl,
    required bool isPremium,
    bool isLocked = false,
  }) : super(isPremium: isPremium, isLocked: isLocked);

  factory PDFResponse.fromJson(Map<String, dynamic> json) {
    return PDFResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pageCount: json['pageCount'] ?? 0,
      downloadUrl: json['downloadUrl'] ?? '',
      isPremium: json['isPremium'] ?? false,
      isLocked: json['is_locked'] ?? false,
    );
  }

  @override
  List<Object?> get props => [...super.props, id, name, pageCount, downloadUrl];
}

// Question model
class Question extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((option) => option.toString())
              .toList() ??
          [],
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    questionText,
    options,
    correctAnswerIndex,
    explanation,
  ];
}

// Exam Result Create model (for submitting exam results)
class ExamResultCreate extends Equatable {
  final String studentId;
  final double score;
  final double positiveMark;
  final double negativeMark;
  final int totalQuestions;
  final int attemptedQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final double avgSpeed;
  final List<int> selectedIndexes;
  final int timeTaken;
  final bool isCompleted;

  const ExamResultCreate({
    required this.studentId,
    required this.score,
    required this.positiveMark,
    required this.negativeMark,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.avgSpeed,
    required this.selectedIndexes,
    required this.timeTaken,
    this.isCompleted = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'score': score,
      'positive_mark': positiveMark,
      'negative_mark': negativeMark,
      'total_questions': totalQuestions,
      'attempted_questions': attemptedQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'skipped_questions': skippedQuestions,
      'avg_speed': avgSpeed,
      'selected_indexes': selectedIndexes,
      'time_taken': timeTaken,
      'is_completed': isCompleted,
    };
  }

  @override
  List<Object?> get props => [
    studentId,
    score,
    positiveMark,
    negativeMark,
    totalQuestions,
    attemptedQuestions,
    correctAnswers,
    wrongAnswers,
    skippedQuestions,
    avgSpeed,
    selectedIndexes,
    timeTaken,
    isCompleted,
  ];
}

// Exam Result Response model (for receiving exam results)
class ExamResultResponse extends Equatable {
  final String studentId;
  final double score;
  final double positiveMark;
  final double negativeMark;
  final int totalQuestions;
  final int attemptedQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final DateTime datetime;
  final double avgSpeed;
  final List<int> selectedIndexes;
  final int timeTaken;
  final bool isCompleted;
  final int? rank;

  const ExamResultResponse({
    required this.studentId,
    required this.score,
    required this.positiveMark,
    required this.negativeMark,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.datetime,
    required this.avgSpeed,
    required this.selectedIndexes,
    required this.timeTaken,
    required this.isCompleted,
    this.rank,
  });

  factory ExamResultResponse.fromJson(Map<String, dynamic> json) {
    return ExamResultResponse(
      studentId: json['student_id'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      positiveMark: (json['positive_mark'] ?? 0.0).toDouble(),
      negativeMark: (json['negative_mark'] ?? 0.0).toDouble(),
      totalQuestions: json['total_questions'] ?? 0,
      attemptedQuestions: json['attempted_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      wrongAnswers: json['wrong_answers'] ?? 0,
      skippedQuestions: json['skipped_questions'] ?? 0,
      datetime: DateTime.parse(
        json['datetime'] ?? DateTime.now().toIso8601String(),
      ),
      avgSpeed: (json['avg_speed'] ?? 0.0).toDouble(),
      selectedIndexes:
          (json['selected_indexes'] as List<dynamic>?)
              ?.map((index) => index as int)
              .toList() ??
          [],
      timeTaken: json['time_taken'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      rank: json['rank'],
    );
  }

  @override
  List<Object?> get props => [
    studentId,
    score,
    positiveMark,
    negativeMark,
    totalQuestions,
    attemptedQuestions,
    correctAnswers,
    wrongAnswers,
    skippedQuestions,
    datetime,
    avgSpeed,
    selectedIndexes,
    timeTaken,
    isCompleted,
    rank,
  ];
}

// Upcoming Exam Najirs (Quiz of the Day) model
class UpcomingExamNajirsResponse extends LockableItem {
  final String id;
  final String title;
  final String description;
  final List<NotesResponse> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UpcomingExamNajirsResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
    required bool isPremium,
    bool isLocked = false,
    this.createdAt,
    this.updatedAt,
  }) : super(isPremium: isPremium, isLocked: isLocked);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    items,
    isPremium,
    isLocked,
    createdAt,
    updatedAt,
  ];

  factory UpcomingExamNajirsResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingExamNajirsResponse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => NotesResponse.fromJson(item))
              .toList() ??
          [],
      isPremium: json['is_premium'] ?? false,
      isLocked: json['is_locked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}
