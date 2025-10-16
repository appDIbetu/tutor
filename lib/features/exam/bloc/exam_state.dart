part of 'exam_bloc.dart';

abstract class ExamState extends Equatable {
  const ExamState();
  @override
  List<Object> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoadInProgress extends ExamState {}

class ExamLoadSuccess extends ExamState {
  final List<Exam> exams;
  const ExamLoadSuccess({required this.exams});
  @override
  List<Object> get props => [exams];
}

class ExamLoadFailure extends ExamState {}
