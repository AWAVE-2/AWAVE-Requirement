# Offline Support System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Network Detection
- **@react-native-community/netinfo** - Network state monitoring
  - Real-time connectivity detection
  - Network state change listeners
  - Connection type detection (WiFi, cellular, etc.)

#### File System
- **react-native-fs** - File system operations
  - File downloads
  - Directory management
  - File existence checks
  - Storage statistics

#### Storage
- **@react-native-async-storage/async-storage** - Local data persistence
  - Queue data storage
  - Metadata caching
  - Download tracking
  - Configuration storage

#### Backend Integration
- **Supabase Storage** - Audio file storage
  - Public and signed URLs
  - File downloads
  - Storage bucket management

- **Supabase Database** - Data synchronization
  - Queue operation execution
  - Favorites management
  - Profile updates

#### Audio Playback
- **react-native-track-player** - Audio playback
  - Local file playback
  - Streaming playback
  - Playback state management

---

## 📁 File Structure

```
src/
├── services/
│   ├── OfflineQueueService.ts              # Offline operation queue
│   ├── SupabaseAudioLibraryManager.ts       # Audio download & management
│   ├── BackgroundDownloadService.ts         # Background downloads
│   ├── UnifiedAudioPlaybackService.ts      # Unified audio playback
│   └── NetworkDiagnosticsService.ts         # Network diagnostics
├── utils/
│   ├── networkDiagnostics.ts               # Network utilities
│   └── errorHandler.ts                      # Error handling utilities
├── hooks/
│   └── useFavoritesManagement.ts             # Favorites with offline support
└── bootstrap/
    └── AppBootstrap.tsx                     # Service initialization
```

---

## 🔧 Services

### OfflineQueueService
**Location:** `src/services/OfflineQueueService.ts`  
**Type:** Static Service Class  
**Purpose:** Offline operation queue management and synchronization

#### Storage Keys
- `offline_action_queue` - Queued operations

#### Configuration
- `MAX_RETRIES = 3` - Maximum retry attempts
- `QUEUE_KEY = 'offline_action_queue'` - Storage key

#### Methods

**`addToQueue(action, table, data): Promise<void>`**
- Adds operation to queue
- Generates unique action ID
- Stores in AsyncStorage
- Attempts immediate processing if online

**`getQueue(): Promise<QueuedAction[]>`**
- Retrieves current queue from AsyncStorage
- Returns empty array if no queue exists

**`processQueue(): Promise<number>`**
- Processes all queued actions
- Checks network connectivity
- Executes actions in order
- Handles retries and failures
- Returns count of processed actions

**`processQueueIfOnline(): Promise<void>`**
- Checks network state
- Processes queue if online
- No-op if offline

**`executeAction(action): Promise<void>`**
- Executes single queued action
- Routes to appropriate handler (create, update, delete)

**`executeCreate(table, data): Promise<void>`**
- Executes INSERT operation
- Uses Supabase client

**`executeUpdate(table, data): Promise<void>`**
- Executes UPDATE operation
- Requires `id` field in data

**`executeDelete(table, data): Promise<void>`**
- Executes DELETE operation
- Requires `id` field in data

**`clearQueue(): Promise<void>`**
- Removes all queued actions
- Clears AsyncStorage

**`getQueueStatus(): Promise<QueueStatus>`**
- Returns queue statistics
- Count, oldest timestamp, action types

**`setupNetworkListener(): () => void`**
- Sets up network state listener
- Automatically processes queue on connection
- Returns unsubscribe function

**`initialize(): Promise<() => void>`**
- Initializes service
- Processes pending queue
- Sets up network listener
- Returns cleanup function

#### Error Handling
- Network errors: Queue remains, retry on next connection
- Operation errors: Increment retry count, retry up to max
- Max retries exceeded: Discard action, log error
- Storage errors: Log error, continue operation

---

### SupabaseAudioLibraryManager
**Location:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Audio file download and local storage management

#### Storage Configuration
- `STORAGE_BUCKET = 'awave-audio'` - Supabase storage bucket
- `LOCAL_AUDIO_DIR = 'Documents/audio'` - Local storage directory
- `MAX_CACHE_SIZE = 2GB` - Maximum cache size
- `DOWNLOAD_TIMEOUT = 30000` - Download timeout (30 seconds)

