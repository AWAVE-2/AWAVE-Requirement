# Library System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase Database** - Primary data source
  - `sound_metadata` table - Sound catalog
  - `user_favorites` table - User favorites
  - Real-time subscriptions for metadata updates

- **Supabase Storage** - Audio file storage
  - `awave-audio` bucket - Audio files
  - Public and signed URLs for streaming
  - Progressive download support

#### State Management
- **React Hooks** - Component state management
  - `useState` - Local component state
  - `useMemo` - Computed values and filtering
  - `useCallback` - Memoized callbacks
  - `useEffect` - Side effects and data loading

- **Custom Hooks** - Reusable logic
  - `useFavoritesManagement` - Favorites state and operations
  - `useProductionAuth` - Authentication state
  - `useUnifiedTheme` - Theme management

#### Services Layer
- `ProductionBackendService` - Supabase API integration
- `SupabaseAudioLibraryManager` - Audio file management
- `AudioLibraryManager` - Legacy compatibility layer
- Subscription Service - Tier checking and filtering

#### Storage
- **AsyncStorage** - Local caching
- **React Native FS** - File system for offline downloads
- **Supabase Session** - User authentication state

---

## 📁 File Structure

```
src/
├── screens/
│   └── LibraryScreen.tsx              # Main library screen
├── components/
│   └── SoundLibraryPicker.tsx         # Sound selection picker
├── hooks/
│   └── useFavoritesManagement.ts      # Favorites management hook
├── services/
│   ├── ProductionBackendService.ts    # Backend API service
│   ├── SupabaseAudioLibraryManager.ts # Audio library manager
│   ├── AudioLibraryManager.ts         # Legacy compatibility
│   └── subscriptions.ts               # Subscription tier service
├── integrations/
│   └── supabase/
│       └── client.ts                  # Supabase client and types
└── data/
    └── exactDataStructures.ts         # Category and sound data
```

---

## 🔧 Components

### LibraryScreen
**Location:** `src/screens/LibraryScreen.tsx`

**Purpose:** Main library interface with browsing, search, filtering, and mix creation

**Props:**
```typescript
interface LibraryScreenProps {
  onClose?: () => void; // Optional close callback for modal context
}
```

**State:**
- `subscriptionTier: SubscriptionTier` - User subscription tier
- `libraryStats: { total: number; accessible: number }` - Library statistics
- `rawMetadata: SoundMetadata[]` - Raw sound metadata from backend
- `tracks: LibraryTrack[]` - Processed track data
- `selectedCategory: string` - Currently selected category filter
- `searchQuery: string` - Current search query
- `isLoading: boolean` - Loading state
- `selectedSounds: Set<string>` - Selected sound IDs for mix creation
- `isSelectMode: boolean` - Mix creation mode state

**Features:**
- Sound catalog loading from Supabase
- Real-time search functionality
- Category filtering
- Favorites management integration
- Subscription-based content filtering
- Mix creation mode (select up to 4 sounds)
- Library statistics display
- Error handling and retry

**Dependencies:**
- `useFavoritesManagement` hook
- `useProductionAuth` hook
- `ProductionBackendService`
- `filterContentBySubscription` service
- `useUnifiedTheme` hook
- `useTranslation` hook

---

### SoundLibraryPicker
**Location:** `src/components/SoundLibraryPicker.tsx`

**Purpose:** Reusable sound selection picker component

**Props:**
```typescript
interface SoundLibraryPickerProps {
  categoryId: string;
  onSoundSelect: (sound: Sound) => void;
  selectedSoundId?: string;
}
```

**Features:**
- Category-based sound filtering
- Search functionality
- Sound selection with visual feedback
- Loading states
- Empty states

**Dependencies:**
- `exactDataStructures` - Sound data
- `useTheme` hook
- `GlassMorphism` component

---

## 🔌 Services

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Library-Related Methods:**

**`getSoundMetadata(): Promise<SoundMetadata[]>`**
- Fetches all sound metadata from Supabase
- Returns array of sound metadata objects
- Handles errors with safeApiCall wrapper

