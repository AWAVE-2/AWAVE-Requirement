# Favorite Functionality - Functional Requirements

**App context:** AWAVE iOS (Swift). Favorites are implemented in **three strictly separated** ways:

1. **Sound favorites** – Single sounds (Library, player).
2. **Klangwelten favorites** – Saved Klangwelten mixes only; stored in `users/{userId}/mixes` with `playbackMode: .klangwelten`; displayed **only** in the Klangwelten tab and Klangwelten player; **never** in `favoriteSessions`, Home, or category detail.
3. **Session/mix favorites (category-based)** – Per category (Schlaf, Ruhe, Im Fluss); stored in `users/{userId}/favoriteSessions`; drive **only** Home screen sections and category detail "Meine Favoriten" / "Favorisierte Sessions"; **never** displayed in the Klangwelten screen. When resolving customMix from `favoriteSessions`, mixes with `playbackMode == .klangwelten` must be excluded.

### Reference: Major Audioplayer implementation report

The full **guided-session favorites** implementation (mixer state, Home real tiles, tap-to-load with mixer, offline cache, download on save) and the requirement set **F-01–F-12** with implementation mapping are documented in:

**[Final Report: Major Audioplayer Favorites (Home, Category, Mixer, Offline)](../../../FINAL-REPORT-MAJOR-AUDIOPLAYER-FAVORITES-MIXER-OFFLINE.md)**

That report covers: session + mixer state in Firebase and local cache (F-01, F-02); FavoriteSession reference for listing (F-03); dedicated component separate from Klangwelten (F-04); Home real tiles, no mocks (F-05); tap session favorite → session + mixer load and override (F-06); single source of truth for Home and Category (F-07); category detail favorites and tap behavior (F-08, F-09); offline list from local cache (F-10); download on save (F-11); clear message when audio missing (F-12). Use it for implementation details and verification.

---

## 📋 Separation Rule (Non-Negotiable)

- **Klangwelten favorites** and **category session/mix favorites** must be strictly separated:
  - Klangwelten saved mixes are **not** added to `favoriteSessions`; they appear only in "Deine Klangwelten" (Klangwelten tab) and open only in the Klangwelten player.
  - Home and category detail "Favorisierte Sessions" show **only** category-based favorites (generator sessions + saved mixes from the major player with `playbackMode != .klangwelten`). Klangwelten mixes must not appear there.

---

## 📋 Home Screen & Category Favorites (Session/Mix – Category Only)

### Home Screen – Favorites per Category

- [x] Favorites from the major audio player (session generator sessions and saved mixes) are displayed **per category** on the Home screen.
- [x] A category that has **no** favorites must **not** be displayed as a section on the Home screen.
- [x] Only when a user saves a session or mix as a favorite from a specific category (Schlaf, Ruhe, Im Fluss) does that category appear as a section on the Home screen.
- [x] The **display category** (first section) is the user’s onboarding choice (e.g. Schlaf). Other categories that have at least one favorite appear as additional sections below (e.g. "Im Fluss Session" with favorite tiles).
- [x] Each section shows: session tiles and/or saved mix tiles for that category; "Neue Session generieren" link to the category detail screen.
- [ ] **Bug to fix:** Saving a mix from the player and adding it to favorites can fail with "Mix was saved but could not be added to favorites." (Mix was saved but could not be added to favorites.) The mix is stored successfully; `addFavoriteSession` fails. This must be fixed so that flow (or any category) session → generate session → save as mix → add to favorites succeeds and the mix appears on the Home screen under that category.

### Category Detail Screen – Meine Favoriten

- [x] Each category detail screen (Schlaf, Ruhe, Im Fluss) has a **Meine Favoriten** (German) / "My Favorites" section for **session and mix favorites** of that category.
- [x] This section is shown only when there is at least one favorite session or saved mix for that category (same as Home: no empty category section).
- [x] Section shows: favorited generator sessions and saved mixes (CustomMix) as tiles; tapping opens the player with that session or mix.
- [x] Labels: "Favorisierte Sessions" is used in the app for this block; product copy may use "Meine Favoriten" for the section heading (requirements: section exists and shows per-category session/mix favorites).

