# AWAVE iOS – App-Wide Test Case Scenario Coverage

**Date:** February 1, 2026  
**Status:** DRAFT  
**Version:** 2.0  

---

## Requirements Sources

This document provides app-wide test case scenario coverage and traceability to:

- [01-PRD](PRD/01-PRD.md) – Product Requirements Document  
- [02-FEATURE-SPECS](PRD/02-FEATURE-SPECS.md) – Screen-level specs F01–F16  
- [06-PROJECT-INTEGRATION-PLAN](PRD/06-PROJECT-INTEGRATION-PLAN.md) – EPICs, Done/Open, feature folders  
- [APP-Feature Description](APP-Feature%20Description/) – Per-feature requirements, user-flows, technical-spec  

---

## 1. Executive Summary & Status Quo

**Current Test Coverage Estimate:** ~15–20% (Unit Tests only)  
**UI Test Coverage:** 0% (Critical Gap)  
**Regression Status:** Manual testing only. High risk of regression in critical flows.

The codebase (`AWAVE2-Swift`) uses local Swift Packages (`AWAVECore`, `AWAVEDomain`, `AWAVEData`, `AWAVEFeatures`). Automated testing is currently limited to:

1. **Domain entities:** Good coverage of data models (`Session`, `UserStats`, etc.) via Swift Testing.
2. **Authentication:** `AuthViewModel` tested with mocks.
3. **Session generation:** Basic logic for category and session generation tested.

**Critical missing areas:**

- **UI tests:** No `AWAVEUITests` target; no automated UI or user-flow verification.
- **Player logic:** No comprehensive unit tests for `PlayerViewModel` or AudioEngine integration.
- **Feature ViewModels:** Home, Library, Profile, Onboarding ViewModels largely untested.
- **Integration:** No automated integration tests for Data Repositories (Firestore/Firebase).

**App-wide coverage map:** Acceptance test scenarios in this document cover all Feature Specs (F01–F16) and EPICs from the Integration Plan. Section 2 maps each to implementation and test status; Section 3 covers implemented features; Section 4 covers features yet to come.

---

## 2. Test Coverage Map (Requirements → Tests)

| Feature / EPIC | PRD / Spec ref | Implemented? | Current test coverage | Scenario section |
|----------------|----------------|--------------|------------------------|------------------|
| Splash & content check | F01, F02 | Y | None | §3.1 |
| Main Menu & navigation | F03 | Y | None | §3.3 |
| Onboarding (Start Screens) | F01, F02, Start Screens | Y | None | §3.2 |
| Meditation Topics / Category Screens | F04 | Y | Unit (CategorySessionsViewModel) | §3.4 |
| Symptom Finder | F05 | Y | None | §3.5 |
| SOS Screen | F06 | Y | None | §3.6 |
| User Session Config | F07 | Y | None | §3.7 |
| Soundscapes Browser | F08 | Y | None | §3.8 |
| Live Player | F09 | Y | None | §3.9 |
| After Session | F10 | Y | None | §3.10 |
| Favorites | F11 | Y | None | §3.11 |
| Session Editor (Pro) | F12a–F12c | N | None | §4.1 |
| Info Menu / Profile / Support / Legal | F13 | Y | None | §3.12 |
| Upgrade / Subscription | F14 | Y | None | §3.13 |
| EEG view | F15 | N (defer) | — | — |
| Dialog system | F16 | Y | None | §3.18 |
| Authentication | Supporting EPIC | Y | Unit (AuthViewModel) | §3.14 |
| User Onboarding | Supporting EPIC | Y | None | §3.2 |
| Profile & Settings | Supporting EPIC | Y | None | §3.12 |
| Library | Supporting EPIC | Y | None | §3.15 |
| Session Tracking | Supporting EPIC | Y | None | §3.16 |
| Notifications | Supporting EPIC | N | None | §4.8 |
| Offline support | Supporting EPIC | Partial | None | §3.17, §4.9 |
| Session-based async download | Supporting EPIC | Partial | None | §3.17 |
| Visual effects | Supporting EPIC | Y | None | — |
| APIs & business logic | Supporting EPIC | Y | None | — |
| Multi-track playback & fading | EPIC Audio | Y | Low (Unit) | §3.9 |
| Frequency synthesis (full) | EPIC Audio | Partial | Unit (AWAVEAudio) | §4.2 |
| Colored noise & NeuroFlow | EPIC Audio | N | None | §4.3 |
| Content DB & session generation | EPIC Audio/Content | Y | Unit (SessionGenerator) | §4.7 |
| User tiers & demo timer | EPIC Platform | Partial | None | §4.5 |
| File import/export | EPIC Platform | N | None | §4.4 |
| Background/foreground & lifecycle | EPIC Platform | Partial | None | §4.6 |

---

## 3. Implemented Features – Test Case Scenarios

