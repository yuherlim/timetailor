import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/config/routes.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/theme/theme.dart';
import 'package:timetailor/core/theme/util.dart';
import 'package:timetailor/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

// Lock the orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme = createTextTheme(context, "Kanit", "Kanit");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: appRouter,
      title: 'TimeTailor',
      theme: theme.dark(),
      themeMode: ThemeMode.dark,
    );
  }
}
