# AWAVE – Production Ready Overview & Parity Check

**Purpose:** Single document for production readiness assessment: PRD parity, feature-spec parity, quality criteria, and ship checklist. Use alongside [06-PROJECT-INTEGRATION-PLAN](06-PROJECT-INTEGRATION-PLAN.md) for Done/Open status.

**Related docs:** [01-PRD](01-PRD.md) · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) · [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) · [06-PROJECT-INTEGRATION-PLAN](06-PROJECT-INTEGRATION-PLAN.md)

**Status date:** 2026-02-03

---

## 1. Document Index & Prozentuale Übersicht

### 1.1 Prozentuale Umsetzung (Übersicht)

| Bereich | Erfüllt | Teilweise | Offen / N/A | **Umsetzung** |
|---------|---------|-----------|-------------|----------------|
| **PRD (01-PRD)** §2–§12 | 12 | 20 | 9 | **~54 %** |
| **Feature Specs (F01–F16)** | 10 | 5 | 1 (⏸ 1) | **~78 %** |
| **Quality: Functional** | 2 | 6 | 4 | **~42 %** |
| **Quality: Audio** | 1 | 1 | 4 (2 N/A) | **~30 %** |
| **Quality: Performance** | 0 | 5 | 0 | **~50 %** |
| **Ship Checklist** (Critical/High/Medium/Launch) | 0 | 1 | 18 | **~3 %** |

**Gesamt-Parity (gewichtet):** PRD und Feature Specs abgedeckt, Quality und Ship offen → **ca. 52 %** production-ready gegenüber vollem PRD-Soll.

*Berechnung: Erfüllt = 100 %, Teilweise = 50 %, Offen/N/A = 0 %; ⏸ = bei Berechnung ausgenommen.*

### 1.2 Dokument-Navigation

| Section | Content |
|---------|---------|
| §2 | PRD parity (01-PRD section-by-section) |
| §3 | Feature specs parity (F01–F16) mit Links zu Requirements |
| §4 | Quality criteria (functional, audio, performance) |
| §5 | Old App (Cordova) vs New iOS – gap summary |
| §6 | Ship preparation checklist |
| §7 | Summary & recommendation |

---

## 2. PRD Parity Check (01-PRD)

*Reference: [01-PRD](01-PRD.md). ✓ = met, ◐ = partial, ✗ = not met. **Gesamt §2: ~54 %.***

### 2.1 Product Overview (§1) — ~67 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| German-language wellness/meditation app | ✓ | UI and content DE |
| Multi-phase audio sessions, binaural/frequency, content library | ◐ | Sessions from Firestore; no multi-phase, no frequency synthesis in engine |
| Three tiers: Demo, User, Pro | ◐ | Demo/User via StoreKit; Pro (SHA256) not implemented |
| In-app subscription monetization | ✓ | StoreKit 2, SubscribeScreen, DownsellScreen |

### 2.2 User Tiers & Monetization (§2) — ~40 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Demo: 10-minute session timer per launch | ✗ | No demo timer implemented |
| Demo: UI countdown, upsell at expiry | ✗ | — |
| User: subscription (yearly/monthly), full playback, no editor/export | ✓ | StoreKit 2, premium gating |
| Pro: SHA256 password unlock, full editor, import/export | ✗ | No Pro unlock, no session editor |
| Restore purchases, state persistence (user, currentSubscription, purchaseDate) | ✓ | Subscription state persisted |

### 2.3 Navigation Architecture (§3) — ~50 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Screen map: Splash → Content Loader → Main Menu → flows | ◐ | Preloader/Onboarding → 4-tab (Schlaf, Stress, Im Fluss, Profile); no classic “Content Loader” |
| Meditation Topics, Soundscapes, Favorites, Info | ✓ | Category screens, MixerSheet (Klangwelten), Favorites, Profile/Support |
| Session Editor (Pro) in menu | ✗ | No session editor |
| Context-sensitive menu bar (7 states) | ◐ | Tab bar + sheets; not 1:1 with PRD menu states |
| Background theme by topic | ◐ | Theming present; topic-specific backgrounds partial |

