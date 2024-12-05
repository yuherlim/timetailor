import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/shared/provider/navigation_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey _bottomNavBarKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // fetch bottom nav height and update global state for bottom nav height.
      final RenderBox? renderBox =
          _bottomNavBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final bottomNavHeight = renderBox.size.height;
        ref
            .read(bottomNavHeightNotifierProvider.notifier)
            .updateHeight(bottomNavHeight);
      }
      print(ref.watch(bottomNavHeightNotifierProvider));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        key: _bottomNavBarKey,
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          index == widget.navigationShell.currentIndex
              ? widget.navigationShell.goBranch(index, initialLocation: true)
              : widget.navigationShell.goBranch(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
