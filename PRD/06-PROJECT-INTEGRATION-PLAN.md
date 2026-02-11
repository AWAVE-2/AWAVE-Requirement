# AWAVE – Project Integration Plan
## High-Level Overview Alongside PRD

**Purpose:** Single documented overview of all requirements, with Done vs Open ToDo Review and full traceability to PRD, Feature Specs, and APP-Feature Description (user stories).

**Related PRD docs:** [01-PRD](01-PRD.md) · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) · [03-DATA-MODELS](03-DATA-MODELS.swift) · [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) · [07-PRODUCTION-READY-OVERVIEW](07-PRODUCTION-READY-OVERVIEW.md)

---

## Document Index & Conventions

| Abbreviation | Document / Location |
|--------------|----------------------|
| **PRD** | [docs/Requirements/PRD/01-PRD.md](01-PRD.md) – Product Requirements Document |
| **FEATURE-SPECS** | [docs/Requirements/PRD/02-FEATURE-SPECS.md](02-FEATURE-SPECS.md) – Screen-by-screen specs (F01–F16) |
| **DATA-MODELS** | [docs/Requirements/PRD/03-DATA-MODELS.swift](03-DATA-MODELS.swift) – Swift data structures |
| **AUDIO-ARCH** | [docs/Requirements/PRD/04-AUDIO-ARCHITECTURE.md](04-AUDIO-ARCHITECTURE.md) – Audio engine design |
| **REQ-SUMMARY** | [docs/Requirements/PRD/05-REQUIREMENTS-SUMMARY.md](05-REQUIREMENTS-SUMMARY.md) – Scope, risks, phases, quality criteria |
| **PROD-READY** | [docs/Requirements/PRD/07-PRODUCTION-READY-OVERVIEW.md](07-PRODUCTION-READY-OVERVIEW.md) – Production ready checklist, parity check |
| **APP-Feature** | [docs/Requirements/APP-Feature Description/](../APP-Feature%20Description/) – Feature folders (requirements, user-flows, technical-spec, components, services) |

**Link convention:** Feature folders are referenced as `APP-Feature Description/<FeatureName>/`; user stories and requirements live in `requirements.md`, `user-flows.md`, and related files inside each folder.

---

## 1. Done (Completed / Baseline)

Items below are considered done for the purpose of this plan (e.g. documentation complete, or delivered and accepted). Update this section as work is completed.

### 1.1 Requirements & PRD Baseline

| Item | Description | Linked documents |
|------|-------------|-------------------|
| PRD baseline | Full product requirements for native iOS rewrite (Swift/SwiftUI, iOS 17+) | [01-PRD](01-PRD.md) |
| Feature specs | Screen-level specs F01–F16 for all main flows | [02-FEATURE-SPECS](02-FEATURE-SPECS.md) |
| Data models | Swift structs for session, phases, content | [03-DATA-MODELS](03-DATA-MODELS.swift) |
| Audio architecture | Audio engine design (multi-track, synthesis, noise) | [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) |
| Requirements summary | Scope, risks, ADRs, phases, quality criteria, content migration | [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) |

### 1.2 Feature Documentation Structure

| Item | Description | Linked documents |
|------|-------------|-------------------|
| APP-Feature index | Feature folder index and template | [APP-Feature Description/README.md](../APP-Feature%20Description/README.md) |
| Feature mapping | Code-to-feature mapping (screens, components, services, hooks) | [APP-Feature Description/FEATURE_MAPPING.md](../APP-Feature%20Description/FEATURE_MAPPING.md) |
| Structure summary | Feature folder list and doc structure per feature | [APP-Feature Description/STRUCTURE_SUMMARY.md](../APP-Feature%20Description/STRUCTURE_SUMMARY.md) |
| Requirements update summary | Alignment of requirements to Swift/Firebase stack | [REQUIREMENTS_UPDATE_SUMMARY.md](../REQUIREMENTS_UPDATE_SUMMARY.md) |

### 1.3 Delivered Features / Implementation

*Add rows here when a feature is implemented and accepted (e.g. “Splash & Content Loader – F01, F02 – Done”). Full parity check: [07-PRODUCTION-READY-OVERVIEW](07-PRODUCTION-READY-OVERVIEW.md).*

