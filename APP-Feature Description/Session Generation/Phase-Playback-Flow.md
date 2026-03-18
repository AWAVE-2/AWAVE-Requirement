# Phase Playback Flow (iOS / Swift)

This document describes how multi-phase session playback works in the native iOS app. It is the reference for Android parity.

**Components:** `SessionPlayerService` (AWAVE app), `PhasePlayer` (AWAVEAudio package), `AWAVEAudioEngine` (AWAVEAudio).

---

## Overview

1. **SessionPlayerService** owns the current phase index and the session; it loads one phase at a time via **PhasePlayer**.
2. **PhasePlayer** loads a single `SessionPhase` into the audio engine (text, music, nature, sound, frequency), runs the phase timer and clip queue, and calls `onPhaseComplete` when the phase duration is reached or the phase ends.
3. When **onPhaseComplete** fires, SessionPlayerService calls **advanceToNextPhase()**, then **loadCurrentPhase()** for the next phase. When there is no next phase, the session ends.

---

## Flow (Step by Step)

1. **Session loaded** — `PlayerViewModel.loadSession()` pre-resolves all content URLs, builds a `SessionManifest` via `SessionManifestBuilder`, and creates `SessionPlayerService(audioEngine:manifest:displayNames:)`.

2. **Playback start** — SessionPlayerService sets `currentPhaseIndex = 0`, then calls **loadCurrentPhase()**.

3. **loadCurrentPhase()**  
   - If `currentPhaseIndex >= session.phases.count`, session is complete → **finishSession()** (removeAllTracks, `onSessionDidFinish?()`).  
   - Otherwise:  
     - Stops any previous PhasePlayer.  
     - Gets `phase = session.phases[currentPhaseIndex]`.  
     - Creates a new **PhasePlayer()**, sets `onTimeUpdate` (for UI) and **onPhaseComplete** (to call `advanceToNextPhase()`).  
     - Calls **phasePlayer.load(phase:engine:resolveURL:displayNames:clipURLsByContentId:previousPhase:startOffset:enableFrequency:userVolumeOverrides:userMuteOverrides:userFrequencyVolumeOverride:)**.  
     - PhasePlayer loads each layer (text, music, nature, sound, frequency) into the engine, sets up clip queues for text, fade controllers, and phase timer.  
     - If already playing, calls `engine.play()`.

4. **During phase** — PhasePlayer’s timer and backup tick update elapsed time; `onTimeUpdate` updates SessionPlayerService’s `currentPhaseTime` and `totalSessionTime`. When the phase duration is reached (or text clip ends in graceful exit), PhasePlayer calls **markComplete()** → **onPhaseComplete()**.

5. **onPhaseComplete** — SessionPlayerService (on MainActor) runs **advanceToNextPhase()**:  
   - Captures user volume overrides.  
   - Stops current PhasePlayer.  
   - Increments **currentPhaseIndex**, resets `currentPhaseTime` to 0.  
   - Calls **loadCurrentPhase()** again (step 3).  
   - After load, calls **onPhaseDidChange?()** (so PlayerViewModel can refresh UI, e.g. phase name).  
   - If playing, resumes PhasePlayer and calls `engine.play()`.

6. **Session end** — When there is no next phase, **finishSession()** stops PhasePlayer, calls `audioEngine.removeAllTracks()`, sets `isSessionActive = false`, and invokes **onSessionDidFinish?()**. PlayerViewModel then runs session-complete logic (tracking, analytics, UI).

---

## Key Types and Locations

| Component | Location | Role |
|-----------|----------|------|
| SessionPlayerService | AWAVE/Services/SessionPlayerService.swift | Owns session, currentPhaseIndex; loadCurrentPhase, advanceToNextPhase, finishSession |
| PhasePlayer | AWAVE/Packages/AWAVEAudio/Sources/AWAVEAudio/Engine/PhasePlayer.swift | Loads one SessionPhase into engine; phase timer; onPhaseComplete |
| SessionManifestBuilder | AWAVE/Services/SessionManifestBuilder.swift | Validates phases and resolved URLs before playback |
| PlayerViewModel | AWAVE/Features/Player/PlayerViewModel.swift | loadSession, preResolveSessionContentURLs, creates SessionPlayerService, wires onPhaseDidChange / onSessionDidFinish |

---

## See Also

- [base-documentation.md](base-documentation.md) — Content-IDs, resolution order, mixer display.
- [README.md](README.md) — Session generation overview and Swift components.
- [docs/20260306_leftovers.md](../../../20260306_leftovers.md) — Known issues (e.g. mixer slots not updating per phase, volume/mute sync).
