# Offline Support System - User Flows

## 🔄 Primary User Flows

### 1. Offline Operation Queue Flow

```
User Action (Offline)              System Response
─────────────────────────────────────────────────────────
1. User performs action (e.g., add favorite)
   └─> Check network connectivity
       ├─> Online → Execute immediately
       └─> Offline → Continue
           └─> OfflineQueueService.addToQueue()
               └─> Store in AsyncStorage
                   └─> Show success feedback (local)
                       └─> Action appears in UI

2. Network connection restored
   └─> NetInfo listener detects connection
       └─> OfflineQueueService.processQueue()
           └─> Process queued actions
               ├─> Success → Remove from queue
               └─> Failure → Retry (up to 3 times)
                   └─> Max retries → Discard, log error
```

**Success Path:**
- Action queued when offline
- Action synced when connection restored
- User sees updated state

**Error Paths:**
- Network error during sync → Retry on next connection
- Max retries exceeded → Action discarded, user notified
- Invalid data → Action discarded, error logged

---

### 2. Audio Download Flow

#### 2a. On-Demand Download

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User requests to play sound
   └─> UnifiedAudioPlaybackService.playSound()
       └─> Check sound source
           ├─> Generated → Play immediately
           ├─> Local → Play local file
           └─> Not local → Continue
               └─> Check network connectivity
                   ├─> Offline → Show error
                   └─> Online → Continue
                       └─> SupabaseAudioLibraryManager.downloadFile()
                           └─> Show download progress (optional)
                               └─> Download completes
                                   └─> Play local file
```

**Success Path:**
- Sound downloads successfully
- File saved to local storage
- Playback starts from local file

**Error Paths:**
- Network error → Fallback to streaming (if available)
- Download timeout → Fallback to streaming
- Storage full → Show error, suggest cache cleanup

#### 2b. Background Download

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User logs in
   └─> BackgroundDownloadService.downloadFavorites()
       └─> Get user favorites
           └─> For each favorite
               └─> SupabaseAudioLibraryManager.downloadFile()
                   ├─> Success → Continue to next
                   └─> Failure → Log, continue to next
                       └─> All favorites downloaded
                           └─> Download complete
```

**Success Path:**
- Favorites download in background
- Files available for offline playback
- User notified when complete

**Error Paths:**
- Network error → Downloads pause, resume on connection
- Storage full → Downloads stop, user notified
- Individual failures → Logged, other downloads continue

---

### 3. Network Restoration Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Network connection restored
   └─> NetInfo listener detects connection
       └─> OfflineQueueService.processQueue()
           └─> Get queued actions
               ├─> No queue → Continue
               └─> Queue exists → Process
                   └─> For each action
                       ├─> Execute action
                       │   ├─> Success → Remove from queue
                       │   └─> Failure → Continue
                       │       └─> Increment retry count
                       │           ├─> Under max → Keep in queue
                       │           └─> Max exceeded → Discard
                       └─> All actions processed
                           └─> Queue cleared (if all successful)
```

**Success Path:**
- All queued actions sync successfully
- Queue cleared
- User data up to date

**Error Paths:**
- Some actions fail → Retry on next connection
- All actions fail → Queue remains, retry later
- Network drops during sync → Queue remains, retry on next connection

---

### 4. Cache Management Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App initialization
   └─> SupabaseAudioLibraryManager.initialize()
       └─> Get cache statistics
           └─> Check cache size
               ├─> Under limit → Continue
               └─> Over limit → Continue
                   └─> optimizeCache()
                       └─> Get downloaded files (sorted by LRU)
                           └─> Remove files until 80% capacity
                               └─> Update metadata
                                   └─> Save to AsyncStorage
                                       └─> Cache optimized
```

**Success Path:**
- Cache optimized automatically
- Space freed up
- Most recently used files retained

**Error Paths:**
- File deletion fails → Log error, continue with next
- Storage error → Log error, continue operation
- Cache still over limit → Log warning, continue

---

### 5. Offline Playback Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User requests to play sound
   └─> UnifiedAudioPlaybackService.playSound()
       └─> Check sound type
           ├─> Generated → Play generated sound
           │   └─> Always available offline
           │
           ├─> Check if downloaded
           │   ├─> Downloaded → Play local file
           │   │   └─> Available offline
           │   │
           │   └─> Not downloaded → Continue
           │       └─> Check network
           │           ├─> Offline → Show error
           │           └─> Online → Download & play
           │
           └─> Fallback to streaming
               └─> Requires network
                   └─> Play stream
```

**Success Path:**
- Sound plays from appropriate source
- Offline playback works for downloaded/generated sounds

**Error Paths:**
- Not downloaded and offline → Show error
- Download fails → Fallback to streaming (if online)
- Playback error → Show error message

---

## 🔀 Alternative Flows

### Favorites with Offline Support

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User adds favorite (offline)
   └─> Check authentication
       ├─> Authenticated → Continue
       └─> Not authenticated → Store locally
           └─> Local storage only

2. Authenticated user adds favorite (offline)
   └─> OfflineQueueService.addToQueue('create', 'user_favorites', data)
       └─> Store in AsyncStorage
           └─> Show success (local)
               └─> Favorite appears in UI

3. Connection restored
   └─> OfflineQueueService.processQueue()
       └─> Sync favorite to Supabase
           ├─> Success → Remove from queue
           └─> Failure → Retry later
```

