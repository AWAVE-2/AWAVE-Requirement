# Guided Session Favorites — Structured Requirements (Major Audioplayer)

**Feature:** Save and replay generated guided sessions as favorites on Home and Category screens.  
**Scope:** Major Audioplayer (session generator) only; implemented as a singular component separate from Klangwelten.  
**References:** `Session and Wave Generation_Requirements.md`, `docs/homescreen/home-screen-regactoring.md`, `docs/FAVORITES-SAVE-MAJOR-AUDIOPLAYER-ANALYSIS-AND-PROPOSAL.md`

---

## 1. Goal

Users can **save a generated guided session** (from the Major Audioplayer / session generator) as a **favorite** and access it from:

- **A) Home screen** — quick access to saved sessions (no mock tiles; real data).
- **B) Related category screen** — favorites appear in the category detail screen (e.g. Schlaf, Ruhe, Im Fluss).

When the user taps a favorite tile (Home or Category), the **saved session and its mixer state** load into the session player and **override** any current session so the user can continue exactly where they left off (same sounds, same volumes). Favorites are stored in **Firebase and locally** so they can be **played and downloaded for offline use**.

---

## 2. User Stories

### 2.1 Saving a Session

- **As a user**, after I have generated a session and optionally adjusted the mixer (volumes, active slots), **I want to save it as a favorite** (e.g. via heart / Favoriten in the full player) **so that** I can find and replay it later from Home or the category screen.
- **As a user**, when I save a session as favorite, **I expect** the **mixer state** (selected sounds per slot, volume per slot, active/inactive) and the **session definition** (phases, content IDs, voice, topic) to be stored **in Firebase and locally**, so that I can play it offline after it has been downloaded.

### 2.2 Home Screen

- **As a user**, **I want to see my real favorites** on the Home screen (for my selected category and, where applicable, other categories) **so that** I do not see mock or placeholder tiles.
- **As a user**, **I want to tap a favorite session tile** on the Home screen **so that** that session (and its mixer state) loads into the session player and **replaces** any current session, and I can start playback immediately (“lift off” with the stored sounds).

### 2.3 Category Screen

- **As a user**, **I want to see my saved session favorites** on the respective category detail screen (e.g. Schlaf, Ruhe, Im Fluss) **so that** I can start a saved session from the same place I created it.
- **As a user**, **I want to tap a favorite session** on the category screen **so that** the same behavior as on Home applies: session + mixer load and override the current player state.

### 2.4 Offline and Download

- **As a user**, **I want to play my favorite sessions offline** (e.g. airplane mode) **so that** I can use the app without network when I have previously downloaded the content.
- **As a user**, **I want the app to download the session’s audio content** when I save a favorite (or make download available from the tile) **so that** the session is ready for offline playback.

---

## 3. Functional Requirements

### 3.1 Favorite Storage (Guided Sessions Only)

| ID   | Requirement | Status |
|------|-------------|--------|
| F-01 | When the user saves a guided session as favorite, the **session** (id, name, phases, voice, topic, duration, etc.) is stored in Firebase (e.g. `users/{userId}/categorySessions/{category}/sessions`) and in local cache. | Partial (session stored; mixer state not) |
| F-02 | When the user saves a guided session as favorite, the **mixer state** (per-slot: sound/content assignment, volume, active/inactive) is stored together with the session in Firebase and locally. | Not implemented |
| F-03 | A **favorite reference** (e.g. `FavoriteSession` with `itemType: .session`, `itemId: session.id`) is stored so that Home and Category screens can list favorites and resolve to full session + mixer data. | Implemented |
| F-04 | Guided-session favorites are handled by a **dedicated component** (service/manager/repository layer) that does **not** share logic with Klangwelten save/load flows; only storage (e.g. Firestore collections, `FavoriteSession` itemType) may be shared. | To be clarified in implementation |

### 3.2 Home Screen

| ID   | Requirement | Status |
|------|-------------|--------|
| F-05 | The Home screen shows **real favorites** for the user’s selected category (sessions + mixes). No mock “Favorit 1” / “Favorit 2” placeholders for other categories unless they have real data. | Partial (display category has real data; other category sections are mock) |
| F-06 | Tapping a **session** favorite tile on Home opens the full player, loads that session and its mixer state into the session player, **overrides** any current session, and allows the user to start playback immediately. | Partial (session loads; mixer state not restored) |
| F-07 | Home uses the same single source of truth for favorites as the Category screens (Firebase + local cache). | Implemented (shared repositories) |

