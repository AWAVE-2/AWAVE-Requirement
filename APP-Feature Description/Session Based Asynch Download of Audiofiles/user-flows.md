# Session Based Asynchronous Download of Audio Files - User Flows

## 🔄 Primary User Flows

### 1. On-Demand Download Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User selects sound for playback
   └─> UnifiedAudioPlaybackService.playSound()
       └─> Check sound type
           ├─> Generated sound → Play generated
           └─> Regular sound → Continue
               └─> getLocalSoundPath()
                   ├─> Check if audioManager initialized
                   │   └─> No → Initialize audioManager
                   │       └─> Load metadata (if not loaded)
                   │
                   └─> Check local cache
                       ├─> File exists locally → Return local path
                       │   └─> Play local file
                       │
                       └─> File not local → Trigger download
                           └─> SupabaseAudioLibraryManager.downloadFile()
                               ├─> Check if already downloaded
                               │   ├─> Yes → Return local path
                               │   └─> No → Continue
                               │
                               ├─> Check download queue
                               │   ├─> Download in progress → Return existing promise
                               │   └─> Not in progress → Continue
                               │
                               └─> Start new download
                                   ├─> Get streaming URL
                                   │   ├─> Premium → Create signed URL (1 hour)
                                   │   └─> Free → Get public URL
                                   │
                                   ├─> Create local directory if needed
                                   │
                                   ├─> Download file with progress tracking
                                   │   ├─> Progress updates every 500ms
                                   │   └─> Callback reports progress (0-100%)
                                   │
                                   ├─> Download completes
                                   │   ├─> Update file metadata
                                   │   │   ├─> isDownloaded = true
                                   │   │   ├─> storageType = 'local'
                                   │   │   └─> Update file size
                                   │   │
                                   │   ├─> Add to downloaded files set
                                   │   │
                                   │   ├─> Save to AsyncStorage
                                   │   │
                                   │   └─> Return local path
                                   │       └─> Play downloaded file
```

**Success Path:**
- File downloads successfully
- Metadata updated
- File saved locally
- Playback begins with local file

**Error Paths:**
- Download fails → Fallback to streaming
- Network error → Fallback to streaming
- Storage error → Show error, fallback to streaming
- File not found → Show error

---

### 2. Metadata Caching Flow

```
App Startup                    System Response
─────────────────────────────────────────────────────────
1. App initializes
   └─> SupabaseAudioLibraryManager.initialize()
       │
       ├─> Create local directory structure
       │   └─> Documents/audio/{category}/
       │
       ├─> Load cached download data
       │   └─> AsyncStorage.getItem('awave.dev.downloadedFiles')
       │       └─> Restore downloadedFiles Set
       │
       ├─> Load audio metadata from Supabase
       │   └─> loadAudioMetadata()
       │       ├─> Test Supabase connection
       │       │   ├─> Error → Throw error, stop initialization
       │       │   └─> Success → Continue
       │       │
       │       └─> Load in batches (100 per batch)
       │           ├─> Query: sound_metadata (offset, limit)
       │           │   └─> Order by search_weight DESC
       │           │
       │           ├─> For each batch
       │           │   ├─> Convert metadata to AudioFile
       │           │   ├─> Store in audioFiles Map
       │           │   └─> Track total loaded
       │           │
       │           └─> Continue until no more data
       │               └─> Log total loaded (e.g., "✅ Loaded 3000 files")
       │
       ├─> Setup real-time sync
       │   └─> setupRealTimeSync()
       │       └─> Subscribe to sound_metadata changes
       │           ├─> INSERT → Add to cache
       │           ├─> UPDATE → Update cache
       │           └─> DELETE → Remove from cache
       │
       └─> Optimize cache
           └─> optimizeCache()
               ├─> Check cache size
               │   ├─> Under limit → Skip cleanup
               │   └─> Over limit → Continue
               │
               └─> Remove LRU files
                   ├─> Sort by last access (oldest first)
                   ├─> Remove until 80% capacity
                   └─> Update metadata and storage
```

**Success Path:**
- Metadata loads successfully
- All files cached in memory
- Real-time sync active
- Cache optimized

**Error Paths:**
- Connection error → Show error, stop initialization
- Metadata load error → Show error, continue with cached data
- Real-time sync error → Log warning, continue
- Cache optimization error → Log warning, continue

---

### 3. Search with Cached Metadata Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User enters search query
   └─> Search component calls search function
       │
       ├─> Option A: SupabaseAudioLibraryManager.searchAudioFiles()
       │   └─> Search in-memory Map (cached metadata)
       │       ├─> Filter by query (title, description, tags)
       │       │   └─> Case-insensitive search
       │       │
       │       ├─> Filter by category (if specified)
       │       │
       │       ├─> Sort results
       │       │   ├─> Relevance → searchWeight DESC
       │       │   ├─> Duration → duration DESC
       │       │   └─> Title → title ASC
       │       │
       │       ├─> Apply limit (if specified)
       │       │
       │       └─> Return results (< 50ms)
       │           └─> Display results instantly
       │
       └─> Option B: SearchService.searchSounds()
           └─> Query Supabase database
               ├─> Full-text search on title, description, tags
               ├─> Apply filters (category, brainwave, duration, etc.)
               ├─> Limit to 50 results
               └─> Return results (network call, slower)
                   └─> Display results
```

