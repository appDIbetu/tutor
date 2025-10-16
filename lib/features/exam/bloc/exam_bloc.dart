import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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

  const Exam({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.questions,
    required this.price,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    duration,
    questions,
    price,
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
    final exams = [
      const Exam(
        id: 'Phy011',
        name: 'भौतिक विज्ञान परीक्षा',
        description:
            'यो परीक्षाले तपाईंको भौतिक विज्ञानको ज्ञानलाई परख्न मद्दत गर्छ। हाम्रो योग्य टोलीले तयार गरेको।',
        duration: '00:30:00',
        questions: 50,
        price: 25.0,
      ),
      const Exam(
        id: 'Che012',
        name: 'रसायन विज्ञान आधारभूत',
        description: 'रसायन विज्ञानको मौलिक ज्ञानको परीक्षा लिनुहोस्।',
        duration: '00:45:00',
        questions: 60,
        price: 30.0,
      ),
      const Exam(
        id: 'Bio013',
        name: 'जीव विज्ञान परीक्षा',
        description:
            'जीव विज्ञानको विभिन्न क्षेत्रहरूमा तपाईंको ज्ञानको मूल्याङ्कन गर्नुहोस्।',
        duration: '00:40:00',
        questions: 55,
        price: 20.0,
      ),
    ];
    emit(ExamLoadSuccess(exams: exams));
  }
}
