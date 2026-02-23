# Proposal: Separate Klangwelten Favorites from Category Session Favorites

**Status:** Draft  
**Created:** 2026-02-23  
**Aligns with:** `docs/Requirements/APP-Feature Description/Favorite Functionality/`, PRD, source-of-truth

---

## 1. Problem

Favorites are currently mixed between two distinct features:

- **Klangwelten** – User creates a “Klangwelt” (3-slot ambient mix) in the Klangwelten flow and saves it. These saved Klangwelten are shown in the Klangwelten tab (“Deine Klangwelten”) and should **only** be used by the Klangwelten player and Klangwelten detail screen.
- **Category-based session favorites** – User generates a guided session (or saves a mix) from the **major audio player** (Schlaf, Ruhe, Im Fluss). These favorites drive **Home screen sections** and **category detail “Meine Favoriten” / “Favorisierte Sessions”** and open in the session/major player.

**Current mix-up:**

- When saving a Klangwelt, the app calls `favoriteSessionRepository.addFavoriteSession(..., category: ..., itemType: .customMix, itemId: mix.id)`. So Klangwelten mixes are stored in the **same** Firestore collection `users/{userId}/favoriteSessions` as category session favorites.
- Home and category detail screens load **all** `favoriteSessions` for each category (sessions + customMix items) and resolve mixes without filtering by origin. So **Klangwelten mixes appear on Home and on category detail** as if they were category session favorites.
- Conversely, category-session saved mixes (from the major player) could theoretically appear in Klangwelten if we ever showed “all mixes” there; today KlangweltenEntryView correctly filters by `playbackMode == .klangwelten`, but the **storage and semantics** are still shared.

**User-visible result:** Favorites saved in Klangwelten show up under category sections on Home and under “Favorisierte Sessions” on Schlaf/Ruhe/Im Fluss, and tapping them may open the wrong player or context. Category session favorites must not appear in Klangwelten, and Klangwelten favorites must not appear on Home or category detail.

---

## 2. Goal

- **Klangwelten favorites**  
  - Stored and displayed **only** in the Klangwelten context (Klangwelten tab / “Deine Klangwelten”, Klangwelten detail/player).  
  - Use **only** `users/{userId}/mixes` with `playbackMode: .klangwelten`. Do **not** add Klangwelten mixes to `favoriteSessions`.  
  - **Persist** the Klangwelten mix (3-slot sounds and volumes); when the user taps a saved Klangwelt, **restore** it in the **Klangwelten player** with the respective sounds so the user can **start** the Klangwelt.

- **Category session favorites**  
  - Stored in `users/{userId}/favoriteSessions` (sessions + customMix with **category/session** origin only).  
  - Displayed **only** on Home (per-category sections) and on category detail screens (Schlaf, Ruhe, Im Fluss) in “Meine Favoriten” / “Favorisierte Sessions”.  
  - **Persist** session and mixer state (or saved mix with tracks/volumes); when the user taps a category favorite, **restore** it in the **major audio player** with the respective sounds so the user can **start the session** (or mix).  
  - When resolving `customMix` items, **exclude** mixes whose `playbackMode == .klangwelten`.  
  - Never shown on the Klangwelten details/entry screen.

---

## 2.1 Category-based conditional views (Home and category detail)

Category session/mix favorites must be **stored and displayed per category** on both the Home screen and the category detail screen. This must work for **any** category the user chooses, not only the onboarding base category.

**Required behaviour:**

- When a user saves a session or mix as a favorite from a given category (e.g. **Im Fluss**), that favorite is stored in `favoriteSessions` with that category. It must then:
  1. **Appear on the Home screen** in a **dedicated section for that category** (e.g. an "Im Fluss" / Flow section with that favorite tile). The Home screen must show one section per category that has at least one favorite — including categories that are **not** the user's onboarding choice.
  2. **Appear on that category's detail screen** (e.g. Im Fluss screen) in "Meine Favoriten" / "Favorisierte Sessions", and tapping it must open the major audio player with that session/mix.

**Example:** User's onboarding category is **Schlaf** (Sleep). User navigates to **Im Fluss** (Flow), generates a flow session, and saves it as a favorite. That favorite must:
- Be stored as a favorite for the **Im Fluss** category (in `favoriteSessions` with `category: "flow"` or equivalent).
- Be displayed on the **Home screen** in a **new section** that belongs to the Flow category (e.g. "Im Fluss Session" or similar), not only under the Sleep section.
- Be displayed on the **Im Fluss category detail screen** in "Favorisierte Sessions" / "Meine Favoriten".

If at present favorites are not being displayed or stored correctly on the Home screen or category detail by category, the implementation must fix that so that:
- Favorites are stored with the correct category when saved from the major player.
- Home shows one section per category that has at least one favorite (display order may put the onboarding category first; other categories with favorites get their own sections).
- Each category detail screen shows only that category's favorites in "Meine Favoriten" / "Favorisierte Sessions".

---