**Success Path:**
- Search completes successfully
- Results returned instantly (cached) or quickly (database)
- Results displayed to user

**Error Paths:**
- Search error → Return empty array
- Database error → Return empty array
- Invalid query → Return empty array

---

### 4. Background Download Flow

```
System Trigger                 System Response
─────────────────────────────────────────────────────────
1. Background download triggered
   └─> BackgroundDownloadService.downloadCategory()
       │
       ├─> Check if already downloading
       │   ├─> Yes → Log warning, return
       │   └─> No → Continue
       │       └─> Set isDownloading = true
       │
       └─> Get files for category
           └─> SupabaseAudioLibraryManager.getFilesByCategory()
               └─> Return files sorted by searchWeight
                   │
                   └─> For each file
                       └─> SupabaseAudioLibraryManager.downloadFile()
                           ├─> Check if already downloaded
                           │   ├─> Yes → Skip, continue next
                           │   └─> No → Continue
                           │
                           ├─> Download file
                           │   ├─> Success → Log progress
                           │   └─> Error → Log error, continue next
                           │
                           └─> Continue with next file
                               └─> After all files
                                   └─> Set isDownloading = false
                                       └─> Log completion statistics
```

**Success Path:**
- All files download successfully
- Files stored locally
- Download status tracked

**Error Paths:**
- Individual file error → Log error, continue with next
- Category error → Log error, stop category download
- Network error → Log error, stop downloads

---

### 5. Cache Cleanup Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Cache optimization triggered
   └─> SupabaseAudioLibraryManager.optimizeCache()
       │
       ├─> Get cache statistics
       │   └─> getCacheStats()
       │       ├─> Calculate total downloaded files
       │       ├─> Calculate total cache size (MB)
       │       ├─> Get available storage space
       │       ├─> Calculate cache hit rate
       │       └─> Get last cleanup timestamp
       │
       ├─> Check cache size
       │   ├─> Under 2GB limit → Skip cleanup
       │   └─> Over 2GB limit → Continue
       │
       └─> Remove LRU files
           ├─> Get all downloaded files
           │   └─> Filter by isDownloaded = true
           │
           ├─> Sort by last access time (oldest first)
           │   └─> Sort by updatedAt timestamp
           │
           ├─> Calculate target size (80% of limit)
           │
           └─> For each file (oldest first)
               ├─> Check if current size <= target
               │   ├─> Yes → Stop cleanup
               │   └─> No → Continue
               │
               └─> Remove file
                   ├─> Check if file exists on disk
                   │   ├─> Yes → Delete file
                   │   │   ├─> RNFS.unlink(file.localPath)
                   │   │   │
                   │   │   ├─> Update metadata
                   │   │   │   ├─> isDownloaded = false
                   │   │   │   └─> storageType = 'remote'
                   │   │   │
                   │   │   ├─> Remove from downloadedFiles Set
                   │   │   │
                   │   │   └─> Update current size
                   │   │
                   │   └─> No → Skip, continue next
                   │
                   └─> Continue until target size reached
                       └─> Save cleanup timestamp
                           └─> AsyncStorage.setItem('awave.dev.lastCacheCleanup')
```

**Success Path:**
- Cache size reduced to 80% capacity
- Oldest files removed
- Metadata updated
- Cleanup timestamp saved

**Error Paths:**
- File deletion error → Log error, continue with next
- Storage error → Log error, stop cleanup
- Metadata update error → Log error, continue

---

## 🔀 Alternative Flows

### Download Failure Fallback Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User selects sound
   └─> Download triggered
       └─> Download fails
           ├─> Network error
           │   └─> Log error
           │       └─> Fallback to streaming
           │           └─> Get streaming URL
           │               └─> Play stream
           │
           ├─> Storage error
           │   └─> Log error
           │       └─> Fallback to streaming
           │           └─> Play stream
           │
           └─> Other error
               └─> Log error
                   └─> Fallback to streaming
                       └─> Play stream
```

**User Experience:**
- Download fails silently
- Playback continues with streaming
- No error shown to user (unless critical)

---

### Real-Time Metadata Update Flow

