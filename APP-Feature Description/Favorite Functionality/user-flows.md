# Favorite Functionality - User Flows

## 🔄 Primary User Flows

### 1. Add Favorite from Audio Player Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User plays a sound
   └─> AudioPlayerScreen displays
       └─> AudioPlayerFavoriteButton visible
           └─> Shows "Zu Favoriten hinzufügen" (unfilled heart)

2. User taps favorite button
   └─> Check authentication
       ├─> Not authenticated → Show login prompt
       └─> Authenticated → Continue
           └─> Show loading state (optional)
               └─> Call addFavorite()
                   ├─> ProductionBackendService.addFavorite()
                   │   └─> Supabase insert
                   │       └─> Database insert
                   └─> refreshFavorites()
                       └─> Load updated list
                           └─> Update UI
                               └─> Button shows "Zu Favoriten hinzugefügt" (filled heart)
```

**Success Path:**
- User taps button
- Favorite added to backend
- UI updates immediately
- Button shows filled state

**Error Paths:**
- Not authenticated → Show login prompt
- Network error → Show error message, revert UI
- Invalid data → Show validation error
- Database error → Show error message, revert UI

---

### 2. Add Favorite from Library Screen Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User navigates to Library Screen
   └─> LibraryScreen displays
       └─> Load all sounds
           └─> Load favorites list
               └─> Mark favorites with heart icons

2. User sees sound with unfilled heart icon
   └─> User taps heart icon
       └─> Check authentication
           ├─> Not authenticated → Show login prompt
           └─> Authenticated → Continue
               └─> Optimistic UI update
                   └─> Heart icon fills immediately
                       └─> Call addFavorite()
                           ├─> ProductionBackendService.addFavorite()
                           │   └─> Supabase insert
                           │       └─> Database insert
                           └─> refreshFavorites()
                               └─> Update favorites list
                                   └─> Confirm UI state
```

**Success Path:**
- User taps heart icon
- Icon fills immediately (optimistic)
- Favorite added to backend
- List refreshes to confirm

**Error Paths:**
- Not authenticated → Show login prompt
- Network error → Revert icon, show error
- Invalid data → Revert icon, show error
- Database error → Revert icon, show error

---

### 3. Remove Favorite from Audio Player Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User plays a favorited sound
   └─> AudioPlayerScreen displays
       └─> AudioPlayerFavoriteButton visible
           └─> Shows "Zu Favoriten hinzugefügt" (filled heart)

2. User taps favorite button
   └─> Check authentication
       └─> Authenticated → Continue
           └─> Show loading state (optional)
               └─> Call removeFavorite()
                   ├─> Find favorite by sound ID
                   ├─> ProductionBackendService.removeFavorite()
                   │   └─> Supabase delete
                   │       └─> Database delete
                   └─> refreshFavorites()
                       └─> Load updated list
                           └─> Update UI
                               └─> Button shows "Zu Favoriten hinzufügen" (unfilled heart)
```

**Success Path:**
- User taps button
- Favorite removed from backend
- UI updates immediately
- Button shows unfilled state

**Error Paths:**
- Not authenticated → Show login prompt
- Network error → Show error message, revert UI
- Favorite not found → Log warning, no error shown
- Database error → Show error message, revert UI

---

### 4. Remove Favorite from Library Screen Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User navigates to Library Screen
   └─> LibraryScreen displays
       └─> Load favorites list
           └─> Mark favorites with filled heart icons

2. User sees sound with filled heart icon
   └─> User taps heart icon
       └─> Check authentication
           └─> Authenticated → Continue
               └─> Optimistic UI update
                   └─> Heart icon unfills immediately
                       └─> Call removeFavorite()
                           ├─> Find favorite by sound ID
                           ├─> ProductionBackendService.removeFavorite()
                           │   └─> Supabase delete
                           │       └─> Database delete
                           └─> refreshFavorites()
                               └─> Update favorites list
                                   └─> Confirm UI state
```

**Success Path:**
- User taps heart icon
- Icon unfills immediately (optimistic)
- Favorite removed from backend
- List refreshes to confirm

**Error Paths:**
- Not authenticated → Show login prompt
- Network error → Revert icon, show error
- Favorite not found → Log warning, no error shown
- Database error → Revert icon, show error

---

### 5. View Favorites List Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User navigates to Library Screen
   └─> LibraryScreen displays
       └─> Check authentication
           ├─> Not authenticated → Show local favorites
           └─> Authenticated → Continue
               └─> Load favorites from Supabase
                   ├─> Query user_favorites table
                   ├─> Filter by user_id
                   ├─> Order by last_used (descending)
                   └─> Map to FavoriteItem[]
                       └─> Display in list
                           └─> Show favorite indicators

2. User sees favorites list
   └─> Each sound shows:
       ├─> Title and description
       ├─> Category badge
       ├─> Favorite heart icon (filled)
       └─> Usage stats (optional)
