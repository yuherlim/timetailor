import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen height
    double screenHeight = MediaQuery.of(context).size.height;

    // Define slot height based on screen size
    double slotHeight;
    if (screenHeight <= 800) {
      // Small screens (e.g., mobile)
      slotHeight = 40; // 40px per timeslot
    } else {
      // Large screens (e.g., tablets, desktops)
      slotHeight = 50; // 50px per timeslot
    }

    // Calculate the total height for 24 slots
    double calendarHeight = slotHeight * 24;

    return Container(
      color: Colors.red,
      height: calendarHeight,
    );
  }
}