**Use Cases:**
- User adds favorite while offline
- Favorite syncs when connection restored
- Local storage fallback for unauthenticated users

---

### Download Progress Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User triggers download
   └─> SupabaseAudioLibraryManager.downloadFile()
       └─> Download starts
           └─> Progress callback triggered
               └─> Update UI (if progress component used)
                   └─> Progress: 0% → 100%
                       └─> Download complete
                           └─> File ready for playback
```

**User Experience:**
- Progress visible (if UI component used)
- Real-time updates
- Completion notification

---

### Cache Cleanup Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Cache size exceeds limit
   └─> optimizeCache() triggered
       └─> Get cache statistics
           └─> Calculate files to remove
               └─> Sort files by last access (LRU)
                   └─> Remove files until 80% capacity
                       └─> Update metadata
                           └─> Save cleanup timestamp
```

**Automatic Behavior:**
- Runs on app initialization
- Transparent to user
- Preserves most recently used files

---

## 🚨 Error Flows

### Network Error During Download

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Download in progress
   └─> Network connection lost
       └─> Download fails
           └─> Error caught
               └─> Fallback to streaming (if available)
                   ├─> Online → Stream
                   └─> Offline → Show error
                       └─> User can retry when online
```

**Error Messages:**
- "Download failed. Falling back to streaming."
- "Network error. Please check your connection."

---

### Storage Full Error

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Download attempt
   └─> Check available storage
       └─> Storage full
           └─> Error caught
               └─> Trigger cache cleanup
                   └─> Retry download
                       ├─> Success → Continue
                       └─> Still full → Show error
                           └─> "Storage full. Please free up space."
```

**User Actions:**
- Free up device storage
- Clear app cache manually
- Delete unused downloads

---

### Queue Processing Failure

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Queue processing
   └─> Execute action
       └─> Action fails
           └─> Increment retry count
               ├─> Under max → Keep in queue
               └─> Max exceeded → Discard
                   └─> Log error
                       └─> User notified (optional)
```

**Error Handling:**
- Automatic retry on next connection
- Max retries: 3
- Discarded actions logged for debugging

---

## 🔄 State Transitions

### Queue States

```
Empty → Action Added → Queued
   │         │
   │         └─> Processing → Success → Empty
   │                           │
   │                           └─> Failure → Retry → Processing
   │                                              │
   │                                              └─> Max Retries → Discarded
   │
   └─> Connection Lost → Queued (waiting)
```

### Download States

```
Not Downloaded → Downloading → Downloaded
      │              │
      │              └─> Failed → Not Downloaded (retry available)
      │
      └─> Play Request → On-Demand Download → Downloaded
```

### Network States

```
Online → Connection Lost → Offline
   │                            │
   │                            └─> Connection Restored → Online
   │                                                      │
   │                                                      └─> Process Queue
   │
   └─> Queue Operations → Sync
```

---

## 📊 Flow Diagrams

### Complete Offline Experience

```
App Start
    │
    ├─> Initialize Services
    │   ├─> OfflineQueueService
    │   │   └─> Process pending queue
    │   ├─> SupabaseAudioLibraryManager
    │   │   └─> Load cache, optimize if needed
    │   └─> Network Listener
    │       └─> Monitor connection
    │
    ├─> User Action (Offline)
    │   └─> Queue operation
    │       └─> Store locally
    │           └─> Show success
    │
    ├─> User Plays Sound (Offline)
    │   ├─> Generated → Play
    │   ├─> Downloaded → Play
    │   └─> Not downloaded → Error
    │
    └─> Connection Restored
        └─> Process queue
            └─> Sync operations
                └─> Data synchronized
```

---

### Download and Playback Flow

```
User Selects Sound
    │
    ├─> Check Source Type
    │   ├─> Generated → Play Generated
    │   ├─> Local → Play Local
    │   └─> Remote → Continue
    │
    └─> Check Network
        ├─> Offline → Show Error
        └─> Online → Download
            └─> Show Progress
                └─> Download Complete
                    └─> Play Local
                        └─> Available Offline
```

---

## 🎯 User Goals

### Goal: Use App Offline
- **Path:** Download content → Use offline
- **Time:** Varies (download time)
- **Steps:** Download → Use

### Goal: Sync Offline Actions
- **Path:** Action offline → Auto sync
- **Time:** Automatic on connection
- **Steps:** Action → Queue → Sync

### Goal: Manage Storage
- **Path:** Automatic cache management
- **Time:** Automatic
- **Steps:** Cache full → Cleanup → Continue

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