## 2.2 Persist and restore: session mixer vs Klangwelten sounds

When saving and loading favorites, the app must **persist** the full state (session mixer or Klangwelten sounds) and **restore** it so that the **correct player** loads with the **respective sounds** and the user can **start the session** (or Klangwelt) immediately.

**Category session/mix favorites (major audio player):**

- **Persist:** When the user saves a session or mix as a favorite from the major audio player, store the **session** (and, where applicable, the **mixer state**: selected sounds per slot, volumes, active/inactive tracks) or the **saved mix** (CustomMix with tracks and volumes) so it can be fully restored.
- **Restore:** When the user taps a category favorite on Home or on a category detail screen, the **major audio player** must load that session or mix with its **mixer state / sounds**. The user can then **start the session** (or mix) with the same configuration — same sounds, same volumes — and continue exactly where they left off.

**Klangwelten favorites:**

- **Persist:** When the user saves a Klangwelt, store the **Klangwelten mix** (the 3-slot selection and volumes) in `users/{userId}/mixes` with `playbackMode: .klangwelten`. Optionally persist/cache sound metadata for offline (e.g. KlangweltenSoundMetadataCache).
- **Restore:** When the user taps a saved Klangwelt in "Deine Klangwelten", the **Klangwelten player** must load that mix and resolve the **respective sounds** (the three slot sounds). The user can then **start** the Klangwelt and hear the same combination of sounds.

**Summary:** Depending on whether the stored favorite is a **session/mix** (category) or a **Klangwelten** favorite, the **correct player** (major audio player vs Klangwelten player) must load, with the **respective sounds** restored, so the user can start playback without reconfiguring.

---

## 3. Proposed Changes

**Implementation note:** Ensure that category-based favorites are actually **stored** (with the correct category when saving from the major player) and **displayed** on both the Home screen (one section per category that has favorites) and the category detail screen ("Meine Favoriten" / "Favorisierte Sessions"). If they are currently not displayed or stored correctly, fixing that is in scope for this proposal.

### 3.1 Klangwelten: Stop writing to `favoriteSessions`

**File:** `AWAVE/AWAVE/Features/Klangwelten/KlangweltenSoundDrawerView.swift`

- In `saveKlangweltFavorite()`:
  - Keep: `customMixRepository.saveMix(..., playbackMode: .klangwelten)` (already correct).
  - **Remove:** the call to `favoriteSessionRepository.addFavoriteSession(...)` for the saved Klangwelt.
- Klangwelten “favorites” are then **only** the list of CustomMixes with `playbackMode == .klangwelten`, which `KlangweltenEntryView` already loads via `customMixRepository.getMixes(userId)` and filters by `.klangwelten`. No change needed for how the Klangwelten tab displays saved Klangwelten.

### 3.2 Home & category detail: Exclude Klangwelten mixes when resolving favorites

**Home**

**File:** `AWAVE/AWAVE/Features/Home/HomeViewModel.swift`

- In `loadContent()`, when resolving mixes from `favoriteSessions` (loop over `mixIds`, `customMixRepository.getMix(id:userId:)`):
  - After fetching each mix, **only** add it to `mixes` if `mix.playbackMode != .klangwelten` (i.e. only `.guided` or `.session` for mixes).  
- Effect: Klangwelten mixes that were previously added to `favoriteSessions` will no longer appear on the Home screen. No new Klangwelten mixes will be added to `favoriteSessions` after 3.1.

**Category detail (Schlaf, Ruhe, Im Fluss)**

**Files:** `AWAVE/AWAVE/Features/Categories/SchlafScreen.swift`, `RuheScreen.swift`, `ImFlussScreen.swift`

- In each screen’s `loadFavoriteSessions()` (or equivalent), when building the `mixes` list from `favoriteSession` records with `itemType == .customMix`:
  - After `customMixRepository.getMix(id:userId:)`, **only** append to the resolved mixes list if `mix.playbackMode != .klangwelten`.  
- Effect: Klangwelten mixes no longer appear in “Favorisierte Sessions” / “Meine Favoriten” on category detail. Category session mixes (guided/session) continue to appear and open in the major player.

### 3.3 Optional: Clean up existing Klangwelten entries in `favoriteSessions`

- **Option A (recommended for first release):** No migration. Rely on read-time filtering (3.2). Old Klangwelten entries in `favoriteSessions` simply stop appearing on Home and category detail; they remain harmless in Firestore until we optionally add a one-time or background cleanup.
- **Option B:** One-time migration (e.g. in app startup or a small utility): for each user, list `favoriteSessions` with `itemType == .customMix`, resolve each mix, and remove the document if `mix.playbackMode == .klangwelten`. Document in release notes.

### 3.4 Domain / docs

- **Entity comment:** In `AWAVE/Packages/AWAVEDomain/Sources/AWAVEDomain/Entities/FavoriteSession.swift`, clarify that `FavoriteSession` (and thus `favoriteSessions`) is **only** for category-based session/mix favorites (guided sessions and saved mixes from the major audio player), not for Klangwelten saved mixes.
- **Requirements:** Update Favorite Functionality docs to state explicitly that Klangwelten favorites and category session favorites are two separate features with separate storage and UI (see section 4 below).

