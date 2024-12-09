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
}