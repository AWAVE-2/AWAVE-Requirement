# Library System - Services Documentation

## 🔧 Service Layer Overview

The Library system uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, audio file management, favorites synchronization, and subscription tier checking.

---

## 📦 Services

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Supabase API integration layer

#### Library-Related Methods

**`getSoundMetadata(): Promise<SoundMetadata[]>`**
- Fetches all sound metadata from Supabase
- Queries `sound_metadata` table
- Orders by `category_id` ascending
- Returns array of sound metadata objects
- Handles errors with `safeApiCall` wrapper
- Throws user-friendly error messages

**Usage:**
```typescript
const metadata = await ProductionBackendService.getSoundMetadata();
```

**Error Handling:**
- Network errors: User-friendly message with retry suggestion
- API errors: Logged with details, thrown with context

---

**`searchSounds(keyword: string): Promise<SoundMetadata[]>`**
- Searches sounds by keyword
- Searches in title, keywords, and tags
- Uses case-insensitive matching (ilike)
- Orders by search_weight descending
- Returns matching sound metadata

**Usage:**
```typescript
const results = await ProductionBackendService.searchSounds('rain');
```

---

**`addFavorite(userId: string, favoriteData: Partial<UserFavorite>): Promise<UserFavorite>`**
- Adds sound to user favorites
- Creates record in `user_favorites` table
- Sets `date_added` to current timestamp
- Initializes `use_count` to 0
- Sets `is_public` to false
- Returns created favorite record

**Parameters:**
```typescript
{
  userId: string;
  favoriteData: {
    sound_id: string;
    title: string;
    description?: string | null;
    category_id?: string | null;
    image_url?: string | null;
    tracks?: any | null;
  }
}
```

**Usage:**
```typescript
const favorite = await ProductionBackendService.addFavorite(userId, {
  sound_id: 'sound-123',
  title: 'Ocean Waves',
  description: 'Calming ocean sounds',
  category_id: 'ocean'
});
```

---

**`removeFavorite(favoriteId: string, userId: string): Promise<void>`**
- Removes favorite from user favorites
- Deletes record from `user_favorites` table
- Validates user ownership (user_id check)
- Returns void on success

**Usage:**
```typescript
await ProductionBackendService.removeFavorite(favoriteId, userId);
```

---

**`getUserFavorites(userId: string): Promise<UserFavorite[]>`**
- Gets all favorites for user
- Queries `user_favorites` table
- Filters by `user_id`
- Orders by `last_used` descending
- Returns array of favorite records

**Usage:**
```typescript
const favorites = await ProductionBackendService.getUserFavorites(userId);
```

---

**`updateFavoriteUsage(favoriteId: string, userId: string, currentUseCount: number): Promise<UserFavorite>`**
- Updates favorite usage tracking
- Increments `use_count`
- Updates `last_used` timestamp
- Called when user plays a favorite sound

**Usage:**
```typescript
await ProductionBackendService.updateFavoriteUsage(favoriteId, userId, currentCount);
```

---

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Audio file management with Supabase Storage

#### Configuration
```typescript
STORAGE_BUCKET = 'awave-audio'
LOCAL_AUDIO_DIR = ${RNFS.DocumentDirectoryPath}/audio
MAX_CACHE_SIZE = 2 * 1024 * 1024 * 1024 // 2GB
DOWNLOAD_TIMEOUT = 30000 // 30 seconds
```

#### Methods

**`getInstance(): SupabaseAudioLibraryManager`**
- Returns singleton instance
- Creates instance if not exists

**`initialize(): Promise<void>`**
- Initializes audio library manager
- Creates local directory structure
- Loads cached data from AsyncStorage
- Loads audio metadata from Supabase (batched)
- Sets up real-time sync subscriptions
- Performs cache optimization
- Called once at app startup

**`loadAudioMetadata(): Promise<void>`**
- Loads sound metadata in batches (100 per batch)
- Handles large catalogs (3000+ files)
- Converts Supabase metadata to AudioFile format
- Stores in memory Map
- Error handling with detailed logging
- Progress tracking for large loads

