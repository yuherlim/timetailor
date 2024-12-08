import 'package:flutter_riverpod/flutter_riverpod.dart';

final screenHeightProvider = StateProvider<double>((ref) => 0.0);
final localDyProvider = StateProvider<double>((ref) => 0.0);
final localCurrentTimeSlotHeightProvider = StateProvider<double>((ref) => 0.0);
final showDraggableBoxProvider = StateProvider<bool>((ref) => false);
final isScrolledProvider = StateProvider<bool>((ref) => false);
final maxTaskHeightProvider = StateProvider<double>((ref) => 0.0);
final slotStartXProvider = StateProvider<double>((ref) => 0.0);
final slotWidthProvider = StateProvider<double>((ref) => 0.0);
final sidePaddingProvider = StateProvider<double>((ref) => 0.0);
final textPaddingProvider = StateProvider<double>((ref) => 0.0);
