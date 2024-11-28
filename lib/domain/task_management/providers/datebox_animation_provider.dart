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

      print('Initializing keys for weekDates: $weekDates');

      for (var date in weekDates) {
        state[date] = GlobalKey();
      }
      keysChanged = true;
    }

    if (keysChanged) {
      print('dateBoxKeys after initialization:');
      state.forEach((key, value) {
        print('Date: $key, GlobalKey: $value');
      });
      // Update state to notify listeners
      state = Map.from(state);
    }
  }

  // Trigger ripple effect programmatically
  void triggerRipple(DateTime date, BuildContext context) {
    final key = state[date];

    if (key == null) {
      print('No GlobalKey found for date: $date');
      return;
    } else {
      print("Got global key.");
    }

    final boxContext = key.currentContext;
    if (boxContext == null) {
      print('Context for GlobalKey is null for date: $date');
      return;
    } else {
      print("Got context.");
    }

    final renderBox = boxContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      print('RenderBox is not attached for date: $date');
      return;
    } else {
      print("Got renderBox.");
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
