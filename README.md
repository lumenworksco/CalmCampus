# CalmCampus

**Privacy-first wellness companion for university students**

[**lumenworksco.github.io/CalmCampus**](https://lumenworksco.github.io/CalmCampus/) — pitch site and impact report

CalmCampus helps students notice when stress is building up — using signals their phone already has (sleep, activity, screen time) plus quick daily check-ins — and offers short, evidence-based exercises (breathing, grounding, progressive muscle relaxation, thought reframing, gratitude). All data stays on the device.

Originally built for the **KU Leuven KICK Challenge 2026**.

---

## Status

The project is being rebuilt as native apps — **SwiftUI on iOS first, then Kotlin/Jetpack Compose on Android** — so passive sensing (HealthKit, Screen Time, Health Connect) and on-device AI can use the platform APIs directly.

The previous Flutter prototype is preserved at git tag [`flutter-final`](https://github.com/lumenworksco/CalmCampus/tree/flutter-final).

## Roadmap

1. **Feasibility spike** (`spike/`) — measure which signals iOS actually provides and how reliably.
2. **iOS MVP** — SwiftUI + SwiftData; real signals only, a calibration period for new users, on-device AI.
3. **Pilot** — TestFlight study with KU Leuven students: do passive signals track self-reported check-ins?
4. **Android** — Kotlin/Compose + Health Connect, sharing the scoring engine.

## Repository layout

```
spike/          iOS feasibility spike (XcodeGen project)
docs/           Pitch site + impact report (GitHub Pages)
design/
  mockups/      HTML mockups of the app screens
  brand/        App icon, color palette
```

## Privacy

- No cloud storage, analytics, or accounts — data lives on-device.
- AI features run on-device only (Apple Foundation Models / Gemini Nano), never through a cloud API.
- Users can delete all their data at any time.

## Team

- **Florian Braun** — Engineering Technology, UCLL
- **Helene David** — Economics and Business, UCLL

## License

[MIT](LICENSE)
