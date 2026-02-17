# 08 – Test Coverage and UI Test Proposals

**Version:** 1.1  
**Status:** DRAFT  
**Date:** 2026-02-16  
**Language:** English  

---

## 1. Purpose and Scope

This document consolidates:

- an **analysis of current test coverage** of the AWAVE iOS app (entire app from a test perspective),
- **concrete UI test proposals** for all relevant screens and user journeys, including priority and technical notes.

**Scope:** Entire native iOS app (AWAVE2-Swift). This iOS app is the **baseline for the Android app**; see [docs/ANDROID-NORDSTERN.md](../../ANDROID-NORDSTERN.md).  
**Boundaries:**

- Detailed acceptance scenarios (Given/When/Then) for F01–F16 are in [TEST_COVERAGE.md](../TEST_COVERAGE.md); this document references them and adds the analysis plus focused UI test proposals.
- Phased plan and goals for unit tests (Domain, Audio, SessionGenerator, CI) are in [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md); referenced here, not duplicated.

---

## 2. Known Issues and Current Limitations (as of 2026-02-16)

The following are **known not to work or to be incomplete**; they affect testability and production readiness:

| # | Area | Status | Notes |
|---|------|--------|--------|
| 1 | **Sound generation** | Not working | Frequency/noise synthesis in playback not fully functional end-to-end. |
| 2 | **Email authentication** | Can be deprioritized | Implemented in code (AuthService, AuthView) but may have issues; lower priority for release. |
| 3 | **Category screens** | Incomplete | Two category screens still need finalization (content/UX). |
| 4 | **Push notifications** | Not working | FCM/Firebase Messaging present but push delivery/registration not fully working. |
| 5 | **Background play** | Not working | Sound in background, Lock Screen, and Dynamic Island / Control Center Now Playing controls are not working reliably. |
| 6 | **Test coverage** | Low | No UI test target; unit coverage ~15–20%; many ViewModels and flows untested. |
| 7 | **Sound generation via search** | Not working | Search → topic match → session generation/play flow does not work as expected. |

When writing or prioritizing tests, account for these limitations: e.g. skip or mock sound generation in search until fixed; treat background/lock-screen behaviour as manual checks until implemented.

---

## 3. Test Coverage Analysis

### 3.1 Summary

| Type | Estimated Coverage | Notes |
|------|--------------------|--------|
| **Unit tests** | ~15–20 % | Domain, Audio, Auth, Category-Sessions, SessionGenerator; many ViewModels/Services without tests |
| **UI tests** | 0 % | No `AWAVEUITests` target present |
| **Integration** | 0 % | No automated tests for Firestore/Storage/Session Tracking |
| **Regression** | Manual | High regression risk on critical flows |

### 3.2 Coverage by Module/Feature

| Module / Feature | Type | Status | Spec Ref |
|------------------|------|--------|----------|
| AWAVEDomain (Entities) | Unit | Present | Session, PlaybackSession, UserStats, Sound, FrequencyType, NoiseType, ContentCategory, CustomMix, Favorite, etc. |
| AWAVECore | Unit | Present | KeychainService, HTTPClient, ColorHex, FoundationExtensions |
| AWAVEAudio | Unit | Present | FrequencyGenerator, ShepardEngine, PulseModulator, FrequencySweep, FrequencyModeEngine |
| AWAVEDesign / AWAVEFeatures / AWAVEData | Unit | Minimal / placeholder | — |
| Auth | Unit | Present | AuthViewModelTests |
| Category Screens (F04) | Unit | Present | CategorySessionsViewModel, CategorySessionGenerator |
| SessionGenerator (App) | Unit | Present | SessionGeneratorTests |
| SessionPreloadService | Unit | Excluded from scheme | excludes in project.yml |
| Splash & Preloader (F01, F02) | UI/Unit | Missing | — |
| Main Menu & Navigation (F03) | UI/Unit | Missing | — |
| Onboarding | UI/Unit | Missing | — |
| Symptom Finder (F05) | UI/Unit | Missing | — |
| SOS Screen (F06) | UI/Unit | Missing | — |
| User Session Config (F07) | UI/Unit | Missing | — |
| Soundscapes / Explore (F08) | UI/Unit | Missing | — |
| Live Player (F09) | UI/Unit | Missing | — |
| After Session (F10) | UI/Unit | Missing | — |
| Favorites (F11) | UI/Unit | Missing | — |
| Profile, Support, Legal (F13) | UI/Unit | Missing | — |
| Upgrade / Subscription (F14) | UI/Unit | Missing | — |
| Dialog system (F16) | UI/Unit | Missing | — |
| HomeViewModel, LibraryViewModel, PlayerViewModel | Unit | Missing | — |
| OnboardingViewModel, SearchViewModel, SubscriptionViewModel | Unit | Missing | — |
| Firestore/Storage Repositories, Session Tracking | Integration | Missing | — |

