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
      title: 'Calm Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // The UI is designed as a light iOS aesthetic — text colors are
      // hard-coded light-mode values across the app. Force light mode until
      // we do a proper dark-theme pass.
      themeMode: ThemeMode.light,
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