### 3.1 Splash & Preloader (F01, F02)

*Requirements:* PRD §3.1, F01, F02, EPIC: Splash & content check, APP-Feature Description/Start Screens/, APP-Feature Description/Index & Landing/.

#### Scenario 1: Preloader display and duration
**Given** the app is launched  
**When** the preloader is shown  
**Then** the AWAVE logo and branding are visible  
**And** the preloader runs for approximately 3 seconds  
**And** a smooth fade-out transition occurs before navigation  

#### Scenario 2: Routing – first-time user
**Given** onboarding has not been completed  
**When** the preloader finishes  
**Then** the user is navigated to Onboarding (full flow)  
**And** no black screen is shown during the transition  

#### Scenario 3: Routing – returning user
**Given** onboarding has been completed  
**When** the preloader finishes  
**Then** the user is navigated to Main Tabs  
**And** the initial tab reflects onboarding category preference when applicable  

#### Scenario 4: Content availability
**Given** the app launches  
**When** content check runs  
**Then** audio/resources availability is verified or a loading state is shown  
**And** the app transitions to Main Menu or Content Loader as defined  

---

### 3.2 Onboarding (Start Screens / User Onboarding)

*Requirements:* PRD §3.1, F01, F02, APP-Feature Description/Start Screens/, APP-Feature Description/User Onboarding Screens/.

#### Scenario 1: First launch – full onboarding
**Given** a first-time user  
**When** they complete the preloader  
**Then** they see onboarding slides (e.g. Welcome, Features, Choice)  
**And** they can swipe or tap Next to advance  
**And** on the last slide they must select a category (Sleep, Stress, Flow)  
**And** "Get Started" or equivalent is enabled only after a category is selected  

#### Scenario 2: Category selection and persistence
**Given** the user is on the category selection slide  
**When** they select one category (e.g. Better Sleep)  
**Then** selection is saved immediately  
**And** they can tap "Get Started" to complete onboarding  
**And** they are navigated to Main Tabs with the selected category as initial context  

#### Scenario 3: Skip onboarding
**Given** the user is on any slide before the last  
**When** they tap "Skip"  
**Then** they are taken to the last slide (category selection)  
**And** they must select a category to finish  

#### Scenario 4: Returning user – incomplete onboarding
**Given** the user has a profile but onboarding is not completed  
**When** the preloader finishes  
**Then** they see onboarding starting at the category selection slide (or questionnaire only)  
**And** they can change selection and complete onboarding  

#### Scenario 5: State persistence
**Given** the user has completed onboarding  
**When** they restart the app  
**Then** they are not shown onboarding again  
**And** they go directly to Main Tabs  

---

### 3.3 Main Menu & Navigation (F03)

*Requirements:* PRD §3.1, §3.2, F03, EPIC: Main Menu & navigation, APP-Feature Description/Navigation/, APP-Feature Description/Index & Landing/.

#### Scenario 1: Tab bar visibility
**Given** the user is on Main Tabs  
**Then** the main tabs (e.g. Home, Explore, Library, Search, Profile) are visible  
**And** the active tab is clearly indicated  

#### Scenario 2: Tab switching
**Given** the user is on Main Tabs  
**When** they select another tab  
**Then** the corresponding screen is shown  
**And** tab state is preserved when switching back  

#### Scenario 3: Initial tab from onboarding
**Given** the user has just completed onboarding with a selected category  
**When** Main Tabs load  
**Then** the initial tab reflects the selected category where applicable  

#### Scenario 4: Navigation stack and back
**Given** the user has navigated into a detail screen from a tab  
**When** they tap Back or use gesture  
**Then** they return to the previous screen  
**And** the navigation stack is consistent  

---

### 3.4 Meditation Topics & Category Screens (F04)

*Requirements:* PRD §4.1, §4.2, F04, EPIC: Meditation Topics, APP-Feature Description/Category Screens/.

#### Scenario 1: Category screen content
**Given** the user is on a Category Screen (e.g. Schlafen, Stress, Im Fluss)  
**Then** the screen displays at least **5 generated sessions**  
**And** sessions are relevant to the category  
**And** a "Neue Session generieren" (or equivalent) button is visible  

#### Scenario 2: Generating a new session
**Given** the user is on a Category Screen  
**When** they tap "Neue Session generieren"  
**Then** a loading indicator appears briefly  
**And** a new session is generated and added to the list  
**And** the list updates to show the new session  

#### Scenario 3: Session persistence (in-memory)
**Given** the user has generated sessions in one category  
**When** they navigate away (e.g. to Home) and back to that category  
**Then** the previously generated sessions are still shown (no unexpected reset)  

#### Scenario 4: Navigation to session config
**Given** the user is on a Category Screen with sessions listed  
**When** they tap a session  
**Then** they are navigated to User Session Config (or session detail)  
**And** they can start or regenerate the session from there  

