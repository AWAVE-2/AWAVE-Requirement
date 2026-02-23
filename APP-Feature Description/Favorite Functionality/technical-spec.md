# Favorite Functionality - Technical Specification

## iOS Implementation (AWAVE Swift App)

**Implementation report:** The guided-session favorites implementation (mixer state in Firebase/local, tap-to-load with mixer, Home real tiles, category favorites, offline cache, download on save) and the full requirement-to-implementation mapping (F-01–F-12) are documented in **[FINAL-REPORT-MAJOR-AUDIOPLAYER-FAVORITES-MIXER-OFFLINE.md](../../../FINAL-REPORT-MAJOR-AUDIOPLAYER-FAVORITES-MIXER-OFFLINE.md)**.

### Separation of Favorites (Mandatory)

- **Klangwelten favorites:** Stored only in `users/{userId}/mixes` with `playbackMode: .klangwelten`. **Never** written to `favoriteSessions`. Displayed only in Klangwelten tab ("Deine Klangwelten") and Klangwelten player. Klangwelten save flow must **not** call `favoriteSessionRepository.addFavoriteSession()`.
- **Category session/mix favorites:** Stored in `users/{userId}/favoriteSessions`. When resolving `customMix` items for Home or category detail, **exclude** any mix where `mix.playbackMode == .klangwelten` so Klangwelten mixes never appear on Home or category "Favorisierte Sessions".

### Session/Mix Favorites (per category – category-based only)

- **Storage:** Firestore `users/{userId}/favoriteSessions`; document ID `{itemType}_{itemId}` (e.g. `customMix_abc123`); fields: `category`, `itemType` (session | customMix), `itemId`, `addedAt`. Used **only** for category-based session/mix favorites (major audio player), not for Klangwelten.
- **Protocol:** `FavoriteSessionRepositoryProtocol`; implementation `FirestoreFavoriteSessionRepository`.
- **Home screen:** `HomeViewModel.loadContent()` loads `getFavoriteSessions(userId, category)` per onboarding category; when resolving mixes from favoriteSessions, only include mixes where `playbackMode != .klangwelten`. `categoriesWithFavorites` = categories with ≥1 favorite; `favoritesByCategory` = resolved sessions + filtered mixes. Only categories in `categoriesWithFavorites` get a section; display category = onboarding choice.
- **Category detail:** SchlafScreen, RuheScreen, ImFlussScreen each have `favoriteSessionsSection` (headline "Favorisierte Sessions"); when resolving customMix from favoriteSessions, exclude mixes with `playbackMode == .klangwelten`. Section shown when `resolvedFavoriteSessions` or filtered `resolvedFavoriteMixes` non-empty; tiles for sessions and mixes.
- **Player:** `PlayerViewModel.currentFavoriteCategory` set when loading a session from a category (e.g. `loadSession(_, category: .flow)`). Full player heart: session mode → `toggleFavorite()` (session + addFavoriteSession) or opens mixer; mixer save → `MixerSheetView.saveMix()` → `customMixRepository.saveMix()` then `favoriteSessionRepository.addFavoriteSession(..., itemType: .customMix, itemId: mix.id)`. Category for add = `favoriteCategoryRaw ?? player.currentFavoriteCategory`. Known bug: addFavoriteSession can fail after successful saveMix ("Mix was saved but could not be added to favorites.").

### Klangwelten Favorites (saved Klangwelten mixes only)

- **Storage:** `users/{userId}/mixes` with `playbackMode: .klangwelten` only. No `favoriteSessions` entries for Klangwelten mixes.
- **Display:** KlangweltenEntryView loads `customMixRepository.getMixes(userId)` and filters `playbackMode == .klangwelten`; shows "Deine Klangwelten". Tapping a saved Klangwelt opens Klangwelten player via `player.loadCustomMix(mix, sounds:, category:)` and coordinator.
- **Save flow:** KlangweltenSoundDrawerView `saveKlangweltFavorite()` calls only `customMixRepository.saveMix(..., playbackMode: .klangwelten)`; must **not** call `favoriteSessionRepository.addFavoriteSession()`.

### Sound Favorites (Library)

