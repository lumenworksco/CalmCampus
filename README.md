# CalmCampus

**Privacy-first student burnout prevention**

CalmCampus is a mobile wellness companion designed for university students. It passively monitors behavioral signals -- sleep patterns, screen time, typing cadence, and focus sessions -- to detect early signs of burnout. When anomalies appear, it delivers evidence-based micro-interventions grounded in CBT and ACT frameworks. All data stays on-device.

> Built for the **KU Leuven KICK Challenge 2026**.

---

## Screenshots

*Screenshots coming soon.*

---

## Key Features

- **Passive behavioral signal monitoring** -- sleep quality, screen time, typing patterns, and focus sessions tracked without manual input
- **Real-time step counting** via native pedometer APIs
- **Evidence-based micro-interventions** -- guided breathing exercises, mindfulness prompts, progressive muscle relaxation, and grounding techniques
- **Anomaly detection** with smart wellness alerts when patterns deviate from your baseline
- **Privacy-first architecture** -- all data stays on-device, no cloud sync, no tracking, GDPR-native by design
- **Campus resources integration** -- direct links to KU Leuven student support services and emergency contacts
- **CBT & ACT therapeutic framework** -- interventions rooted in Cognitive Behavioral Therapy and Acceptance & Commitment Therapy
- **Dark mode support** -- automatic system theme detection

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.11+ |
| Language | Dart 3.x |
| State Management | Provider 6 |
| Local Storage | Hive (wellness data), SharedPreferences (settings) |
| Charts | fl_chart |
| Sensors | pedometer (native step counting) |
| Permissions | permission_handler |
| Notifications | flutter_local_notifications |
| Links | url_launcher (phone, email, web) |
| Formatting | intl (dates and localization) |
| Design | Material Design 3, iOS-native styling |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.11+
- Dart 3.0+
- iOS Simulator (macOS) or Android Emulator
- Xcode (for iOS) or Android Studio (for Android)

### Installation

```bash
git clone <repo-url>
cd CalmCampus
flutter pub get
flutter run
```

Use `flutter run -d ios` or `flutter run -d android` to target a specific platform.

---

## Project Structure

```
lib/
  main.dart            # Entry point
  app.dart             # App configuration and routing
  data/                # Data engine, intervention content, mood data
  models/              # Data models (BehavioralSignal, DailyData, BreathingPattern)
  providers/           # State management (AppState, PedometerProvider)
  screens/             # Full-page views (Dashboard, Insights, Interventions, Onboarding, Profile)
  widgets/             # Reusable UI (BreathingExercise, WellnessGauge, TrendChart, CrisisBanner)
  services/            # Business logic (WellnessRepository, BaselineService)
  navigation/          # Tab scaffold and routing
  theme/               # Colors, Material/Cupertino theme, dark mode
test/                  # Unit and widget tests
```

---

## Privacy & Data

CalmCampus is built on a strict privacy-first principle:

- **No cloud storage.** All behavioral data is persisted locally via Hive on-device database.
- **No analytics or tracking.** Zero third-party data collection.
- **No account required.** The app works fully offline.
- **GDPR-native.** There is no personal data to regulate because it never leaves the device.

Users own their data completely and can clear it at any time from the Settings screen.

---

## KICK Challenge 2026

This project was developed for the [KU Leuven KICK Challenge](https://kick.kuleuven.be/) -- a student innovation competition with a prize pool of EUR 5,000. KICK encourages interdisciplinary teams to tackle real-world problems with creative, viable solutions.

---

## Team

- **Florian Braun** -- Engineering Technology, UCLL
- **Helene David** -- Economics and Business, UCLL

---

## License

[MIT](LICENSE)
