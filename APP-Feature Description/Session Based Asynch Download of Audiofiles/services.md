# Session Based Asynchronous Download of Audio Files - Services Documentation

## 🔧 Service Layer Overview

The asynchronous download system uses a service-oriented architecture with clear separation of concerns. Services handle all download operations, cache management, metadata synchronization, and integration with playback and search systems.

---

## 📦 Services

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Core download and cache management service

#### Configuration
```typescript
STORAGE_BUCKET = 'awave-audio'
LOCAL_AUDIO_DIR = 'Documents/audio'
MAX_CACHE_SIZE = 2 * 1024 * 1024 * 1024 // 2GB
DOWNLOAD_TIMEOUT = 30000 // 30 seconds
BATCH_SIZE = 100 // Metadata loading batch size
```

#### Storage Keys (AsyncStorage)
- `awave.dev.downloadedFiles` - Array of downloaded file IDs (JSON)
- `awave.dev.lastCacheCleanup` - Last cleanup timestamp (ISO string)

#### Methods

**`initialize(): Promise<void>`**
- Creates local directory structure
- Loads cached download data from AsyncStorage
- Loads audio metadata from Supabase (batched)
- Sets up real-time sync subscriptions
- Performs cache optimization
- Called once at app startup
- Throws error on failure

**`loadAudioMetadata(): Promise<void>`**
- Loads metadata in batches (100 per batch)
- Handles large catalogs (3000+ files)
- Tests Supabase connection first
- Converts Supabase metadata to AudioFile format
- Stores in memory Map for O(1) lookup
- Error handling with detailed logging
- Progress tracking for large loads
- Throws error if no files loaded

**`downloadFile(fileId: string, onProgress?: (progress: DownloadProgress) => void): Promise<string>`**
- Checks if file already downloaded (returns local path immediately)
- Checks if download already in progress (returns existing promise)
- Prevents duplicate downloads via download queue
- Downloads file with progress tracking (500ms intervals)
- Updates file metadata on completion
- Saves to downloaded files set
- Persists download state to AsyncStorage
- Returns local file path
- Throws error on failure

**`getStreamingUrl(fileId: string): Promise<string>`**
- Gets streaming URL for audio file
- Creates signed URL for premium content (1 hour expiry)
- Returns public URL for free content
- Handles storage errors
- Throws error if file not found

**`searchAudioFiles(query: string, options?: SearchOptions): AudioFile[]`**
- Searches cached metadata (no network calls)
- Searches by title, description, tags (case-insensitive)
- Filters by category if specified
- Sorts by relevance (searchWeight), duration, or title
- Applies limit if specified
- Returns array of AudioFile objects
- Synchronous operation (instant results)

**`getFilesByCategory(categoryId: string, options?: PaginationOptions): AudioFile[]`**
- Gets files by category with pagination
- Filters by category ID
- Sorts by search weight descending
- Supports offset and limit
- Returns array of AudioFile objects
- Synchronous operation

**`getCacheStats(): Promise<CacheStats>`**
- Calculates cache statistics
- Total downloaded files count
- Total cache size (MB)
- Available storage space
- Cache hit rate calculation
- Last cleanup timestamp
- Returns CacheStats object

**`optimizeCache(): Promise<void>`**
- Checks cache size against 2GB limit
- Removes LRU files if over limit
- Sorts files by last access time (oldest first)
- Targets 80% capacity after cleanup
- Updates file metadata
- Removes files from downloaded set
- Saves cleanup timestamp
- Persists changes to AsyncStorage

**`setupRealTimeSync(): Promise<void>`**
- Subscribes to Supabase real-time changes
- Listens to `sound_metadata` table changes
- Handles INSERT, UPDATE, DELETE events
- Updates local metadata cache automatically
- No app restart required for updates
- Error handling for sync failures

**`getAudioFile(fileId: string): AudioFile | undefined`**
- Gets audio file by ID from cache
- Returns AudioFile or undefined
- Synchronous operation (O(1) lookup)

**`isFileAvailableLocally(fileId: string): Promise<boolean>`**
- Checks if file exists locally
- Verifies file system existence
- Returns boolean
- Async operation

#### Dependencies
- `react-native-fs` - File system operations
- `@react-native-async-storage/async-storage` - Persistence
- `supabase` client - Storage and database
- Supabase Storage API
- Supabase Database API
- Supabase Realtime API

#### Error Handling
- Download errors: Log error, throw exception
- Storage errors: Log error, throw exception
- Network errors: Log error, throw exception
- Metadata errors: Log error, continue with cached data
- Real-time sync errors: Log warning, continue operation

