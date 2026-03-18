# Parity Backlog: OLD-APP (V.1) & Web App

**Purpose:** Single backlog of features that exist in OLD-APP (V.1) or the React Web App but are not yet fully in the **current native iOS app (Swift)**. The current iOS app is the **baseline for Android app development**; this backlog lists candidate features to add to iOS (and then Android) for parity.

**Baseline:** Current AWAVE iOS app (Swift/SwiftUI, Firebase).  
**Target:** Android app will use iOS behaviour and feature set as the baseline.  
**Last updated:** 2026-02-16

---

## Why this folder exists

The previous "missing migration" folders targeted a **React Native iOS app**, which is outdated. The app is now **native iOS (Swift)**. To avoid confusion and to support the Android baseline plan:

- **This folder** is the single place for "parity backlog" with OLD-APP and Web App.
- **Existing APP-Feature folders** (Session Generation, Major Audioplayer, SalesScreens, Category Screens, etc.) remain the source of truth for what is **implemented** or **specified** in the current iOS app.
- Items below are either **already documented elsewhere** (with a link) or **only described in the old "missing migration" folders** (with a pointer to that content until it is moved).

---

## OLD-APP (V.1) parity backlog

| Feature | Status in iOS | Documented in | Notes |
|--------|----------------|----------------|--------|
| **Multi-Phase Session System** | Implemented | [Major Audioplayer](../Major%20Audioplayer/), [Session Generation](../Session%20Generation/), [PRD 04-AUDIO-ARCHITECTURE](../../PRD/04-AUDIO-ARCHITECTURE.md) | SessionPlayerService + PhasePlayer (AWAVEAudio); sequential phase playback, loadCurrentPhase → advanceToNextPhase. See [Session Generation Phase-Playback-Flow](../Session%20Generation/Phase-Playback-Flow.md). |
| **Frequency Generation** | Implemented | [PRD 04-AUDIO-ARCHITECTURE](../../PRD/04-AUDIO-ARCHITECTURE.md), [07-PRODUCTION-READY](../../PRD/07-PRODUCTION-READY-OVERVIEW.md) | FrequencyGenerator in AWAVEAudio; binaural/isochronic synthesis per phase. |
| **Noise Generation** | Not implemented | [PRD 04-AUDIO-ARCHITECTURE](../../PRD/04-AUDIO-ARCHITECTURE.md) | Colored noise, NeuroFlow. Same PRD as above. |
| **Session Import/Export** | Not implemented | [PRD 01-PRD](../../PRD/01-PRD.md) §10.3 | .awave format. Detail: `missing migration from OLD-APP (V.1)/Session Import Export/` |
| **Content Database** | Partial (Firestore) | [Session Generation](../Session%20Generation/), [Databases](../Databases/) | Firestore `sounds` + content IDs. Detail: `missing migration from OLD-APP (V.1)/Content Database/` |
| **Preset Sounds Library** | Partial (Firestore/catalog) | [Library](../Library/), [Session Generation](../Session%20Generation/) | Preset configs/category mapping. Detail: `missing migration from OLD-APP (V.1)/Preset Sounds Library/` |
| **Symptom Finder** | Partial (Search) | [Seach Drawer](../Seach%20Drawer/), [SOS Screen](../SOS%20Screen/) | Search + SOS; full keyword DB not migrated. |
| **Multiple Voice Options** | Partial | [Session Generation](../Session%20Generation/), [Major Audioplayer](../Major%20Audioplayer/) | Voice in session model; UI may be partial. |
| **Live Volume Control** | Implemented | [Major Audioplayer](../Major%20Audioplayer/) | Per-track volume in mixer. |
| **Session Generator** | Implemented | [Session Generation](../Session%20Generation/), [Category Screens](../Category%20Screens/) | CategorySessionGenerator, SessionGenerator; multi-phase playback via SessionPlayerService + PhasePlayer (same implementation as Multi-Phase Session System above). |
| **Preset Frequency Settings** | Not implemented | PRD 04 | Gamma/beta/alpha/theta/delta presets. |
| **Pro Mode Unlock** | Not implemented | [PRD 01-PRD](../../PRD/01-PRD.md) §2.3 | SHA256 password. |
| **Session Phase Editor** | Not implemented | PRD §8 | Pro-only phase editor. |
| **Session Export/Import** | Not implemented | See Session Import/Export above. |

---

## Web App (React / Lovable) parity backlog

| Feature | Status in iOS | Documented in | Notes |
|--------|----------------|----------------|--------|
| **Category Tile Selector** | Partial | [Category Screens](../Category%20Screens/), [User Onboarding Screens](../User%20Onboarding%20Screens/) | Onboarding category selection + tab categories. Tile-style UI: `missing migration from React APP (Lovalbe)/Category Tile Selector/` |
| **Custom Sound Library** | Partial | [Library](../Library/), [Klangwelten](../Klangwelten/) | Custom mixes, favorites. |
| **Recommendation Section** | Not implemented | — | Personalized recommendations; no dedicated doc. |
| **Trial Management UI** | Partial | [SalesScreens](../SalesScreens/), [Subscription & Payment](../Subscription%20%26%20Payment/) | Trial info on SubscribeScreen; banners/reminders may vary. |
| **Scientific Proof / Social Proof / Objection Handling / Money Back / Value Proposition** | Implemented | [SalesScreens](../SalesScreens/) | SubscribeScreen, DownsellScreen, components. |
| **Enhanced Subscription Cards** | Implemented | [SalesScreens](../SalesScreens/) | ProductCard, plan comparison. |
| **Discount Button / Shake discount** | Implemented | [SalesScreens](../SalesScreens/) | Discount system documented. |
| **Subscription Management Modal** | Partial | [Profile View](../Profile%20View/), [Subscription & Payment](../Subscription%20%26%20Payment/) | Restore, subscription state. |

---

## How to use this backlog for Android

1. **Baseline:** Implement Android to match the **current iOS app** (features and flows in the main APP-Feature folders and PRD).
2. **Parity:** Use this backlog when prioritising **additional** features to add first to iOS, then to Android (e.g. multi-phase, frequency/noise, import/export, or UI enhancements like category tiles).
3. **Source of truth:** For "how it works today", use the linked APP-Feature folders and PRD. For "how OLD-APP or Web App did it", the old "missing migration" subfolders still hold the detailed specs until content is moved here or into the main feature folders.

---

## Deprecated folders (do not use as primary reference)

- **`missing migration from OLD-APP (V.1)/`** – Content is superseded by this README and the linked folders above. Detailed OLD-APP specs remain in that folder for reference only.
- **`missing migration from React APP (Lovalbe)/`** – Content is superseded by this README and the linked folders above. Detailed Web App specs remain in that folder for reference only.

Prefer **Backlog-Parity-OLD-APP-and-Web** (this folder) and the main **APP-Feature Description** folders for all new requirement and Android baseline work.
