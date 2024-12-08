import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDyProvider = StateProvider<double>((ref) => 0.0);
final localCurrentTimeSlotHeightProvider = StateProvider<double>((ref) => 0.0);
final isScrolledProvider = StateProvider<bool>((ref) => false);
final maxTaskHeightProvider = StateProvider<double>((ref) => 0.0);
