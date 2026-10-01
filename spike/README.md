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

## Findings

### Run 1: Florian, iPhone 16, iOS 27, WHOOP band, Sept 26 – Oct 1 2026 (Lite build, so no Q3)

| Signal | Available? | Precision / coverage | Reliability in background | Go / no-go |
|--------|-----------|----------------------|---------------------------|-----------|
| Steps (HealthKit) | Yes, every day | 4.7k–18.6k/day, plausible | Observer wakes ~1–2×/day | **Go** |
| Exercise minutes | 3 of 5 days | Missing on days without a logged workout. Mostly an Apple Watch metric, so WHOOP only fills it sometimes | Same as steps | **No-go as a core signal**. Use steps; show exercise only when present |
| Sleep (HealthKit), wearable | Yes, every night | 5.9–9.0 h asleep, 7.4–9.7 h in bed. Source: **WHOOP**, not an Apple Watch: third-party wearables count | Wake-ups come in the morning after the wearable syncs | **Go** |
| Sleep (HealthKit), iPhone only | Not tested | | | Test on a phone with no wearable |
| Sleep (motion estimate) | Yes | **Overestimates by 2.5–7.8 h** (8.4–15.3 h vs 5.9–9.0 h). Measures "phone left untouched", e.g. from 18:08 or until 13:26. 2 of 7 nights missing | n/a | **No-go** |
| Screen time (thresholds) | Not tested | Needs a paid team | | Pending |
| On-device AI | Yes ("available") | 3 reframes in **4.2 s**, warm and usable. One was validation rather than a reframe, so the prompt needs tuning. Needs Apple Intelligence hardware (iPhone 15 Pro or newer) | n/a | **Go, with a non-AI fallback** |
| Daily background job (`BGAppRefreshTask`) | Yes | **Ran once in ~3.5 days** (Sept 28, 13:45), never again even though it was rescheduled | Unreliable when the app is rarely opened | **No-go** for daily processing |

Caveat on the motion estimate: one user, and the heuristic is crude. But with no screen-unlock data on iOS, "phone still" can't be told apart from "phone on the desk".

### Conclusion → MVP signal set

- **Sleep:** HealthKit sleep from any source (Apple Watch, WHOOP, Oura, iPhone sleep schedule). If there's none, ask about sleep in the daily check-in. Drop the motion estimate.
- **Activity:** HealthKit steps. Exercise minutes only as a bonus when present.
- **Screen time:** pending Q3 (paid team + Family Controls).
- **AI:** Apple Foundation Models where available (prewarm the session, stream the output), curated static reframes otherwise.
- **Daily processing:** don't depend on a scheduled job. Close out days lazily, whenever the app opens or a HealthKit observer wakes it. Those wakes arrived reliably, 1–2 a day.
- **Product implication:** the fully passive experience needs a wearable or a sleep schedule. Students without one rely on check-ins, so the check-in has to stand on its own.

### Still to test

- Q3 Screen Time on a paid team.
- A phone **without a wearable** and **without Apple Intelligence**. Hélène's iPhone 15 covers both: it shows iPhone-only sleep coverage and the AI fallback.
