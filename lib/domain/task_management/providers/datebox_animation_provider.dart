import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datebox_animation_provider.g.dart'; // Generated file

@riverpod
class DateboxAnimationNotifier extends _$DateboxAnimationNotifier {
  @override
  Map<DateTime, GlobalKey> build() {
    // Initial state is an empty map of dateBoxKeys
    return {};
  }

  // Initialize keys for week dates
  void initializeKeys(List<DateTime> weekDates) {
    bool keysChanged = false;

    // Only update keys if necessary
    if (state.isEmpty || !setEquals(state.keys.toSet(), weekDates.toSet())) {
      state.clear();

      for (var date in weekDates) {
        state[date] = GlobalKey();
      }

      keysChanged = true;
    }

    if (keysChanged) {
      // Update state to notify listeners
      state = Map.from(state);
    }
  }

  // Trigger ripple effect programmatically
  void triggerRipple(DateTime date, BuildContext context) {
    final key = state[date];

    if (key == null) {
      print("global key is null for this date: $date");
      return;
    }

    final boxContext = key.currentContext;

    if (boxContext == null) {
      print("context is null for this date: $date");
      return;
    }

    final renderBox = boxContext.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      print("renderBox is null for this date: $date");
      return;
    }

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(
      renderBox.size.center(Offset.zero),
      ancestor: overlay,
    );

    final materialState = Material.of(boxContext);
    InkRipple(
      position: position,
      color: Colors.blue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      controller: materialState,
      referenceBox: renderBox,
      textDirection: TextDirection.ltr,
    ).confirm();
  }
}