```

**Success Path:**
- Favorites load from backend
- List displays with favorite indicators
- Sorted by most recently used

**Error Paths:**
- Network error → Show local favorites or empty state
- Authentication error → Show local favorites
- Database error → Show error message, retry option

---

### 6. Filter Favorites by Category Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User navigates to Library Screen
   └─> LibraryScreen displays favorites
       └─> Category filter buttons visible

2. User selects category filter
   └─> Update selectedCategory state
       └─> Filter favorites list
           ├─> Filter by categoryId
           └─> Update displayed list
               └─> Show only favorites in selected category

3. User selects "All" category
   └─> Clear category filter
       └─> Show all favorites
           └─> Update displayed list
```

**Success Path:**
- Category filter applied
- List updates in real-time
- Only matching favorites shown

**Error Paths:**
- Invalid category → Show all favorites
- No favorites in category → Show empty state

---

### 7. Search Favorites Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User navigates to Library Screen
   └─> LibraryScreen displays favorites
       └─> Search input visible

2. User types in search input
   └─> Update searchQuery state
       └─> Filter favorites list
           ├─> Search in title (case-insensitive)
           ├─> Search in description (case-insensitive)
           ├─> Search in tags (case-insensitive)
           └─> Search in keywords (case-insensitive)
               └─> Update displayed list
                   └─> Show only matching favorites

3. User clears search
   └─> Clear searchQuery state
       └─> Show all favorites
           └─> Update displayed list
```

**Success Path:**
- Search query applied
- List filters in real-time
- Matching favorites shown

**Error Paths:**
- No matches → Show empty state
- Invalid query → Show all favorites

---

### 8. Usage Tracking Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User plays a favorite sound
   └─> Audio player starts playback
       └─> Check if sound is favorite
           └─> If favorite → Continue
               └─> markFavoritePlayed()
                   ├─> Find favorite by sound ID
                   ├─> Supabase update
                   │   ├─> Increment use_count
                   │   └─> Update last_used timestamp
                   └─> refreshFavorites()
                       └─> Re-sort by last_used
                           └─> Update UI (if visible)
```

**Success Path:**
- Favorite played
- Usage tracked automatically
- List re-sorted by most recent
- No user interaction required

**Error Paths:**
- Favorite not found → Log warning, continue playback
- Network error → Log warning, continue playback
- Database error → Log warning, continue playback

---

## 🔀 Alternative Flows

### Offline Add Favorite Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User is offline
   └─> User taps favorite button
       └─> Check authentication
           ├─> Not authenticated → Continue
           │   └─> AWAVEStorage.setFavorites()
           │       └─> Store in AsyncStorage
           │           └─> Update UI optimistically
           └─> Authenticated → Continue
               └─> Queue operation for sync
                   └─> Store in local queue
                       └─> Update UI optimistically

2. User comes online
   └─> Check for queued operations
       └─> Sync queued favorites to backend
           ├─> ProductionBackendService.addFavorite()
           └─> Clear local queue
               └─> Refresh favorites list
```

**Use Cases:**
- User adds favorite while offline
- Changes sync when online
- No data loss during offline period

---

### Sync After Authentication Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User authenticates
   └─> Check for local favorites
       └─> If local favorites exist → Continue
           └─> Load favorites from Supabase
               └─> Merge local and remote
                   ├─> Server wins on conflicts
                   └─> Update local storage
                       └─> Refresh favorites list
                           └─> Update UI
```

**Use Cases:**
- User adds favorites before authentication
- Favorites sync after login
- No duplicate favorites created

---

### Bulk Operations Flow (Future)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User enters select mode
   └─> LibraryScreen shows selection UI
       └─> User selects multiple favorites

2. User taps "Remove Selected"
   └─> Confirm action
       └─> Batch remove favorites
           ├─> ProductionBackendService.removeFavorite() (for each)
           └─> refreshFavorites()
               └─> Update UI
```

**Use Cases:**
- Remove multiple favorites at once
- Bulk operations for efficiency
- Better UX for power users

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User attempts to add favorite
   └─> Network request fails
       └─> Catch error
           ├─> Revert optimistic UI update
           └─> Show error message
               └─> "Favorit konnte nicht hinzugefügt werden"
                   └─> Provide retry option
```

**Error Messages:**
- "Favorit konnte nicht hinzugefügt werden"
- "Favorit konnte nicht entfernt werden"
- "Bitte überprüfe deine Internetverbindung"
- Retry button available

---

### Authentication Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User attempts to add favorite
   └─> Check authentication
       └─> Not authenticated → Continue
           └─> Show login prompt
               └─> "Bitte melde dich an, um Favoriten zu verwalten"
                   └─> Navigate to auth screen (optional)