### 3.3 Gaps

- **No UI test target:** In `project.yml` only `AWAVETests` (unit) exists; an **AWAVEUITests** target (XCUIApplication) is not defined. Without a UI target, automated UI or user-flow tests cannot be run.
- **ViewModels without unit tests:** HomeViewModel, LibraryViewModel, PlayerViewModel, OnboardingViewModel, SearchViewModel, SubscriptionViewModel, DownsellViewModel and others are not covered by unit tests.
- **Services/Integration:** No automated tests for Firestore/Storage repositories, Session Tracking, or audio download; player and playback logic are untested.
- **Accessibility for UI tests:** Only sporadic `accessibilityIdentifier` / `accessibilityLabel` (e.g. MainTabView, SoundCarouselView, KlangweltenScreen). Systematic IDs for main buttons, tabs, and lists are missing and are a prerequisite for stable UI tests.

**References:** Detailed scenarios and gap analysis in [TEST_COVERAGE.md](../TEST_COVERAGE.md). Phases and goals for unit tests in [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md).

---

## 4. UI Test Proposals

### 4.1 Technical Prerequisites

- **AWAVEUITests target:** Add a new UI test target (e.g. `AWAVEUITests`) in `project.yml` that launches the app and drives it via XCUIApplication. Not implemented in this document; recommendation only.
- **Accessibility IDs:** For stable selectors, key elements (Tab Bar, main buttons, lists, search field, player controls) should use `.accessibilityIdentifier()`. Existing use: e.g. MainTabView, SoundCarouselView, KlangweltenScreen; extend to other areas.
- **Backend/Mocks:** UI tests should run as independently as possible from live Firebase (Firebase Emulator or injected mocks). Concrete implementation is left to the implementation phase.

### 4.2 Smoke Tests and Critical User Journeys

The following IDs are taken from [TEST_COVERAGE.md](../TEST_COVERAGE.md) and form the core of the UI test proposals.

**Smoke tests (implement first):**

| ID | Description | Priority |
|----|-------------|----------|
| SMOKE-01 | App launches; Preloader or main UI visible | Critical |
| SMOKE-02 | After Preloader: Onboarding or Main Tabs reachable | Critical |
| SMOKE-03 | All main tabs (Home, Explore, Library, Search, Profile) tappable and load without crash | Critical |
| SMOKE-04 | Opening each tab does not crash | Critical |

**Critical User Journeys (CUJ):**

| ID | Journey | Priority | Spec |
|----|---------|----------|------|
| CUJ-01 | Onboarding: Preloader → Onboarding → Category selection → Main Tabs | High | F01, F02, §3.2 |
| CUJ-02 | Session: Choose topic/category → Session generated → Session Config → Start playback | Critical | F04, F07, F09 |
| CUJ-03 | Audio: Play → Timer/progress → Pause → Resume → Exit (or Restart) | Critical | F09 |
| CUJ-04 | Subscription: Paywall on locked content; Restore visible and usable | High | F14 |
| CUJ-05 | Search → Session (no SOS): Search drawer → Text → Topic match → Session → Play | High | F05, F07, F09 |
| CUJ-06 | Search → SOS: Search drawer → SOS keyword → SOS screen → Call/Chat/Dismiss | High | F05, F06 |
| CUJ-07 | Favorites: Add from player/list; remove from list; list updates | Medium | F11 |
| CUJ-08 | Category: ≥5 sessions visible; tap “Generate new session” → new session appears | Critical | F04, §3.4 |