- **Storage:** Firestore (FavoritesRepository); Library screen and player heart for single-sound mode.
- **Entities:** `Favorite` (soundId, etc.); `FavoriteSession` (category, itemType, itemId) – used only for category-based session/mix favorites, not Klangwelten.

---

## 🏗️ Architecture Overview (Reference – legacy/other platforms)

### Technology Stack

#### Backend
- **Supabase** - PostgreSQL database with real-time capabilities (reference; iOS uses Firestore)
  - `user_favorites` table for persistent storage
  - Row-level security (RLS) for user data isolation
  - Real-time subscriptions (optional for live updates)
  - Automatic API generation

#### Storage
- **AsyncStorage** - Local storage for offline support
  - `awaveFavorites` key for local favorites cache
  - Fallback when user is unauthenticated
  - Sync queue for offline operations

#### State Management
- **React Hooks** - `useFavoritesManagement` for state management
- **React Context** - `AuthContext` for user authentication state
- **Local State** - Component-level state for UI updates

#### Services Layer
- `ProductionBackendService` - Backend API integration
- `AWAVEStorage` - Local storage service
- `useFavoritesManagement` - Favorites management hook

---

## 📁 File Structure

```
src/
├── hooks/
│   └── useFavoritesManagement.ts       # Main favorites hook
├── components/
│   ├── audio-player/
│   │   └── AudioPlayerFavoriteButton.tsx  # Favorite button component
│   ├── AudioPlayerScreen.tsx            # Player with favorites
│   ├── AudioPlayerEnhanced.tsx         # Enhanced player
│   └── AudioPlayerLayout.tsx           # Layout component
├── screens/
│   └── LibraryScreen.tsx               # Library with favorites
├── services/
│   ├── ProductionBackendService.ts     # Backend API methods
│   └── AWAVEStorage.ts                 # Local storage
├── types/
│   └── hooks.ts                        # Type definitions
└── integrations/
    └── supabase/
        └── client.ts                   # Supabase client
```

---

## 🔧 Components

### useFavoritesManagement Hook
**Location:** `src/hooks/useFavoritesManagement.ts`

**Purpose:** Main hook for managing user favorites

**Parameters:**
```typescript
useFavoritesManagement(categoryId?: string)
```

**Returns:**
```typescript
{
  favorites: FavoriteItem[];
  isLoading: boolean;
  refreshFavorites: () => Promise<void>;
  addFavorite: (userId: string, payload: FavoriteUpsertPayload) => Promise<void>;
  removeFavorite: (favoriteIdOrSoundId: string) => Promise<void>;
  markFavoritePlayed: (favoriteId: string) => Promise<void>;
}
```

**Features:**
- Load favorites from Supabase (primary)
- Load favorites from local storage (fallback)
- Add favorite to backend
- Remove favorite from backend
- Mark favorite as played (usage tracking)
- Filter favorites by category
- Automatic refresh after operations

**State:**
- `favorites: FavoriteItem[]` - Current favorites list
- `isLoading: boolean` - Loading state

**Dependencies:**
- `useAuth` - Authentication context
- `ProductionBackendService` - Backend API
- `AWAVEStorage` - Local storage
- `supabase` - Supabase client

---

### AudioPlayerFavoriteButton Component
**Location:** `src/components/audio-player/AudioPlayerFavoriteButton.tsx`

**Purpose:** Favorite toggle button for audio player

**Props:**
```typescript
interface AudioPlayerFavoriteButtonProps {
  isFavorite: boolean;
  onToggleFavorite: () => void;
}
```

**Features:**
- Visual favorite status indicator
- Toggle favorite on press
- Theme-aware styling
- Heart icon with text label
- Active/inactive states

**Styling:**
- Active: Primary color background, white text
- Inactive: Transparent background, muted text
- Rounded button with icon and text

**Dependencies:**
- `useTheme` - Theme provider
- `Icon` - Icon component

---

### LibraryScreen Component
**Location:** `src/screens/LibraryScreen.tsx`

**Purpose:** Library screen with favorites management

**Features:**
- Display all sounds with favorite indicators
- Toggle favorites from list
- Filter favorites by category
- Search favorites
- View favorite status
- Handle locked/premium content