### 2.4 Meditation Topics (§4) — ~50 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| 10+ topic categories with background theme | ◐ | 3 category tabs (Schlaf, Stress, Im Fluss); guided sessions from Firestore |
| Session generation from topic | ◐ | Guided sessions; no legacy generator-session-content parity |
| Symptom finder: text input, keyword matching (2,655 lines) | ◐ | Search + SOS; full keyword DB not migrated |
| SOS detection → emergency screen | ✓ | Implemented in search |
| Pro unlock via symptom input (SHA256) | ✗ | Not implemented |

### 2.5 Content Library (§5) — ~67 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| 62+ guided text items, 4 voices | ◐ | Content from Firestore; multi-voice selection not in UI |
| 8 music genres, 18+ nature, frequency bands, 6+6 noise, sound effects | ◐ | Content model and playback; frequency/noise synthesis not in engine |
| Content DB (JSON/Codable) | ✓ | Firestore + local caching |

### 2.6 Session Structure (§6) — ~33 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Session config (id, name, voice, topic, type, enableFreq, phases) | ◐ | Session/custom mix models; no multi-phase model in playback |
| Phase structure: 6 layers (text, music, nature, sound, noise, frequency) | ✗ | Flat mixes only; no phase transitions |
| Mix types: one, loop, mute | ◐ | Playback modes exist; not exposed per-phase in editor |

### 2.7 Audio Engine (§7) — ~33 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Multi-track playback (5: Text, Music, Nature, Sound, Demo) | ◐ | 3-track (e.g. voice, music, nature); no Sound/Demo track, no frequency/noise synthesis |
| Per-track volume, fade-in/out, cross-phase continuity | ◐ | Volume/fading for 3 tracks; no phases |
| 12 frequency modes (root, binaural, monaural, isochronic, bilateral, molateral, Shepard variants) | ✗ | Not implemented (critical gap) |
| 6 colored noise + 6 NeuroFlow | ✗ | Not implemented (critical gap) |
| Play/pause, restart, exit, live content swap, keep-awake, portrait lock | ◐ | Play/restart/exit/keep-awake; live content swap and portrait lock to be confirmed |
| Background/foreground: pause, “Session Pausiert” on resume | ◐ | Lifecycle handling; exact copy to be confirmed |

### 2.8 Session Editor – Pro (§8) — 0 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Session-level: name, phase list, add/delete/reorder, total duration, import/export | ✗ | Not implemented |
| Phase-level: 6 editors (Text, Music, Nature, Frequency, Noise, Sound), timer, preview | ✗ | Not implemented |

### 2.9 Favorites (§9) — ~75 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Save with name, duplicate handling (2), (3), topic reset to "user" | ✓ | Custom mixes save/load/delete |
| Load, delete, delete all, import | ◐ | Load/delete; import and delete-all not implemented |

### 2.10 Platform (§10) — ~50 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| Portrait only, keep-awake, status bar, keyboard | ◐ | Orientation/keep-awake to be confirmed |
| .awave import/export (Base64 JSON), version check | ✗ | Not implemented |
| Offline: full except purchase/restore | ✓ | Offline mode, downloads, caching |

### 2.11 Localization & NFR (§11–§12) — ~50 %

| Requirement | Status | Notes |
|-------------|--------|-------|
| German UI, Localizable.strings | ◐ | DE in use; .strings extraction open |
| Performance, battery, accessibility (VoiceOver, Dynamic Type) | ◐ | Accessibility and Dynamic Type not fully done |
| Data migration from web/localStorage | ◐ | New app uses Firestore; no .awave import path |

---

## 3. Feature Specs Parity (F01–F16) — ~78 %

*Reference: [02-FEATURE-SPECS](02-FEATURE-SPECS.md). Jedes Feature verlinkt auf den passenden Requirements-Ordner in [APP-Feature Description](../APP-Feature%20Description/) (requirements.md).*