*Note: CUJ-05 depends on sound generation via search; currently not working (see §2).*

### 4.3 UI Test Cases by Area

#### 1. Launch & Onboarding (F01, F02)

- **Description:** Preloader, content check, onboarding slides, category selection, routing first-time vs. returning user.
- **Test cases (examples):**
  - **Given** app is launched **When** Preloader is shown **Then** logo/branding visible, after ~3 s fade-out and navigation.
  - **Given** onboarding not completed **When** Preloader ends **Then** navigate to Onboarding (full slides).
  - **Given** onboarding completed **When** Preloader ends **Then** navigate to Main Tabs; initial tab may depend on category.
  - **Given** first-time user **When** on last slide (category) **Then** category selectable, “Get Started” active only after selection; tap → Main Tabs.
  - **Given** user has completed onboarding **When** app is restarted **Then** no onboarding, direct entry to Main Tabs.
- **Priority:** High (CUJ-01).

#### 2. Main Navigation (F03)

- **Description:** Tab bar visible, all tabs tappable, switch without crash, initial tab after onboarding.
- **Test cases:**
  - **Given** user on Main Tabs **Then** tabs Home, Explore, Library, Search, Profile visible and clearly active.
  - **Given** user on Main Tabs **When** another tab is selected **Then** corresponding screen appears; state preserved when switching back.
  - **Given** user comes from onboarding with chosen category **When** Main Tabs load **Then** initial tab matches category where specified.
  - **Given** user on detail screen of a tab **When** Back/gesture **Then** return to previous screen, navigation consistent.
- **Priority:** Critical (Smoke, CUJ).

#### 3. Categories (F04)

- **Description:** Sleep, Stress, In Flow: session list, “Generate new session”, navigation to Session Config.
- **Test cases:**
  - **Given** user on category screen (e.g. Sleep) **Then** at least 5 sessions visible, “Generate new session” (or equivalent) button visible.
  - **Given** user on category screen **When** “Generate new session” tapped **Then** short loading indicator, new session in list, list updated.
  - **Given** user has sessions in a category **When** navigate to Home and back to category **Then** previous sessions still visible (no unexpected reset).
  - **Given** user on category screen **When** session tapped **Then** navigate to User Session Config (or session detail); Start/Regenerate available from there.
- **Priority:** Critical (CUJ-02, CUJ-08).

#### 4. Search & SOS (F05, F06)

- **Description:** Open search drawer, text input, topic match → session; SOS keywords → SOS screen, Call/Chat, Dismiss.
- **Test cases:**
  - **Given** search drawer open **When** text entered (e.g. “I can’t sleep”) **Then** input accepted, keyword matching runs (possibly with debounce).
  - **Given** text matches a topic **When** match complete **Then** session is created, user can go to Config/Playback.
  - **Given** text matches no topic **When** match complete **Then** error or “Choose topic” dialog/message; correction or manual selection possible.
  - **Given** text contains no SOS keywords **When** search runs **Then** SOS screen does not appear, normal search/session flow.
  - **Given** text contains SOS keyword **When** search runs **Then** SOS screen appears in time; Call button with number, possibly Chat button; Dismiss closes and resets state.
- **Priority:** High (CUJ-05, CUJ-06). *Sound generation from search is currently not working (§2).*

#### 5. Session Config & Player (F07, F09)