```
Database Change                System Response
─────────────────────────────────────────────────────────
1. Metadata updated in Supabase
   └─> Supabase Realtime triggers event
       └─> SupabaseAudioLibraryManager.handleMetadataUpdate()
           │
           ├─> Event Type: INSERT
           │   └─> Convert new metadata to AudioFile
           │       └─> Add to audioFiles Map
           │           └─> Search now includes new file
           │
           ├─> Event Type: UPDATE
           │   └─> Convert updated metadata to AudioFile
           │       └─> Update in audioFiles Map
           │           └─> Search reflects changes
           │
           └─> Event Type: DELETE
               └─> Remove from audioFiles Map
                   └─> Search no longer includes file
```

**User Experience:**
- Changes reflected immediately
- No app restart required
- Search results update automatically

---

### Cache Full Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User downloads file
   └─> Download completes
       └─> Check cache size
           ├─> Under limit → Save file, continue
           └─> Over limit → Trigger cleanup
               └─> optimizeCache()
                   └─> [Same cleanup flow as above]
                       └─> After cleanup
                           └─> Save new file
                               └─> Continue normal operation
```

**User Experience:**
- Cleanup happens automatically
- User doesn't need to manage storage
- Old files removed transparently

---

## 🚨 Error Flows

### Network Error During Download

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Download in progress
   └─> Network connection lost
       └─> react-native-fs download fails
           └─> Error caught in downloadFile()
               ├─> Log error
               │
               ├─> Remove from download queue
               │
               ├─> Throw error to caller
               │
               └─> UnifiedAudioPlaybackService handles error
                   └─> Fallback to streaming
                       └─> Get streaming URL
                           └─> Play stream
```

**User Experience:**
- Download fails silently
- Playback continues with streaming
- No interruption to user

---

### Storage Quota Exceeded

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Download in progress
   └─> Storage quota exceeded
       └─> File write fails
           └─> Error caught
               ├─> Log error
               │
               ├─> Trigger cache cleanup
               │   └─> optimizeCache()
               │       └─> Free up space
               │
               └─> Retry download (optional)
                   └─> Or fallback to streaming
```

**User Experience:**
- Cache cleanup happens automatically
- Download may retry or fallback
- User doesn't need to manage storage

---

### Metadata Load Failure

```
App Startup                    System Response
─────────────────────────────────────────────────────────
1. App initializes
   └─> loadAudioMetadata() called
       └─> Supabase connection fails
           └─> Error caught
               ├─> Log detailed error
               │
               ├─> Throw error
               │
               └─> Initialization fails
                   └─> App shows error message
                       └─> User can retry
```

**User Experience:**
- Error message shown
- App doesn't crash
- User can retry initialization

---

## 🔄 State Transitions

### Download State Transitions

```
Not Downloaded → Downloading → Downloaded
     │               │              │
     │               └─> Error      │
     │                   └─> Not Downloaded (retry)
     │
     └─> Download Failed → Fallback to Streaming
```

### Cache State Transitions

```
Cache Empty → Files Downloaded → Cache Full
     │              │                  │
     │              │                  └─> Cleanup Triggered
     │              │                      └─> Cache Optimized
     │              │
     │              └─> Real-Time Update
     │                  └─> Cache Updated
     │
     └─> Metadata Loaded → Cache Ready
```

### Metadata State Transitions

```
Not Loaded → Loading → Loaded
     │          │          │
     │          └─> Error  │
     │              └─> Not Loaded (retry)
     │                      │
     │                      └─> Real-Time Sync
     │                          └─> Metadata Updated
     │
     └─> App Restart → Not Loaded (reload)
```

---

## 📊 Flow Diagrams

### Complete On-Demand Download Journey

```
User opens app
    │
    └─> App initializes
        └─> SupabaseAudioLibraryManager.initialize()
            ├─> Load metadata (3000+ files)
            ├─> Setup real-time sync
            └─> Optimize cache
                │
                └─> User browses/search
                    └─> Search uses cached metadata (< 50ms)
                        │
                        └─> User selects sound
                            └─> UnifiedAudioPlaybackService.playSound()
                                ├─> Check local cache
                                │   ├─> Found → Play local
                                │   └─> Not found → Download
                                │       └─> Download with progress
                                │           └─> Play downloaded file
                                │
                                └─> Download fails → Fallback to stream
                                    └─> Play stream
```

---

## 🎯 User Goals

### Goal: Play Sound Instantly
- **Path:** Local cache → Play immediately
- **Time:** < 100ms
- **Steps:** Check cache → Play

### Goal: Download on Demand
- **Path:** Select sound → Download → Play
- **Time:** < 10 seconds (depends on file size)
- **Steps:** Select → Download → Play

### Goal: Fast Search
- **Path:** Enter query → Search cached metadata → Results
- **Time:** < 50ms
- **Steps:** Query → Search → Results

### Goal: Offline Access
- **Path:** Download files → Use offline
- **Time:** Varies by download size
- **Steps:** Download → Available offline

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