### Session/Mix Favorite Sources

- [x] User can favorite a **generator session** from the full player (heart) → one-tap saves session + mixer state and adds to favorites for the current category.
- [x] User can **save a mix** (name + save) from the mixer sheet; the mix is stored and, when category is available, added as a favorite so it appears on the Home screen and category detail under that category.
- [ ] When the user goes to a category detail (e.g. Im Fluss), generates a flow session, then saves that as a mix and adds to favorites, the **flow session favorite/mix** must appear as a tile on the Home screen under the Flow section. Currently blocked by the "Mix was saved but could not be added to favorites" error; fixing the add-to-favorites step unblocks this.

---

## 📋 Core Requirements (Sound Favorites – Library)

### 1. Add to Favorites

#### From Audio Player
- [x] User can add sound to favorites from audio player
- [x] Favorite button visible in player controls
- [x] Button shows current favorite status (filled/unfilled heart icon)
- [x] Visual feedback on button press
- [x] Success confirmation (button state change)
- [x] Error handling for failed requests
- [x] Authentication check before adding

#### From Library Screen
- [x] User can add sound to favorites from library list
- [x] Heart icon visible on each sound card
- [x] Icon changes color when favorited
- [x] Tap to toggle favorite status
- [x] Visual feedback on toggle
- [x] Optimistic UI updates
- [x] Error handling with rollback

#### Metadata Capture
- [x] Sound ID stored
- [x] Title stored
- [x] Description stored (optional)
- [x] Category ID stored (optional)
- [x] Image URL stored (optional)
- [x] Date added timestamp
- [x] Initial use_count set to 0
- [x] is_public set to false by default

### 2. Remove from Favorites

#### From Audio Player
- [x] User can remove favorite from audio player
- [x] Button shows filled state when favorited
- [x] Tap to remove from favorites
- [x] Visual confirmation on removal
- [x] Error handling for failed requests

#### From Library Screen
- [x] User can remove favorite from library list
- [x] Heart icon shows filled state
- [x] Tap to remove from favorites
- [x] Optimistic UI updates
- [x] Error handling with rollback

#### Removal Logic
- [x] Remove by favorite ID (primary method)
- [x] Remove by sound ID (fallback)
- [x] User ID verification before removal
- [x] Database cleanup on removal

### 3. View Favorites

#### List Display
- [x] Display all user favorites in library screen
- [x] Show sound title and description
- [x] Show category information
- [x] Show favorite status indicator
- [x] Show usage statistics (play count, last used)
- [x] Empty state when no favorites exist

#### Filtering
- [x] Filter favorites by category
- [x] Filter by "All" (show all favorites)
- [x] Category filter persists during session
- [x] Filter updates list in real-time

#### Sorting
- [x] Sort by most recently used (default)
- [x] Sort by date added (fallback)
- [x] Sort order persists during session
- [x] Re-sort after usage tracking updates

#### Search
- [x] Search favorites by title
- [x] Search favorites by description
- [x] Search favorites by tags
- [x] Search favorites by keywords
- [x] Case-insensitive search
- [x] Real-time search filtering

### 4. Usage Tracking

#### Play Count Tracking
- [x] Increment use_count when favorite is played
- [x] Track play count per favorite
- [x] Display play count in UI (optional)
- [x] Automatic update on play

#### Last Used Tracking
- [x] Update last_used timestamp when favorite is played
- [x] Store timestamp in ISO format
- [x] Use timestamp for sorting
- [x] Display last used date (optional)

#### Automatic Updates
- [x] Track usage when favorite sound is played
- [x] Update database automatically
- [x] Refresh favorites list after update
- [x] Re-sort list by last_used after update

### 5. Offline Support

#### Local Storage
- [ ] Store favorites locally when offline (Not implemented - uses Firestore)
- [ ] Load favorites from local storage when offline (Not implemented - uses Firestore)
- [ ] Sync local favorites to backend on authentication (Not implemented)
- [ ] Merge local and remote favorites on sync (Not implemented)