- **Description:** Session overview, Start, Live Player: Play/Pause, progress/timer, Exit/Restart; Mini-Player if applicable.
- **Test cases:**
  - **Given** user on Session Config **Then** session name and duration (or overview) visible, “Start”/“Start session” button visible.
  - **Given** session with voice **When** on Config **Then** voice selection (e.g. Franca, Flo, Marion, Corinna) available; preview if applicable.
  - **Given** session with frequency **When** on Config **Then** frequency on/off toggle; selection applied on start.
  - **Given** user on Session Config **When** “Start session” tapped **Then** playback starts, navigate to Live Player; Play ↔ Pause, timer/progress visible.
  - **Given** playback running **When** Pause tapped **Then** audio paused; Play again **Then** resume at same position.
  - **Given** user in Live Player **When** Exit tapped **Then** possibly confirmation, then return to previous screen; Restart starts session from beginning.
  - **Given** playback running **When** switch to another tab **Then** Mini-Player/strip visible, Pause/Resume and return to full player possible.
- **Priority:** Critical (CUJ-02, CUJ-03). *Lock screen / Dynamic Island controls currently not working (§2).*

#### 6. After Session & Favorites (F10, F11)

- **Description:** Completion/cancellation message, “Save to Favorites”; favorites list, empty state, add/remove, load session.
- **Test cases:** (Same structure as in TEST_COVERAGE; completion/abort messages, save to favorites, list behaviour, empty state, delete, load.)
- **Priority:** Medium to High (CUJ-07).

#### 7. Soundscapes / Explore (F08) & Library

- **Description:** Categories/lists on Explore; tap to detail/player. Library: Favorites, All Mixes, History.
- **Test cases:** (Explore categories, tap item, back; Library sections and navigation.)
- **Priority:** Medium.

#### 8. Profile, Support, Legal (F13)

- **Description:** Profile, Account, Support, Legal, Version/Upgrade linked.
- **Test cases:** (Profile entries, sub-pages, Version/Upgrade options.)
- **Priority:** Medium.

#### 9. Subscription / Sales (F14)

- **Description:** Plan display, Subscribe, Restore; paywall on locked content.
- **Test cases:** (Plans visible, Subscribe flow, Restore, paywall on locked content.)
- **Priority:** High (CUJ-04).

#### 10. Dialogs (F16)

- **Description:** Confirmation dialogs (e.g. Exit Session, Delete favorite), error dialogs.
- **Test cases:** (Confirm/Cancel, optional text input, error display and dismiss.)
- **Priority:** Medium.

---

## 5. Prioritization and Next Steps

**Immediate (foundation for UI tests):**

1. Add **AWAVEUITests target** in `project.yml`.
2. Implement **smoke tests:** SMOKE-01 to SMOKE-04 (launch, Preloader/Onboarding or Main Tabs, all tabs tappable, no crash).
3. Set **accessibility IDs** for Tab Bar and main buttons (e.g. Start, Generate new session, Play/Pause) so UI tests run stably.

**Critical user journeys (next):**

- CUJ-02 (Session generate → Config → Play), CUJ-03 (Playback), CUJ-08 (Category, Generate new session).
- Then CUJ-01 (Onboarding), CUJ-04 (Subscription), CUJ-05/CUJ-06 (Search/SOS), CUJ-07 (Favorites).

**Other areas:**

- Implement UI test cases from §4.3 by priority and resources (Launch/Onboarding, Navigation, then Categories, Search/SOS, Player, Favorites, Explore/Library, Profile, Subscription, Dialogs).
- Expand unit tests for missing ViewModels and services as in [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md) and [TEST_COVERAGE.md](../TEST_COVERAGE.md).

---

## 6. References

| Document | Content |
|----------|---------|
| [01-PRD.md](01-PRD.md) | Product and navigation overview |
| [02-FEATURE-SPECS.md](02-FEATURE-SPECS.md) | Screen specs F01–F16 |
| [TEST_COVERAGE.md](../TEST_COVERAGE.md) | Scenario coverage F01–F16, Smoke/CUJ/Regression, gap analysis, detailed Given/When/Then |
| [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md) | Phased plan for unit tests (Domain, Audio, SessionGenerator, CI), coverage goals |
| [TESTING_IMPLEMENTATION_SUMMARY.md](../../handovers/TESTING_IMPLEMENTATION_SUMMARY.md) | Implemented Category-Sessions tests (ViewModel + Generator) |
