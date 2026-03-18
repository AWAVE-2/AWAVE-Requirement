# Session Tracking System - Technical Specification (Swift / Firebase)

**Implementation:** Native iOS (Swift, SwiftUI). Backend: **Firestore**. No Supabase. Session records are stored per user; analytics events are sent via **Firebase Analytics** (see Analytics section below) when the user has granted consent.

---

## Architecture Overview

### Technology Stack

- **Firestore** — Session records in subcollection `users/{userId}/playbackHistory`. Each document: soundIds, sessionType, startedAt, durationPlayed, endedAt, sessionTitle, mixId, totalDuration, guidedSessionId, category.
- **SessionTrackingProtocol** (AWAVEDomain) — Contract: startSession, endSession, updateProgress, getHistory, getLastIncompleteSession, getStats, restoreActiveSession.
- **FirestoreSessionTracker** (AWAVEData) — Implements SessionTrackingProtocol; writes/reads Firestore; holds in-memory map of active session IDs for endSession/updateProgress when userId is not passed.
- **AnalyticsService** — Centralized Firebase Analytics event logging; all events gated by AnalyticsConsentService.hasAnalyticsConsent. Events: sessionStarted, sessionCompleted, sessionAbandoned, sessionResumed, screenView, favoriteAdded/Removed, etc.
- **AnalyticsConsentService** — Opt-in consent stored in UserDefaults; toggles `Analytics.setAnalyticsCollectionEnabled(_:)`. Consent is collected during onboarding (toast) and can be updated for logged-in users in Firestore.

### Where Session Lifecycle Is Triggered

- **PlayerViewModel** — Primary: starts session when starting playback (guided session, Klangwelten, or single sound); updates progress (e.g. on background or periodic); ends session when playback finishes or user abandons. Calls `sessionTracker.startSession(...)`, `sessionTracker.updateProgress(...)`, `sessionTracker.endSession(...)`. Also logs AnalyticsService events (sessionStarted, sessionCompleted, sessionAbandoned, sessionResumed).
- **HomeViewModel / Category screens** — Start session indirectly by calling `PlayerViewModel.startSessionWithPreloader(session, category:...)` when user taps a session or "Weiterhören". Session start/end are still executed inside PlayerViewModel and sessionTracker.
- **LibraryViewModel** — Injected with `sessionTracker` (SessionTrackingProtocol); used for any library-driven playback that starts a session (e.g. continue listening). Actual start/end/update are coordinated with player lifecycle in PlayerViewModel.

---

## Firestore Schema: playbackHistory

**Path:** `users/{userId}/playbackHistory/{sessionId}`

| Field | Type | Description |
|-------|------|-------------|
| soundIds | array | Sound IDs in the session/mix |
| sessionType | string | e.g. "guided", "mix", "single" (PlaybackSession.SessionType.rawValue) |
| startedAt | timestamp | When the session started |
| durationPlayed | number | Seconds played (updated on updateProgress and endSession) |
| endedAt | timestamp | Set when session ends (optional until endSession) |
| sessionTitle | string | Display title |
| mixId | string? | Custom mix ID if applicable |
| totalDuration | number | Total duration in seconds |
| guidedSessionId | string? | For guided sessions |
| category | string? | e.g. "schlafen", "stress", "leichtigkeit" |

FirestoreSessionTracker stores the session document on startSession; on endSession or updateProgress it updates durationPlayed and (on end) endedAt. For endSession/updateProgress after app restart, the tracker has overloads that take `userId` so the document path can be built without in-memory state.

---

## SessionTrackingProtocol (AWAVEDomain)

- **startSession(userId:soundIds:type:sessionTitle:mixId:totalDuration:guidedSessionId:category:)** → `PlaybackSession`. Creates document in `users/{userId}/playbackHistory`; returns PlaybackSession with id.
- **endSession(id:durationPlayed:)** or **endSession(id:userId:durationPlayed:)** — Updates document with endedAt and durationPlayed.
- **updateProgress(id:durationPlayed:)** or **updateProgress(id:userId:durationPlayed:)** — Updates durationPlayed only.
- **restoreActiveSession(id:userId:)** — Re-registers session in in-memory map so updateProgress/endSession without userId work after resume.
- **getHistory(userId:limit:)** — Returns recent PlaybackSession list.
- **getLastIncompleteSession(userId:)** — For "Continue Listening".
- **getStats(userId:)** — Returns UserStats (aggregates from playback history).

---

## Analytics (Firebase Analytics + Consent)

- **AnalyticsService** (AWAVE app) — Singleton; `log(_ event: Event)`. Events are only sent when `AnalyticsConsentService.shared.hasAnalyticsConsent` is true. Event types: screenView, sessionStarted, sessionCompleted, sessionAbandoned, sessionResumed, favoriteAdded/Removed, mixSaved, searchPerformed, sosTriggered, trialStarted, purchaseCompleted/Failed, subscriptionCancelled, downloadStarted/Completed/Failed, onboardingCompleted.
- **AnalyticsConsentService** — `hasAnalyticsConsent` (UserDefaults); `setAnalyticsConsent(_:)`; updates Firebase `Analytics.setAnalyticsCollectionEnabled(_:)`. Consent is asked during onboarding (AnalyticsConsentToastView); for logged-in users, choice can be written to Firestore.

**User flow:** Session start → PlayerViewModel calls sessionTracker.startSession and AnalyticsService.log(.sessionStarted(...)). During playback, updateProgress is called. On session end or abandon → sessionTracker.endSession and AnalyticsService.log(.sessionCompleted(...)) or (.sessionAbandoned(...)).

---

## File Locations (Swift)

| Component | Location |
|-----------|----------|
| SessionTrackingProtocol | AWAVE/Packages/AWAVEDomain/Sources/AWAVEDomain/Protocols/SessionTrackingProtocol.swift |
| FirestoreSessionTracker | AWAVE/Packages/AWAVEData/Sources/AWAVEData/Repositories/FirestoreSessionTracker.swift |
| AnalyticsService | AWAVE/AWAVE/Services/AnalyticsService.swift |
| AnalyticsConsentService | AWAVE/AWAVE/Services/AnalyticsConsentService.swift |
| PlayerViewModel (session start/end/update) | AWAVE/AWAVE/Features/Player/PlayerViewModel.swift |
| DependencyContainer (sessionTracker) | AWAVE/AWAVE/App/DependencyContainer.swift |

---

*Legacy: An earlier version of this document described a React/TypeScript + Supabase stack. The current iOS app uses Swift and Firebase/Firestore only.*
