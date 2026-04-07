import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_state.dart';
import 'providers/pedometer_provider.dart';
import 'services/baseline_service.dart';
import 'services/wellness_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
  } catch (_) {
    // Hive init can fail on some platforms; continue without persistence
  }

  final appState = AppState();
  await appState.init();

  final repo = WellnessRepository();
  try {
    await repo.init();
  } catch (_) {
    // Repository init failed; app will still work with synthetic data
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => PedometerProvider()..init()),
        ChangeNotifierProvider.value(value: repo),
        Provider(create: (_) => BaselineService(repo)),
      ],
      child: const CalmCampusApp(),
    ),
  );
}