### 3.3 Category Detail Screen

| ID   | Requirement | Status |
|------|-------------|--------|
| F-08 | The category detail screen (e.g. SchlafScreen, RuheScreen, ImFlussScreen) shows **saved session favorites** for that category (already implemented conceptually; ensure consistency with Home). | Implemented |
| F-09 | Tapping a session favorite on the category screen loads that session and its mixer state into the session player and overrides the current session (same as Home). | Partial (session loads; mixer state not restored) |

### 3.4 Offline and Download

| ID   | Requirement | Status |
|------|-------------|--------|
| F-10 | Favorite list (session references and, where used, session + mixer payload) is available from **local cache** when offline so that the user can see their favorites and attempt playback. | Partial (local cache for sessions per category; mixer state not in cache) |
| F-11 | When the user saves a session as favorite, the **audio files** required for that session (e.g. phase content IDs resolved to sounds) can be **downloaded** so that the session is playable offline. | To be defined (download on save vs. on-demand) |
| F-12 | When the user taps a favorite and one or more required audio files are not available locally, the app shows a clear message (e.g. “Connect to download this session for offline use”) and does not start playback with missing content. | Partially (offline error messaging exists; behavior to align with F-11) |

---

## 4. Non-Functional Requirements

### 4.1 Component Boundaries

- **Guided Session Favorites** is implemented as a **singular, well-bounded component** (or small set of components) so that:
  - It can be maintained and extended by an external party without touching Klangwelten-specific code.
  - Klangwelten favorites (CustomMix, “Deine Klangwelten”) and Major Audioplayer session favorites do not interfere: shared storage (e.g. `FavoriteSession` with `itemType`) is acceptable; shared UI/UX flows and state machines should be avoided where they would couple the two features.

### 4.2 Maintainability

- Code is structured in **small, testable components** (e.g. repository, local storage, use-case or view model) with clear responsibilities.
- Dependencies are explicit (e.g. protocol-based) so that tests can use mocks and the feature can be reasoned about in isolation.

### 4.3 Testability

- Unit tests cover: saving a session (with mixer state), loading a session (with mixer state), resolving favorites for Home and Category, offline fallback (local cache), and error handling.
- UI or integration tests cover: tap favorite on Home → session + mixer load and override; tap favorite on Category → same behavior; offline list and offline playback when content is present.

---

## 5. Out of Scope (Explicit)

- **Klangwelten** tap-tile restart, offline mix list, and download-on-save are specified in `docs/Requirements/APP-Feature Description/Klangwelten/requirements.md` and `draft/PROPOSAL-KLANGWELTEN-TAP-TILE-RESTART-SESSION-AND-OFFLINE.md`; they are not part of this document.
- Changes to **session generation algorithm** (e.g. stage pools, exclusion) are covered in session-generation docs, not here.
- **Sound-only** favorites (single sound, not session) remain in the existing Favorites/Sound flow.

---

## 6. Acceptance Criteria (Summary)

- [ ] User can save a generated guided session as favorite from the full player (heart / Favoriten).
- [ ] Saved session includes **session definition** and **mixer state** (slots, volumes, active/inactive); both stored in Firebase and locally.
- [ ] Home screen shows **real** favorites for the selected category; **mock tiles** for other categories are replaced by real data when available (or omitted when no favorites).
- [ ] Category detail screen shows the same session favorites for that category.
- [ ] Tapping a **session** favorite tile (Home or Category) loads that session and its mixer state into the session player and **overrides** the current session; user can start playback immediately.
- [ ] Favorites and session + mixer data are available from **local cache** when offline; playback is possible when required audio files are present locally.
- [ ] Guided-session favorites are implemented in a **dedicated, maintainable component** that does not interfere with Klangwelten favorites.
- [ ] **Test scenarios** exist for save, load, Home/Category list, tap-to-load, and offline behavior.

---

*Implementation proposal: `draft/PROPOSAL-MAJOR-AUDIOPLAYER-FAVORITES-HOME-CATEGORY-MIXER-OFFLINE.md`*
