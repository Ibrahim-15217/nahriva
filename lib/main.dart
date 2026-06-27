import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDA26GMN1CZfRKkt90h_JOYcu3_cXmU_jI',
        authDomain: 'nahriva.firebaseapp.com',
        projectId: 'nahriva',
        storageBucket: 'nahriva.firebasestorage.app',
        messagingSenderId: '473789704291',
        appId: '1:473789704291:web:486b546c0a258ebe5f3056',
        measurementId: 'G-6T52FHL2J9',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: NahrivaApp()));
}

class NahrivaApp extends ConsumerWidget {
  const NahrivaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nahriva',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