**`addFavorite(userId: string, favoriteData: Partial<UserFavorite>): Promise<UserFavorite>`**
- Adds sound to user favorites
- Creates record in user_favorites table
- Returns created favorite record

**`removeFavorite(favoriteId: string, userId: string): Promise<void>`**
- Removes favorite from user favorites
- Deletes record from user_favorites table
- Validates user ownership

---

### SupabaseAudioLibraryManager
**Location:** `src/services/SupabaseAudioLibraryManager.ts`

**Class:** Singleton service

**Purpose:** Audio file management with Supabase Storage integration

**Key Methods:**

**`initialize(): Promise<void>`**
- Initializes audio library manager
- Creates local directory structure
- Loads cached data
- Loads audio metadata from Supabase
- Sets up real-time sync
- Performs cache optimization

**`loadAudioMetadata(): Promise<void>`**
- Loads sound metadata in batches (100 per batch)
- Converts Supabase metadata to AudioFile format
- Handles large catalogs (3000+ files)
- Error handling and logging

**`getStreamingUrl(fileId: string): Promise<string>`**
- Gets streaming URL for audio file
- Creates signed URL for premium content (1 hour expiry)
- Returns public URL for free content

**`downloadFile(fileId: string, onProgress?: (progress: DownloadProgress) => void): Promise<string>`**
- Downloads audio file with progress tracking
- Checks if already downloaded
- Prevents duplicate downloads
- Updates file metadata on completion
- Saves to local file system

**`getLocalAudioPath(fileId: string): string | null`**
- Returns local file path if available
- Returns null if not downloaded

**`isFileAvailableLocally(fileId: string): Promise<boolean>`**
- Checks if file exists locally
- Verifies file system existence

**`searchAudioFiles(query: string, options?: SearchOptions): AudioFile[]`**
- Searches audio files by query
- Filters by category if specified
- Sorts by relevance, duration, or title
- Applies limit if specified

**`getFilesByCategory(categoryId: string, options?: PaginationOptions): AudioFile[]`**
- Gets files by category with pagination
- Sorts by search weight
- Supports offset and limit

**`getCacheStats(): Promise<CacheStats>`**
- Returns cache statistics
- Total files, total size, available space
- Cache hit rate, last cleanup time

**`optimizeCache(): Promise<void>`**
- Removes least recently used files if over limit
- Target: 80% of MAX_CACHE_SIZE (2GB)
- Updates file metadata
- Saves cache state

**Configuration:**
- `STORAGE_BUCKET = 'awave-audio'`
- `LOCAL_AUDIO_DIR = ${RNFS.DocumentDirectoryPath}/audio`
- `MAX_CACHE_SIZE = 2GB`
- `DOWNLOAD_TIMEOUT = 30 seconds`

---

### AudioLibraryManager
**Location:** `src/services/AudioLibraryManager.ts`

**Purpose:** Legacy compatibility layer

**Implementation:**
- Delegates all operations to SupabaseAudioLibraryManager
- Maintains backward compatibility
- Singleton pattern

---

### Subscription Service
**Location:** `src/services/subscriptions.ts`

**Functions:**

**`getUserSubscriptionTier(userId: string): Promise<SubscriptionTier>`**
- Gets user subscription tier
- Returns: 'none' | 'free' | 'premium' | 'pro'

**`filterContentBySubscription(content: SoundMetadata[], tier: SubscriptionTier): FilterResult`**
- Filters content by subscription tier
- Returns accessible content and statistics
- Marks locked content

---

## 🪝 Hooks

### useFavoritesManagement
**Location:** `src/hooks/useFavoritesManagement.ts`

**Purpose:** Favorites state management and operations

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
- Loads favorites from Supabase
- Falls back to local storage if not authenticated
- Syncs with backend on add/remove
- Real-time favorite status updates
- Category filtering support

**Dependencies:**
- `useAuth` context
- `ProductionBackendService`
- `AWAVEStorage`
- Supabase client

---

## 🔐 Data Models

