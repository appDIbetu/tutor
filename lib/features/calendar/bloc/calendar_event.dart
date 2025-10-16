part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

// Event to trigger loading calendar data
class CalendarDataLoaded extends CalendarEvent {}