#### Scenario 5: Navigation from Main Tabs to category
**Given** the user is in the Main Tab Bar  
**When** they select the tab that leads to category screens  
**Then** they can reach the Category Screens (Schlaf, Stress, Im Fluss)  
**And** Back or tab change behaves correctly  

---

### 3.5 Symptom Finder (F05)

*Requirements:* PRD §4.3, F05, EPIC: Symptom Finder, APP-Feature Description/Seach Drawer/.

#### Scenario 1: Text input and search
**Given** the user has opened the Search / Symptom Finder  
**When** they enter text (e.g. "Ich kann nicht einschlafen")  
**Then** the input is accepted  
**And** keyword matching runs (with or without debounce as specified)  

#### Scenario 2: Topic match and session generation
**Given** the user has entered text that matches a topic  
**When** matching completes  
**Then** a session is generated for that topic  
**And** the user can proceed to session config or playback  

#### Scenario 3: No match
**Given** the user has entered text that matches no topic  
**When** matching completes  
**Then** an error or "choose topic" dialog/message is shown  
**And** the user can correct input or select a topic manually  

#### Scenario 4: SOS not triggered
**Given** the user has entered text with no crisis keywords  
**When** matching runs  
**Then** the SOS screen does not appear  
**And** normal search/session flow is used  

---

### 3.6 SOS Screen (F06)

*Requirements:* PRD §4.3, F06, EPIC: SOS Screen, APP-Feature Description/SOS Screen/.

#### Scenario 1: SOS trigger – crisis keywords
**Given** the user is in the Search / Symptom Finder  
**When** they enter text containing configured SOS keywords (e.g. "selbstmord", "suizid")  
**Then** the SOS screen opens (e.g. full-screen or full-height sheet)  
**And** it opens in a timely way (e.g. real-time, bypassing debounce where specified)  
**And** search results are not shown for that query  

#### Scenario 2: SOS screen content
**Given** the SOS screen is visible  
**Then** the title (e.g. "Du bist nicht ALLEIN") and crisis message are shown  
**And** a call button with a valid phone number is present  
**And** a chat button is present if configured  
**And** a list of resources is displayed when configured  

#### Scenario 3: Call and chat actions
**Given** the SOS screen is visible  
**When** the user taps the call button  
**Then** the device dialer opens with the correct number  
**When** the user taps the chat button (if present)  
**Then** the configured chat link opens  

#### Scenario 4: Dismiss and clear input
**Given** the SOS screen is visible  
**When** the user taps Back or Close  
**Then** the SOS screen is dismissed  
**And** the search input is cleared (or state is reset) as specified  

---

### 3.7 User Session Config (F07)

*Requirements:* PRD §6, §7.5, F07, EPIC: User Session Config, APP-Feature Description/Major Audioplayer/.

#### Scenario 1: Session overview
**Given** the user has selected a session (from topic or category)  
**When** they are on the User Session Config screen  
**Then** session name and duration (or overview) are shown  
**And** a "Start" or "Start Session" button is visible  

#### Scenario 2: Voice selector and preview
**Given** the session contains voice content  
**When** the user is on session config  
**Then** a voice selector (e.g. Franca, Flo, Marion, Corinna) is available  
**And** the user can preview a voice if the feature is implemented  

#### Scenario 3: Frequency toggle
**Given** the session supports frequency  
**When** the user is on session config  
**Then** a frequency on/off toggle is available  
**And** the choice is applied when starting the session  

#### Scenario 4: Start and Regenerate
**Given** the user is on session config  
**When** they tap "Start Session"  
**Then** playback starts and they are taken to the Live Player  
**When** they tap "Regenerate" (if shown for topic sessions)  
**Then** a new session is generated and the config screen updates  

#### Scenario 5: Back to topics/categories
**Given** the user is on session config  
**When** they tap Back  
**Then** they return to Meditation Topics or Category Screens  

---

### 3.8 Soundscapes / Explore (F08)

*Requirements:* PRD §5, §3.1, F08, EPIC: Soundscapes Browser, APP-Feature Description/Klangwelten/.

#### Scenario 1: Categories visible
**Given** the user is on the Soundscapes / Explore screen  
**Then** categories (e.g. Music, Nature, Frequency, Noise) or equivalent are visible  
**And** the user can tap a category to see details  

#### Scenario 2: Detail grid and tap to play
**Given** the user has opened a soundscape category  
**When** they tap an item in the grid/list  
**Then** a soundscape session is created or configured  
**And** they are taken to the Live Player (or session config as designed)  

#### Scenario 3: Back navigation
**Given** the user is in a soundscape detail view  
**When** they tap Back  
**Then** they return to the main Soundscapes/Explore or Main Menu  

---

### 3.9 Live Player (F09)

