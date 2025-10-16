// lib/features/exam/bloc/exam_event.dart

part of 'exam_bloc.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object> get props => [];
}

// Add your specific events here, for example:
class ExamsFetched extends ExamEvent {}
