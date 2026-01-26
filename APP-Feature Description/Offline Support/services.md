# Offline Support System - Services Documentation

## 🔧 Service Layer Overview

The offline support system uses a service-oriented architecture with clear separation of concerns. Services handle all offline operations, downloads, synchronization, and network management.

---

## 📦 Services

### OfflineQueueService
**File:** `src/services/OfflineQueueService.ts`  
**Type:** Static Service Class  
**Purpose:** Offline operation queue management and synchronization

#### Configuration
```typescript
QUEUE_KEY = 'offline_action_queue'
MAX_RETRIES = 3
```

#### Methods

**`addToQueue(action, table, data): Promise<void>`**
- Adds operation to offline queue
- Generates unique action ID
- Stores in AsyncStorage
- Attempts immediate processing if online
- Used by: Favorites, Profile, any feature needing offline queuing

**`processQueue(): Promise<number>`**
- Processes all queued actions
- Checks network connectivity
- Executes actions in order
- Handles retries and failures
- Returns count of processed actions
- Prevents concurrent processing

**`getQueueStatus(): Promise<QueueStatus>`**
- Returns queue statistics
- Count, oldest timestamp, action types
- Used for debugging and status display

**`initialize(): Promise<() => void>`**
- Initializes service
- Processes pending queue
- Sets up network listener
- Returns cleanup function
- Called at app startup

#### Dependencies
- `@react-native-async-storage/async-storage` - Queue persistence
- `@react-native-community/netinfo` - Network state monitoring
- `supabase` client - Database operations

#### Storage
- `offline_action_queue` - Queued operations (AsyncStorage)

#### Error Handling
- Network errors: Queue remains, retry on connection
- Operation errors: Increment retry, retry up to max
- Max retries exceeded: Discard action, log error

---

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Audio file download and local storage management

#### Configuration
```typescript
STORAGE_BUCKET = 'awave-audio'
LOCAL_AUDIO_DIR = 'Documents/audio'
MAX_CACHE_SIZE = 2GB
DOWNLOAD_TIMEOUT = 30000 // 30 seconds
```

#### Methods

**`initialize(): Promise<void>`**
- Creates local directories
- Loads cached data
- Loads audio metadata from Supabase (batched)
- Sets up real-time sync
- Performs cache optimization
- Called at app startup

**`downloadFile(fileId, onProgress?): Promise<string>`**
- Downloads file from Supabase Storage
- Checks if already downloaded
- Prevents duplicate downloads
- Tracks download progress
- Returns local file path
- Used by: UnifiedAudioPlaybackService, BackgroundDownloadService

**`getStreamingUrl(fileId): Promise<string>`**
- Gets public URL for free content
- Creates signed URL for premium content (1 hour expiry)
- Returns streaming URL
- Used for streaming playback

**`getCacheStats(): Promise<CacheStats>`**
- Calculates cache statistics
- Total files, size, available space
- Cache hit rate
- Last cleanup timestamp
- Used for cache management UI

**`optimizeCache(): Promise<void>`**
- Checks cache size against limit
- Removes LRU files if over limit
- Targets 80% capacity after cleanup
- Updates metadata and storage
- Called on app initialization

#### Dependencies
- `react-native-fs` - File system operations
- `@react-native-async-storage/async-storage` - Metadata storage
- `supabase` client - Storage and database

#### Storage
- `awave.dev.downloadedFiles` - Downloaded file IDs (AsyncStorage)
- `awave.dev.lastCacheCleanup` - Last cleanup timestamp (AsyncStorage)
- `Documents/audio/{category}/{sound_id}.mp3` - Audio files (File System)

#### Error Handling
- Download errors: Log error, return null (fallback to streaming)
- Storage errors: Log error, continue operation
- Network errors: Download fails, fallback to streaming

---

### BackgroundDownloadService
**File:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Class  
**Purpose:** Proactive content downloading

#### Methods

**`downloadFavorites(userId): Promise<void>`**
- Downloads user's favorite sounds
- High priority downloads
- Triggered after login
- Uses SupabaseAudioLibraryManager

**`downloadCategory(categoryId): Promise<void>`**
- Downloads all files from category
- Processes files sequentially
- Tracks success/failure counts
- Used for bulk downloads

**`downloadPriorityCategories(): Promise<void>`**
- Downloads priority categories in order
- Order: music > nature > noise > sound
- Based on audio inventory counts
- Background process

#### Dependencies
- `SupabaseAudioLibraryManager` - File downloads

#### Error Handling
- Download failures: Log error, continue with next file
- Network errors: Download fails, can retry later

---

### UnifiedAudioPlaybackService
**File:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Singleton Class  
**Purpose:** Unified audio playback with offline support

#### Playback Priority
1. Generated sounds (always available)
2. Local files (downloaded)
3. Stream (requires network)

#### Methods

**`initialize(): Promise<void>`**
- Initializes audio manager
- Cleans up old generated files
- Called at app startup

**`playSound(sound): Promise<void>`**
- Main playback method
- Routes to appropriate source
- Priority: Generated > Local > Stream
- Used by audio player components

**`getLocalSoundPath(sound): Promise<string | null>`**
- Checks if file exists locally
- Attempts on-demand download if not local
- Returns local path or null
- Used for offline availability check

**`isAvailableOffline(sound): Promise<boolean>`**
- Checks if sound is available offline
- Generated sounds: always true
- Other sounds: checks local availability
- Used for offline indicators

#### Dependencies
- `SupabaseAudioLibraryManager` - File management
- `SoundGenerationService` - Generated sounds
- `react-native-track-player` - Audio playback
- `react-native-fs` - File system checks

