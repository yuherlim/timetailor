class TaskManager {
  static int binarySearchSlotIndex(
    double tapPosition,
    List<double> timeSlotBoundaries,
  ) {
    int low = 0;
    int high = timeSlotBoundaries.length - 1;
    int slotIndex = -1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;

      if (mid < timeSlotBoundaries.length - 1 &&
          tapPosition >= timeSlotBoundaries[mid] &&
          tapPosition < timeSlotBoundaries[mid + 1]) {
        slotIndex = mid; // Found the slot
        break;
      } else if (tapPosition < timeSlotBoundaries[mid]) {
        high = mid - 1; // Search in the left half
      } else {
        low = mid + 1; // Search in the right half
      }
    }
    return slotIndex;
  }

  // Format as "HH:MM AM/PM" from 24 hour format
  static String formatTime(int hour, int minutes) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final paddedMinutes = minutes.toString().padLeft(2, '0');
    return '$normalizedHour:$paddedMinutes $period';
  }
}