---

### UnifiedAudioPlaybackService
**File:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Singleton Class  
**Purpose:** On-demand download integration with playback

#### Methods

**`initialize(): Promise<void>`**
- Initializes audio manager if not initialized
- Cleans up old generated files
- Called at app startup
- Error handling with logging

**`playSound(sound: Sound): Promise<void>`**
- Main playback method
- Priority: Generated > Local > Download > Stream
- Routes to appropriate source
- Handles all playback types

**`getLocalSoundPath(sound: Sound): Promise<string | null>`**
- Checks if file exists locally
- Triggers on-demand download if not local
- Returns local path or null (fallback to streaming)
- Handles download errors gracefully
- Logs progress in development mode

**`detectSoundSource(sound: Sound): Promise<'generated' | 'local' | 'stream'>`**
- Detects sound source type
- Returns source for UI display
- Checks generated, local, then stream

**`isAvailableOffline(sound: Sound): Promise<boolean>`**
- Checks if sound is available offline
- Generated sounds always available
- Local files available offline
- Returns boolean

#### Dependencies
- `SupabaseAudioLibraryManager` - Download management
- `SoundGenerationService` - Generated sounds
- `react-native-track-player` - Audio playback
- `react-native-fs` - File system

#### Error Handling
- Download failures: Fallback to streaming, log warning
- File system errors: Fallback to streaming, log warning
- Playback errors: Throw exception

---

### BackgroundDownloadService
**File:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Class  
**Purpose:** Background download orchestration

#### Methods

**`downloadCategory(categoryId: string): Promise<void>`**
- Downloads all files from specific category
- Gets files from audio manager
- Downloads each file sequentially
- Tracks success/failure counts
- Logs progress in development mode
- Continues downloading remaining files on error
- Error handling per file

**`downloadFavorites(userId: string): Promise<void>`**
- Downloads user's favorite sounds
- High priority downloads
- Triggered after login
- Prevents concurrent downloads
- Error handling with logging
- TODO: Implementation pending (database integration)

**`downloadPriorityCategories(): Promise<void>`**
- Downloads priority categories
- Order: music > nature > noise > sound
- Background operation
- Sequential category downloads
- Error handling per category

**`isCurrentlyDownloading(): boolean`**
- Returns download status
- Prevents concurrent downloads
- Returns boolean

**`getQueueSize(): number`**
- Returns download queue size
- For status display
- Returns number

#### Dependencies
- `SupabaseAudioLibraryManager` - Download execution

#### Error Handling
- Download errors: Log warning, continue with next file
- Category errors: Log error, continue with next category
- Queue errors: Log error, reset queue

---

### SearchService
**File:** `src/services/SearchService.ts`  
**Type:** Static Service Class  
**Purpose:** Search with metadata support

#### Methods

**`searchSounds(query: string, filters?: SearchFilters): Promise<SoundMetadata[]>`**
- Searches Supabase database
- Full-text search on title, description, tags
- Applies filters (category, brainwave type, duration, public/private)
- Returns up to 50 results
- Sorted by title ascending
- Error handling returns empty array

**`getSearchSuggestions(query: string): Promise<SearchSuggestion[]>`**
- Gets autocomplete suggestions
- Requires minimum 2 characters
- Searches tags, keywords, category
- Returns top 5 suggestions
- Sorted by count descending

**`searchByCategory(categoryId: string): Promise<SoundMetadata[]>`**
- Searches sounds by category
- Returns all sounds in category
- Sorted by title ascending
- Error handling returns empty array

**`getPopularSearches(limit: number): Promise<string[]>`**
- Gets popular search terms
- Based on search analytics
- Sorted by results count
- Returns array of search queries

**`logSearch(userId: string | null, query: string, resultsCount: number, sosTriggered: boolean): Promise<void>`**
- Logs search query to analytics
- Includes SOS trigger status
- Error handling with warning

#### Dependencies
- `supabase` client - Database queries

#### Error Handling
- Search errors: Log error, return empty array
- Database errors: Log error, return empty array
- Analytics errors: Log warning, continue

---

## 🔗 Service Dependencies

### Dependency Graph
```
UnifiedAudioPlaybackService
├── SupabaseAudioLibraryManager
│   ├── react-native-fs
│   ├── AsyncStorage
│   └── supabase client
│       ├── Supabase Storage API
│       ├── Supabase Database API
│       └── Supabase Realtime API
└── SoundGenerationService

BackgroundDownloadService
└── SupabaseAudioLibraryManager
    └── [Same dependencies as above]

SearchService
└── supabase client
    └── Supabase Database API
```

