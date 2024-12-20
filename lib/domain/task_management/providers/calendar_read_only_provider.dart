import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

part 'calendar_read_only_provider.g.dart';

@riverpod
double smallScreenTimeSlotHeight(ref) => 180.0;

@riverpod
double bigScreenTimeSlotHeight(ref) => 204.0;

@riverpod
double defaultTimeSlotHeight(ref) => ref.watch(screenHeightProvider) <= 800
    ? ref.watch(smallScreenTimeSlotHeightProvider)
    : ref.watch(bigScreenTimeSlotHeightProvider);

@riverpod
double snapIntervalMinutes(ref) => 5;

@riverpod
double snapIntervalHeight(ref) =>
    ref.watch(defaultTimeSlotHeightProvider) /
    60 *
    ref.watch(snapIntervalMinutesProvider);

@riverpod
double calendarHeight(ref) => ref.watch(defaultTimeSlotHeightProvider) * 24;

@riverpod
double calendarWidgetTopBoundaryY(ref) => 16;

@riverpod
double calendarBottomPadding(ref) => 150;

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
double draggableBoxIndicatorHeight(ref) => 40;

@riverpod
double draggableBoxIndicatorIconSize(ref) => 16;

@riverpod
double defaultDragIndicatorWidth(ref) => 70;

@riverpod
double defaultDragIndicatorHeight(ref) => 40;

@riverpod
double dragIndicatorIconSize(ref) => 20;

@riverpod
double autoScrollAmount(ref) => 15;

@riverpod
double initialBottomSheetExtent(ref) => 0.15;

@riverpod
double minBottomSheetExtent(ref) => 0.10;

@riverpod
double middleBottomSheetExtent(ref) => 0.5;
