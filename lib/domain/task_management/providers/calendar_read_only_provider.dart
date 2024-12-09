import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';

part 'calendar_read_only_provider.g.dart';

const _snapIntervalMinutes = 5;

@riverpod
double defaultTimeSlotHeight(ref) =>
    ref.watch(screenHeightProvider) <= 800 ? 120 : 144;

@riverpod
double snapIntervalHeight(ref) =>
    ref.watch(defaultTimeSlotHeightProvider) / 60 * _snapIntervalMinutes;

@riverpod
double calendarHeight(ref) => ref.watch(defaultTimeSlotHeightProvider) * 24;

@riverpod
double calendarWidgetTopBoundaryY(ref) => 16;

@riverpod
double calendarBottomPadding(ref) => 120;

@riverpod
double calendarWidgetBottomBoundaryY(ref) =>
    ref.watch(calendarWidgetTopBoundaryYProvider) +
    ref.watch(calendarHeightProvider);

// Generate time slot boundaries
@riverpod
List<double> timeSlotBoundaries(ref) => List.generate(
      24,
      (i) =>
          ref.watch(calendarWidgetTopBoundaryYProvider) +
          (ref.watch(defaultTimeSlotHeightProvider) * i),
    );

// Used for display time on calendar widget
@riverpod
List<String> timePeriods(ref) => [
      '12 AM',
      ' 1 AM',
      ' 2 AM',
      ' 3 AM',
      ' 4 AM',
      ' 5 AM',
      ' 6 AM',
      ' 7 AM',
      ' 8 AM',
      ' 9 AM',
      '10 AM',
      '11 AM',
      '12 PM',
      ' 1 PM',
      ' 2 PM',
      ' 3 PM',
      ' 4 PM',
      ' 5 PM',
      ' 6 PM',
      ' 7 PM',
      ' 8 PM',
      ' 9 PM',
      '10 PM',
      '11 PM'
    ];

@riverpod
double timeIndicatorIconSize(ref) => 8;

@riverpod
double draggableBoxIndicatorWidth(ref) => 60;

@riverpod
double draggableBoxIndicatorHeight(ref) => 20;

@riverpod
double dragIndicatorWidth(ref) => 15;

@riverpod
double dragIndicatorHeight(ref) => 25;