### LibraryTrack
```typescript
interface LibraryTrack {
  id: string;
  title: string;
  description: string;
  categoryId: string | null;
  categoryLabel: string;
  categoryIcon: string;
  duration: number | null;
  tags: string[];
  keywords: string[];
  audioUrl: string | null;
  isFavorite: boolean;
  bucketId?: string | null;
  storagePath?: string | null;
  isLocked: boolean;
}
```

### SoundMetadata
```typescript
interface SoundMetadata {
  sound_id: string;
  id?: string;
  title: string;
  description: string | null;
  category_id: string;
  duration: number | null;
  tags: string[];
  keywords: string[];
  file_url?: string | null;
  file_path?: string | null;
  search_weight: number;
  created_at: string;
  updated_at: string;
}
```

### FavoriteItem
```typescript
interface FavoriteItem {
  favoriteId: string;
  sound: Sound;
  metadata: FavoriteRecord;
}
```

### AudioFile
```typescript
interface AudioFile {
  id: string;
  title: string;
  description: string;
  category: string;
  subcategory: string;
  duration: number;
  size: number;
  storageType: 'local' | 'remote';
  localPath?: string;
  remoteUrl?: string;
  storagePath: string;
  isDownloaded: boolean;
  isPremium: boolean;
  tags: string[];
  searchWeight: number;
  createdAt: string;
  updatedAt: string;
}
```

---

## 🔄 State Management

### LibraryScreen State Flow
```
Component Mount
    │
    ├─> Load Tracks (ProductionBackendService.getSoundMetadata)
    │   └─> Set rawMetadata
    │
    ├─> Load Subscription Tier (getUserSubscriptionTier)
    │   └─> Set subscriptionTier
    │
    └─> Load Favorites (useFavoritesManagement)
        └─> Set favoriteIds

rawMetadata + subscriptionTier + favoriteIds
    │
    └─> Process Tracks
        ├─> Filter by subscription tier
        ├─> Map to LibraryTrack format
        ├─> Mark favorites
        └─> Mark locked content
            └─> Set tracks

tracks + selectedCategory + searchQuery
    │
    └─> Filter Tracks
        ├─> Filter by category
        └─> Filter by search query
            └─> Set filteredTracks
```

---

## 🌐 API Integration

### Supabase Database Queries

**Get Sound Metadata:**
```typescript
supabase
  .from('sound_metadata')
  .select('*')
  .order('search_weight', { ascending: false })
```

**Get User Favorites:**
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
    description: description,
    category_id: categoryId,
    date_added: new Date().toISOString()
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

### Supabase Storage

**Get Streaming URL (Public):**
```typescript
supabase.storage
  .from('awave-audio')
  .getPublicUrl(storagePath)
```

**Get Streaming URL (Signed - Premium):**
```typescript
supabase.storage
  .from('awave-audio')
  .createSignedUrl(storagePath, 3600) // 1 hour expiry
```

---

## 📱 Platform-Specific Notes

### iOS
- Native file system access via RNFS
- Background download support
- Document directory for audio files
- Cache management with system limits

### Android
- Native file system access via RNFS
- Background download support
- External storage for audio files
- Cache management with system limits

---

## 🧪 Testing Strategy

### Unit Tests
- Track filtering logic
- Search query matching
- Category filtering
- Subscription tier filtering
- Favorite status updates

### Integration Tests
- Supabase API calls
- Favorites sync
- Audio download
- Cache management
- Real-time updates

### E2E Tests
- Complete library browsing flow
- Search and filter flow
- Favorite add/remove flow
- Mix creation flow
- Offline download flow

---

## 🐛 Error Handling

### Error Types
- Network errors (connection failures)
- API errors (Supabase errors)
- File system errors (download failures)
- Authentication errors (favorites)
- Subscription errors (tier checking)

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

---

## 📊 Performance Considerations

### Optimization
- Memoized filtered tracks (useMemo)
- Batch metadata loading (100 per batch)
- Lazy loading of audio files
- Efficient search filtering
- Cache optimization (LRU)

### Monitoring
- Library load time
- Search response time
- Favorite sync success rate
- Download success rate
- Cache hit rate

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