| Feature / EPIC | PRD / Spec ref | Feature folder | Status |
|----------------|----------------|----------------|--------|
| Splash & Preloader | F01, F02 | Start Screens | Done |
| Main Menu & Tab Navigation | F03 | Navigation | Done |
| Category Screens (Meditation) | F04 | Category Screens | Done |
| Symptom Finder / Search | F05 | Search Drawer | Partial |
| SOS Screen | F06 | SOS Screen | Done |
| User Session Config / Guided Session | F07 | Major Audioplayer | Done |
| Soundscapes / Klangwelten | F08 | Klangwelten | Done |
| Live Player | F09 | Major Audioplayer | Done |
| After Session | F10 | Major Audioplayer | Partial |
| Favorites / Custom Mixes | F11 | Favorite Functionality | Done |
| Session Editor (Pro) | F12 | Major Audioplayer | Open |
| Info Menu | F13 | Support, Legal | Partial |
| Upgrade / Subscription | F14 | Subscription & Payment | Done |
| EEG View | F15 | — | Deferred |
| Dialog System | F16 | Styles and UI | Partial |
| Authentication | — | Authentication | Done |
| Onboarding, Profile, Library, Offline, Stats | — | Various | Done |
| 3-track playback | §7.1 | Major Audioplayer | Done |
| Frequency synthesis, Noise, Multi-phase | §7.3–7.4, §6 | Audio Architecture | Open |
| Demo timer, .awave import/export, Pro SHA256 | §2, §10.3 | Various | Open |
| Real user ID (no local-user), Sleep timer, Seeking | — | Cross-cutting | Open |
| Schlafscreen Hero → Full-Player, Session min. 3 Phasen, Content-ID-Schema & Mapping-Fallback | Session Generation, Major Audioplayer | Session Generation, Major Audioplayer | Done |

**Regression nach Session-/Vollsession-Umsetzung:** Session-Generierung und Playback, Lock Screen und Dynamic Island manuell prüfen (Checkliste: [docs/learn/PLAY_TESTS_LOCKSCREEN_DYNAMIC_ISLAND.md](../../learn/PLAY_TESTS_LOCKSCREEN_DYNAMIC_ISLAND.md)); kein Dispatch-/Main-Thread-Crash.

---

## 2. Open ToDo Review (EPICs)

All open work is listed as **EPICs**. Each EPIC points to the PRD section, the relevant Feature Spec(s), and the **APP-Feature Description** folder where **user stories and detailed requirements** live (`requirements.md`, `user-flows.md`, `technical-spec.md`, etc.).

### 2.1 Foundation & Entry

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: Splash & content check** | Splash sequence, demo timer init, content availability check, transition to Main Menu or Content Loader | PRD §3.1 Screen Map | F01 Splash, F02 Content Loader | [Start Screens/](../APP-Feature%20Description/Start%20Screens/), [Index & Landing/](../APP-Feature%20Description/Index%20%26%20Landing/) |
| **EPIC: Main Menu & navigation** | App logo, menu bar (Demo/User/Pro), Meditation / Soundscapes / Favorites / Info, background theme | PRD §3.1, §3.2 | F03 Main Menu | [Navigation/](../APP-Feature%20Description/Navigation/), [Index & Landing/](../APP-Feature%20Description/Index%20%26%20Landing/) |

**Linked docs per EPIC:**

- **Splash & content check:**  
  [PRD 01](01-PRD.md) §3.1 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F01, F02 · [Start Screens/README, requirements, user-flows](../APP-Feature%20Description/Start%20Screens/) · [Index & Landing/README, requirements, user-flows](../APP-Feature%20Description/Index%20%26%20Landing/)
- **Main Menu & navigation:**  
  [PRD 01](01-PRD.md) §3 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F03 · [Navigation/README, requirements, technical-spec, user-flows, components, services](../APP-Feature%20Description/Navigation/) · [Index & Landing/](../APP-Feature%20Description/Index%20%26%20Landing/)

---

