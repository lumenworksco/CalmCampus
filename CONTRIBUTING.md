# Contributing to CalmCampus

Thanks for your interest. CalmCampus is an early-stage student project, so small, focused changes are easiest to review.

## Before you start

Open an issue to discuss anything larger than a bug fix or typo.

## Ground rules

These come from the product's principles and are not negotiable:

- **Data stays on-device.** No cloud AI, analytics, accounts or network calls that carry user data.
- **No synthetic data in the product.** A signal is real, missing or unavailable.
- **Check-in questions:** never change a question `id`; bump `version` when wording or options change. No clinical screeners (PHQ/GAD, scored cutoffs) and no self-harm items. Keep every question skippable and within the burden budget (3 core + sleep fallback + at most 2 extra).
- **Wellness wording, not medical claims.** Say "supports", not "detects" or "diagnoses".

## Development

```bash
cd ios && xcodegen generate && open -a Xcode CalmCampus.xcodeproj
xcodebuild test -project ios/CalmCampus.xcodeproj -scheme CalmCampus \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Edit `project.yml`, not the generated `.xcodeproj`. Logic such as `CheckinPlanner` should stay pure and covered by unit tests. For the model in `ml/`, follow `ml/README.md`; large weights and run output stay out of git.

## Pull requests

- Branch from `main`, keep the change focused, and explain the why in the description.
- Make sure the tests pass.
- Match the surrounding code style.

By contributing you agree that your work is released under the [MIT License](LICENSE).

Please be respectful and constructive; we follow the spirit of the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
