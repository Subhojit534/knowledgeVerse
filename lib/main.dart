import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/loading_screen.dart';
import 'services/api_config.dart';
import 'theme/app_theme.dart';

/// Application entry point integrating KnowledgeVerse app flow with Flame Engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env configuration and initialize ApiConfig
  await ApiConfig.init();

  // Configure Flame landscape mode & fullscreen orientation
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const KnowledgeVerseApp());
}

/// Primary Application Widget housing KnowledgeVerse theme.
class KnowledgeVerseApp extends StatelessWidget {
  const KnowledgeVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KnowledgeVerse - Academy World',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoadingScreen(),
    );
  }
}
