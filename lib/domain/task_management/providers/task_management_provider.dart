import 'dart:async';

import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_management_provider.g.dart'; // Generated file

@riverpod
class CurrentDateNotifier extends _$CurrentDateNotifier {
  @override
  DateTime build() {
    // Initialize current date
    return todayDate();
  }

  DateTime todayDate() {
    return DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
  }

  void updateDate({required DateTime date}) {
    state = DateTime(date.year, date.month, date.day);
  }

  void updateToToday() {
    state = todayDate();
  }

  bool currentDateIsToday() {
    return state == todayDate();
  }
}

@riverpod
class CurrentMonthNotifier extends _$CurrentMonthNotifier {
  Timer? _midnightTimer;

  @override
  String build() {
    // Initialize current month
    updateCurrentMonth();
    scheduleMidnightUpdate();

    ref.onDispose(() {
      _midnightTimer?.cancel();
    });

    return state;
  }

  void updateCurrentMonth() {
    // state = date != null
    //     ? DateFormat('MMMM yyyy').format(date)
    //     : DateFormat('MMMM yyyy').format(DateTime.now());
    state =
        DateFormat('MMMM yyyy').format(ref.watch(currentDateNotifierProvider));
  }

  void scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () {
      updateCurrentMonth();
      scheduleMidnightUpdate(); // Reschedule for the next day
    });
  }
}

@riverpod
class CurrentWeekDatesNotifier extends _$CurrentWeekDatesNotifier {
  @override
  List<DateTime> build() {
    // Initialize current week dates
    updateWeekDates();
    return state;
  }

  void updateWeekDates() {
    // Get the current date
    final currentDate = ref.watch(currentDateNotifierProvider);
    // final currentDate = date ?? DateTime.now();

    // Calculate the start of the current week (Monday)
    final startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    // Generate a list of dates for the current week
    state = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });
  }
}