*Requirements:* PRD §7, §10, F09, EPIC: Live Player, APP-Feature Description/Major Audioplayer/, APP-Feature Description/MiniPlayer Strip/.

#### Scenario 1: Playback start
**Given** a session is selected and the user is on session config or player  
**When** they tap "Play"  
**Then** audio starts playing  
**And** the timer counts down (or shows elapsed/total)  
**And** the Play button changes to Pause  

#### Scenario 2: Pause and resume
**Given** playback is in progress  
**When** the user taps Pause  
**Then** audio pauses  
**And** the button changes to Play  
**When** they tap Play again  
**Then** playback resumes from the same position  

#### Scenario 3: Progress and timer
**Given** playback is in progress  
**Then** a progress bar (or equivalent) reflects elapsed time  
**And** the session timer updates (e.g. every second)  

#### Scenario 4: Per-track controls (if exposed)
**Given** the Live Player shows per-track controls  
**Then** the user can adjust volume (or content) per track as designed  
**And** changes take effect during playback  

#### Scenario 5: Exit and restart
**Given** the user is in the Live Player  
**When** they tap Exit (or equivalent)  
**Then** a confirmation is shown (if required)  
**And** they leave the player and return to the previous screen  
**When** they tap Restart (if available)  
**Then** the session restarts from the beginning  

#### Scenario 6: Mini player (if present)
**Given** playback is in progress  
**When** the user navigates to another tab or screen  
**Then** a mini player or strip is visible  
**And** they can pause/resume or return to full player  

---

### 3.10 After Session (F10)

*Requirements:* PRD §3.1, F10, EPIC: After Session, APP-Feature Description/Major Audioplayer/, APP-Feature Description/Favorite Functionality/.

#### Scenario 1: Completion message
**Given** the user has completed a session (or it ended normally)  
**When** the After Session screen is shown  
**Then** a completion message (e.g. "Session erfolgreich abgeschlossen") is displayed  
**And** options such as Save to Favorites, Exit, and (for Pro) Edit/Export are available as implemented  

#### Scenario 2: Abort message
**Given** the user has exited the session before completion  
**When** the After Session screen is shown  
**Then** an abort message (e.g. "Session abgebrochen") is displayed  
**And** the same action buttons are available as for completion  

#### Scenario 3: Save to favorites
**Given** the user is on the After Session screen  
**When** they tap "Save to Favorites"  
**Then** they are prompted for a session name (or a default is used)  
**And** the session is saved and they receive confirmation  

---

### 3.11 Favorites (F11)

*Requirements:* PRD §9, F11, EPIC: Favorites, APP-Feature Description/Favorite Functionality/.

#### Scenario 1: List display
**Given** the user has saved favorites  
**When** they open the Favorites list (e.g. from Library tab)  
**Then** saved sessions are shown (e.g. newest first)  
**And** each item shows session name and supports load/delete as designed  

#### Scenario 2: Empty state
**Given** the user has no favorites  
**When** they open the Favorites list  
**Then** an empty state message (e.g. "Keine Favoriten vorhanden") is shown  
**And** an option to add favorites (e.g. from player) is available  

#### Scenario 3: Add to favorites (from player)
**Given** the user is in the Live Player or After Session  
**When** they tap Save to Favorites (or heart icon)  
**Then** the session is added to favorites  
**And** they can see it in the Favorites list  

#### Scenario 4: Remove from favorites
**Given** the user is on the Favorites list  
**When** they delete a favorite (swipe or button)  
**Then** a confirmation is shown if required  
**And** the item is removed from the list  

#### Scenario 5: Load favorite session
**Given** the user is on the Favorites list  
**When** they tap a favorite  
**Then** the session is loaded and they can start playback or edit (Pro) as designed  

---

### 3.12 Info Menu, Profile, Support, Legal (F13)

*Requirements:* PRD §3.1, F13, EPIC: Info Menu, APP-Feature Description/Support/, APP-Feature Description/Legal & Privacy/, APP-Feature Description/Profile View/.

#### Scenario 1: Profile and subscreens
**Given** the user is on the Profile tab  
**Then** they can open Account Settings, Support, Legal, Privacy as implemented  
**And** each sub-page displays the correct content  

#### Scenario 2: Info menu items
**Given** the user opens the Info menu or Profile  
**Then** items such as Vorbereitung, Brainwave, AGB, Datenschutz, Impressum, Haftungsausschluss, Support, Version are available as implemented  
**And** tapping an item opens the corresponding screen or content  

#### Scenario 3: Version and upgrade
**Given** the user opens Version or Upgrade  
**Then** they see upgrade/subscription options (Demo/User) or Pro panel (Pro) as designed  

---

### 3.13 Upgrade / Subscription (F14)

*Requirements:* PRD §2, §10.4, F14, EPIC: Upgrade / Subscription, APP-Feature Description/Subscription & Payment/, APP-Feature Description/SalesScreens/.

