part of 'calendar_bloc.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoadInProgress extends CalendarState {}

class CalendarLoadSuccess extends CalendarState {
  final List<CalendarItem> events;

  const CalendarLoadSuccess({required this.events});

  @override
  List<Object> get props => [events];
}

class CalendarLoadFailure extends CalendarState {
  final String error;

  const CalendarLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}