### 2.2 Meditation Flow & Session Generation

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: Meditation Topics** | Topic grid (10 topics), topic selection, session generation, loading overlay, navigate to User Session Config | PRD §4.1, §4.2 | F04 Meditation Topics | [Category Screens/](../APP-Feature%20Description/Category%20Screens/) |
| **EPIC: Symptom Finder** | Text input, keyword matching (generator-keywords), topic match, session generation; SOS detection; Pro unlock (SHA256) | PRD §4.3 | F05 Symptom Finder | [Seach Drawer/](../APP-Feature%20Description/Seach%20Drawer/) |
| **EPIC: SOS Screen** | Full-screen emergency/crisis resources, no menu, back/confirm, clear input on dismiss | PRD §4.3 | F06 SOS Screen | [SOS Screen/](../APP-Feature%20Description/SOS%20Screen/) |
| **EPIC: User Session Config** | Session overview, voice selector & preview, frequency toggle, Start/Regenerate/Edit (Pro), back to Meditation Topics | PRD §6, §7.5 | F07 User Session Config | [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) |

**Linked docs per EPIC:**

- **Meditation Topics:**  
  [PRD 01](01-PRD.md) §4 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F04 · [Category Screens/README, requirements, technical-spec, user-flows, components, services](../APP-Feature%20Description/Category%20Screens/)
- **Symptom Finder:**  
  [PRD 01](01-PRD.md) §4.3 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F05 · [Seach Drawer/README, requirements, technical-spec, user-flows, components, services](../APP-Feature%20Description/Seach%20Drawer/)
- **SOS Screen:**  
  [PRD 01](01-PRD.md) §4.3 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F06 · [SOS Screen/README, requirements, technical-spec, user-flows, components, services](../APP-Feature%20Description/SOS%20Screen/)
- **User Session Config:**  
  [PRD 01](01-PRD.md) §6, §7 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F07 · [Major Audioplayer/README, requirements](../APP-Feature%20Description/Major%20Audioplayer/) · [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md)

---

### 2.3 Soundscapes & Live Playback

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: Soundscapes Browser** | Back to Main Menu; 4 categories (Music, Nature, Frequency, Noise); detail grids; tap item → soundscape session → Live Player | PRD §5, §3.1 | F08 Soundscapes Browser | [Klangwelten/](../APP-Feature%20Description/Klangwelten/) |
| **EPIC: Live Player** | Live header, progress, timer, play/pause, per-track controls (name, volume), live content swap overlay, exit/restart/EEG footer | PRD §7, §10 | F09 Live Player | [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/), [MiniPlayer Strip/](../APP-Feature%20Description/MiniPlayer%20Strip/) |
| **EPIC: After Session** | Completion/abort message, save to favorites prompt, Save / Exit / Edit (Pro) / Export (Pro) | PRD §3.1 | F10 After Session | [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) |

**Linked docs per EPIC:**

- **Soundscapes Browser:**  
  [PRD 01](01-PRD.md) §5, §3.1 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F08 · [Klangwelten/README, requirements, technical-spec, user-flows, components, services](../APP-Feature%20Description/Klangwelten/)
- **Live Player:**  
  [PRD 01](01-PRD.md) §7, §10 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F09 · [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) · [MiniPlayer Strip/](../APP-Feature%20Description/MiniPlayer%20Strip/)
- **After Session:**  
  [PRD 01](01-PRD.md) §3.1 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F10 · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) · [Favorite Functionality/](../APP-Feature%20Description/Favorite%20Functionality/)

---

### 2.4 Favorites & Session Editor (Pro)

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: Favorites** | List (newest first), load/delete, empty state, Import, Delete All; save flow (name, duplicate handling, deep copy, topic reset) | PRD §9 | F11 Favorites | [Favorite Functionality/](../APP-Feature%20Description/Favorite%20Functionality/) |
| **EPIC: Session Editor (Pro)** | New Session, Session Overview (phase list, add/delete/reorder), Phase Editor (6 sections: Text, Music, Nature, Frequency, Noise, Sound), timer, preview, import/export | PRD §8 | F12a–F12c Session Editor | [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) |

**Linked docs per EPIC:**

