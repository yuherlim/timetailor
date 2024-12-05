import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart'; // Generated file

@riverpod
class BottomNavHeightNotifier extends _$BottomNavHeightNotifier {
  @override
  double build() {
    return 0;
  }

  void updateHeight(double height) {
    state = height;
  }
}