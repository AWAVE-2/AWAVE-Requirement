# Session Generation – Feature Overview

**Feature:** Topic-based and category-based therapeutic session generation for AWAVE iOS.  
**Status:** Implemented in Swift. Sound generation and search→session flow are known issues (see PRD 07/08).  
**Last updated:** 2026-02-16  

---

## Purpose

Session Generation produces multi-phase audio sessions from:

- **Topics** (11 types: sleep, dream, obe, stress, healing, angry, sad, depression, trauma, belief, meditation).
- **Category** (onboarding: Schlaf, Stress, Im Fluss) for the category screens (5 sessions per category, with optional preferences).
- **Search** (text → topic match → session; currently not working reliably).

Sessions consist of phases with content IDs for text, music, nature, sound, and noise; resolution is done via the audio library (Firestore + SessionContentMapping), with display names shown in the mixer.

---

## Swift Implementation Summary

| Component | Role |
|-----------|------|
| `SessionGenerator` | Builds a single multi-phase `Session` from topic, voice, optional journey/music genre, and RNG. |
| `CategorySessionGenerator` | Produces 5 varied sessions for an `OnboardingCategory`, with optional `SessionGeneratorPreferences`. |
| `SessionTopic` / `SessionTopicConfig` | Defines stages, music genre pools, and frequency configs per topic. |
| `SessionNameGenerator` | Generates session name and info text (fantasy vs non-fantasy). |
| `SessionContentResolver` | Resolves phase content IDs to `Sound` from repository; no category fallback. |
| `SessionContentMapping` | Optional fallback: contentId → Firestore sound document ID. |
| `SessionGeneratorView` | UI: topic grid, voice, "Session erstellen"; supports `initialTopic` (e.g. from search). |
| `CategorySessionGeneratorBlock` / `CategorySessionPersonalizationDrawerView` | Category-screen block: drawer, preferences, "Neue Sessions generieren". |
| `CategorySessionsViewModel` | Loads/stores category sessions and preferences (local/Firestore). |
| `SessionPlayerService` / `PhasePlayer` | Playback using resolved URLs and display names. |

---

## Documentation Index (This Folder)

| Document | Content |
|----------|---------|
| **requirements.md** | Functional requirements checklist (this feature); references to other docs. |
| **README.md** | This overview and index. |
| **base-documentation.md** | Content-IDs for iOS, resolution order, mixer display. |
| **base-dockuemtation.md** | Legacy typo filename; same content as base-documentation. |
| **SESSION_GENERATION_AUDIO_LIBRARY_REFACTORING_REPORT.md** | Refactoring: no category fallback, SessionContentResolver, displayNames. |
| **Session-Content-IDs-Catalog.md** | Catalog of content IDs. |
| **AWAVE-Session-Naming-Logic.md** | Naming logic and examples. |
| **AWAVE-Session-Generation-Naming.md** | Naming implementation details. |
| **Session-Preload-System.md** | Preload system design. |
| **PLAN-Session-Uniqueness-And-Time-Update.md** | Uniqueness and time-update plan. |
| **SESSION_GENERATOR_ABSCHLUSSBERICHT.md** | German completion report. |

---

## Related Features

- **Category Screens** – Category block, personalization drawer, "Neue Sessions generieren".
- **Seach Drawer** – Search text → topic → session (known issue: not working).
- **Major Audioplayer** – Playback, PhasePlayer, mixer labels.
- **User Onboarding Screens** – Category selection (schlafen, stress, leichtigkeit) used for category→topic mapping.

---

## Cross-Check

For a cross-check of session generation and registration flows against requirements, see:

- [../../SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md](../../SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md)