#### Scenario 1: Plan display
**Given** the user is on the Subscription / Upgrade screen  
**Then** available plans (e.g. weekly, monthly, annual) are shown  
**And** pricing and savings (if any) are displayed  
**And** a recommended plan is indicated if designed  

#### Scenario 2: Subscribe and Restore
**Given** the user is on the Subscription screen  
**When** they tap Subscribe (for a plan)  
**Then** the native purchase flow (StoreKit) is triggered  
**When** they tap "Restore purchases"  
**Then** restore is attempted and success/failure feedback is given  

#### Scenario 3: Paywall for locked content
**Given** the user is in Demo or unsubscribed state  
**When** they access locked content  
**Then** a paywall or upgrade prompt is shown  
**And** they can Subscribe or Restore from there  

---

### 3.14 Authentication

*Requirements:* EPIC: Authentication, APP-Feature Description/Authentication/.

#### Scenario 1: Sign in with Apple – success
**Given** the user is on the Auth screen  
**When** they tap Sign in with Apple and complete the flow successfully  
**Then** they are signed in  
**And** user/repository state is updated  
**And** the UI returns to idle (no error)  

#### Scenario 2: Sign in with Apple – failure
**Given** the user is on the Auth screen  
**When** they tap Sign in with Apple and the flow fails (e.g. network error)  
**Then** an error message is shown  
**And** they can retry  

#### Scenario 3: Sign in with Apple – cancellation
**Given** the user is on the Auth screen  
**When** they tap Sign in with Apple and cancel  
**Then** no error is shown (idle state)  
**And** they remain on the Auth screen  

---

### 3.15 Library

*Requirements:* EPIC: Library, APP-Feature Description/Library/.

#### Scenario 1: Favorites, All Mixes, History
**Given** the user is on the Library tab  
**Then** they can access Favorites, All Mixes, History (or equivalent) as implemented  
**And** each list shows the correct items  

#### Scenario 2: Navigation to detail
**Given** the user is on a Library list (e.g. Favorites or History)  
**When** they tap an item  
**Then** they are navigated to the mix/session detail or player as designed  

---

### 3.16 Session Tracking

*Requirements:* EPIC: Session Tracking, APP-Feature Description/Session Tracking/.

#### Scenario 1: Session start and complete (if implemented)
**Given** the user starts playback  
**Then** a session is created or updated in the tracking layer  
**When** playback completes or the user exits  
**Then** the session is marked complete (or cancelled)  
**And** analytics/stats are updated as designed  

#### Scenario 2: Progress updates (if implemented)
**Given** playback is in progress  
**Then** progress is reported at the defined interval (e.g. every 30 seconds)  
**And** duration and completion state are correct  

---

### 3.17 Offline / Downloads (implemented parts)

*Requirements:* EPIC: Offline support, Session-based async download, APP-Feature Description/Offline Support/, APP-Feature Description/Session Based Asynch Download of Audiofiles/.

#### Scenario 1: Download on play (if implemented)
**Given** the user selects content that is not yet downloaded  
**When** they start playback  
**Then** the app downloads the audio (or shows progress) as designed  
**And** playback starts when ready or after download  

#### Scenario 2: Cache use
**Given** content has been downloaded previously  
**When** the user plays it again  
**Then** playback uses the cached file  
**And** no unnecessary re-download occurs  

#### Scenario 3: Offline indicator (if implemented)
**Given** the device is offline  
**When** the user uses the app  
**Then** an offline indicator or message is shown where relevant  
**And** cached content remains playable as designed  

---

### 3.18 Dialog System (F16)

*Requirements:* F16, EPIC: Dialog system, APP-Feature Description/Styles and UI/.

#### Scenario 1: Confirm / Cancel
**Given** an action requires confirmation (e.g. delete favorite, exit session)  
**When** the user triggers the action  
**Then** a modal dialog with Confirm and Cancel is shown  
**And** Confirm performs the action and dismisses the dialog  
**And** Cancel dismisses without performing the action  

#### Scenario 2: Text input (e.g. session name)
**Given** the user is saving a session and a name is required  
**When** the save flow runs  
**Then** a dialog with an optional text field and Confirm/Cancel is shown  
**And** the entered name is used for the saved session  

#### Scenario 3: Error dialogs
**Given** an error occurs (e.g. network, storage)  
**When** the error is surfaced to the user  
**Then** an error dialog or message is shown  
**And** the user can dismiss and continue  

---

## 4. Features Yet to Come – Test Case Scenarios

### 4.1 Session Editor (Pro) (F12a–F12c)

*Requirements:* PRD §8, F12a–F12c, EPIC: Session Editor (Pro), APP-Feature Description/Major Audioplayer/.

#### Scenario 1: New session
**Given** the user is Pro and opens the Session Editor  
**When** they tap "New Session"  
**Then** a new empty session is created  
**And** they can add phases and configure content  