**Favorite Integration:**
- Uses `useFavoritesManagement` hook
- Displays favorite heart icons
- Handles add/remove operations
- Updates UI optimistically

---

### AudioPlayerScreen Component
**Location:** `src/components/AudioPlayerScreen.tsx`

**Purpose:** Audio player with favorite button

**Props:**
```typescript
interface AudioPlayerScreenProps {
  sound: Sound;
  favoriteId?: string;
  isFavorite: boolean;
  onToggleFavorite: () => void;
  // ... other props
}
```

**Features:**
- Integrates `AudioPlayerFavoriteButton`
- Passes favorite state to button
- Handles favorite toggle callback

---

## 🔌 Services

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Class:** Static service class

#### Methods

**`getUserFavorites(userId: string): Promise<UserFavorite[]>`**
- Fetches all favorites for a user
- Orders by `last_used` (descending)
- Returns empty array on error

**`addFavorite(userId: string, favoriteData: Partial<UserFavorite>): Promise<UserFavorite>`**
- Creates new favorite record
- Sets default values (date_added, use_count: 0, is_public: false)
- Returns created favorite

**`removeFavorite(favoriteId: string, userId: string): Promise<void>`**
- Deletes favorite by ID
- Verifies user ownership
- Returns void on success

**`updateFavoriteUsage(favoriteId: string, userId: string, currentUseCount: number): Promise<UserFavorite>`**
- Updates use_count (increments by 1)
- Updates last_used timestamp
- Returns updated favorite

**Error Handling:**
- All methods use `safeApiCall` wrapper
- Errors are caught and logged
- User-friendly error messages

---

### AWAVEStorage Service
**Location:** `src/services/AWAVEStorage.ts`

**Class:** Static service class

#### Methods

**`getFavorites(): Promise<UserFavorite[]>`**
- Retrieves favorites from AsyncStorage
- Returns empty array if none exist
- Parses JSON data

**`setFavorites(favorites: UserFavorite[]): Promise<void>`**
- Stores favorites in AsyncStorage
- Serializes to JSON
- Used for offline fallback

**Storage Key:**
- `awaveFavorites` - Local favorites cache

---

## 🗄️ Database Schema

### user_favorites Table

```sql
CREATE TABLE user_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sound_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  category_id TEXT,
  tracks JSONB,
  date_added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_used TIMESTAMP WITH TIME ZONE,
  use_count INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, sound_id)
);

-- Indexes
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_sound_id ON user_favorites(sound_id);
CREATE INDEX idx_user_favorites_last_used ON user_favorites(last_used DESC);
CREATE INDEX idx_user_favorites_category_id ON user_favorites(category_id);

-- Row Level Security
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own favorites"
  ON user_favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
  ON user_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own favorites"
  ON user_favorites FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
  ON user_favorites FOR DELETE
  USING (auth.uid() = user_id);
```

### Type Definitions

```typescript
interface UserFavorite {
  id: string;
  user_id: string;
  sound_id: string;
  title: string;
  description?: string | null;
  image_url?: string | null;
  category_id?: string | null;
  tracks?: any | null;
  date_added: string;
  last_used?: string | null;
  use_count: number;
  is_public: boolean;
  created_at: string;
  updated_at: string;
}

interface FavoriteRecord {
  id: string;
  soundId: string;
  title: string;
  description?: string;
  imageUrl?: string;
  categoryId?: string;
  tracks?: AudioTrackConfig;
  createdAt?: string;
  updatedAt?: string;
}

interface FavoriteItem {
  favoriteId: string;
  sound: Sound;
  metadata: FavoriteRecord;
}

interface FavoriteUpsertPayload {
  soundId: string;
  title: string;
  description?: string;
  imageUrl?: string;
  categoryId?: string;
  tracks?: AudioTrackConfig;
}
```

---

## 🔄 Data Flow

### Add Favorite Flow

```
User Action
    │
    ├─> Component calls addFavorite()
    │   └─> useFavoritesManagement.addFavorite()
    │       ├─> Check authentication
    │       ├─> ProductionBackendService.addFavorite()
    │       │   └─> Supabase insert
    │       │       └─> Database insert
    │       └─> refreshFavorites()
    │           └─> Load from Supabase
    │               └─> Update state
    │                   └─> UI updates
```