#### Storage Keys
- `awave.dev.downloadedFiles` - List of downloaded file IDs
- `awave.dev.lastCacheCleanup` - Last cleanup timestamp

#### Directory Structure
```
Documents/audio/
├── meditation/
├── nature/
├── noise/
├── music/
└── premium/
```

#### Methods

**`initialize(): Promise<void>`**
- Creates local directories
- Loads cached data
- Loads audio metadata from Supabase
- Sets up real-time sync
- Performs cache optimization

**`loadAudioMetadata(): Promise<void>`**
- Loads metadata in batches (100 per batch)
- Converts Supabase metadata to AudioFile format
- Stores in memory map
- Handles large datasets efficiently

**`downloadFile(fileId, onProgress?): Promise<string>`**
- Downloads file from Supabase Storage
- Checks if already downloaded
- Prevents duplicate downloads
- Tracks download progress
- Returns local file path

**`performDownload(file, onProgress?): Promise<string>`**
- Gets download URL (public or signed)
- Creates local directory if needed
- Downloads file with progress tracking
- Updates file metadata
- Saves to downloaded files set

**`getStreamingUrl(fileId): Promise<string>`**
- Gets public URL for free content
- Creates signed URL for premium content (1 hour expiry)
- Returns streaming URL

**`getLocalAudioPath(fileId): string | null`**
- Returns local file path if downloaded
- Returns null if not downloaded

**`isFileAvailableLocally(fileId): Promise<boolean>`**
- Checks if file exists locally
- Verifies file existence on disk

**`getCacheStats(): Promise<CacheStats>`**
- Calculates cache statistics
- Total files, size, available space
- Cache hit rate
- Last cleanup timestamp

**`optimizeCache(): Promise<void>`**
- Checks cache size against limit
- Removes LRU files if over limit
- Targets 80% capacity after cleanup
- Updates metadata and storage

**`searchAudioFiles(query, options?): AudioFile[]`**
- Searches files by title, description, tags
- Filters by category if specified
- Sorts by relevance, duration, or title
- Applies limit if specified

**`getFilesByCategory(categoryId, options?): AudioFile[]`**
- Gets files for specific category
- Supports pagination (limit, offset)
- Sorted by search weight

**`setupRealTimeSync(): Promise<void>`**
- Subscribes to Supabase real-time changes
- Handles INSERT, UPDATE, DELETE events
- Updates local metadata cache

**`loadCachedData(): Promise<void>`**
- Loads downloaded files list from AsyncStorage
- Restores downloaded files set

**`saveCachedData(): Promise<void>`**
- Saves downloaded files list to AsyncStorage
- Persists download state

#### Data Structures

