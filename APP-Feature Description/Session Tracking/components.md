# Session Tracking System - Components Inventory (Swift)

**Implementation:** Native iOS (Swift, SwiftUI). Session data in Firestore `users/{userId}/playbackHistory`. Analytics via Firebase Analytics (consent-gated). No React/TypeScript or Supabase.

---

## Session tracking and analytics usage

### PlayerViewModel
**Location:** AWAVE/AWAVE/Features/Player/PlayerViewModel.swift

**Role:** Primary owner of session lifecycle and session analytics events.

- **Session start:** Calls `sessionTracker.startSession(userId:soundIds:type:sessionTitle:mixId:totalDuration:guidedSessionId:category:)` when starting guided session, Klangwelten mix, or single-sound playback. Stores `activeSessionId`. Logs `AnalyticsService.shared.log(.sessionStarted(mode:category:))`.
- **Progress:** Calls `sessionTracker.updateProgress(id:userId:durationPlayed:)` (e.g. when app goes to background or on periodic update). Uses `LastPlaybackSnapshotStore` and `NowPlayingService.updateProgress` for display/continuation.
- **Session end:** On playback stop or abandon, calls `sessionTracker.endSession(id:userId:durationPlayed:)` and logs `AnalyticsService.shared.log(.sessionCompleted(...))` or `.sessionAbandoned(...)`. On resume (Weiterhören), logs `.sessionResumed(...)` and may call `sessionTracker.restoreActiveSession(id:userId:)`.
- **Dependencies:** Injected `sessionTracker: SessionTrackingProtocol` (DependencyContainer provides FirestoreSessionTracker).

### HomeViewModel / HomeView
**Location:** AWAVE/AWAVE/Features/Home/HomeViewModel.swift, HomeView.swift

**Role:** Starts playback (and thus session) when user taps a session or "Weiterhören". Delegates to PlayerViewModel.startSessionWithPreloader(session, category:, mixerState:). Session start/end/update are performed inside PlayerViewModel and sessionTracker.

### Category screens (SchlafScreen, RuheScreen, ImFlussScreen)
**Location:** AWAVE/AWAVE/Features/Categories/*.swift

**Role:** When user taps a generated session or continues listening, they call `player.startSessionWithPreloader(session, category:, mixerState:)`. Session tracking runs inside PlayerViewModel.

### LibraryViewModel
**Location:** AWAVE/AWAVE/Features/Library/LibraryViewModel.swift

**Role:** Injected with `sessionTracker: SessionTrackingProtocol`. Used for any library-driven playback that creates a session; actual start/end/update are coordinated with PlayerViewModel when the player is used.

### DependencyContainer
**Location:** AWAVE/AWAVE/App/DependencyContainer.swift

**Role:** Constructs `sessionTracker` as `FirestoreSessionTracker()` and injects it into PlayerViewModel, HomeViewModel, LibraryViewModel.

---

## Analytics (screen views and events)

- **AnalyticsService.shared.log(.screenView(.home))** — HomeView.onAppear
- **AnalyticsService.shared.log(.screenView(.schlaf))** — SchlafScreen
- **AnalyticsService.shared.log(.screenView(.ruhe))** — RuheScreen
- **AnalyticsService.shared.log(.screenView(.imFluss))** — ImFlussScreen
- **AnalyticsService.shared.log(.screenView(.player))** — FullPlayerView
- **AnalyticsService.shared.log(.screenView(.klangwelten))** — KlangweltenScreen
- **AnalyticsService.shared.log(.screenView(.search))** — SearchDrawerView
- **AnalyticsService.shared.log(.screenView(.profile))** — ProfileView
- **AnalyticsService.shared.log(.screenView(.onboarding))** — OnboardingView
- **Session events** — PlayerViewModel (sessionStarted, sessionCompleted, sessionAbandoned, sessionResumed)
- **Favorites, mix, search, SOS, trial, purchase, download, onboarding** — See AnalyticsService.Event in technical-spec or Analytics-Event-Catalog (if present).

All events are dropped when `AnalyticsConsentService.shared.hasAnalyticsConsent` is false.

---

## FirestoreSessionTracker implementation notes

- **FirestoreSessionTracker** — Uses `AWAVEDataFirestoreConfig.firestore()`. startSession creates a new document in `users/{userId}/playbackHistory` and stores the session id + userId in an in-memory lock-protected dictionary so endSession(id:durationPlayed:) can resolve userId. Overloads with userId are used when the app has been restarted and in-memory state is lost.
- **getMostPlayedSounds, getRecentSessions** — Implemented on FirestoreSessionTracker; query Firestore aggregation/ordering as needed for stats UI.

---

## Stats display (Stats & Analytics feature)

Stats and charts (e.g. total minutes, sessions, most played sounds) consume data from Firestore playbackHistory and/or Firebase Analytics. See [Stats & Analytics](../Stats%20%26%20Analytics/) for Swift screens and view models that display this data.

---

*For technical details (schema, protocol, analytics event list), see technical-spec.md.*
