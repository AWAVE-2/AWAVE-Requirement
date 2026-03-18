# Stats & Analytics System - Technical Specification (Swift / Firebase)

**Implementation:** Native iOS (Swift, SwiftUI). Data: **Firestore** playback history and **Firebase Analytics** (consent-gated). No Supabase.

---

## Architecture Overview

### Data Sources

- **Firestore** — `users/{userId}/playbackHistory`. Session documents (startedAt, durationPlayed, sessionType, etc.) are written by FirestoreSessionTracker. Aggregates are computed by **FirestoreSessionTracker.getStats(userId)** and returned as **UserStats** (totalListeningTime, sessionCount, currentStreak, longestStreak, sessionsThisWeek, listeningTimeThisWeek, favoriteCategory).
- **Firebase Analytics** — Events (screen_view, session_started, session_completed, etc.) logged by AnalyticsService when **AnalyticsConsentService.hasAnalyticsConsent** is true. Used for product analytics and dashboards; not for in-app stats UI in the current baseline.

### Technology Stack

- **FirestoreSessionTracker** — Implements SessionTrackingProtocol; getStats(userId) queries/aggregates playbackHistory and returns UserStats.
- **ProfileViewModel** — Calls `sessionTracker.getStats(userId)` in loadStats(); exposes `stats: UserStats` and `isLoadingStats`.
- **AnalyticsService** — Singleton; log(Event); events only sent when consent is true.
- **AnalyticsConsentService** — UserDefaults key; setAnalyticsCollectionEnabled on Firebase.

---

## Swift Components

### ProfileView / ProfileViewModel
- **ProfileViewModel** — Injected with sessionTracker (SessionTrackingProtocol). loadStats() fetches UserStats for the current user and sets `stats`; shows `.empty` on error. Refreshes stats when profile appears or auth changes.
- **ProfileView** — Contains a stats section (statsContentSection). When signed in and not loading, shows **StatsView(stats: viewModel.stats)**. When not signed in, shows **ProfileBlurredStatsView** (blurred placeholder).

### StatsView
**Location:** AWAVE/AWAVE/Features/Profile/StatsView.swift

- Displays **UserStats**: total listening time, session count, current streak, longest streak, sessions this week, listening time this week, favorite category.
- Grid of stat cards; formatting for duration and counts. No separate week/month/year tabs or charts in current implementation.

### ProfileBlurredStatsView
- Placeholder when user is not signed in; shows blurred StatsView with placeholder data.

---

## UserStats (AWAVEDomain)

- totalListeningTime (TimeInterval)
- sessionCount (Int)
- currentStreak (Int)
- longestStreak (Int)
- sessionsThisWeek (Int)
- listeningTimeThisWeek (TimeInterval)
- favoriteCategory (String?)

---

## Implemented vs Not in Baseline

- **Implemented:** Profile stats section; UserStats from FirestoreSessionTracker.getStats; Firebase Analytics events (consent-gated); onboarding analytics consent toast.
- **Not in current iOS baseline:** Dedicated full-screen Stats screen with week/month/year tabs; activity charts (bar chart); most played sounds list; achievement badges with real unlock logic; daily aggregation to a separate table. These can be added in a future iteration and documented here.

---

## File Locations

| Component | Location |
|-----------|----------|
| ProfileViewModel (loadStats) | AWAVE/AWAVE/Features/Profile/ProfileViewModel.swift |
| ProfileView (stats section) | AWAVE/AWAVE/Features/Profile/ProfileView.swift |
| StatsView | AWAVE/AWAVE/Features/Profile/StatsView.swift |
| ProfileBlurredStatsView | AWAVE/AWAVE/Features/Profile/Components/ProfileBlurredStatsView.swift |
| FirestoreSessionTracker.getStats | AWAVE/Packages/AWAVEData/.../FirestoreSessionTracker.swift |
| UserStats | AWAVE/Packages/AWAVEDomain/.../UserStats (or equivalent) |
| AnalyticsService / AnalyticsConsentService | AWAVE/AWAVE/Services/ |

---

*Legacy: An earlier version described a React/TypeScript + Supabase stack. The current iOS app uses Swift and Firebase only.*
