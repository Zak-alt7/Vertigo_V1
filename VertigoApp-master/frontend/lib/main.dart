import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/app_settings.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  final settings = AppSettings();
  await settings.loadFromPrefs();
  runApp(
    ChangeNotifierProvider(
      create: (_) => settings,
      child: VertigoApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class VertigoApp extends StatelessWidget {
  final bool seenOnboarding;
  const VertigoApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertigo',
      theme: VertigoTheme.theme,
      debugShowCheckedModeBanner: false,
      home: seenOnboarding ? const SplashScreen() : const OnboardingScreen(),
    );
  }
}