#### Error Handling
- Download errors: Fallback to streaming
- Playback errors: Log error, throw exception
- File errors: Fallback to streaming

---

### NetworkDiagnosticsService
**File:** `src/utils/networkDiagnostics.ts`  
**Type:** Static Service Class  
**Purpose:** Network connectivity diagnostics

#### Methods

**`testSupabaseConnection(): Promise<NetworkDiagnostics>`**
- Tests Supabase connectivity
- Measures latency
- Returns diagnostic information
- Used before network operations

**`getUserFriendlyError(diagnostics): string`**
- Converts technical errors to user-friendly messages
- German language messages
- Context-specific error messages
- Used for error display

#### Dependencies
- `supabase` client - Connection testing

#### Error Handling
- Connection errors: Return diagnostic with error message
- Timeout errors: Return diagnostic with timeout info

---

## 🔗 Service Dependencies

### Dependency Graph
```
AppBootstrap
├── OfflineQueueService
│   ├── AsyncStorage
│   ├── NetInfo
│   └── Supabase Client
├── SupabaseAudioLibraryManager
│   ├── React Native FS
│   ├── AsyncStorage
│   └── Supabase Client
├── BackgroundDownloadService
│   └── SupabaseAudioLibraryManager
└── UnifiedAudioPlaybackService
    ├── SupabaseAudioLibraryManager
    ├── SoundGenerationService
    └── TrackPlayer
```

### External Dependencies

#### React Native Libraries
- **@react-native-community/netinfo** - Network state monitoring
- **react-native-fs** - File system operations
- **@react-native-async-storage/async-storage** - Local storage
- **react-native-track-player** - Audio playback

#### Backend Services
- **Supabase Storage** - Audio file storage
- **Supabase Database** - Data synchronization
- **Supabase Realtime** - Real-time metadata updates

---

## 🔄 Service Interactions

### Offline Queue Flow
```
User Action (Offline)
    │
    └─> OfflineQueueService.addToQueue()
        ├─> AsyncStorage (persist)
        └─> Network Listener (monitor)
            └─> Connection Restored
                └─> OfflineQueueService.processQueue()
                    └─> Supabase Client (sync)
                        └─> Success → Remove from queue
                        └─> Failure → Retry (up to max)
```

### Download Flow
```
Play Request / Background Trigger
    │
    └─> SupabaseAudioLibraryManager.downloadFile()
        ├─> Check if downloaded
        ├─> Get download URL
        ├─> Download with progress
        └─> Save to file system
            └─> Update metadata
                └─> AsyncStorage (track)
```

### Playback Flow
```
Play Request
    │
    ├─> Generated Sound?
    │   └─> SoundGenerationService
    │       └─> Play Generated
    │
    ├─> Local File?
    │   └─> SupabaseAudioLibraryManager
    │       └─> Play Local
    │
    └─> Not Local?
        └─> On-Demand Download
            ├─> Download Success → Play Local
            └─> Download Failed → Play Stream
```

### Network Restoration Flow
```
Network State Change
    │
    └─> NetInfo Listener
        └─> Connection Restored
            └─> OfflineQueueService.processQueue()
                ├─> Process queued operations
                └─> Supabase Client (sync)
                    └─> Success → Clear queue
                    └─> Failure → Keep in queue
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Queue operations
- Download logic
- Cache management

### Integration Tests
- Supabase API calls
- File system operations
- Network state changes
- Queue synchronization
- Download progress

### Mocking
- Supabase client
- File system
- AsyncStorage
- Network state
- TrackPlayer

---

## 📊 Service Metrics

### Performance
- **Queue Processing:** < 5 seconds for typical queue
- **Download Speed:** Depends on network (typically 1-5 MB/s)
- **Cache Operations:** < 1 second
- **Network Checks:** < 2 seconds
- **File Checks:** < 100ms

### Reliability
- **Queue Success Rate:** > 95%
- **Download Success Rate:** > 90%
- **Sync Completion Rate:** > 98%
- **Cache Hit Rate:** > 60%

### Error Rates
- **Network Errors:** < 1%
- **Download Failures:** < 10%
- **Queue Processing Failures:** < 5%
- **Storage Errors:** < 1%

---

## 🔐 Security Considerations

### Data Protection
- Downloaded files stored securely on device
- Queue data in AsyncStorage (encrypted by platform)
- No sensitive data in logs
- Secure file deletion on cache cleanup

### Privacy
- User data only synced when authenticated
- Local storage isolated per user
- No data leakage between users
- Cache cleanup respects user data

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging
- Graceful degradation

### Error Types
- **Network Errors:** Connectivity issues
- **Download Errors:** File download failures
- **Storage Errors:** File system issues
- **Queue Errors:** Sync failures
- **Cache Errors:** Storage management issues

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
STORAGE_BUCKET=awave-audio
```

### Service Initialization
```typescript
// App startup
await OfflineQueueService.initialize();
await SupabaseAudioLibraryManager.getInstance().initialize();
await UnifiedAudioPlaybackService.getInstance().initialize();
```

### Service Cleanup
```typescript
// App shutdown
const cleanup = await OfflineQueueService.initialize();
// cleanup() called on unmount
```

---

## 🔄 Service Updates

### Future Enhancements
- Incremental sync (only changed data)
- Download chunking for large files
- Parallel download support
- Download pause/resume
- Cache preloading strategies
- Offline-first data architecture
- Selective download UI
- Download scheduling (WiFi-only)

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
