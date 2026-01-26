# Session Based Asynchronous Download of Audio Files - Components Inventory

## 📱 Service Components

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Service Class  
**Purpose:** Core download and cache management

**State:**
- `audioFiles: Map<string, AudioFile>` - All audio files metadata
- `categories: Map<string, AudioCategory>` - Category metadata
- `downloadedFiles: Set<string>` - Downloaded file IDs
- `downloadQueue: Map<string, Promise<string>>` - Active downloads
- `initialized: boolean` - Initialization status

**Key Methods:**
- `initialize()` - Setup and load metadata
- `downloadFile()` - Download with progress tracking
- `searchAudioFiles()` - Search cached metadata
- `getCacheStats()` - Cache statistics
- `optimizeCache()` - LRU cache cleanup

**Dependencies:**
- `react-native-fs` - File system operations
- `@react-native-async-storage/async-storage` - Persistence
- `supabase` client - Storage and database

**Features:**
- Metadata caching in memory
- On-demand downloads
- Download queue management
- Cache optimization
- Real-time metadata sync

---

### UnifiedAudioPlaybackService
**File:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Singleton Service Class  
**Purpose:** On-demand download integration with playback

**State:**
- `audioManager: SupabaseAudioLibraryManager` - Audio manager instance
- `generationService: SoundGenerationService` - Sound generation service

**Key Methods:**
- `playSound()` - Main playback with download support
- `getLocalSoundPath()` - On-demand download trigger
- `detectSoundSource()` - Source type detection
- `isAvailableOffline()` - Offline availability check

**Dependencies:**
- `SupabaseAudioLibraryManager` - Download management
- `SoundGenerationService` - Generated sounds
- `react-native-track-player` - Audio playback
- `react-native-fs` - File system

**Features:**
- Automatic download on sound selection
- Priority-based source selection
- Fallback to streaming
- Progress tracking integration

---

### BackgroundDownloadService
**File:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Service Class  
**Purpose:** Background download orchestration

**State:**
- `audioManager: SupabaseAudioLibraryManager` - Audio manager instance
- `isDownloading: boolean` - Download status
- `downloadQueue: DownloadQueueItem[]` - Download queue

**Key Methods:**
- `downloadCategory()` - Category downloads
- `downloadFavorites()` - Favorites downloads
- `downloadPriorityCategories()` - Priority category downloads
- `isCurrentlyDownloading()` - Status check
- `getQueueSize()` - Queue size

**Dependencies:**
- `SupabaseAudioLibraryManager` - Download execution

**Features:**
- Category-based downloads
- Favorites download
- Priority queue management
- Download status tracking

---

### SearchService
**File:** `src/services/SearchService.ts`  
**Type:** Static Service Class  
**Purpose:** Search with metadata support

**State:**
- `sosConfig: SOSConfig | null` - Cached SOS config
- `sosConfigLoadedAt: number | null` - Cache timestamp

**Key Methods:**
- `searchSounds()` - Search with filters
- `getSearchSuggestions()` - Autocomplete suggestions
- `searchByCategory()` - Category search
- `getPopularSearches()` - Popular terms

**Dependencies:**
- `supabase` client - Database queries

**Features:**
- Full-text search
- Filter support
- Autocomplete suggestions
- Popular searches
- SOS trigger detection

**Note:** While SearchService queries Supabase, SupabaseAudioLibraryManager provides faster cached search via `searchAudioFiles()`.

---

## 🔗 Component Relationships

### Download Flow Component Tree
```
User Action (Select Sound)
    │
    └─> UnifiedAudioPlaybackService.playSound()
        │
        ├─> Check if generated → SoundGenerationService
        │
        ├─> getLocalSoundPath()
        │   ├─> Check local cache → SupabaseAudioLibraryManager.getAudioFile()
        │   │   └─> File exists → Return local path
        │   │
        │   └─> File not local → SupabaseAudioLibraryManager.downloadFile()
        │       ├─> Check download queue → Prevent duplicates
        │       ├─> Get streaming URL → Supabase Storage
        │       ├─> Download file → react-native-fs
        │       ├─> Track progress → Progress callbacks
        │       ├─> Update metadata → Mark as downloaded
        │       └─> Save to cache → AsyncStorage
        │
        └─> Play file or stream
```