**`getStreamingUrl(fileId: string): Promise<string>`**
- Gets streaming URL for audio file
- Creates signed URL for premium content (1 hour expiry)
- Returns public URL for free content
- Handles storage errors

**`downloadFile(fileId: string, onProgress?: (progress: DownloadProgress) => void): Promise<string>`**
- Downloads audio file with progress tracking
- Checks if already downloaded (returns local path)
- Prevents duplicate downloads (download queue)
- Downloads to local file system
- Updates file metadata on completion
- Saves to downloaded files set
- Returns local file path

**Progress Callback:**
```typescript
onProgress?: (progress: {
  fileId: string;
  bytesWritten: number;
  contentLength: number;
  progress: number; // 0-100
  isComplete: boolean;
}) => void
```

**`getLocalAudioPath(fileId: string): string | null`**
- Returns local file path if available
- Returns null if not downloaded
- No async operations

**`isFileAvailableLocally(fileId: string): Promise<boolean>`**
- Checks if file exists locally
- Verifies file system existence
- Returns boolean

**`searchAudioFiles(query: string, options?: SearchOptions): AudioFile[]`**
- Searches audio files by query
- Searches in title, description, tags
- Filters by category if specified
- Sorts by relevance, duration, or title
- Applies limit if specified
- Returns array of AudioFile objects

**Search Options:**
```typescript
{
  category?: string;
  limit?: number;
  sortBy?: 'relevance' | 'duration' | 'title';
}
```

**`getFilesByCategory(categoryId: string, options?: PaginationOptions): AudioFile[]`**
- Gets files by category with pagination
- Filters by category ID
- Sorts by search weight descending
- Supports offset and limit
- Returns array of AudioFile objects

**Pagination Options:**
```typescript
{
  limit?: number;
  offset?: number;
}
```

**`getCacheStats(): Promise<CacheStats>`**
- Returns cache statistics
- Total files, total size, available space
- Cache hit rate, last cleanup time
- Calculates from downloaded files

**Cache Stats:**
```typescript
{
  totalFiles: number;
  totalSize: number; // in MB
  availableSpace: number; // in bytes
  cacheHitRate: number; // 0-1
  lastCleanup: string; // ISO timestamp
}
```

**`optimizeCache(): Promise<void>`**
- Removes least recently used files if over limit
- Target: 80% of MAX_CACHE_SIZE (2GB)
- Sorts files by last access time (oldest first)
- Deletes files until target size reached
- Updates file metadata
- Saves cache state to AsyncStorage

**`getAllAudioFiles(): AudioFile[]`**
- Returns all available audio files
- Returns array from memory Map
- No async operations

**`getAudioFile(fileId: string): AudioFile | undefined`**
- Gets audio file by ID
- Returns AudioFile or undefined
- No async operations

**`isInitialized(): boolean`**
- Checks if manager is initialized
- Returns boolean

#### Real-Time Sync
- Subscribes to `sound_metadata` table changes
- Updates local cache on INSERT/UPDATE
- Removes from cache on DELETE
- Handles sync errors gracefully

#### Cache Management
- Stores downloaded file IDs in AsyncStorage
- Loads cache on initialization
- Saves cache on download completion
- Optimizes cache when over limit

---

### AudioLibraryManager
**File:** `src/services/AudioLibraryManager.ts`  
**Type:** Singleton Class (Legacy Compatibility)

**Purpose:** Legacy compatibility layer for backward compatibility

**Implementation:**
- Delegates all operations to SupabaseAudioLibraryManager
- Maintains same interface as legacy implementation
- Singleton pattern

**Methods:** All methods delegate to SupabaseAudioLibraryManager

---

### Subscription Service
**File:** `src/services/subscriptions.ts`

**Functions:**

**`getUserSubscriptionTier(userId: string): Promise<SubscriptionTier>`**
- Gets user subscription tier
- Queries subscriptions table
- Returns: 'none' | 'free' | 'premium' | 'pro'
- Defaults to 'none' if no subscription

**`filterContentBySubscription(content: SoundMetadata[], tier: SubscriptionTier): FilterResult`**
- Filters content by subscription tier
- Marks locked content
- Returns accessible content and statistics

