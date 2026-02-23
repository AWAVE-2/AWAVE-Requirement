# Favorite Functionality - Feature Documentation

**Feature Name:** User Favorites Management  
**Status:** ✅ Sound favorites complete; ⚠️ Session/mix add-to-favorites has known bug  
**Priority:** High  
**Last Updated:** 2026-02-23

## 📋 Feature Overview

The Favorite Functionality system in AWAVE iOS enables users to save and manage **three** distinct kinds of favorites. **Klangwelten favorites** and **category session/mix favorites** are strictly separated and must not be mixed in storage or display.

1. **Sound favorites** – Single sounds (Library, player). Stored via Firestore `FavoritesRepository`; displayed in Library and category screens.
2. **Klangwelten favorites** – Saved Klangwelten mixes (3-slot ambient mixes created in the Klangwelten flow). Stored **only** in Firestore `users/{userId}/mixes` with `playbackMode: .klangwelten`; **not** in `favoriteSessions`. Displayed **only** in the Klangwelten tab ("Deine Klangwelten") and Klangwelten detail/player. Tapping a saved Klangwelt opens the Klangwelten player only.
3. **Session/mix favorites (category-based)** – Generator sessions and saved mixes from the **major audio player** **per category** (Schlaf, Ruhe, Im Fluss). Stored in Firestore `users/{userId}/favoriteSessions`; drive **Home screen sections** and **category detail "Meine Favoriten" / "Favorisierte Sessions"** only. **Never** displayed in the Klangwelten screen. When resolving `customMix` entries from `favoriteSessions`, mixes with `playbackMode == .klangwelten` must be excluded so Klangwelten mixes do not appear on Home or category detail.

### Description (iOS / Firestore)

- **Sound favorites:** Add/remove from audio player and Library; Firestore backend; usage tracking.
- **Session/mix favorites:** Add from full player (session one-tap or save mix from mixer). Shown on Home screen **only for categories that have at least one favorite**. Category detail screens show a "Favorisierte Sessions" / "Meine Favoriten" section with session and mix tiles for that category.
- **Known issue:** Saving a mix and adding it to favorites can show "Mix was saved but could not be added to favorites." – mix is saved; add-to-favorites step fails. Must be fixed so flow (and any category) session → save mix → add to favorites works and the mix appears on Home and category detail.

### User Value

- **Quick Access** – Save sessions and mixes per category; see them on Home and in the category screen.
- **No clutter** – Categories with no favorites are not shown as sections on the Home screen.
- **Clear ownership** – Favorites from a category (e.g. Im Fluss) appear under that category on Home and under "Meine Favoriten" on the category detail screen.

---

## 🎯 Core Features

### Klangwelten Favorites (saved Klangwelten only)

- **Add:** From Klangwelten flow – save mix with name; stored as CustomMix with `playbackMode: .klangwelten` in `users/{userId}/mixes` only (no `favoriteSessions`).
- **Display:** Only in Klangwelten tab ("Deine Klangwelten") and Klangwelten player. Never on Home or category detail.
- **Remove:** From Klangwelten list/context where supported.
- **Rule:** Klangwelten mixes must never be added to `favoriteSessions` and must never appear in "Favorisierte Sessions" on Home or category screens.

### Session/Mix Favorites (per category – major audio player only)

- **Add:** From full player – one-tap favorite session (saves session + mixer state) or save mix (name + save) and add to favorites for current category. Stored in `favoriteSessions`.
- **Display:** Home screen shows one section per category that has at least one favorite; display category = onboarding choice; other categories with favorites appear as additional sections. Category detail screens show "Meine Favoriten" / "Favorisierte Sessions" with session and mix tiles for that category only. When resolving customMix from favoriteSessions, exclude mixes with `playbackMode == .klangwelten`.
- **Remove:** From player or (where supported) from lists.
- **Bug:** "Mix was saved but could not be added to favorites" when adding mix to favorites after save – must be fixed.

### Sound Favorites (Library)

1. **Add to Favorites** – From audio player and library screen; metadata capture; visual confirmation.
2. **Remove from Favorites** – From player and library; visual confirmation.
3. **View Favorites** – Library screen; filter by category; search; sort by last used or date added.
4. **Usage Tracking** – Play count and last used; automatic updates when favorite is played.
5. **Offline Support** – Local cache for session/mix favorites when offline; graceful degradation.
6. **Synchronization** – Session/mix: Firestore `users/{userId}/favoriteSessions`; sound: Firestore (FavoritesRepository).

---

## 🏗️ Architecture (iOS)

### Technology Stack
- **Backend:** Firebase Firestore (`users/{userId}/favorites`, `users/{userId}/favoriteSessions`, `users/{userId}/mixes`)
- **Session/mix favorites:** `FavoriteSessionRepositoryProtocol` → `FirestoreFavoriteSessionRepository`
- **Sound favorites:** `FavoritesRepositoryProtocol` → `FirestoreFavoritesRepository`
- **State:** SwiftUI + `@Observable` (e.g. `HomeViewModel`, category screens)