#### Scenario 2: Phase list – add, delete, reorder
**Given** the user is on the Session Overview  
**When** they add a phase  
**Then** a new phase (e.g. 60s silence) is appended  
**When** they delete a phase  
**Then** a confirmation is shown and the phase is removed  
**When** they move a phase up or down  
**Then** the order updates and total duration is recalculated  

#### Scenario 3: Phase Editor – all six sections
**Given** the user is editing a phase  
**Then** they can edit Text (voice, volume, fade), Music, Nature, Frequency, Noise, Sound as specified  
**And** timer and fade validation (fadeIn + fadeOut ≤ duration) is enforced  
**And** when text mix is "one", duration is locked to audio length  

#### Scenario 4: Preview
**Given** the user is in the Phase Editor  
**When** they tap Preview  
**Then** all phase audio tracks play (or preview as designed)  
**And** preview stops at phase duration or on stop button  

#### Scenario 5: Import and export
**Given** the user is in the Session Editor  
**When** they import a .awave file  
**Then** the file is validated (version check) and the session is loaded  
**When** they export  
**Then** a .awave (Base64 JSON) file is generated and the share sheet is presented  

---

### 4.2 Frequency Synthesis (full)

*Requirements:* PRD §7.3, EPIC: Frequency synthesis, APP-Feature Description/missing migration from OLD-APP (V.1)/Frequency Generation System/, PRD/04-AUDIO-ARCHITECTURE.md.

#### Scenario 1: All 12 modes available
**Given** a session phase has frequency content  
**Then** the user (or generator) can select among root, binaural, monaural, isochronic, bilateral, molateral, shepard, isoflow, bilawave, binawave, monawave, flowlateral  
**And** the correct oscillator/engine is used for playback  

#### Scenario 2: Pulse and root parameters
**Given** a frequency mode is selected  
**Then** pulse frequency (1–40 Hz) and root frequency (from predefined set) can be set  
**And** start/target values are applied and swept as specified  

#### Scenario 3: Shepard width and direction
**Given** a Shepard-related mode is selected  
**Then** Shepard width (e.g. 20 s per cycle) and direction (up/down) are configurable  
**And** playback reflects these parameters  

---

### 4.3 Colored Noise & NeuroFlow

*Requirements:* PRD §7.4, EPIC: Colored noise & NeuroFlow, APP-Feature Description/Major Audioplayer/, PRD/04-AUDIO-ARCHITECTURE.md.

#### Scenario 1: Six standard colors
**Given** a phase uses colored noise  
**Then** the user can select among white, pink, brown, grey, blue, violet  
**And** the correct noise file or generator is used  

#### Scenario 2: Six NeuroFlow variants
**Given** NeuroFlow (sync) variants are selected  
**Then** the notch filter chain and L/R balance sweep (e.g. 12 s interval) are applied  
**And** spatial effect matches the architecture spec  

#### Scenario 3: Volume and fade
**Given** noise content is configured  
**Then** volume and fade-in/fade-out are applied  
**And** no clicks or pops occur at phase boundaries  

---

### 4.4 File Import/Export

*Requirements:* PRD §10.3, EPIC: File import/export, APP-Feature Description/Favorite Functionality/, APP-Feature Description/missing migration from OLD-APP (V.1)/Session Import Export/.

#### Scenario 1: Import .awave
**Given** the user has a valid .awave (Base64 JSON) file  
**When** they use the Import action (e.g. from Favorites or Editor)  
**Then** the file is decoded and validated  
**And** version compatibility is checked  
**And** the session is loaded and available for play or edit  

#### Scenario 2: Export and share
**Given** the user has a session (current or from favorites)  
**When** they tap Export  
**Then** the session is encoded to .awave format  
**And** the system share sheet is presented with the file  
**And** the user can save or share the file  

#### Scenario 3: Version check on import
**Given** the user imports an .awave file with an unsupported or future version  
**Then** an error or migration path is presented  
**And** the app does not load invalid data  

---

### 4.5 User Tiers & Demo Timer

*Requirements:* PRD §2, F03, F14, EPIC: User tiers & demo timer, APP-Feature Description/Subscription & Payment/.

#### Scenario 1: Demo timer display and countdown
**Given** the user is in Demo mode  
**Then** a demo header or indicator with countdown (e.g. 10 minutes per launch) is visible  
**And** the timer counts down during use  
**And** it pauses in store/upgrade view if designed  

#### Scenario 2: Timer expiration
**Given** the demo timer has expired  
**When** the user returns to the app or tries to play  
**Then** they are prompted to upgrade or the app restricts playback as designed  

#### Scenario 3: User and Pro persistence
**Given** the user has subscribed (User) or unlocked Pro  
**Then** tier is persisted (e.g. user, currentSubscription, purchaseDate)  
**And** on next launch the correct tier is applied  
**And** Restore purchases correctly restores and updates tier  