- **Favorites:**  
  [PRD 01](01-PRD.md) §9 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F11 · [Favorite Functionality/README, requirements, technical-spec, user-flows, components, services](../APP-Feature%20Description/Favorite%20Functionality/)
- **Session Editor (Pro):**  
  [PRD 01](01-PRD.md) §8 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F12 · [Major Audioplayer/README, requirements](../APP-Feature%20Description/Major%20Audioplayer/) · [03-DATA-MODELS](03-DATA-MODELS.swift)

---

### 2.5 Info, Legal, Support & Monetization

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: Info Menu** | Vorbereitung, Brainwave, AGB, Datenschutz, Impressum, Haftungsausschluss, Support, Version → Upgrade or Pro panel | PRD §3.1 | F13 Info Menu | [Support/](../APP-Feature%20Description/Support/), [Legal & Privacy/](../APP-Feature%20Description/Legal%20%26%20Privacy/) |
| **EPIC: Upgrade / Subscription** | Demo→User: plan toggle, Subscribe, Restore; User: current plan, purchase date, pricing; StoreKit 2 | PRD §2, §10.4 | F14 Upgrade / Subscription View | [Subscription & Payment/](../APP-Feature%20Description/Subscription%20%26%20Payment/), [SalesScreens/](../APP-Feature%20Description/SalesScreens/) |
| **EPIC: Dialog system** | Modal confirm/cancel, optional text input; used for confirmations, errors, session naming | — | F16 Dialog System | [Styles and UI/](../APP-Feature%20Description/Styles%20and%20UI/) |

**Linked docs per EPIC:**

- **Info Menu:**  
  [PRD 01](01-PRD.md) §3.1 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F13 · [Support/](../APP-Feature%20Description/Support/) · [Legal & Privacy/](../APP-Feature%20Description/Legal%20%26%20Privacy/)
- **Upgrade / Subscription:**  
  [PRD 01](01-PRD.md) §2, §10.4 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F14 · [Subscription & Payment/](../APP-Feature%20Description/Subscription%20%26%20Payment/) · [SalesScreens/](../APP-Feature%20Description/SalesScreens/)
