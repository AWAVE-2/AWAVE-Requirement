# Offline Support System - Components Inventory

## 📱 Service Components

The Offline Support system is primarily service-based with minimal UI components. Most functionality is handled through services that integrate with existing UI components.

---

## 🔧 Service Components

### OfflineQueueService
**File:** `src/services/OfflineQueueService.ts`  
**Type:** Static Service Class  
**Purpose:** Offline operation queue management

**Features:**
- Queue database operations when offline
- Automatic synchronization when connection restored
- Network state monitoring
- Retry mechanism

**Integration Points:**
- Used by favorites management (offline add/remove)
- Used by profile updates (offline changes)
- Used by any feature that needs offline operation queuing

**State Management:**
- Queue stored in AsyncStorage
- Network state tracked via NetInfo
- Processing state (isProcessing flag)

**User Interactions:**
- Transparent to user (automatic)
- Queue status accessible via `getQueueStatus()`
- No direct UI component

---

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Audio file download and local storage management

**Features:**
- Download audio files from Supabase Storage
- Track downloaded files
- Cache management
- File system operations

**Integration Points:**
- Used by `UnifiedAudioPlaybackService` for downloads
- Used by `BackgroundDownloadService` for bulk downloads
- Used by audio player for offline playback

**State Management:**
- Downloaded files tracked in Set
- File metadata in memory Map
- Cache statistics calculated on demand

**User Interactions:**
- Download progress callbacks (can be used by UI)
- Cache statistics accessible
- No direct UI component

---

### BackgroundDownloadService
**File:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Class  
**Purpose:** Proactive content downloading

**Features:**
- Download user favorites
- Download priority categories
- Queue management
- Download status tracking

**Integration Points:**
- Triggered after user login
- Used for background content preparation
- Can be triggered manually

**State Management:**
- Download queue
- Download status (isDownloading flag)

**User Interactions:**
- Background process (transparent)
- Status accessible via `isCurrentlyDownloading()`
- No direct UI component

---

### UnifiedAudioPlaybackService
**File:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Singleton Class  
**Purpose:** Unified audio playback with offline support

**Features:**
- Play downloaded files offline
- Play generated sounds offline
- Fallback to streaming
- On-demand downloads

**Integration Points:**
- Used by audio player components
- Integrates with TrackPlayer
- Handles source detection

**State Management:**
- Playback state managed by TrackPlayer
- Source detection (generated, local, stream)

**User Interactions:**
- Transparent to user
- Automatic source selection
- Download progress can be displayed (via callbacks)

---

### NetworkDiagnosticsService
**File:** `src/utils/networkDiagnostics.ts`  
**Type:** Static Service Class  
**Purpose:** Network connectivity diagnostics

**Features:**
- Test Supabase connection
- Measure latency
- Generate user-friendly error messages
- Diagnostic logging

**Integration Points:**
- Used before network operations
- Used for error handling
- Can be used by UI for status display

**State Management:**
- Diagnostic results (returned, not stored)

**User Interactions:**
- Error messages displayed to user
- Can be used to show connection status
- No direct UI component

---

## 🎨 UI Integration Points

### Progress Component
**File:** `src/components/ui/Progress.tsx`  
**Type:** Reusable UI Component  
**Purpose:** Display progress indicators

**Usage for Offline Support:**
- Can display download progress
- Shows percentage completion
- Supports linear and circular variants

**Props:**
```typescript
{
  progress: number; // 0-100
  variant?: 'default' | 'circular' | 'step';
  size?: 'sm' | 'md' | 'lg';
  showPercentage?: boolean;
  label?: string;
}
```

**Integration:**
- Can be used with download progress callbacks
- Displays download status
- Shows sync progress

---

### ComponentStateHandler
**File:** `src/components/ui/ComponentStates.tsx`  
**Type:** Reusable UI Component  
**Purpose:** Display component states (loading, error, empty)

**Usage for Offline Support:**
- Can display offline state
- Shows network error messages
- Displays retry options

**Props:**
```typescript
{
  state: 'loading' | 'error' | 'empty' | 'success';
  errorText?: string;
  onRetry?: () => void;
}
```

**Integration:**
- Used for offline error states
- Network error display
- Retry functionality

---

## 🔗 Service Integration Patterns

### Favorites with Offline Support
**File:** `src/hooks/useFavoritesManagement.ts`

**Pattern:**
- Loads from Supabase when online
- Falls back to local storage when offline
- Queues operations when offline
- Syncs when connection restored

**Components Used:**
- `OfflineQueueService` - Queue operations
- `AsyncStorage` - Local storage
- Supabase client - Remote storage

---

### Audio Playback with Offline Support
**File:** `src/services/UnifiedAudioPlaybackService.ts`

**Pattern:**
- Checks for local file first
- Attempts on-demand download if not local
- Falls back to streaming
- Priority: Generated > Local > Stream

**Components Used:**
- `SupabaseAudioLibraryManager` - File management
- `UnifiedAudioPlaybackService` - Playback routing
- TrackPlayer - Audio playback

---

## 📊 State Management

### Queue State
```typescript
{
  queue: QueuedAction[];
  isProcessing: boolean;
  networkState: 'online' | 'offline';
}
```

**Storage:**
- AsyncStorage: `offline_action_queue`
- In-memory: Processing state

---

### Download State
```typescript
{
  downloads: Map<string, DownloadProgress>;
  queue: DownloadQueueItem[];
  isDownloading: boolean;
}
```

**Storage:**
- AsyncStorage: `awave.dev.downloadedFiles`
- In-memory: Active downloads, queue

---

### Cache State
```typescript
{
  downloadedFiles: Set<string>;
  cacheStats: CacheStats;
  lastCleanup: string;
}
```

**Storage:**
- AsyncStorage: `awave.dev.downloadedFiles`, `awave.dev.lastCacheCleanup`
- File System: Downloaded audio files
- In-memory: File metadata, cache stats

---

## 🎯 Component Relationships

### Offline Queue Flow
```
User Action (Offline)
    │
    └─> OfflineQueueService.addToQueue()
        └─> AsyncStorage (persist)
            └─> Network Listener (monitor)
                └─> Connection Restored
                    └─> OfflineQueueService.processQueue()
                        └─> Supabase (sync)
```

### Download Flow
```
User Action / Background Trigger
    │
    └─> SupabaseAudioLibraryManager.downloadFile()
        └─> Progress Callback (optional UI update)
            └─> File System (save)
                └─> AsyncStorage (track)
                    └─> UnifiedAudioPlaybackService (play)
```

### Playback Flow
```
Play Request
    │
    ├─> Generated Sound? → Play Generated
    │
    ├─> Local File? → Play Local
    │
    └─> Not Local? → On-Demand Download
        ├─> Download Success → Play Local
        └─> Download Failed → Play Stream
```

---

## 🧪 Testing Considerations

### Service Tests
- Queue operations (add, process, clear)
- Download functionality
- Network state detection
- Cache management
- Error handling

### Integration Tests
- Service interactions
- Storage persistence
- Network restoration
- Download progress
- Playback source selection

### UI Tests
- Progress display
- Error state display
- Offline indicators
- Retry functionality

---

## 📝 Notes

### Service-Based Architecture
- Most offline functionality is service-based
- UI components are minimal and optional
- Services integrate with existing UI components
- Transparent to user where possible

### UI Components
- Progress component can show download progress
- ComponentStateHandler can show offline states
- No dedicated offline UI components
- Integration with existing components

### Future UI Enhancements
- Download queue management UI
- Cache management UI
- Offline status indicator
- Download progress indicators
- Sync status display

---

*For service details, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