**AudioFile**
```typescript
{
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

**DownloadProgress**
```typescript
{
  fileId: string;
  bytesWritten: number;
  contentLength: number;
  progress: number; // 0-100
  isComplete: boolean;
}
```

**CacheStats**
```typescript
{
  totalFiles: number;
  totalSize: number; // MB
  availableSpace: number; // bytes
  cacheHitRate: number; // 0-1
  lastCleanup: string; // ISO timestamp
}
```

---

### BackgroundDownloadService
**Location:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Class  
**Purpose:** Proactive content downloading

#### Methods

**`downloadFavorites(userId): Promise<void>`**
- Downloads user's favorite sounds
- High priority downloads
- Triggered after login

**`downloadCategory(categoryId): Promise<void>`**
- Downloads all files from category
- Processes files sequentially
- Tracks success/failure counts

**`downloadPriorityCategories(): Promise<void>`**
- Downloads priority categories in order
- Order: music > nature > noise > sound
- Based on audio inventory counts

**`isCurrentlyDownloading(): boolean`**
- Returns download status
- Prevents concurrent downloads

**`getQueueSize(): number`**
- Returns download queue size

---

### UnifiedAudioPlaybackService
**Location:** `src/services/UnifiedAudioPlaybackService.ts`  
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

**`playSound(sound): Promise<void>`**
- Main playback method
- Routes to appropriate source
- Priority: Generated > Local > Stream

**`getLocalSoundPath(sound): Promise<string | null>`**
- Checks if file exists locally
- Attempts on-demand download if not local
- Returns local path or null

**`playGeneratedSound(sound): Promise<void>`**
- Plays generated sound
- Uses SoundGenerationService

**`playLocalFile(sound, filePath): Promise<void>`**
- Plays local file via TrackPlayer
- Uses file:// URL scheme

**`playStream(sound): Promise<void>`**
- Plays stream from server
- Gets streaming URL
- Uses TrackPlayer

**`detectSoundSource(sound): Promise<'generated' | 'local' | 'stream'>`**
- Detects sound source type
- Returns source identifier

**`isAvailableOffline(sound): Promise<boolean>`**
- Checks if sound is available offline
- Generated sounds: always true
- Other sounds: checks local availability

---

### NetworkDiagnosticsService
**Location:** `src/utils/networkDiagnostics.ts`  
**Type:** Static Service Class  
**Purpose:** Network connectivity diagnostics

#### Methods

**`testSupabaseConnection(): Promise<NetworkDiagnostics>`**
- Tests Supabase connectivity
- Measures latency
- Returns diagnostic information

**`getUserFriendlyError(diagnostics): string`**
- Converts technical errors to user-friendly messages
- German language messages
- Context-specific error messages

**`logDiagnostics(diagnostics): void`**
- Logs diagnostic information
- Development debugging

#### Data Structures

**NetworkDiagnostics**
```typescript
{
  isConnected: boolean;
  latency?: number; // milliseconds
  error?: string;
  details: {
    supabaseUrl: string;
    authEndpoint: string;
    restEndpoint: string;
    timestamp: string;
  };
}
```

---

## 🔄 State Management

### Queue State
```typescript
{
  queue: QueuedAction[];
  isProcessing: boolean;
  networkState: 'online' | 'offline';
}
```

### Download State
```typescript
{
  downloads: Map<string, DownloadProgress>;
  queue: DownloadQueueItem[];
  isDownloading: boolean;
}
```

### Cache State
```typescript
{
  downloadedFiles: Set<string>;
  cacheStats: CacheStats;
  lastCleanup: string;
}
```

---

## 🌐 API Integration

### Supabase Storage
- `supabase.storage.from(bucket).getPublicUrl(path)` - Public URLs
- `supabase.storage.from(bucket).createSignedUrl(path, expiry)` - Signed URLs
- `supabase.storage.from(bucket).download(path)` - File downloads

### Supabase Database
- `supabase.from(table).insert(data)` - Create operations
- `supabase.from(table).update(data).eq('id', id)` - Update operations
- `supabase.from(table).delete().eq('id', id)` - Delete operations

### Real-time Subscriptions
- `supabase.channel(name).on('postgres_changes', ...)` - Real-time updates

---

## 📱 Platform-Specific Notes

### iOS
- File system: `Documents/audio/`
- Background downloads: Supported
- Storage permissions: Automatic
- Network monitoring: Native support

### Android
- File system: `Documents/audio/`
- Background downloads: Supported
- Storage permissions: May require runtime permission
- Network monitoring: Native support
- External storage: Optional support

---

## 🧪 Testing Strategy

### Unit Tests
- Queue operations (add, process, clear)
- Download logic (file existence, progress)
- Cache management (optimization, cleanup)
- Network state detection
- Error handling

### Integration Tests
- Supabase Storage downloads
- Queue synchronization
- Network restoration
- Cache optimization
- Real-time sync

### E2E Tests
- Complete download flow
- Offline operation queuing
- Network restoration and sync
- Cache management
- Playback with offline files

---

## 🐛 Error Handling

### Error Types
- Network errors
- Storage errors
- Download failures
- Queue processing errors
- File system errors

### Error Recovery
- Automatic retry for transient failures
- Queue persistence for offline operations
- Download resume capability
- Cache corruption recovery
- Network restoration handling

---

## 📊 Performance Considerations

### Optimization
- Batch metadata loading (100 per batch)
- Lazy download initialization
- Efficient cache lookup (Set data structure)
- LRU cache cleanup
- Debounced network checks

### Monitoring
- Download success rate
- Queue processing time
- Cache hit rate
- Storage utilization
- Network restoration time

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
