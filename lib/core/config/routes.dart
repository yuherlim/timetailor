import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/main_layout.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/screens/note_management/note_creation_screen.dart';
import 'package:timetailor/screens/task_management/task_completion_history_screen.dart';
import 'package:timetailor/screens/task_management/task_management_screen.dart';
import 'package:timetailor/screens/note_management/note_management_screen.dart';
import 'package:timetailor/screens/task_management/task_details_screen.dart';
import 'package:timetailor/screens/user_management/account_management_screen.dart';
import 'package:timetailor/screens/user_management/reset_password_screen.dart';
import 'package:timetailor/screens/user_management/getting_started_screen.dart';
import 'package:timetailor/screens/user_management/login_screen.dart';
import 'package:timetailor/screens/user_management/register_screen.dart';

final GlobalKey<NavigatorState> _taskNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _noteNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _accountNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePath.taskManagementPath,
  // redirect: (context, state) async {
  //   // final isLoggedIn = await AuthService.checkLoginStatus();
  //   final isLoggedIn = false;
  //   final isGettingStarted =
  //       state.matchedLocation == RoutePath.gettingStartedPath;
  //   final isLoggingIn = state.matchedLocation == RoutePath.loginPath;
  //   final isRegistering = state.matchedLocation == RoutePath.registerPath;
  //   final isAtResetPasswordScreen =
  //       state.matchedLocation == RoutePath.resetPasswordPath;

  //   if (!isLoggedIn &&
  //       !isLoggingIn &&
  //       !isGettingStarted &&
  //       !isRegistering &&
  //       !isAtResetPasswordScreen) {
  //     return RoutePath.gettingStartedPath;
  //   }

  //   if (isLoggedIn &&
  //       (isLoggingIn ||
  //           isGettingStarted ||
  //           isRegistering ||
  //           isAtResetPasswordScreen)) {
  //     return RoutePath.taskManagementPath;
  //   }

  //   return null;
  // },
  routes: [
    GoRoute(
      path: RoutePath.gettingStartedPath,
      builder: (context, state) => const GettingStartedScreen(),
      routes: [
        GoRoute(
          path: RoutePath.relativeLoginPath,
          builder: (context, state) => const LoginScreen(),
          routes: [
            GoRoute(
              path: RoutePath.relativeResetPasswordPath,
              builder: (context, state) => const ResetPasswordScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RoutePath.relativeRegisterPath,
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _taskNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePath.taskManagementPath,
              builder: (context, state) => const TaskManagementScreen(),
              routes: [
                GoRoute(
                  path: RoutePath.relativeTaskHistoryPath,
                  builder: (context, state) =>
                      const TaskCompletionHistoryScreen(),
                  routes: [
                    GoRoute(
                      path: RoutePath.relativeTaskDetailsPath,
                      builder: (context, state) {
                        final task = state.extra as Task;
                        return TaskDetailsScreen(
                          task: task,
                          isNavigateFromHistory: true,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: RoutePath.relativeTaskDetailsPath,
                  builder: (context, state) {
                    final task = state.extra as Task;
                    return TaskDetailsScreen(
                      task: task,
                      isNavigateFromHistory: false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _noteNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePath.noteManagementPath,
              builder: (context, state) => const NoteManagementScreen(),
              routes: [
                GoRoute(
                  path: RoutePath.relativeNoteCreationPath,
                  builder: (context, state) => const NoteCreationScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _accountNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePath.accountManagementPath,
              builder: (context, state) => const AccountManagementScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