- **Dialog system:**  
  [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F16 · [Styles and UI/README, requirements](../APP-Feature%20Description/Styles%20and%20UI/)

---

### 2.6 Audio Engine & Content

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: Multi-track playback & fading** | 5 tracks (Text, Music, Nature, Sound, Demo), per-track volume, fade-in/out, cross-phase continuity | PRD §7.1, §7.2 | F09 (Live Player) | [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) |
| **EPIC: Frequency synthesis** | 12 modes (root, binaural, monaural, isochronic, bilateral, molateral, shepard, isoflow, bilawave, binawave, monawave, flowlateral); pulse/root params, Shepard width | PRD §7.3 | — | [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) · [missing migration from OLD-APP (V.1)/Frequency Generation System/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/Frequency%20Generation%20System/) |
| **EPIC: Colored noise & NeuroFlow** | 6 colors + 6 NeuroFlow (notch filter chain, L/R balance sweep) | PRD §7.4 | — | [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) |
| **EPIC: Content database & session generation** | JSON content DB, session generation from topic, keyword matching, 62+ text, 8 music, 18+ nature, sound effects, keywords DB | PRD §5, §4.2, §4.3 | F04, F05 | [missing migration from OLD-APP (V.1)/Content Database/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/Content%20Database/) · [03-DATA-MODELS](03-DATA-MODELS.swift) |

**Linked docs per EPIC:**

- **Multi-track playback & fading:**  
  [PRD 01](01-PRD.md) §7 · [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/) · [Major Audioplayer/Session and Wave Generation_Requirements.md](../APP-Feature%20Description/Major%20Audioplayer/Session%20and%20Wave%20Generation_Requirements.md)
- **Frequency synthesis:**  
  [PRD 01](01-PRD.md) §7.3 · [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [missing migration from OLD-APP (V.1)/Frequency Generation System/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/Frequency%20Generation%20System/)
- **Colored noise & NeuroFlow:**  
  [PRD 01](01-PRD.md) §7.4 · [04-AUDIO-ARCHITECTURE](04-AUDIO-ARCHITECTURE.md) · [Major Audioplayer/](../APP-Feature%20Description/Major%20Audioplayer/)
- **Content database & session generation:**  
  [PRD 01](01-PRD.md) §5, §4 · [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) §5 Content Migration · [missing migration from OLD-APP (V.1)/Content Database/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/Content%20Database/) · [03-DATA-MODELS](03-DATA-MODELS.swift)

---

### 2.7 Platform, Persistence & Cross-Cutting

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: User tiers & demo timer** | Demo (10 min timer), User (subscription), Pro (password); persistence (user, currentSubscription, purchaseDate) | PRD §2 | F03, F14 | [Subscription & Payment/](../APP-Feature%20Description/Subscription%20%26%20Payment/) |
| **EPIC: File import/export** | .awave Base64 JSON import; export/share via share sheet; version check | PRD §10.3 | F11, F12 | [Favorite Functionality/](../APP-Feature%20Description/Favorite%20Functionality/) · [missing migration from OLD-APP (V.1)/Session Import Export/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/Session%20Import%20Export/) |
| **EPIC: Background/foreground & lifecycle** | Pause on background, “Session Pausiert” on resume; keep-awake; portrait lock; charging recommendation | PRD §10.1, §10.2 | F09 | [Background Audio/](../APP-Feature%20Description/Background%20Audio/) |
| **EPIC: EEG view (optional)** | Placeholder/future Muse EEG; evaluate for iOS rewrite | — | F15 | (Defer; no dedicated feature folder) |

**Linked docs per EPIC:**

- **User tiers & demo timer:**  
  [PRD 01](01-PRD.md) §2 · [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F03, F14 · [Subscription & Payment/](../APP-Feature%20Description/Subscription%20%26%20Payment/)
- **File import/export:**  
  [PRD 01](01-PRD.md) §10.3 · [missing migration from OLD-APP (V.1)/Session Import Export/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/Session%20Import%20Export/) · [Favorite Functionality/](../APP-Feature%20Description/Favorite%20Functionality/)
- **Background/foreground & lifecycle:**  
  [PRD 01](01-PRD.md) §10 · [Background Audio/](../APP-Feature%20Description/Background%20Audio/)
- **EEG view:**  
  [02-FEATURE-SPECS](02-FEATURE-SPECS.md) F15 (evaluate/defer)

---

### 2.8 Migration & Legacy Parity

| EPIC | Description | PRD ref | Feature Spec | Feature folder (user stories) |
|------|-------------|---------|--------------|-------------------------------|
| **EPIC: OLD-APP (V.1) migration** | Content DB, frequency generation, multi-phase sessions, preset sounds, session import/export | PRD §5, §6, §7 | Multiple | [missing migration from OLD-APP (V.1)/](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/) (README, Content Database, Frequency Generation System, Multi-Phase Session System, Preset Sounds Library, Session Import Export) |
| **EPIC: React APP parity (optional)** | Category tile selector and other web parity items | — | — | [missing migration from React APP (Lovalbe)/](../APP-Feature%20Description/missing%20migration%20from%20React%20APP%20(Lovalbe)/) |

**Linked docs per EPIC:**

- **OLD-APP (V.1) migration:**  
  [PRD 01](01-PRD.md) §5, §6, §7 · [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) §5 Content Migration · [missing migration from OLD-APP (V.1)/README](../APP-Feature%20Description/missing%20migration%20from%20OLD-APP%20(V.1)/README.md) and subfolders
- **React APP parity:**  
  [missing migration from React APP (Lovalbe)/README](../APP-Feature%20Description/missing%20migration%20from%20React%20APP%20(Lovalbe)/README.md) · [Category Tile Selector/](../APP-Feature%20Description/missing%20migration%20from%20React%20APP%20(Lovalbe)/Category%20Tile%20Selector/)

---

### 2.9 Supporting Features (from APP-Feature Description)

These EPICs are defined in the feature folders and support the main PRD flows; link to user stories in the given folders.

| EPIC | Description | Feature folder (user stories) |
|------|-------------|-------------------------------|
| **EPIC: Authentication** | Sign in/up, email verification, password reset, OAuth (Apple), session management | [Authentication/](../APP-Feature%20Description/Authentication/) |
| **EPIC: User Onboarding** | First-time flow, onboarding screens | [User Onboarding Screens/](../APP-Feature%20Description/User%20Onboarding%20Screens/) |
| **EPIC: Profile & Settings** | Profile view, account/privacy/notification settings | [Profile View/](../APP-Feature%20Description/Profile%20View/), [Settings/](../APP-Feature%20Description/Settings/) |
| **EPIC: Library** | User audio library, saved/custom sounds, playlists | [Library/](../APP-Feature%20Description/Library/) |
| **EPIC: Session tracking & analytics** | Session recording, stats, phases, activity | [Session Tracking/](../APP-Feature%20Description/Session%20Tracking/), [Stats & Analytics/](../APP-Feature%20Description/Stats%20%26%20Analytics/) |
| **EPIC: Notifications** | Push notifications, preferences | [Notifications/](../APP-Feature%20Description/Notifications/) |
| **EPIC: Offline support** | Offline mode, cached content, background downloads | [Offline Support/](../APP-Feature%20Description/Offline%20Support/) |
| **EPIC: Session-based async download** | Async download of audio files for sessions | [Session Based Asynch Download of Audiofiles/](../APP-Feature%20Description/Session%20Based%20Asynch%20Download%20of%20Audiofiles/) |
| **EPIC: Visual effects** | Animations, transitions, UI polish | [Visual Effects/](../APP-Feature%20Description/Visual%20Effects/) |
| **EPIC: APIs & business logic** | Backend/API integration, error handling | [APIs and Business Logic/](../APP-Feature%20Description/APIs%20and%20Business%20Logic/), [Databases/](../APP-Feature%20Description/Databases/) |

---

## 3. Quality Criteria (from REQ-SUMMARY)

The checklist in [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) §6 (Functional Parity, Audio Quality, Performance) applies to the EPICs above. Use it for Done/Open review:

- **Functional parity:** [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) §6 – All 25+ screens, session generation, SOS, frequency/noise types, voices, editor, favorites, demo timer, subscriptions, .awave import/export.
- **Audio quality:** No clicks/pops, binaural/Shepard/NeuroFlow behavior, smooth fading, cross-phase continuity.
- **Performance:** Launch & session start time, long-session stability, battery, memory.

---

## 4. Implementation Phases (from REQ-SUMMARY)

For sequencing, see [05-REQUIREMENTS-SUMMARY](05-REQUIREMENTS-SUMMARY.md) §4:

1. **Phase 1: Foundation** – Project setup, data models, content DB, navigation skeleton, user tier, UI theme  
2. **Phase 2: Core Audio** – AVAudioEngine, file playback, volume/fading, phase timer, basic live player UI  
3. **Phase 3: Content & Navigation** – Topics, symptom finder, SOS, soundscapes, session config, favorites  
4. **Phase 4: Frequency Synthesis** – Root, binaural, monaural, isochronic, bilateral, molateral, sweep  
5. **Phase 5: Advanced Audio** – Shepard, variants, colored noise, NeuroFlow, cross-phase, live content swap  
6. **Phase 6: Session Editor (Pro)** – Phase list, Text/Music/Nature/Frequency/Noise/Sound editors, preview  
7. **Phase 7: Monetization & Polish** – StoreKit 2, demo timer, restore, subscription UI, lifecycle, accessibility, testing  

---

## 5. Maintenance

- **Done:** Move EPICs (or sub-items) from §2 to §1.3 when implemented and accepted.
- **Open:** Add new EPICs under §2 and link PRD, Feature Specs, and APP-Feature folder.
- **Links:** Keep paths relative to `docs/Requirements/`; all links are from `docs/Requirements/PRD/` (this file’s location).

---

*Document version: 1.1 · Single overview alongside [PRD](01-PRD.md), [Requirements Summary](05-REQUIREMENTS-SUMMARY.md), and [Production Ready Overview](07-PRODUCTION-READY-OVERVIEW.md).*
