import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/tab_scaffold.dart';
import 'providers/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

class CalmCampusApp extends StatelessWidget {
  const CalmCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalmCampus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.hasOnboarded) {
            return const TabScaffold();
          }
          return const Scaffold(
            body: OnboardingScreen(),
          );
        },
      ),
    );
  }
}
