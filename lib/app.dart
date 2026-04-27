import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/native_tab_host.dart';
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
          // Tell the iOS native shell whether we're in onboarding so it can
          // hide its Liquid Glass tab bar accordingly. Wrapped in a
          // post-frame callback so we don't fire a method channel call
          // during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NativeTabHost.setOnboardingMode(!appState.hasOnboarded);
          });

          if (appState.hasOnboarded) {
            return const NativeTabHost();
          }
          return const Scaffold(
            body: OnboardingScreen(),
          );
        },
      ),
    );
  }
}
