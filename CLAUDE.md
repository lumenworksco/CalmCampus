# CalmCampus — Student Wellness App

**Status (Sept 2026):** migrating from Flutter to native apps — SwiftUI on iOS first, then Kotlin/Compose on Android. The Flutter app was removed from `main`; it lives at git tag `flutter-final` and is the reference for UI, exercise content, and scoring logic (`git show flutter-final:lib/data/interventions_data.dart`).

## Layout

- `spike/` — throwaway iOS feasibility spike (what sensor data iOS actually gives us). See `spike/README.md`.
- `docs/` — pitch site + impact report, served by GitHub Pages (CNAME). Plain HTML/CSS.
- `design/mockups/` — HTML mockups of the app screens; `design/brand/` — app icon, palette.

## Commands

```bash
cd spike && xcodegen generate && open -a Xcode CalmCampusSpike.xcodeproj   # needs full Xcode
# compile check without signing:
xcodebuild -project spike/CalmCampusSpike.xcodeproj -scheme CalmCampusSpike \
  -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
python3 -m http.server 3400 --directory docs                        # preview the site
```

`.xcodeproj` files are generated from `project.yml` (XcodeGen) and gitignored — edit `project.yml`, not the project.

## Principles

- **All data stays on-device.** No cloud AI or analytics. On-device AI only (Apple Foundation Models / Gemini Nano). The Flutter version sent user text to Groq — do not reintroduce that.
- **No synthetic data in the product.** Every signal is real, missing, or unavailable; never fabricated.
- **Wellness wording, not medical claims** ("supports", not "detects burnout") — EU MDR risk.
