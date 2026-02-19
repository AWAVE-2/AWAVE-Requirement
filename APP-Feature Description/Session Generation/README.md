# Session Generation – Feature Overview

**Feature:** Topic-based and category-based therapeutic session generation for AWAVE iOS.  
**Status:** Implemented in Swift. Search→session flow works (session suggestion on topic match, OLD-APP parity). Other items may be in progress (see PRD 07/08).  
**Last updated:** 2026-02-19  

---

## Purpose

Session Generation produces multi-phase audio sessions from:

- **Topics** (11 types: sleep, dream, obe, stress, healing, angry, sad, depression, trauma, belief, meditation).
- **Category** (onboarding: Schlaf, Ruhe, Im Fluss) for the category screens and Home:
  - **Category titles** on Home and in the app are Schlaf, Ruhe, Flow (from `OnboardingCategory.title`).
  - **Category Detail** is reached via Category Overview; one of SchlafScreen, RuheScreen, ImFlussScreen per category.
  - **Category screens** (Schlaf, Ruhe, Im Fluss): Each screen generates **only** sessions for that category's topic (Schlaf→sleep, Ruhe→stress, Flow→meditation). No mixing of topics. Only `SessionTopic.sleep`, `.stress`, `.meditation` are used for category-based generation, via `CategorySessionGenerator.mapToSessionTopic(OnboardingCategory)`.
  - **Home:** Shows the onboarding-selected category and/or categories with favorites; section titles are Schlaf / Ruhe / Flow. Sessions generated or displayed on Home for a category are exclusively for that category's topic.
- **Search** (text → topic match → session; session suggestion shown whenever topic matches, including when sound results exist; direct session start as in OLD-APP).

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
| **PLAN-Session-Uniqueness-And-Time-Update.md** | Uniqueness and time-update plan; includes Content-Fingerprint and deduplication (Feb 2026). |
| **SESSION_GENERATOR_ABSCHLUSSBERICHT.md** | German completion report. |

**Handover & Abschlussbericht (Session-Uniqueness, Deduplizierung):**

| Document | Location | Content |
|----------|----------|---------|
| HANDOVER_SESSION_UNIQUENESS_AND_DEDUPLICATION.md | [docs/handovers/](../../../handovers/HANDOVER_SESSION_UNIQUENESS_AND_DEDUPLICATION.md) | Handover: Content-Fingerprint, Deduplizierung, geänderte Dateien. |
| ABSCHLUSSBERICHT-SESSION-UNIQUENESS-AND-DEDUPLICATION.md | [docs/](../../../ABSCHLUSSBERICHT-SESSION-UNIQUENESS-AND-DEDUPLICATION.md) | Abschlussbericht: Session-Einzigartigkeit und Deduplizierung. |

---

## Related Features

- **Category Screens** – Category block, personalization drawer, "Neue Sessions generieren".
- **Seach Drawer** – Search text → topic → session; session suggestion on topic match (OLD-APP parity).
- **Major Audioplayer** – Playback, PhasePlayer, mixer labels.
- **User Onboarding Screens** – Category selection (schlafen, stress, leichtigkeit) used for category→topic mapping and for the single category shown on Home.

---

## OLD-APP vs Swift

The OLD-APP (Capacitor/JS) generates sessions **topic-based** only (topic from topic button or Symptom Finder; no separate “Home category”). The Swift app goes further: **category screens** each show one category = one topic; **Home** shows only the onboarding-selected category, so session generation and display on Home are strictly category-based (e.g. only Flow sessions when the user chose Flow in onboarding).

---

## Cross-Check

For a cross-check of session generation and registration flows against requirements, see:

- [../../SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md](../../SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md)