| Spec | Name | Umsetzungsstatus | Implementation / Gap | Requirements |
|------|------|------------------|------------------------|--------------|
| F01 | Splash Screen | ✓ 100 % | PreloaderView, onboarding flow | [Start Screens](../APP-Feature%20Description/Start%20Screens/requirements.md) |
| F02 | Content Loader | ◐ 50 % | Preloader/onboarding; no explicit “content availability check” screen | [Start Screens](../APP-Feature%20Description/Start%20Screens/requirements.md), [Index & Landing](../APP-Feature%20Description/Index%20%26%20Landing/requirements.md) |
| F03 | Main Menu | ✓ 100 % | MainTabView: Schlaf, Stress, Im Fluss, Profile; sheets for Session, Klangwelten, Search | [Navigation](../APP-Feature%20Description/Navigation/requirements.md), [Index & Landing](../APP-Feature%20Description/Index%20%26%20Landing/requirements.md) |
| F04 | Meditation Topics | ✓ 100 % | SchlafScreen, StressScreen, ImFlussScreen; CategorySessionsView, GuidedSessionsView | [Category Screens](../APP-Feature%20Description/Category%20Screens/requirements.md) |
| F05 | Symptom Finder | ◐ 50 % | SearchDrawerView + SOS; no full keyword matching (2,656) | [Seach Drawer](../APP-Feature%20Description/Seach%20Drawer/requirements.md) |
| F06 | SOS Screen | ✓ 100 % | SOS trigger, crisis resources | [SOS Screen](../APP-Feature%20Description/SOS%20Screen/requirements.md) |
| F07 | User Session Config | ✓ 100 % | GuidedSessionDetailView; multi-voice selector missing | [Major Audioplayer](../APP-Feature%20Description/Major%20Audioplayer/requirements.md) |
| F08 | Soundscapes Browser | ✓ 100 % | MixerSheetView (Klangwelten), 3-track; 4 categories as flat mixes | [Klangwelten](../APP-Feature%20Description/Klangwelten/requirements.md) |
| F09 | Live Player | ✓ 100 % | FullPlayerView, MiniPlayerView; 6-track and freq/noise synthesis missing | [Major Audioplayer](../APP-Feature%20Description/Major%20Audioplayer/requirements.md), [MiniPlayer Strip](../APP-Feature%20Description/MiniPlayer%20Strip/requirements.md) |
| F10 | After Session | ◐ 50 % | Exit/restart in player; no dedicated After Session screen with Save/Edit/Export | [Major Audioplayer](../APP-Feature%20Description/Major%20Audioplayer/requirements.md) |
| F11 | Favorites | ✓ 100 % | FavoritesListView, save/load/delete; Import/Delete All open | [Favorite Functionality](../APP-Feature%20Description/Favorite%20Functionality/requirements.md) |
| F12a–c | Session Editor (Pro) | ✗ 0 % | Not implemented | [Major Audioplayer](../APP-Feature%20Description/Major%20Audioplayer/requirements.md) |
| F13 | Info Menu | ◐ 50 % | Profile, Support, Account; Legal/AGB/Datenschutz/Impressum to be consolidated | [Support](../APP-Feature%20Description/Support/requirements.md), [Legal & Privacy](../APP-Feature%20Description/Legal%20%26%20Privacy/requirements.md) |
| F14 | Upgrade / Subscription | ✓ 100 % | StoreKit 2, SubscribeScreen, DownsellScreen | [Subscription & Payment](../APP-Feature%20Description/Subscription%20%26%20Payment/requirements.md), [SalesScreens](../APP-Feature%20Description/SalesScreens/requirements.md) |
| F15 | EEG View | ⏸ — | Deferred | — |
| F16 | Dialog System | ◐ 50 % | Native .alert, toasts; no unified modal with optional text input | [Styles and UI](../APP-Feature%20Description/Styles%20and%20UI/requirements.md) |

**Legend:** ✓ Done (100 %) · ◐ Partial (50 %) · ✗ Open (0 %) · ⏸ Deferred (nicht in Berechnung)

---

## 4. Quality Criteria (from 05-REQUIREMENTS-SUMMARY §6)

*Source: [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md). Functional ~42 %, Audio ~30 %, Performance ~50 % (siehe §1.1).*

### 4.1 Functional Parity

