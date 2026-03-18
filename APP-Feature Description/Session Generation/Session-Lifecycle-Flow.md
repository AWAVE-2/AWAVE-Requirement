# Session Lifecycle Flow (End-to-End)

One-page reference for the full path from session generation to session end and tracking/analytics. Baseline for Android.

---

## 1. Session generation

- User selects category (Schlaf, Ruhe, Im Fluss) or topic; taps "Neue Sessions generieren" or a session tile.
- **CategorySessionGenerator** or **SessionGenerator** produces a **Session** (phases with content IDs for text, music, nature, sound, frequency, noise).
- Session is passed to **PlayerViewModel** (e.g. startSessionWithPreloader(session, category:, mixerState:)).

---

## 2. Pre-resolve and manifest

- **PlayerViewModel.preResolveSessionContentURLs** collects all content IDs from the session’s phases and resolves them to URLs (soundRepository.getSound(byContentId:), SessionContentMapping fallback).
- **SessionManifestBuilder.build(session:urls:clipURLsByContentId:)** validates that every phase layer has a URL; if any layer is missing, it throws (user sees playback error or offline-style message).
- **SessionPlayerService** is created with the manifest (resolvedURLs, clipURLsByContentId).

---

## 3. Phase playback

- **SessionPlayerService** sets currentPhaseIndex = 0 and calls **loadCurrentPhase()**.
- For each phase: **PhasePlayer.load(phase:engine:resolveURL:...)** loads the phase’s layers into **AWAVEAudioEngine**, sets up clip queues and phase timer. **PhasePlayer** runs until phase duration (or graceful text-clip end), then calls **onPhaseComplete**.
- **SessionPlayerService.advanceToNextPhase()** increments index, captures user volumes, stops current PhasePlayer, calls **loadCurrentPhase()** for the next phase, invokes **onPhaseDidChange** (PlayerViewModel refreshes UI). If there is no next phase, **finishSession()** runs.

---

## 4. Session end and tracking

- **finishSession()** — Stops PhasePlayer, calls **audioEngine.removeAllTracks()**, sets isSessionActive = false, invokes **onSessionDidFinish**.
- **PlayerViewModel** in the session-did-finish path:
  - Calls **sessionTracker.endSession(id:userId:durationPlayed:)** (Firestore update: endedAt, durationPlayed).
  - Logs **AnalyticsService.shared.log(.sessionCompleted(mode:category:durationSeconds:))** (or .sessionAbandoned if abandoned).
- If the user had abandoned earlier, **sessionTracker.updateProgress** may have been called (e.g. on background); **endSession** is still called when playback stops or app handles session end.

---

## 5. Summary diagram

```
Session generated
    → preResolveSessionContentURLs
    → SessionManifestBuilder.build
    → SessionPlayerService(manifest)
    → loadCurrentPhase (PhasePlayer)
    → [phase completes] → advanceToNextPhase → loadCurrentPhase (repeat)
    → [no next phase] → finishSession
    → sessionTracker.endSession + AnalyticsService.sessionCompleted/Abandoned
```

---

## Links

- [Phase-Playback-Flow.md](Phase-Playback-Flow.md) — Phase-level detail (SessionPlayerService ↔ PhasePlayer).
- [PRD 04-AUDIO-ARCHITECTURE](../../PRD/04-AUDIO-ARCHITECTURE.md) — Multi-phase playback subsection.
- [Session Tracking](../Session%20Tracking/technical-spec.md) — Firestore schema and AnalyticsService.