#### Fallback Behavior
- [ ] Use local storage for unauthenticated users (Not implemented)
- [x] Graceful degradation when offline (Implemented)
- [ ] Queue operations for sync when online (Not implemented)
- [ ] Conflict resolution (server wins) (Not implemented)

### 6. Real-time Synchronization

#### Backend Sync
- [x] Load favorites from Firestore on app start (FirestoreFavoritesRepository)
- [x] Refresh favorites after add/remove operations (FirestoreFavoritesRepository)
- [ ] Sync favorites across devices (Not implemented)
- [ ] Handle sync conflicts (Not implemented)

#### State Management
- [ ] Maintain favorites state in hook (Not applicable - React hook, Swift uses @Observable)
- [x] Update state optimistically (Implemented)
- [x] Revert state on error (Implemented)
- [x] Refresh state after operations (FirestoreFavoritesRepository)

---

## 🎯 User Stories

### As a user, I want to:
- Save my favorite sounds so I can access them quickly
- Remove favorites I no longer need
- See all my favorites in one place
- Filter my favorites by category
- Search through my favorites
- Have my favorites sync across all my devices
- Access my favorites even when offline

### As a user playing audio, I want to:
- Quickly add a sound to favorites while listening
- See if a sound is already in my favorites
- Remove a sound from favorites if I change my mind
- Have my favorite status persist across app sessions

### As a user browsing the library, I want to:
- See which sounds I've favorited
- Add or remove favorites directly from the list
- Filter to see only my favorites
- Search within my favorites

---

## ✅ Acceptance Criteria

### Add Favorite
- [x] User can add favorite in < 2 seconds
- [x] Visual feedback appears immediately
- [x] Favorite persists after app restart
- [x] Favorite syncs to backend within 5 seconds
- [x] Error message shown if add fails

### Remove Favorite
- [x] User can remove favorite in < 2 seconds
- [x] Visual feedback appears immediately
- [x] Removal persists after app restart
- [x] Favorite removed from backend within 5 seconds
- [x] Error message shown if removal fails

### View Favorites
- [x] Favorites list loads in < 3 seconds
- [x] All user favorites displayed correctly
- [x] Empty state shown when no favorites
- [x] Filtering works in real-time
- [x] Search works in real-time

### Usage Tracking
- [x] Usage tracked automatically on play
- [x] Play count increments correctly
- [x] Last used timestamp updates correctly
- [x] List re-sorts after usage update
- [x] Updates persist after app restart

### Offline Support
- [ ] Favorites accessible when offline (Not implemented - requires Firestore offline persistence)
- [ ] Add/remove works offline (Not implemented)
- [ ] Changes sync when online (Not implemented)
- [ ] No data loss during offline period (Not implemented)

---

## 🚫 Non-Functional Requirements

### Performance
- Favorites list loads in < 3 seconds
- Add/remove operations complete in < 2 seconds
- Usage tracking updates in < 1 second
- Search filtering is instant (< 100ms)
- No UI blocking during operations

### Security
- Only authenticated users can sync to backend
- User can only see their own favorites
- Row-level security enforced in database
- Secure API calls with authentication tokens
- No sensitive data in local storage

### Usability
- Clear visual indicators for favorite status
- Intuitive favorite button placement
- Immediate feedback on all actions
- Error messages are user-friendly
- Empty states provide helpful guidance

### Reliability
- Favorites persist across app restarts
- Offline operations queue for sync
- Network errors handled gracefully
- Automatic retry for transient failures
- Data consistency maintained

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before operations (Implemented)
- [ ] Queue operations for sync when online (Not implemented)
- [x] User-friendly error messages (Implemented)
- [ ] Retry capability (Not implemented)
- [ ] Network status display (Not implemented)

### Invalid Data
- [x] Missing sound ID handling
- [x] Invalid favorite ID handling
- [x] Duplicate favorite prevention
- [x] Data validation before save
- [x] Error logging for debugging