| Criterion | Status | Notes |
|-----------|--------|-------|
| All 25+ screens navigable | ◐ | Main flows present; PRD “25+ screens” includes Editor, Info sub-pages, some not 1:1 |
| All 10 meditation topics generate valid sessions | ◐ | 3 category tabs + guided sessions from Firestore; 10 legacy topics not all mapped |
| Symptom finder matches keywords correctly | ◐ | Search + SOS only; full keyword DB not migrated |
| SOS detection for all crisis terms | ✓ | SOS path implemented |
| All 12 frequency types produce correct output | ✗ | No frequency synthesis |
| All 12 noise types work | ✗ | No noise synthesis |
| 4 voices selectable and correct audio | ✗ | Single voice path; 4-voice UI not implemented |
| Session editor creates valid multi-phase sessions | ✗ | No session editor |
| Favorites save/load/delete/import/export | ◐ | Save/load/delete done; import/export open |
| Demo timer limits session to 10 minutes | ✗ | No demo timer |
| Subscriptions purchasable and verifiable | ✓ | StoreKit 2 |
| .awave import/export compatible | ✗ | Not implemented |

### 4.2 Audio Quality

| Criterion | Status | Notes |
|-----------|--------|-------|
| No clicks/pops at phase transitions | — | N/A (no phases) |
| Binaural beats perceptible | ✗ | No binaural synthesis |
| Shepard tones continuous | ✗ | No Shepard synthesis |
| Fading smooth | ◐ | Fading on current tracks; not validated for all cases |
| Cross-phase continuity | — | N/A (no phases) |
| NeuroFlow spatial effect | ✗ | No NeuroFlow |
| Clean stop on session exit | ✓ | Expected; to be verified |

### 4.3 Performance

| Criterion | Status | Notes |
|-----------|--------|-------|
| App launch < 2 s | ◐ | To be measured |
| Session start < 1 s | ◐ | To be measured |
| No glitches in 2+ hour sessions | ◐ | To be tested |
| Battery acceptable for background playback | ◐ | To be tested |
| Memory stable over session | ◐ | To be tested |

---

## 5. Old App (Cordova) vs New iOS – Gap Summary

*Source: AWAVE/docs/Old-App-Feature-Gap-Analysis.md and Current-Status-and-Remaining-Work.md.*

### 5.1 Critical Gaps (Core Therapeutic Engine)

| Gap | Description | Impact |
|-----|-------------|--------|
| Frequency generation (12 modes) | No real-time binaural/isochronic/Shepard synthesis | Core therapeutic value missing |
| Noise generation (12 types) | No colored noise, no NeuroFlow | Core therapeutic value missing |
| Multi-phase sessions | Only flat mixes; no phase list, no cross-phase continuity | Session model and UX differ from PRD |
| 6-track engine | Current engine is 3-track (no Sound, Frequency, Noise tracks) | Cannot fulfill PRD §7 |

### 5.2 Major Gaps (Content & Intelligence)

| Gap | Description | Impact |
|-----|-------------|--------|
| Session generator (topic-based) | No parity with generator-session-content.js (11 topics, templates) | Different content model (Firestore-guided vs legacy) |
| Symptom finder (2,656 keywords) | SOS only; full keyword→topic matching not migrated | Weaker discovery from free text |
| Session editor (Pro) | Not implemented | No Pro tier parity |
| Multiple voices (4) | Single voice path in UI | No voice selector parity |

### 5.3 Medium Gaps

| Gap | Description |
|-----|-------------|
| Demo timer (10 min) | Not implemented |
| Session import/export (.awave) | Not implemented |
| Real-time content swap | Not implemented in player |
| Real user ID | Hardcoded "local-user" in many flows (critical for production) |
| Sleep timer | Not implemented |
| Playback seeking | Slider read-only |
| Forgot password / password visibility | Not implemented |

### 5.4 What the New App Has Beyond Old App

