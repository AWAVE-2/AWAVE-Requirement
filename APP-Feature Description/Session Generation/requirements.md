# Session Generation – Functional Requirements (iOS / Swift)

**Scope:** Topic-based and category-based session generation in the AWAVE iOS app.  
**Status:** Implemented in Swift; some features (e.g. sound generation via search) known not working (see PRD 07/08).  
**Last updated:** 2026-02-16  

---

## 1. Core Session Generation (App-Level)

### 1.1 Topic-Based Generation (`SessionGenerator`)

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| Generate multi-phase session from a single topic | ✓ | `SessionGenerator.generate(topic:voice:...)` |
| Support 11 session topics | ✓ | `SessionTopic` enum: sleep, dream, obe, stress, healing, angry, sad, depression, trauma, belief, meditation |
| Stage sequences per topic | ✓ | `SessionTopic.stages` (e.g. sleep: intro, body, thinkstop, breath, hypnosis, fantasy, introAff, affirmation, silence) |
| SAD topic: two paths (Comfort vs Guided) | ✓ | 44% comfort path, else guided; stages differ |
| Optional journey (fantasy) | ✓ | `FantasyJourneyManager.Journey`; used for fantasy stages and naming |
| Music genre per topic / pool | ✓ | `SessionTopic.musicGenre(using:)`, `musicGenrePool` |
| Voice selection (Franca, Flo, Marion, Corinna) | ✓ | `Voice` enum; passed into `SessionGenerator.generate` |
| Variable phase duration by topic/stage | ✓ | `SessionTopic.durationRange(forStage:)` |
| Frequency config per stage (optional) | ✓ | `resolveFrequencyConfig`, `enableFrequency` in generate |
| Minimum 3 phases per session | ✓ | Fallback loop in `SessionGenerator.generate` |
| Session naming (non-fantasy vs fantasy) | ✓ | `SessionNameGenerator.generateName` / `generateFantasyName` |
| Content IDs for text, music, nature, sound, noise | ✓ | Schema in base-documentation.md; `SessionContentResolver` |

### 1.2 Category-Based Generation (`CategorySessionGenerator`)

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| Map onboarding category to session topic | ✓ | sleep→sleep, calm→stress, flow→meditation |
| Generate 5 varied sessions per category | ✓ | `CategorySessionGenerator.generateSessions(for: category)` |
| Distinct journey and music genre per slot | ✓ | Shuffled journeys/genres, one per slot |
| Optional user preferences (voice, duration scale, frequency on/off) | ✓ | `SessionGeneratorPreferences`; second overload of `generateSessions` |
| Duration scaling (e.g. 15–90 min) | ✓ | `preferences.durationScale(defaultMinutes:)`, applied to phase durations |

### 1.3 Session Generator UI (`SessionGeneratorView`)

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| Topic grid (all 11 topics) | ✓ | `SessionTopic.allCases` in grid |
| Voice picker | ✓ | `selectedVoice`, voice section |
| Primary action: "Session erstellen" | ✓ | Calls `SessionGenerator.generate`, then `player.loadSession` + `play` |
| Pre-selected topic from search/drawer | ✓ | `initialTopic` from coordinator |
| Loading overlay during generation | ✓ | `isGenerating` overlay |
| Cancel / dismiss | ✓ | Toolbar "Abbrechen" |

### 1.4 Category Screen Session Block (Category Sessions)

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| First-time / empty: CTA opens personalization drawer | ✓ | "Generiere deine erste Session" → drawer |
| Personalization drawer: length, voice, frequencies | ✓ | `CategorySessionPersonalizationDrawerView` |
| Primary action: "{Category}-Session generieren" | ✓ | Saves preferences, generates, replaces list |
| "Neue Sessions generieren" reopens drawer (pre-filled) | ✓ | Preferences from storage |
| Anonymous: local storage (UserDefaults) | ✓ | `LocalCategorySessionStorage` |
| Registered: Firestore sessions; preferences keyed by user | ✓ | CategorySessionsViewModel |

---

## 2. Content Resolution & Playback

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| Resolve content IDs to sounds (catalog + mapping) | ✓ | `SessionContentResolver.resolveSounds`; `SessionContentMapping.soundId(for:)` fallback |
| No category-based fallback for missing content | ✓ | Only catalog/mapping; see SESSION_GENERATION_AUDIO_LIBRARY_REFACTORING_REPORT.md |
| Display names in mixer (Sound.title) | ✓ | `SessionContentResolution.displayNames`, PhasePlayer |
| Pre-resolve URLs before playback | ✓ | `PlayerViewModel.preResolveSessionContentURLs` |
| Download missing audio via AudioDownloadService | ✓ | In pre-resolve loop |

---

## 3. Search → Session Flow

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| Search drawer: text input → topic match | ◐ | `SearchViewModel.evaluateForSession`; SymptomFinder; SOS handled |
| Topic match → generate session and play | ◐ | SearchDrawerView `submitForSession`; **currently not working** (known issue) |
| No topic match → open SessionGenerator with manual topic | ✓ | `coordinator.sessionGeneratorInitialTopic = nil`, `showSessionGenerator = true` |

---

## 4. Naming & Content IDs

| Requirement | Status | Reference |
|-------------|--------|------------|
| Naming logic (non-fantasy, fantasy, info text) | ✓ | AWAVE-Session-Naming-Logic.md, SessionNameGenerator |
| Content-ID schema (text, music, nature, sound, noise) | ✓ | base-documentation.md, Session-Content-IDs-Catalog.md |
| Session uniqueness / time update | ✓ | PLAN-Session-Uniqueness-And-Time-Update.md |

---

## 5. Session Preload (Optional)

| Requirement | Status | Implementation / Notes |
|-------------|--------|--------------------------|
| Preload sessions for category on first load | ◐ | SessionPreloadService exists; excluded from test scheme; behaviour per Category Screens requirements |
| Anonymous: no preload on first launch | ✓ | First-time shows "Generiere deine erste Session" |

---

## 6. References (Same Folder)

| Document | Purpose |
|----------|---------|
| [base-documentation.md](base-documentation.md) | Content-IDs, resolution order, mixer display |
| [SESSION_GENERATION_AUDIO_LIBRARY_REFACTORING_REPORT.md](SESSION_GENERATION_AUDIO_LIBRARY_REFACTORING_REPORT.md) | No category fallback, SessionContentResolver, displayNames |
| [Session-Content-IDs-Catalog.md](Session-Content-IDs-Catalog.md) | Catalog of content IDs |
| [AWAVE-Session-Naming-Logic.md](AWAVE-Session-Naming-Logic.md) | Naming rules and examples |
| [AWAVE-Session-Generation-Naming.md](AWAVE-Session-Generation-Naming.md) | Naming implementation details |
| [Session-Preload-System.md](Session-Preload-System.md) | Preload design |
| [PLAN-Session-Uniqueness-And-Time-Update.md](PLAN-Session-Uniqueness-And-Time-Update.md) | Uniqueness and time handling |

---

## 7. Related Feature Docs

| Feature | Document | Relevance |
|---------|----------|------------|
| Category Screens | [../Category Screens/requirements.md](../Category%20Screens/requirements.md) | Category block, personalization drawer, "Neue Sessions generieren" |
| Search Drawer | [../Seach Drawer/requirements.md](../Seach%20Drawer/requirements.md) | Search → topic → session (currently broken) |
| Major Audioplayer | [../Major Audioplayer/requirements.md](../Major%20Audioplayer/requirements.md) | Playback, PhasePlayer, mixer |
