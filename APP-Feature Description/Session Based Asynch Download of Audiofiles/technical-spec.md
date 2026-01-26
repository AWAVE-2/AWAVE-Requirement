# Session Based Asynchronous Download of Audio Files - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend Services
- **Supabase Storage** - Audio file storage
  - Bucket: `awave-audio`
  - Signed URLs for premium content (1 hour expiry)
  - Public URLs for free content
  - File organization by category

- **Supabase Database** - Metadata storage
  - Table: `sound_metadata`
  - Fields: title, description, tags, category_id, search_weight, etc.
  - Real-time subscriptions for updates

#### Client Libraries
- **react-native-fs** - File system operations
  - Download files with progress tracking
  - File existence checks
  - Directory management
  - File statistics

- **@react-native-async-storage/async-storage** - Metadata persistence
  - Downloaded files list
  - Cache cleanup timestamp
  - Download state

#### State Management
- **In-Memory Maps** - Fast metadata access
  - `audioFiles: Map<string, AudioFile>` - All audio files
  - `categories: Map<string, AudioCategory>` - Category metadata
  - `downloadedFiles: Set<string>` - Downloaded file IDs
  - `downloadQueue: Map<string, Promise<string>>` - Active downloads

---

## 📁 File Structure

```
src/
├── services/
│   ├── SupabaseAudioLibraryManager.ts    # Core download & cache manager
│   ├── UnifiedAudioPlaybackService.ts    # On-demand download integration
│   ├── BackgroundDownloadService.ts     # Background download orchestration
│   └── SearchService.ts                  # Search with cached metadata
├── integrations/
│   └── supabase/
│       └── client.ts                      # Supabase client
└── types/
    └── sound.ts                           # Sound type definitions
```

---

## 🔧 Services

### SupabaseAudioLibraryManager
**Location:** `src/services/SupabaseAudioLibraryManager.ts`  
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
- `awave.dev.downloadedFiles` - Array of downloaded file IDs
- `awave.dev.lastCacheCleanup` - Last cleanup timestamp (ISO string)

#### Methods

**`initialize(): Promise<void>`**
- Creates local directory structure
- Loads cached download data
- Loads audio metadata from Supabase (batched)
- Sets up real-time sync subscriptions
- Performs cache optimization
- Called once at app startup

**`loadAudioMetadata(): Promise<void>`**
- Loads metadata in batches (100 per batch)
- Handles large catalogs (3000+ files)
- Converts Supabase metadata to AudioFile format
- Stores in memory Map
- Error handling with detailed logging
- Progress tracking for large loads

**`downloadFile(fileId: string, onProgress?: (progress: DownloadProgress) => void): Promise<string>`**
- Checks if file already downloaded (returns local path)
- Checks if download already in progress (returns existing promise)
- Prevents duplicate downloads via queue
- Downloads file with progress tracking
- Updates file metadata on completion
- Saves to downloaded files set
- Returns local file path

**`getStreamingUrl(fileId: string): Promise<string>`**
- Gets streaming URL for audio file
- Creates signed URL for premium content (1 hour expiry)
- Returns public URL for free content
- Handles storage errors

**`searchAudioFiles(query: string, options?: SearchOptions): AudioFile[]`**
- Searches cached metadata (no network calls)
- Searches by title, description, tags
- Filters by category if specified
- Sorts by relevance, duration, or title
- Applies limit if specified
- Returns array of AudioFile objects

**`getFilesByCategory(categoryId: string, options?: PaginationOptions): AudioFile[]`**
- Gets files by category with pagination
- Filters by category ID
- Sorts by search weight descending
- Supports offset and limit

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

**`setupRealTimeSync(): Promise<void>`**
- Subscribes to Supabase real-time changes
- Handles INSERT, UPDATE, DELETE events
- Updates local metadata cache
- No app restart required

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
  size: number; // MB
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

### UnifiedAudioPlaybackService
**Location:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Singleton Class  
**Purpose:** On-demand download integration with playback

#### Methods

**`playSound(sound: Sound): Promise<void>`**
- Main playback method
- Priority: Generated > Local > Download > Stream
- Routes to appropriate source

**`getLocalSoundPath(sound: Sound): Promise<string | null>`**
- Checks if file exists locally
- Triggers on-demand download if not local
- Returns local path or null (fallback to streaming)
- Handles download errors gracefully

**`detectSoundSource(sound: Sound): Promise<'generated' | 'local' | 'stream'>`**
- Detects sound source type
- Returns source for UI display

**`isAvailableOffline(sound: Sound): Promise<boolean>`**
- Checks if sound is available offline
- Generated sounds always available
- Local files available offline

#### Integration Flow
```
User selects sound
  ↓
playSound(sound)
  ↓
Check if generated → playGeneratedSound()
  ↓
getLocalSoundPath(sound)
  ↓
Check local cache → downloadFile() if needed
  ↓
Play local file or stream
```

---

### BackgroundDownloadService
**Location:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Class  
**Purpose:** Background download orchestration

#### Methods

**`downloadCategory(categoryId: string): Promise<void>`**
- Downloads all files from specific category
- Tracks download progress
- Handles errors per file
- Continues downloading remaining files on error

**`downloadFavorites(userId: string): Promise<void>`**
- Downloads user's favorite sounds
- High priority downloads
- Triggered after login