- Native iOS, SwiftUI, 4-tab navigation, 3-track engine, Firebase Auth, Apple Sign-In  
- Custom mixes (save/load/delete), favorites, session history, “Continue Listening”, stats, streaks  
- Offline downloads, NetworkMonitor, OfflineBanner, cached playback  
- StoreKit 2, SubscribeScreen, DownsellScreen, premium gating  
- Onboarding, shimmer loading, haptics, toasts, pull-to-refresh, error states  

---

## 6. Ship Preparation Checklist

*Consolidated from Current-Status-and-Remaining-Work and IMPROVEMENTS.*

### 6.1 Critical (Before Production)

| Task | Status | Owner/Notes |
|------|--------|-------------|
| Replace "local-user" with real user ID everywhere | ✗ | 15+ files; use appState.currentUser?.id |
| Consolidate auth listeners (single source of truth) | ✗ | Avoid duplicate listeners |
| Production Firebase config | ✗ | Required for release |
| Privacy policy & terms (screens/links) | ✗ | Required for App Store |

### 6.2 High Priority (Features)

| Task | Status | Owner/Notes |
|------|--------|-------------|
| Sleep timer (presets + countdown in Mini/Full player) | ✗ | New SleepTimer service, wire to PlayerViewModel |
| Playback seeking (interactive slider, seek in engine) | ✗ | FullPlayerView, PlayerViewModel, AWAVEAudioEngine |
| Forgot password flow | ✗ | Auth flow |
| Content seeding (Firestore) | ◐ | Backend/scripts (Sprint 5) |

### 6.3 Medium Priority (Quality & Compliance)

| Task | Status | Owner/Notes |
|------|--------|-------------|
| Accessibility (VoiceOver labels) | ✗ | Key screens and controls |
| Dynamic Type support | ✗ | Text scaling |
| Firebase Analytics | ✗ | Events |
| Firebase Crashlytics | ✗ | Crashes |
| Unit tests (core ViewModels) | ◐ | Minimal today |
| Password visibility toggle | ✗ | Auth UI |

### 6.4 Launch / Store

| Task | Status | Owner/Notes |
|------|--------|-------------|
| App Store assets & screenshots | ✗ | Required |
| TestFlight setup & distribution | ✗ | Required |
| Localization (.strings) | ◐ | Already DE; extract for consistency |

---

## 7. Summary & Recommendation

### 7.1 Parity Summary

- **PRD:** Partial. Navigation, subscriptions, favorites, offline, and core playback (3-track) are in place. **Not in place:** demo timer, Pro tier, session editor, multi-phase engine, frequency/noise synthesis, .awave import/export, full symptom finder, 4-voice UI.
- **Feature Specs F01–F16:** Majority of screens and flows implemented or partially implemented; **F12 (Session Editor)** and several F10/F11/F13/F16 details are open or partial.
- **Quality criteria (05-REQUIREMENTS-SUMMARY):** Functional parity with legacy app is **not** achieved until frequency/noise synthesis, multi-phase sessions, and session editor (Pro) are implemented. Current app is suitable for a **subset** of the original product (guided sessions + soundscapes + subscriptions + offline), not full therapeutic parity.

### 7.2 Production Readiness (Current Build)

- **Blockers:** Real user ID (no "local-user"), production Firebase, privacy/terms.
- **Strongly recommended before release:** Sleep timer, playback seeking, auth consolidation, forgot password, accessibility baseline.
- **Optional for first release:** Full PRD parity (frequency, noise, multi-phase, editor, demo timer, .awave) can be scheduled in a later phase if product accepts a “simplified” first version.

### 7.3 Recommended Next Steps

1. **Immediate:** Fix "local-user" and auth listeners; add production Firebase and legal screens.  
2. **Short term:** Sleep timer, seeking, forgot password; accessibility and analytics/Crashlytics.  
3. **Roadmap:** Decide whether to ship without full PRD parity or to prioritize frequency/noise and multi-phase engine for a “full parity” release.  
4. **Ongoing:** Update [06-PROJECT-INTEGRATION-PLAN](06-PROJECT-INTEGRATION-PLAN.md) and this document as features are completed.

---

*Document version: 1.1 · Production ready overview with percentage views and requirement links (APP-Feature Description) for AWAVE iOS.*