### Authentication Issues
- [x] Check authentication before backend operations (Implemented)
- [ ] Fallback to local storage when unauthenticated (Not implemented)
- [ ] Sync on authentication (Not implemented)
- [x] Handle expired sessions (Firebase Auth handles)
- [ ] Clear favorites on sign out (Not implemented)

### Large Datasets
- [x] Efficient loading of large favorite lists
- [x] Pagination support (future)
- [x] Performance optimization for rendering
- [x] Memory management
- [x] Search performance optimization

### Concurrent Operations
- [x] Handle simultaneous add/remove operations
- [x] Prevent duplicate favorites
- [x] Conflict resolution
- [x] State consistency
- [x] Optimistic updates with rollback

---

## 📊 Success Metrics

- Favorite add success rate > 95%
- Favorite remove success rate > 95%
- Average add time < 2 seconds
- Average remove time < 2 seconds
- Favorites list load time < 3 seconds
- Usage tracking accuracy > 99%
- Offline sync success rate > 90%
- User satisfaction with favorites feature > 4/5

---

## 🔮 Future Enhancements

### Planned Features
- Bulk add/remove operations
- Favorite folders/categories
- Share favorites with other users
- Favorite playlists
- Favorite recommendations based on usage
- Export favorites list
- Import favorites from other services

### Performance Improvements
- Pagination for large lists
- Virtualized list rendering
- Caching improvements
- Background sync optimization
- Batch operations for usage tracking

---

## 🧪 Testing Requirements

### Unit Tests
- [x] Add favorite functionality (Implemented)
- [x] Remove favorite functionality (Implemented)
- [ ] Usage tracking updates (Not implemented)
- [ ] Local storage operations (Not applicable - uses Firestore)
- [x] Data mapping functions (Implemented)

### Integration Tests
- [x] Backend API calls (FirestoreFavoritesRepository)
- [ ] Local storage sync (Not implemented)
- [x] State management (Implemented)
- [x] Error handling (Implemented)
- [x] Authentication flow (Implemented)

### E2E Tests
- [x] Complete add favorite flow (Implemented)
- [x] Complete remove favorite flow (Implemented)
- [x] View favorites list (Implemented)
- [x] Filter favorites (Implemented)
- [x] Search favorites (Implemented)
- [ ] Usage tracking flow (Not implemented)
- [ ] Offline operations (Not implemented)
- [ ] Sync after authentication (Not implemented)

---

## 🐛 Known Issue – Mix Save and Add to Favorites

**Error shown to user:** "Mix was saved but could not be added to favorites." (DE: "Mix wurde gespeichert, konnte aber nicht zu Favoriten hinzugefügt werden.")

**Behavior:** When the user saves a mix from the major audio player (MixerSheetView save flow), `customMixRepository.saveMix()` succeeds and the mix is stored in Firestore (`users/{userId}/mixes`). The subsequent call `favoriteSessionRepository.addFavoriteSession(..., itemType: .customMix, itemId: mix.id)` fails, so the mix does not appear in Home screen or category detail favorites.

**Requirement:** This must be fixed so that:
1. Saving a mix and adding it to favorites in one flow succeeds when the user is authenticated and has write access.
2. The saved mix then appears as a tile on the Home screen under the correct category and in the category detail "Meine Favoriten" / "Favorisierte Sessions" section.

**Implementation reference:** `AWAVE/AWAVE/Features/Player/MixerSheetView.swift` – `saveMix()`; category from `favoriteCategoryRaw ?? player.currentFavoriteCategory`. Backend: `FirestoreFavoriteSessionRepository.addFavoriteSession`; Firestore path `users/{userId}/favoriteSessions`. See also `docs/FAVORITES-SAVE-MAJOR-AUDIOPLAYER-ANALYSIS-AND-PROPOSAL.md`.

---

*For technical implementation details, see `technical-spec.md`*  
*For component specifications, see `components.md`*  
*For service documentation, see `services.md`*  
*For user flow diagrams, see `user-flows.md`*