**Filter Result:**
```typescript
{
  totalContent: number;
  accessibleCount: number;
  accessibleContent: SoundMetadata[];
  lockedContent: SoundMetadata[];
}
```

---

## 🔗 Service Dependencies

### Dependency Graph
```
LibraryScreen
├── ProductionBackendService
│   └── supabase client
│       ├── Database API
│       └── Storage API
├── useFavoritesManagement
│   ├── ProductionBackendService
│   ├── AWAVEStorage
│   └── supabase client
├── SupabaseAudioLibraryManager
│   ├── supabase client
│   ├── RNFS
│   └── AsyncStorage
└── Subscription Service
    └── supabase client
```

### External Dependencies

#### Supabase
- **Database API:** Sound metadata, user favorites
- **Storage API:** Audio file storage and streaming
- **Realtime API:** Metadata sync subscriptions

#### Native Modules
- **React Native FS:** File system operations
- **AsyncStorage:** Local caching

---

## 🔄 Service Interactions

### Library Loading Flow
```
LibraryScreen Mount
    │
    └─> ProductionBackendService.getSoundMetadata()
        └─> Supabase Database
            └─> Return SoundMetadata[]
                └─> Process & Display
```

### Favorites Flow
```
User Clicks Favorite
    │
    ├─> useFavoritesManagement.addFavorite()
    │   └─> ProductionBackendService.addFavorite()
    │       └─> Supabase Database
    │           └─> Insert user_favorites
    │               └─> Return Favorite
    │                   └─> Update UI
    │
    └─> useFavoritesManagement.removeFavorite()
        └─> ProductionBackendService.removeFavorite()
            └─> Supabase Database
                └─> Delete user_favorites
                    └─> Update UI
```

### Audio Download Flow
```
User Requests Download
    │
    └─> SupabaseAudioLibraryManager.downloadFile()
        ├─> Check if already downloaded
        │   └─> Return local path (if exists)
        │
        └─> Download from Supabase Storage
            ├─> Get streaming URL
            ├─> Download with progress
            ├─> Save to local file system
            ├─> Update metadata
            └─> Save cache state
                └─> Return local path
```

### Subscription Filtering Flow
```
Load Library
    │
    ├─> getUserSubscriptionTier()
    │   └─> Supabase Database
    │       └─> Return SubscriptionTier
    │
    └─> filterContentBySubscription()
        ├─> Filter by tier
        ├─> Mark locked content
        └─> Return FilterResult
            └─> Display accessible content
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Data transformation
- Cache operations
- Filter logic

### Integration Tests
- Supabase API calls
- File download operations
- Favorites sync
- Cache management
- Real-time sync

### Mocking
- Supabase client
- RNFS operations
- AsyncStorage
- Network requests

---

## 📊 Service Metrics

### Performance
- **Metadata Load:** < 3 seconds (100 items per batch)
- **Search:** < 100ms (in-memory)
- **Favorite Add/Remove:** < 500ms
- **Download:** Variable (network dependent)
- **Cache Operations:** < 50ms

### Reliability
- **Metadata Load Success Rate:** > 95%
- **Favorite Sync Success Rate:** > 99%
- **Download Success Rate:** > 90%
- **Cache Hit Rate:** > 60%

### Error Rates
- **Network Errors:** < 2%
- **API Errors:** < 1%
- **File System Errors:** < 0.5%

---

## 🔐 Security Considerations

### API Security
- User authentication required for favorites
- User ownership validation
- Secure Supabase API calls
- Signed URLs for premium content

### File Security
- Local files stored in app directory
- No sensitive data in file paths
- Secure file system access

### Data Privacy
- User favorites are private by default
- No sharing of user data
- Secure token storage

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **API Errors:** Supabase errors
- **File System Errors:** Download/storage failures
- **Authentication Errors:** User not authenticated
- **Subscription Errors:** Tier checking failures

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// App startup
await SupabaseAudioLibraryManager.getInstance().initialize();
```

### Service Cleanup
```typescript
// App shutdown (if needed)
// Services are stateless, no cleanup required
```

---

## 🔄 Service Updates

### Future Enhancements
- Batch favorite operations
- Offline favorites sync
- Enhanced cache strategies
- Background download queue
- Download prioritization

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