---

## 4. Requirements Updates (summary)

- **Klangwelten favorites:**  
  - Scope: Klangwelten only.  
  - Storage: `users/{userId}/mixes` with `playbackMode: .klangwelten`; **no** `favoriteSessions` entries.  
  - Display: Klangwelten tab (“Deine Klangwelten”), Klangwelten detail/player only.  
  - **Persist/restore:** Persist the Klangwelten mix (sounds + volumes); on tap, restore in the Klangwelten player with the respective sounds so the user can start the Klangwelt.  
  - Action: Tap opens Klangwelten player with that mix and sounds; user can start playback.

- **Category session favorites:**  
  - Scope: Home + category detail (Schlaf, Ruhe, Im Fluss).  
  - Storage: `users/{userId}/favoriteSessions` (sessions + customMix where the mix is **not** Klangwelten), **with the correct category** when saved from the major player. Session/mixer state or saved mix (tracks, volumes) must be persisted so it can be restored.  
  - Display: Home must show **one section per category that has at least one favorite** (including categories other than the onboarding base, e.g. user chose Sleep but saved a Flow favorite → Flow gets its own section on Home). Category detail screens show "Meine Favoriten" / "Favorisierte Sessions" for that category only. **Never** on Klangwelten.  
  - **Persist/restore:** Persist session + mixer state (or saved mix); on tap, restore in the major audio player with the respective sounds so the user can start the session (or mix).  
  - Resolve: When resolving `customMix` from `favoriteSessions`, exclude mixes with `playbackMode == .klangwelten`.

These points will be reflected in `docs/Requirements/APP-Feature Description/Favorite Functionality/` (README, requirements.md, technical-spec.md).

---

## 5. Files to Touch

| Area              | File(s)                                                                 | Change |
|-------------------|-------------------------------------------------------------------------|--------|
| Klangwelten       | `KlangweltenSoundDrawerView.swift`                                      | Remove `addFavoriteSession` in `saveKlangweltFavorite()` |
| Home              | `HomeViewModel.swift`                                                   | When resolving mixes from favoriteSessions, exclude `playbackMode == .klangwelten`; ensure one section per category that has favorites (including categories other than onboarding). |
| Category detail   | `SchlafScreen.swift`, `RuheScreen.swift`, `ImFlussScreen.swift`         | Same exclusion when resolving customMix favorites; ensure each screen shows that category's favorites only. |
| Domain (comment)  | `FavoriteSession.swift`                                                  | Clarify that favoriteSessions is category-session only, not Klangwelten |
| Requirements      | `Favorite Functionality/README.md`, `requirements.md`, `technical-spec.md` | Add explicit separation of the two favorites types and rules above |

---

## 6. Testing

- **Klangwelten:** Save a new Klangwelt → it appears only under “Deine Klangwelten” in the Klangwelten tab; it does **not** appear on Home or on any category “Favorisierte Sessions”. Tapping it opens the Klangwelten player.
- **Category (same as onboarding):** From major player in the user's onboarding category (e.g. Schlaf), save a session or mix as favorite → it appears on Home in that category's section and on that category detail “Favorisierte Sessions”; it does **not** appear in “Deine Klangwelten”.
- **Category (different from onboarding):** User's onboarding = Schlaf; user goes to Im Fluss, generates a flow session, saves it as favorite → the favorite is stored for the Im Fluss category; it appears on the **Home screen in a dedicated Im Fluss section** (new section for that category); it appears on the **Im Fluss category detail screen** in "Favorisierte Sessions" / "Meine Favoriten"; tapping opens the major player. It does **not** appear in "Deine Klangwelten".
- **Regression:** Existing category session favorites (sessions + guided mixes) still appear on Home (in the correct category section) and on the corresponding category detail and open in the major player. Existing Klangwelten mixes (after fix) no longer appear on Home/category; existing ones already in `favoriteSessions` are hidden by read-time filter until optional cleanup.

---

## 7. Acceptance

- Klangwelten saved mixes are shown and played only in Klangwelten context; they are not written to `favoriteSessions` and are not shown on Home or category detail. When the user taps a saved Klangwelt, the Klangwelten player loads with the respective sounds and the user can start the Klangwelt.
- Category session/mix favorites are stored with the correct category and are shown on **both** the Home screen (one section per category that has at least one favorite, including categories other than the onboarding base) and the corresponding category detail screen; they are never shown in the Klangwelten “Deine Klangwelten” list (which is already correct by playbackMode filter; we keep that and add the exclusion on the other side). When the user taps a category favorite, the major audio player loads with the session/mixer state or mix and the respective sounds, and the user can start the session (or mix). If category favorites were not previously displayed or stored correctly on Home or category detail, the implementation corrects that so they are.

No code changes beyond the scope above; no unrelated files altered.