### Search Flow Component Tree
```
User Search Query
    │
    └─> SearchService.searchSounds() OR SupabaseAudioLibraryManager.searchAudioFiles()
        │
        ├─> SearchService (Database Query)
        │   └─> Supabase Database Query
        │       └─> Return results
        │
        └─> SupabaseAudioLibraryManager (Cached Search)
            └─> Search in-memory Map
                ├─> Filter by query (title, description, tags)
                ├─> Filter by category
                ├─> Sort by relevance/duration/title
                └─> Return results (< 50ms)
```

### Background Download Component Tree
```
Background Download Trigger
    │
    └─> BackgroundDownloadService.downloadCategory()
        │
        └─> SupabaseAudioLibraryManager.getFilesByCategory()
            └─> For each file
                └─> SupabaseAudioLibraryManager.downloadFile()
                    └─> [Same download flow as above]
```

### Cache Management Component Tree
```
Cache Optimization Trigger
    │
    └─> SupabaseAudioLibraryManager.optimizeCache()
        │
        ├─> getCacheStats()
        │   ├─> Calculate total size
        │   ├─> Get available space
        │   └─> Calculate cache hit rate
        │
        └─> If over limit
            ├─> Sort files by last access (LRU)
            ├─> Remove oldest files
            ├─> Update metadata
            └─> Save cleanup timestamp
```

---

## 🎨 Integration Points

### With Audio Playback
- **UnifiedAudioPlaybackService** triggers downloads
- Downloads happen automatically on sound selection
- Playback continues with streaming if download fails
- Source detection for UI display

### With Search System
- **SearchService** uses database queries
- **SupabaseAudioLibraryManager** provides cached search
- Both return consistent results
- Cached search is faster (< 50ms)

### With Library/UI Components
- Components can check download status
- Components can trigger background downloads
- Components can display cache statistics
- Components can show download progress

### With Offline Support
- Downloaded files available offline
- Metadata cached for offline search
- Cache management prevents storage issues
- Offline availability detection

---

## 🔄 State Management

### Service State
- **In-Memory Maps:** Fast access, no persistence needed
- **Download Queue:** Prevents duplicates, cleared on completion
- **Downloaded Files Set:** Persisted to AsyncStorage
- **Cache Statistics:** Calculated on demand

### Persistent State
- **AsyncStorage:** Download state, cleanup timestamps
- **File System:** Actual audio files
- **Supabase:** Source of truth for metadata

### State Synchronization
- **Real-Time Sync:** Metadata updates via Supabase subscriptions
- **Cache Persistence:** Downloaded files list saved to AsyncStorage
- **File System:** Files persist across app restarts

---

## 🧪 Testing Considerations

### Component Tests
- Service initialization
- Download queue management
- Cache operations
- Search functionality
- Error handling

### Integration Tests
- Download flow with playback
- Search with cached metadata
- Cache cleanup operations
- Real-time sync updates
- Background downloads

### E2E Tests
- Complete user journey (select → download → play)
- Search performance
- Cache management
- Offline functionality
- Error recovery

---

## 📊 Component Metrics

### Complexity
- **SupabaseAudioLibraryManager:** High (core functionality)
- **UnifiedAudioPlaybackService:** Medium (integration layer)
- **BackgroundDownloadService:** Low (orchestration)
- **SearchService:** Medium (search logic)

### Performance
- **Metadata Loading:** < 30 seconds for 3000+ files
- **Search Response:** < 50ms (cached)
- **Download Start:** < 1 second
- **Cache Operations:** < 100ms

### Dependencies
- All services depend on Supabase client
- File operations via react-native-fs
- State persistence via AsyncStorage
- Real-time via Supabase subscriptions

---

## 🔐 Security Considerations

### File Access
- Files stored in app Documents directory
- No external access without app
- Secure file system permissions

### Data Privacy
- No user data in file paths
- Metadata cached locally only
- No sensitive data in logs

---

*For service details, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