### Remove Favorite Flow

```
User Action
    │
    ├─> Component calls removeFavorite()
    │   └─> useFavoritesManagement.removeFavorite()
    │       ├─> Find favorite by ID
    │       ├─> ProductionBackendService.removeFavorite()
    │       │   └─> Supabase delete
    │       │       └─> Database delete
    │       └─> refreshFavorites()
    │           └─> Load from Supabase
    │               └─> Update state
    │                   └─> UI updates
```

### Usage Tracking Flow

```
User Plays Favorite
    │
    ├─> markFavoritePlayed()
    │   └─> useFavoritesManagement.markFavoritePlayed()
    │       ├─> Supabase update
    │       │   └─> Update use_count and last_used
    │       └─> refreshFavorites()
    │           └─> Re-sort by last_used
    │               └─> UI updates
```

### Offline Flow

```
User Action (Offline)
    │
    ├─> Check authentication
    │   ├─> Authenticated → Queue for sync
    │   └─> Unauthenticated → Local storage
    │       └─> AWAVEStorage.setFavorites()
    │           └─> AsyncStorage
    │
    └─> When Online
        └─> Sync local to backend
            └─> Merge with remote
                └─> Update UI
```

---

## 🔐 Security Implementation

### Authentication
- All backend operations require authenticated user
- User ID verified before operations
- Row-level security in database

### Authorization
- Users can only access their own favorites
- RLS policies enforce user isolation
- No cross-user data access

### Data Validation
- Input validation before database operations
- Type checking with TypeScript
- Sanitization of user input

### Error Handling
- Graceful error handling
- User-friendly error messages
- No sensitive data in error logs

---

## 🔄 State Management

### Hook State
```typescript
{
  favorites: FavoriteItem[];
  isLoading: boolean;
}
```

### Component State
- Optimistic UI updates
- Local state for immediate feedback
- Sync with hook state after operations

### Storage State
- AsyncStorage for offline cache
- Supabase for persistent storage
- Automatic sync between storage layers

---

## 🌐 API Integration

### Supabase Queries

**Get Favorites:**
```typescript
supabase
  .from('user_favorites')
  .select('*')
  .eq('user_id', userId)
  .order('last_used', { ascending: false })
```

**Add Favorite:**
```typescript
supabase
  .from('user_favorites')
  .insert({
    user_id: userId,
    sound_id: soundId,
    title: title,
    // ... other fields
    date_added: new Date().toISOString(),
    use_count: 0,
    is_public: false,
  })
```

**Remove Favorite:**
```typescript
supabase
  .from('user_favorites')
  .delete()
  .eq('id', favoriteId)
  .eq('user_id', userId)
```

**Update Usage:**
```typescript
supabase
  .from('user_favorites')
  .update({
    use_count: currentUseCount + 1,
    last_used: new Date().toISOString(),
  })
  .eq('id', favoriteId)
  .eq('user_id', userId)
```

---

## 📱 Platform-Specific Notes

### iOS
- AsyncStorage uses native storage
- No platform-specific code required
- Standard React Native components

### Android
- AsyncStorage uses native storage
- No platform-specific code required
- Standard React Native components

### Web (Future)
- localStorage fallback
- Same API surface
- Cross-platform compatibility

---

## 🧪 Testing Strategy

### Unit Tests
- Hook functionality
- Service methods
- Data mapping functions
- Error handling

### Integration Tests
- Backend API calls
- Local storage operations
- State management
- Authentication flow

### E2E Tests
- Complete user flows
- Offline operations
- Error scenarios
- Performance testing

---

## 🐛 Error Handling

### Error Types
- Network errors
- Authentication errors
- Validation errors
- Database errors

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable

### Error Recovery
- Automatic retry for transient failures
- Fallback to local storage
- Queue operations for sync
- Graceful degradation

---

## 📊 Performance Considerations

### Optimization
- Efficient database queries with indexes
- Memoized favorites list
- Optimistic UI updates
- Debounced search (future)

### Caching
- Local storage cache
- React state caching
- Supabase query caching
- Cache invalidation strategy

### Monitoring
- API response times
- Database query performance
- State update frequency
- Error rates

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