---

### 4.6 Background/Foreground & Lifecycle

*Requirements:* PRD §10.1, §10.2, F09, EPIC: Background/foreground & lifecycle, APP-Feature Description/Background Audio/.

#### Scenario 1: Pause on background
**Given** a session is playing  
**When** the app goes to background  
**Then** playback pauses  
**And** fade/timer state is preserved  

#### Scenario 2: Resume dialog
**Given** the app was in background during a session  
**When** the app returns to foreground  
**Then** a "Session pausiert" (or equivalent) message is shown  
**And** the user can resume or exit  

#### Scenario 3: Keep-awake and portrait lock
**Given** the user is in the Live Player  
**Then** the device stays awake during playback (if implemented)  
**And** orientation is locked to portrait as specified  

#### Scenario 4: Charging recommendation
**Given** the user is about to start a long session  
**Then** a recommendation to keep the device plugged in may be shown  
**And** it does not block starting the session  

---

### 4.7 Content DB & Session Generation (migration)

*Requirements:* PRD §5, §4.2, §4.3, EPIC: Content database & session generation, APP-Feature Description/missing migration from OLD-APP (V.1)/Content Database/, PRD/03-DATA-MODELS.swift.

#### Scenario 1: Keyword database
**Given** the Symptom Finder is used  
**Then** keyword matching uses the full keyword database (e.g. German, 2,655 lines equivalent)  
**And** all categories (sleep, stress, depression, healing, dream, obe, trauma, meditation, belief, angry, problem, SOS) are supported  

#### Scenario 2: Content database coverage
**Given** session generation runs  
**Then** text content (62+ items), music (8 genres), nature (18+), sound effects, and frequency/noise options are available as per PRD  
**And** generated sessions use valid content IDs and structure  

#### Scenario 3: Session structure validation
**Given** a session is generated  
**Then** it conforms to the Session and Phase data models  
**And** duration, phases, and per-phase content are consistent  

---

### 4.8 Notifications

*Requirements:* EPIC: Notifications, APP-Feature Description/Notifications/.

#### Scenario 1: Push permission and display (when implemented)
**Given** the app supports push notifications  
**When** the user is prompted for permission  
**Then** the system permission dialog is shown  
**And** the user can allow or deny  
**When** a notification is sent  
**Then** it is displayed according to system and app settings  

#### Scenario 2: Notification preferences (when implemented)
**Given** the user is in Settings or Profile  
**Then** they can open notification preferences  
**And** they can enable/disable categories (e.g. reminders, offers) as designed  

---

### 4.9 Offline Queue & Full Offline

*Requirements:* EPIC: Offline support (queue), APP-Feature Description/Offline Support/.

#### Scenario 1: Queue when offline (when implemented)
**Given** the device is offline  
**When** the user performs an action that requires network (e.g. sync favorite)  
**Then** the action is queued  
**And** the user receives feedback that it will sync when online  

#### Scenario 2: Sync when online (when implemented)
**Given** there are queued actions  
**When** the device comes online  
**Then** the queue is processed automatically  
**And** success/failure is handled and the queue is updated  
**And** retries and max retries behave as specified  

#### Scenario 3: Cache limit and statistics (when implemented)
**Given** the app has a maximum cache size (e.g. 2 GB)  
**When** the limit is reached  
**Then** old or least-used items are evicted (or the user is prompted)  
**And** cache statistics (size, file count) are available where designed  

---

## 5. Smoke, Critical User Journey (CUJ), and Regression

### 5.1 Smoke Tests

**Objective:** Verify the app launches and core navigation works without crash.

| ID | Description | Automated? |
|----|-------------|------------|
| SMOKE-01 | App launches and shows preloader or main UI | No (no UITest target) |
| SMOKE-02 | After preloader, user reaches Onboarding or Main Tabs | No |
| SMOKE-03 | All main tabs (Home, Explore, Library, Search, Profile) are tappable and load | No |
| SMOKE-04 | No crash on opening each tab | No |

**Recommendation:** There is currently **no `AWAVEUITests` target**. Add an `AWAVEUITests` target and implement at least one smoke test: launch app, wait for preloader/main UI, then verify that all main tabs are reachable and tappable without crash.

---

### 5.2 Critical User Journeys (CUJ)

