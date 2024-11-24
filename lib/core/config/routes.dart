import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:timetailor/core/constants/route_paths.dart';
import 'package:timetailor/core/shared/main_layout.dart';
import 'package:timetailor/screens/task_management/task_completion_history_screen.dart';
import 'package:timetailor/screens/task_management/task_management_screen.dart';
import 'package:timetailor/screens/note_management/note_management_screen.dart';
import 'package:timetailor/screens/user_management/account_management_screen.dart';

final GlobalKey<NavigatorState> _taskNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _noteNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _accountNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: taskManagementPath,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _taskNavigatorKey,
          routes: [
            GoRoute(
              path: taskManagementPath,
              builder: (context, state) => const TaskManagementScreen(),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const TaskCompletionHistoryScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _noteNavigatorKey,
          routes: [
            GoRoute(
              path: noteManagementPath,
              builder: (context, state) => const NoteManagementScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _accountNavigatorKey,
          routes: [
            GoRoute(
              path: accountManagementPath,
              builder: (context, state) => const AccountManagementScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);