### External Dependencies

#### Supabase
- **Storage API:** Audio file storage and retrieval
- **Database API:** Metadata queries and updates
- **Realtime API:** Metadata synchronization

#### React Native Libraries
- **react-native-fs:** File system operations
- **@react-native-async-storage/async-storage:** Local persistence
- **react-native-track-player:** Audio playback (via UnifiedAudioPlaybackService)

---

## 🔄 Service Interactions

### On-Demand Download Flow
```
User selects sound
    │
    └─> UnifiedAudioPlaybackService.playSound()
        │
        └─> UnifiedAudioPlaybackService.getLocalSoundPath()
            │
            ├─> SupabaseAudioLibraryManager.getAudioFile()
            │   └─> Check if downloaded
            │
            └─> SupabaseAudioLibraryManager.downloadFile()
                ├─> Check download queue
                ├─> SupabaseAudioLibraryManager.getStreamingUrl()
                │   └─> Supabase Storage API
                ├─> react-native-fs.downloadFile()
                ├─> Update metadata
                └─> AsyncStorage.setItem()
```

### Search Flow
```
User searches
    │
    ├─> SearchService.searchSounds()
    │   └─> Supabase Database API
    │       └─> Return results
    │
    └─> SupabaseAudioLibraryManager.searchAudioFiles()
        └─> Search in-memory Map
            └─> Return results (< 50ms)
```

### Background Download Flow
```
Background trigger
    │
    └─> BackgroundDownloadService.downloadCategory()
        │
        └─> SupabaseAudioLibraryManager.getFilesByCategory()
            └─> For each file
                └─> SupabaseAudioLibraryManager.downloadFile()
                    └─> [Same download flow as above]
```

### Cache Cleanup Flow
```
Cache limit reached
    │
    └─> SupabaseAudioLibraryManager.optimizeCache()
        │
        ├─> SupabaseAudioLibraryManager.getCacheStats()
        │   └─> react-native-fs.getFSInfo()
        │
        └─> For each file to remove
            └─> react-native-fs.unlink()
                └─> Update metadata
                    └─> AsyncStorage.setItem()
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Cache operations
- Download queue management
- Metadata conversion
- Search functionality

### Integration Tests
- Supabase API calls
- File system operations
- Download progress tracking
- Cache optimization
- Real-time sync
- AsyncStorage operations

### Mocking
- Supabase client
- react-native-fs
- AsyncStorage
- Network requests
- File system operations

---

## 📊 Service Metrics

### Performance
- **Metadata Load:** < 30 seconds for 3000+ files
- **Search Response:** < 50ms (cached)
- **Download Start:** < 1 second
- **Cache Operations:** < 100ms
- **Real-Time Sync:** < 1 second latency

### Reliability
- **Download Success Rate:** > 95%
- **Cache Hit Rate:** > 80%
- **Metadata Sync Success:** > 99%
- **Search Accuracy:** 100% (cached metadata)

### Error Rates
- **Download Failures:** < 5%
- **Cache Errors:** < 1%
- **Metadata Sync Failures:** < 1%
- **Search Errors:** < 1%

---

## 🔐 Security Considerations

### File Storage
- Files stored in app Documents directory
- No external access without app
- Secure file system permissions

### URL Generation
- Signed URLs for premium content (1 hour expiry)
- Public URLs for free content
- No direct file access without authentication

### Data Privacy
- No user data in file paths
- Metadata cached locally only
- No sensitive data in logs

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging
- Graceful degradation

### Error Types
- **Network Errors:** Download failures, connection issues
- **Storage Errors:** Quota exceeded, permissions
- **File System Errors:** Corruption, missing files
- **Metadata Errors:** Sync failures, invalid data
- **Cache Errors:** Cleanup failures, corruption

---

## 📝 Service Configuration

### Environment Variables
```typescript
// Supabase configuration (from client setup)
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// App startup
await SupabaseAudioLibraryManager.getInstance().initialize();
await UnifiedAudioPlaybackService.getInstance().initialize();
```

### Service Cleanup
```typescript
// App shutdown (if needed)
// Services are singletons, cleanup handled automatically
```

---

## 🔄 Service Updates

### Future Enhancements
- Resume interrupted downloads
- Download prioritization
- Bandwidth management
- Enhanced cache strategies
- Multi-threaded downloads
- Download scheduling

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
