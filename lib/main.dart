import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'services/gemini_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/lessons_viewmodel.dart';
import 'viewmodels/level_viewmodel.dart';
import 'viewmodels/practice_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/tests_viewmodel.dart';
import 'views/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  final gemini = GeminiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(storage)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(storage)),
        ChangeNotifierProvider(create: (_) => TestsViewModel(storage)),
        ChangeNotifierProvider(create: (_) => LevelViewModel(gemini)),
        ChangeNotifierProvider(create: (_) => PracticeViewModel(gemini)),
        ChangeNotifierProvider(create: (_) => LessonsViewModel()),
      ],
      child: const SoruUretimApp(),
    ),
  );
}

class SoruUretimApp extends StatelessWidget {
  const SoruUretimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soru Üretim Merkezi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashPage(),
    );
  }
}