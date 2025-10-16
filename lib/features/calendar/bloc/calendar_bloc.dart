import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

// Simple model for a calendar item
class CalendarItem extends Equatable {
  final String title;
  final DateTime date;
  final Color color;

  const CalendarItem({
    required this.title,
    required this.date,
    required this.color,
  });

  @override
  List<Object> get props => [title, date, color];
}

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarInitial()) {
    on<CalendarDataLoaded>(_onCalendarDataLoaded);
  }

  Future<void> _onCalendarDataLoaded(
    CalendarDataLoaded event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoadInProgress());
    try {
      // --- FAKE API CALL ---
      // In a real app, you would fetch this data from a repository
      await Future.delayed(const Duration(milliseconds: 600));

      final today = DateTime.now();
      final mockEvents = [
        CalendarItem(
          title: 'Physics Exam - Wave Optics',
          date: today.add(const Duration(days: 2)),
          color: Colors.blue,
        ),
        CalendarItem(
          title: 'Counselling Session Reminder',
          date: today.add(const Duration(days: 5)),
          color: Colors.orange,
        ),
        CalendarItem(
          title: 'Chemistry Test - Organic',
          date: today.add(const Duration(days: 10)),
          color: Colors.red,
        ),
      ];

      emit(CalendarLoadSuccess(events: mockEvents));
    } catch (e) {
      emit(CalendarLoadFailure(error: e.toString()));
    }
  }
}