**`downloadPriorityCategories(): Promise<void>`**
- Downloads priority categories
- Order: music > nature > noise > sound
- Background operation

**`isCurrentlyDownloading(): boolean`**
- Returns download status
- Prevents concurrent downloads

**`getQueueSize(): number`**
- Returns download queue size
- For status display

---

### SearchService
**Location:** `src/services/SearchService.ts`  
**Type:** Static Service Class  
**Purpose:** Search with cached metadata

#### Methods

**`searchSounds(query: string, filters?: SearchFilters): Promise<SoundMetadata[]>`**
- Searches Supabase database
- Uses cached metadata for fast results
- Applies filters (category, brainwave type, duration, etc.)
- Returns matching sounds

**Note:** While SearchService queries Supabase directly, the SupabaseAudioLibraryManager's `searchAudioFiles()` method uses fully cached metadata for even faster results.

---

## 🔄 State Management

### In-Memory State

**Audio Files Map**
```typescript
audioFiles: Map<string, AudioFile>
```
- Key: File ID (sound_id)
- Value: AudioFile object
- O(1) lookup performance
- Updated via real-time sync

**Downloaded Files Set**
```typescript
downloadedFiles: Set<string>
```
- Contains file IDs of downloaded files
- Persisted to AsyncStorage
- Used for quick download status checks

**Download Queue**
```typescript
downloadQueue: Map<string, Promise<string>>
```
- Key: File ID
- Value: Download promise
- Prevents duplicate downloads
- Cleared on completion/failure

### Persistent State

**AsyncStorage**
- `awave.dev.downloadedFiles` - JSON array of file IDs
- `awave.dev.lastCacheCleanup` - ISO timestamp string

**File System**
- `Documents/audio/{category}/{sound_id}.mp3` - Audio files
- Organized by category subdirectories

---

## 🌐 API Integration

### Supabase Storage API
- `supabase.storage.from('awave-audio').getPublicUrl(path)` - Public URLs
- `supabase.storage.from('awave-audio').createSignedUrl(path, expiry)` - Signed URLs
- `supabase.storage.from('awave-audio').download(path)` - Direct download

### Supabase Database API
- `supabase.from('sound_metadata').select('*')` - Metadata queries
- `supabase.from('sound_metadata').select('*').range(offset, limit)` - Paginated queries
- Real-time subscriptions via `supabase.channel()`

### React Native FS API
- `RNFS.downloadFile(options)` - File download with progress
- `RNFS.exists(path)` - File existence check
- `RNFS.mkdir(path)` - Directory creation
- `RNFS.stat(path)` - File statistics
- `RNFS.unlink(path)` - File deletion
- `RNFS.getFSInfo()` - File system information

---

## 📱 Platform-Specific Notes

### iOS
- Files stored in app Documents directory
- Automatic backup to iCloud (configurable)
- File system access via react-native-fs
- Background downloads supported

### Android
- Files stored in app Documents directory
- File system access via react-native-fs
- Background downloads supported
- Storage permissions handled by library

### File System Structure
```
Documents/
└── audio/
    ├── meditation/
    │   └── {sound_id}.mp3
    ├── nature/
    │   └── {sound_id}.mp3
    ├── noise/
    │   └── {sound_id}.mp3
    ├── music/
    │   └── {sound_id}.mp3
    └── premium/
        └── {sound_id}.mp3
```

---

## 🧪 Testing Strategy

### Unit Tests
- Metadata loading and conversion
- Download queue management
- Cache cleanup logic
- Search functionality
- File path generation

### Integration Tests
- Supabase Storage downloads
- Metadata sync via real-time
- Cache optimization
- Download progress tracking
- Error handling and fallback

### E2E Tests
- Complete download flow
- Search with cached metadata
- Cache cleanup on limit
- Real-time metadata updates
- Background downloads

---

## 🐛 Error Handling

### Error Types
- Network errors (download failures)
- Storage errors (quota exceeded, permissions)
- File system errors (corruption, missing files)
- Metadata sync errors (real-time failures)
- Cache errors (cleanup failures)

### Error Recovery
- Download failures → Fallback to streaming
- Storage errors → Trigger cache cleanup
- File system errors → Log and continue
- Metadata sync errors → Continue with cached data
- Cache errors → Retry or skip

### Error Messages
- User-friendly error messages
- Detailed logging for debugging
- Error tracking for analytics
- Graceful degradation

---

## 📊 Performance Considerations

### Optimization Strategies
- **Batch Loading:** Metadata loaded in batches (100 per batch)
- **In-Memory Caching:** O(1) lookup performance
- **Download Queue:** Prevents duplicate downloads
- **LRU Eviction:** Maintains cache performance
- **Real-Time Sync:** Updates without full reload

### Performance Metrics
- **Metadata Load Time:** < 30 seconds for 3000+ files
- **Search Response Time:** < 50ms (cached metadata)
- **Download Start Time:** < 1 second
- **Cache Hit Rate:** Tracked and optimized
- **Memory Usage:** Monitored for large catalogs

### Monitoring
- Download success rate
- Cache hit rate
- Metadata load time
- Search response time
- Cache cleanup frequency
- Real-time sync success rate

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

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
