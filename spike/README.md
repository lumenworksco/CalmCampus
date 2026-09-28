# iOS feasibility spike

Throwaway app that answers one question before we build the MVP: **what real signals can CalmCampus get on an iPhone, and how reliably?** Delete this folder once the findings below are filled in.

## Run it

Needs full Xcode 26+ (not just the Command Line Tools), a **physical iPhone** (Screen Time doesn't work in the simulator), and an Apple Developer Program team.

```bash
cd spike
xcodegen generate            # brew install xcodegen, if missing
open -a Xcode CalmCampusSpike.xcodeproj
```

1. Pick the scheme:
   - **CalmCampusSpikeLite** — Q1, Q2, Q4, Q5. Works with a free Personal Team.
   - **CalmCampusSpike** — adds Q3 (Screen Time). Needs a paid Developer Program team: Apple doesn't grant Family Controls to Personal Teams. Both share a bundle ID, so installing one replaces the other.

   The team comes from `DEVELOPMENT_TEAM` in `project.yml`; change it there when switching to the paid team.
2. If signing complains the bundle ID or App Group is taken, change `co.lumenworks.calmcampus.spike` / `group.co.lumenworks.calmcampus.spike` in `project.yml` **and** `Shared/SpikeLog.swift`, then regenerate.
3. Run on the phone, go through Q1–Q5, then **leave it installed for 3–5 days** of normal use — most answers are about what happens in the background over time.

Ideally run it on a few phones: one with an Apple Watch, one without, one without a sleep schedule.

## What each screen tests

| # | Question | How |
|---|----------|-----|
| Q1 | Do students have sleep/steps/exercise data in HealthKit? | 14-day daily totals + which apps/devices wrote the sleep data. Observer queries log background wake-ups. |
| Q2 | Can we estimate sleep without a watch? | Longest overnight "phone stationary" stretch from Core Motion (7 days), side by side with HealthKit sleep. |
| Q3 | How precise can screen time be? | Screen Time API thresholds every 30 min up to 10 h; the monitor extension logs each crossing. iOS never gives the raw number. |
| Q4 | Can AI features run on-device? | Apple Foundation Models reframing a negative thought: availability, latency, quality. |
| Q5 | Does a daily background job run? | `BGAppRefreshTask`, logged every time it runs. |

## Before shipping anything built on Q3

Family Controls (Screen Time API) only works in development builds until Apple grants the **distribution entitlement** — request it at developer.apple.com/contact/request/family-controls-distribution. Approval can take weeks, so request it early.

## Findings (fill in)

| Signal | Available? | Precision / coverage | Reliability in background | Go / no-go |
|--------|-----------|----------------------|---------------------------|-----------|
| Steps (HealthKit) | | | | |
| Exercise minutes | | | | |
| Sleep (HealthKit) — with Watch | | | | |
| Sleep (HealthKit) — iPhone only | | | | |
| Sleep (motion estimate) | | error vs HealthKit: | n/a | |
| Screen time (thresholds) | | ±30 min? event delay: | | |
| On-device AI | | devices supported: · latency: | n/a | |
| Daily background job | | runs per day: | | |

**Conclusion → MVP signal set:**
