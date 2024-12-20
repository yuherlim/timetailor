import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';

part 'datebox_animation_provider.g.dart'; // Generated file

@riverpod
class DateboxAnimationNotifier extends _$DateboxAnimationNotifier {
  @override
  Map<DateTime, GlobalKey> build() {
    // if not initialized before, initialize it.
    state = {};

    // Call initializeKeys to populate state
    initializeKeys();
    return state;
  }

  // Initialize keys for week dates
  void initializeKeys() {
    final weekDates = ref.watch(currentWeekDatesNotifierProvider);
    // bool keysChanged = false;

    // // Only update keys if necessary
    // print("Start checking state");
    // if (state!.isEmpty || !setEquals(state!.keys.toSet(), weekDates.toSet())) {
    //   if (state!.isEmpty) {
    //     print("state is empty.");
    //   }

    //   if (!setEquals(state!.keys.toSet(), weekDates.toSet())) {
    //     print("new week dates, reinitializing state.");
    //   }

    //   state!.clear();

    //   for (var date in weekDates) {
    //     state![date] = GlobalKey();
    //   }

    //   keysChanged = true;
    // }
    state.clear();

    for (var date in weekDates) {
      state[date] = GlobalKey();
    }
    state = Map.from(state);
    // if (keysChanged) {
    //   // Update state to notify listeners
    //   state = Map.from(state!);
    //   print("Success state update.");
    // }
  }
}