| ID | Journey | Priority | Description | Spec ref |
|----|---------|----------|-------------|----------|
| CUJ-01 | Onboarding flow | High | New user completes preloader → onboarding → category selection → Main Tabs | F01, F02, §3.2 |
| CUJ-02 | Session generation | Critical | User selects topic/category → session generated → session config → start playback | F04, F07, F09 |
| CUJ-03 | Audio playback | Critical | Play → timer/progress → Pause → Resume → Exit (or Restart) | F09 |
| CUJ-04 | Subscription | High | Paywall for locked content; Restore purchases visible and functional | F14 |
| CUJ-05 | Search → session (no SOS) | High | Search drawer → enter text → topic match → session → play | F05, F07, F09 |
| CUJ-06 | Search → SOS | High | Search drawer → enter SOS keyword → SOS screen → call/chat/dismiss | F05, F06 |
| CUJ-07 | Favorites add/remove | Medium | From player or list: add favorite; from list: remove favorite; list updates | F11 |
| CUJ-08 | Category → 5 sessions → Neue Session generieren | Critical | Category screen shows ≥5 sessions; tap "Neue Session generieren" → new session appears | F04, §3.4 |

---

### 5.3 Regression Checklist (App-Wide)

High-level checklist by feature area. Each line should be validated (manual or automated) before release.

| Area | Checklist items |
|------|------------------|
| F01, F02 | Preloader shows ~3 s; routing to Onboarding vs Main correct; no black screen |
| F03 | All tabs visible and switchable; initial tab from onboarding |
| F04 | Category screens (Schlaf, Stress, Im Fluss); ≥5 sessions; "Neue Session generieren"; navigation to config |
| F05 | Symptom Finder input; keyword match; topic → session; no match → dialog |
| F06 | SOS keywords trigger SOS screen; call/chat; dismiss clears state |
| F07 | Session overview; voice/frequency; Start/Regenerate; Back |
| F08 | Soundscapes categories; detail grid; tap → session/player |
| F09 | Play/Pause; timer; progress; per-track controls; Exit/Restart; mini player if present |
| F10 | After Session message (complete/abort); Save to Favorites; Exit/Edit/Export |
| F11 | Favorites list; add/remove; empty state; load session |
| F12 | (When implemented) New session; phase add/delete/reorder; Phase Editor; preview; import/export |
| F13 | Profile; Support; Legal; Version → Upgrade/Pro |
| F14 | Plans; Subscribe; Restore; paywall for locked content |
| F16 | Confirm/Cancel dialogs; text input (e.g. session name); error dialogs |
| Auth | Sign in with Apple success/failure/cancel |
| Library | Favorites, All Mixes, History; navigation to detail |
| Session Tracking | Start/update/complete (if implemented) |
| Offline/Downloads | Download on play; cache use; offline indicator (if implemented) |

---

## 6. Gap Analysis & Recommendations

### 6.1 Gap Table (Requirements vs. Implementation & Test)

| Requirement | Implemented? | Test type (current) | Risk |
|-------------|--------------|---------------------|------|
| F01, F02 Splash & content check | Y | None | High |
| F03 Main Menu & navigation | Y | None | High |
| F04 Meditation Topics / Category Screens | Y | Unit (partial) | Medium |
| F05 Symptom Finder | Y | None | High |
| F06 SOS Screen | Y | None | Medium |
| F07 User Session Config | Y | None | High |
| F08 Soundscapes Browser | Y | None | Medium |
| F09 Live Player | Y | None | Critical |
| F10 After Session | Y | None | Medium |
| F11 Favorites | Y | None | Medium |
| F12 Session Editor (Pro) | N | None | Low (not shipped) |
| F13 Info Menu / Profile / Support / Legal | Y | None | Low |
| F14 Upgrade / Subscription | Y | None | High |
| F15 EEG | N (defer) | — | — |
| F16 Dialog system | Y | None | Low |
| Authentication | Y | Unit | Low |
| Session Tracking | Y | None | Medium |
| Offline / Downloads | Partial | None | Medium |
| Multi-track playback & fading | Y | Low (Unit) | High |
| Frequency synthesis (full) | Partial | Unit (packages) | Medium |
| Colored noise & NeuroFlow | N | None | Medium |
| Content DB & session generation | Y | Unit | Medium |
| User tiers & demo timer | Partial | None | High |
| File import/export | N | None | Low |
| Background/foreground & lifecycle | Partial | None | Medium |

### 6.2 Recommendations

1. **Enforce 80% coverage on new code:** New ViewModels and critical services (e.g. Category Screens, Player) must have unit tests.
2. **Mock data repositories:** Ensure `MockSessionRepository`, `MockFavoritesRepository`, and similar mocks are stable and used in UI tests so tests do not depend on live Firebase.
3. **CI integration:** Run the full test suite (unit + UI when added) on every PR via GitHub Actions or Xcode Cloud.
4. **Prioritize UI smoke and CUJs:** Add `AWAVEUITests` and implement smoke tests (launch + tabs) and at least CUJ-01, CUJ-02, CUJ-03 for implemented flows.
5. **When implementing Session Editor, Frequency/NeuroFlow, import/export:** Move the corresponding scenarios from Section 4 to Section 3, add unit/UI tests, and include them in the regression checklist and CI.