### Key Types
- `FavoriteSession` – Per-category session/mix favorite only (major audio player); not used for Klangwelten.
- `Favorite` – Sound favorite (soundId, etc.)
- `CustomMix.playbackMode` – `.klangwelten` for Klangwelten mixes (excluded from Home/category favorite resolution); `.guided` (or `.session`) for category mixes in favoriteSessions.
- `HomeViewModel.favoritesByCategory`, `categoriesWithFavorites` – Drive Home sections; when resolving mixes, exclude `playbackMode == .klangwelten`.
- `FullPlayerView` / `MixerSheetView` – Save session or mix and add to favorites (category only).
- `KlangweltenSoundDrawerView.saveKlangweltFavorite()` – Saves mix with `.klangwelten` only; must not call `addFavoriteSession`.

---

## 📱 Screens (iOS)

1. **HomeView** – Home screen; section per category that has favorites (display category = onboarding); session/mix tiles per category; "Neue Session generieren" to category detail.
2. **Category detail (SchlafScreen, RuheScreen, ImFlussScreen)** – "Favorisierte Sessions" / Meine Favoriten section (session + mix tiles for that category), then session generator block.
3. **FullPlayerView** – Major audio player; heart toggles session/mix favorite or opens mixer/save-mix sheet.
4. **MixerSheetView** – Save mix (name) and add to favorites for current category; currently can show "Mix was saved but could not be added to favorites."
5. **LibraryView** – Sound favorites list and management.

---

## 🔄 User Flows

### Session/Mix Favorites (per category)
1. **Home:** User sees sections only for categories that have at least one favorite; display category = onboarding (e.g. Schlaf); other categories with favorites below (e.g. Im Fluss Session with tiles).
2. **Category detail:** User opens Schlaf/Ruhe/Im Fluss → sees "Favorisierte Sessions" / Meine Favoriten (if any) → session and mix tiles → then session generator.
3. **Add session favorite:** Full player, session mode → tap heart → session + mixer state saved and added to favorites for current category → appears on Home and category detail.
4. **Add mix favorite:** Full player → open mixer → save mix (name) → mix saved and (when working) added to favorites for current category. **Current bug:** add-to-favorites step fails with "Mix was saved but could not be added to favorites."

### Sound Favorites (Library)
1. **Add/Remove** – From player or Library → Save to / delete from Firestore → Update UI.
2. **View** – Library → filter by category → search → sort by last used.
3. **Usage** – Play favorite → update usage → re-sort list.

---

## 🔐 Security Features

- User-scoped favorites (only user can see their favorites)
- Authentication required for backend sync
- Secure token-based API calls
- Row-level security in Supabase

---

## 📊 Integration Points

### Related Features
- **Home** – Favorites per category; sections only when category has favorites; `HomeViewModel`, `favoritesByCategory`, `categoriesWithFavorites`.
- **Category detail (Schlaf, Ruhe, Im Fluss)** – "Meine Favoriten" / "Favorisierte Sessions" section; session and mix tiles; `loadFavoriteSessions()`, `resolvedFavoriteSessions`, `resolvedFavoriteMixes`.
- **Full player** – Session/mix favorite toggle; save mix from mixer; `currentFavoriteCategory` set when loading session from category.
- **Library** – Sound favorites display and management.
- **Offline** – LocalCategorySessionStorage for cached sessions; anonymous/local fallback.

### External Services
- Firebase Firestore: `users/{userId}/favoriteSessions`, `users/{userId}/mixes`, `users/{userId}/favorites` (or equivalent)
- Firebase Auth (user authentication)

---

## 🧪 Testing Considerations

### Test Cases
- Add favorite from audio player
- Remove favorite from library
- View favorites list
- Filter favorites by category
- Search favorites
- Usage tracking on play
- Offline add/remove
- Sync after authentication
- Error handling (network, invalid data)

### Edge Cases
- Network connectivity issues
- Duplicate favorites
- Invalid sound IDs
- Expired authentication
- Large favorite lists (performance)

---

## 📚 Additional Resources

- **[Final Report: Major Audioplayer Favorites (Home, Category, Mixer, Offline)](../../../FINAL-REPORT-MAJOR-AUDIOPLAYER-FAVORITES-MIXER-OFFLINE.md)** – Implementation record for guided-session favorites: mixer state (GuidedSessionMixerState), session + mixer save/load, Home real tiles (no mocks), category favorites with mixer, offline cache, download on save, and requirements F-01–F-12 mapping.
- [Supabase Database Documentation](https://supabase.com/docs/guides/database) (reference; iOS uses Firestore)
- [Favorites Usage Tracking Documentation](../../../FAVORITES_USAGE_TRACKING.md) (if present)

---

## 📝 Notes

- Favorites require user authentication for backend sync
- Local storage is used as fallback for unauthenticated users
- Usage tracking updates automatically when favorites are played
- Favorites are sorted by `last_used` (most recent first) by default
- Maximum favorites limit: None (unlimited)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
