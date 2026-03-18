# MiniPlayer Strip - Technical Specification (Swift)

**Implementation:** Native iOS (Swift, SwiftUI). Compact strip shown above the tab bar when the user has current playback or a "continue listening" session. No React Native or Supabase.

---

## Architecture Overview

### Technology Stack

- **SwiftUI** — MiniPlayerView is a SwiftUI view; uses AWAVEDesign (spacing, colors, fonts) and AWAVEDomain (PlaybackSession).
- **State** — All state comes from **PlayerViewModel** via `@Environment(PlayerViewModel.self)`. No local playback state; the strip is a thin UI over the shared player.
- **Navigation** — **AppCoordinator** (also from environment) drives full-player and Klangwelten presentation. Tapping the strip sets `player.showFullPlayer = true` or opens Klangwelten as appropriate.

### Key Components

| Component | Location | Role |
|-----------|----------|------|
| MiniPlayerView | AWAVE/AWAVE/Features/Player/MiniPlayerView.swift | Compact strip: current playback or "Weiterhören" (continue listening) session; play, close, tap-to-expand |
| PlayerViewModel | AWAVE/AWAVE/Features/Player/PlayerViewModel.swift | hasContent, continueListeningSession, miniPlayerDismissedByUser, showFullPlayer; dismissMiniPlayer(), dismissContinueListening() |
| MainTabView | AWAVE/AWAVE/Navigation/MainTabView.swift | Shows MiniPlayerView when (player.hasContent \|\| player.continueListeningSession != nil) && !player.miniPlayerDismissedByUser |

---

## Behaviour

1. **When to show** — MainTabView displays MiniPlayerView above the tab bar when there is something to show (current playback or a saved "continue listening" session) and the user has not dismissed the mini player. Dismissal is tracked by `PlayerViewModel.miniPlayerDismissedByUser`; it is reset when the user starts new playback (e.g. starts a session or plays a mix).

2. **Current playback strip** — If `player.hasContent` is true, the strip shows artwork, title/subtitle (from player), a play/pause button, and a close button. Tapping the strip opens the full player (`player.showFullPlayer = true`) or Klangwelten (if `player.playbackMode == .klangwelten`). Close calls `await player.dismissMiniPlayer()`.

3. **Weiterhören (continue listening) strip** — If `player.continueListeningSession != nil`, the strip shows the session title, progress, and remaining time; a play button resumes the session and opens the full player; a close button calls `player.dismissContinueListening()`.

4. **Expansion** — Tapping the strip or the play button (in continue-listening mode) opens the full player (FullPlayerView) or Klangwelten screen; the full player is presented as a fullScreenCover and receives the same PlayerViewModel from the environment.

---

## File Structure (Swift)

```
AWAVE/AWAVE/
├── Features/Player/
│   ├── MiniPlayerView.swift    # Strip UI (current playback + Weiterhören)
│   ├── PlayerViewModel.swift   # hasContent, continueListeningSession, miniPlayerDismissedByUser, dismissMiniPlayer, showFullPlayer
│   └── FullPlayerView.swift    # Full-screen player (opened from strip)
└── Navigation/
    └── MainTabView.swift       # Tab bar + conditional MiniPlayerView
```

---

## Dependencies

- **PlayerViewModel** — Injected via environment; provides playback state, session state, and actions (dismissMiniPlayer, dismissContinueListening, showFullPlayer).
- **AppCoordinator** — Injected via environment; used to open Klangwelten with `klangweltenOpenInPlayerPhase` when playback mode is Klangwelten.
- **AWAVEDesign** — AWAVESpacing, AWAVEColors, AWAVEFonts; AWAVEHaptics for feedback.
- **AWAVEDomain** — PlaybackSession for continue-listening strip.

---

*Legacy: An earlier version of this document described a React Native/TypeScript MiniPlayerStrip with Supabase. The current iOS app uses Swift and PlayerViewModel only.*