```

**User Actions:**
- Navigate to login
- Cancel and continue browsing
- Add to local storage (if unauthenticated)

---

### Invalid Data Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User attempts to add favorite
   └─> Validate input data
       ├─> Missing sound ID → Show error
       │   └─> "Ungültige Sound-ID"
       ├─> Missing title → Show error
       │   └─> "Titel ist erforderlich"
       └─> Valid → Continue
           └─> Add favorite
```

**Validation:**
- Sound ID required
- Title required
- Other fields optional
- Clear error messages

---

### Duplicate Favorite Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User attempts to add favorite
   └─> Check if already favorited
       └─> If already favorited → Continue
           └─> Database constraint prevents duplicate
               └─> Show error or silently ignore
                   └─> Update UI to show favorited state
```

**Handling:**
- Database UNIQUE constraint prevents duplicates
- UI should reflect current state
- No error shown (expected behavior)

---

## 🔄 State Transitions

### Favorite Status States

```
Not Favorited → Adding → Favorited
     │            │
     │            └─> Error → Not Favorited
     │
     └─> Error (retry)
```

### Loading States

```
Idle → Loading → Loaded
  │       │
  │       └─> Error → Idle (retry)
  │
  └─> Refreshing → Loaded
```

### Usage Tracking States

```
Played → Tracking → Updated
  │         │
  │         └─> Error → Played (no update)
  │
  └─> Not Tracked (silent failure)
```

---

## 📊 Flow Diagrams

### Complete Add Favorite Journey

```
Library Screen / Audio Player
    │
    ├─> User taps favorite button
    │   └─> Check authentication
    │       ├─> Not authenticated
    │       │   └─> Show login prompt
    │       │       └─> User authenticates
    │       │           └─> Retry add favorite
    │       │
    │       └─> Authenticated
    │           └─> Optimistic UI update
    │               └─> Call addFavorite()
    │                   ├─> ProductionBackendService.addFavorite()
    │                   │   └─> Supabase insert
    │                   │       └─> Database insert
    │                   └─> refreshFavorites()
    │                       └─> Load updated list
    │                           └─> Confirm UI state
    │
    └─> Success → Favorite added, UI updated
```

---

### Complete Remove Favorite Journey

```
Library Screen / Audio Player
    │
    ├─> User taps favorite button (filled)
    │   └─> Check authentication
    │       └─> Authenticated
    │           └─> Optimistic UI update
    │               └─> Call removeFavorite()
    │                   ├─> Find favorite by ID
    │                   ├─> ProductionBackendService.removeFavorite()
    │                   │   └─> Supabase delete
    │                   │       └─> Database delete
    │                   └─> refreshFavorites()
    │                       └─> Load updated list
    │                           └─> Confirm UI state
    │
    └─> Success → Favorite removed, UI updated
```

---

### Complete View Favorites Journey

```
App Start / Navigation
    │
    └─> Navigate to Library Screen
        └─> LibraryScreen mounts
            └─> useFavoritesManagement() initializes
                └─> loadFavorites()
                    ├─> Check authentication
                    ├─> If authenticated:
                    │   └─> loadFromSupabase()
                    │       └─> Query database
                    │           └─> Map to FavoriteItem[]
                    │               └─> Update state
                    │                   └─> Render list
                    └─> If not authenticated:
                        └─> loadFromStorage()
                            └─> Read from AsyncStorage
                                └─> Map to FavoriteItem[]
                                    └─> Update state
                                        └─> Render list
```

---

## 🎯 User Goals

### Goal: Quick Favorite Access
- **Path:** Add favorite → View in library → Quick access
- **Time:** < 5 seconds to add, instant access
- **Steps:** 2-3 taps

### Goal: Organize Favorites
- **Path:** View favorites → Filter by category → Find desired sound
- **Time:** < 10 seconds
- **Steps:** 3-4 taps

### Goal: Track Usage
- **Path:** Play favorite → Automatic tracking → See in sorted list
- **Time:** Automatic (no user action)
- **Steps:** 0 (automatic)

---

## 🔄 Integration Flows

### Audio Player Integration

```
Audio Player
    │
    ├─> Display favorite button
    │   └─> Check if sound is favorited
    │       └─> Set button state
    │
    ├─> User toggles favorite
    │   └─> Call onToggleFavorite()
    │       └─> Update favorite status
    │           └─> Refresh button state
    │
    └─> User plays favorite
        └─> markFavoritePlayed()
            └─> Update usage tracking
```

### Library Screen Integration

```
Library Screen
    │
    ├─> Load all sounds
    │   └─> Load favorites list
    │       └─> Mark favorites with icons
    │
    ├─> User toggles favorite
    │   └─> Update favorite status
    │       └─> Refresh icon state
    │
    └─> Filter by favorites
        └─> Show only favorites
            └─> Update displayed list
```

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
