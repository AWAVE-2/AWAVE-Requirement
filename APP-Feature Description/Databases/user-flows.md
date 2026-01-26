# Database System - User Flows

## 🔄 Primary User Flows

### 1. Database Read Flow (Online)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component requests data
   └─> ProductionBackendService.getUserProfile()
       └─> Check network connectivity
           ├─> Offline → Return error / use cache
           └─> Online → Continue
               └─> Execute Supabase query
                   ├─> Error → Handle error
                   └─> Success → Return data
                       └─> Update local cache (optional)
```

**Success Path:**
- Network available
- Query succeeds
- Data returned to component
- Cache updated (if applicable)

**Error Paths:**
- Network error → Show connectivity error
- RLS policy violation → Show permission error
- Not found → Return null
- Timeout → Retry or show error

---

### 2. Database Write Flow (Online)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User performs action (e.g., add favorite)
   └─> Component calls ProductionBackendService.addFavorite()
       └─> Check network connectivity
           ├─> Offline → Queue operation
           │   └─> OfflineQueueService.addToQueue()
           │       └─> Store in AsyncStorage
           │           └─> Return success (queued)
           └─> Online → Continue
               └─> Execute Supabase query
                   ├─> Error → Handle error
                   └─> Success → Return data
                       └─> Update local cache (optional)
```

**Success Path:**
- Network available
- Query succeeds
- Data written to database
- Local cache updated
- User sees success feedback

**Error Paths:**
- Network error → Queue operation
- Validation error → Show error message
- RLS policy violation → Show permission error
- Duplicate key → Show conflict error

---

### 3. Offline Operation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User performs action (Offline)
   └─> Component calls ProductionBackendService method
       └─> Check network connectivity
           └─> Offline detected
               └─> OfflineQueueService.addToQueue()
                   ├─> Create QueuedAction
                   ├─> Store in AsyncStorage
                   └─> Return success (queued)
                       └─> Show "Saved offline" message

2. Network Restored
   └─> NetInfo listener triggers
       └─> OfflineQueueService.processQueue()
           ├─> Get queue from AsyncStorage
           ├─> For each queued action:
           │   ├─> Execute Supabase query
           │   ├─> Success → Remove from queue
           │   └─> Error → Increment retry count
           │       ├─> Retry count < max → Keep in queue
           │       └─> Retry count >= max → Discard
           └─> Update queue in AsyncStorage
               └─> Show sync status (if applicable)
```

**Success Path:**
- Operation queued when offline
- Network restored
- Queue processed automatically
- Operations synced to database
- User sees sync confirmation

**Error Paths:**
- Queue processing fails → Retry on next network restore
- Max retries exceeded → Discard operation, log error
- Network drops during sync → Resume on next restore

---

### 4. Local Storage Read Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component requests local data
   └─> AWAVEStorage.getFavorites() or storage.getItem()
       ├─> If using storage utility:
       │   └─> Check if initialized
       │       ├─> Not initialized → Warn, return from cache
       │       └─> Initialized → Return from cache (sync)
       └─> If using AWAVEStorage:
           └─> AsyncStorage.getItem() (async)
               └─> Parse JSON
                   └─> Return data
```

**Success Path:**
- Storage initialized
- Data found in cache/storage
- Data returned to component

**Error Paths:**
- Storage not initialized → Return null, warn in dev
- Data not found → Return null/empty
- Parse error → Return null, log error

---

### 5. Local Storage Write Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Component saves local data
   └─> AWAVEStorage.setFavorites() or storage.setItem()
       ├─> If using storage utility:
       │   └─> Update cache immediately (sync)
       │       └─> AsyncStorage.setItem() (background)
       │           └─> Fire-and-forget persistence
       └─> If using AWAVEStorage:
           └─> AsyncStorage.setItem() (async)
               └─> JSON.stringify() data
                   └─> Persist to storage
```

**Success Path:**
- Data saved to cache/storage
- Persistence initiated
- Component continues immediately

**Error Paths:**
- Storage quota exceeded → Log error, keep in cache
- Write failure → Log error, keep in cache
- Invalid data → Validation error

---

### 6. Session Tracking Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User starts audio session
   └─> ProductionBackendService.startSession()
       ├─> Check network connectivity
       ├─> Create session record
       ├─> Store device info
       └─> Return session ID
           └─> Store session ID locally

2. User ends audio session
   └─> ProductionBackendService.endSession()
       ├─> Calculate duration
       ├─> Update session record
       ├─> Mark as completed
       └─> Return updated session
           └─> Clear local session ID
```

**Success Path:**
- Session started and tracked
- Session ended with duration
- Data persisted to database

**Error Paths:**
- Network error → Queue session end
- Session not found → Log error
- Invalid duration → Validation error

---

### 7. Favorites Management Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User adds favorite
   └─> ProductionBackendService.addFavorite()
       ├─> Check network connectivity
       ├─> Create favorite record
       └─> Return created favorite
           └─> Update local cache (optional)

2. User removes favorite
   └─> ProductionBackendService.removeFavorite()
       ├─> Check network connectivity
       ├─> Delete favorite record
       └─> Return success
           └─> Update local cache

3. User plays favorite
   └─> ProductionBackendService.updateFavoriteUsage()
       ├─> Increment use_count
       ├─> Update last_used timestamp
       └─> Return updated favorite
```

**Success Path:**
- Favorite added/removed/updated
- Database updated
- Local cache synced

**Error Paths:**
- Network error → Queue operation
- Favorite not found → Show error
- Duplicate favorite → Show conflict error

---

### 8. Custom Sound Session Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User creates custom mix
   └─> ProductionBackendService.createCustomSoundSession()
       ├─> Validate tracks_config
       ├─> Set swiper_positions defaults
       ├─> Create session record
       └─> Return created session

2. User updates custom mix
   └─> ProductionBackendService.updateCustomSoundSession()
       ├─> Update tracks_config
       ├─> Update swiper_positions
       ├─> Update updated_at timestamp
       └─> Return updated session

3. User deletes custom mix
   └─> ProductionBackendService.deleteCustomSoundSession()
       ├─> Delete session record
       └─> Return success
```

**Success Path:**
- Custom session created/updated/deleted
- Database updated
- User sees confirmation

**Error Paths:**
- Invalid tracks_config → Validation error
- Session not found → Show error
- Network error → Queue operation

---

## 🔀 Alternative Flows

### Cache-First Read Flow

```
Component Request
    │
    └─> Check local cache
        ├─> Cache hit → Return cached data
        │   └─> Fetch from database in background
        │       └─> Update cache
        └─> Cache miss → Fetch from database
            └─> Update cache
                └─> Return data
```

**Use Cases:**
- Sound metadata (public data)
- User profile (frequently accessed)
- Favorites (user-specific)

---

### Optimistic Update Flow

```
User Action
    │
    └─> Update local cache immediately
        └─> Show updated UI
            └─> Execute database operation in background
                ├─> Success → Confirm update
                └─> Error → Revert cache, show error
```

**Use Cases:**
- Favorite toggling
- Profile updates
- Settings changes

---

### Batch Operation Flow

```
Multiple Operations
    │
    └─> Group operations
        └─> Execute in batch
            ├─> All succeed → Return all results
            └─> Any fails → Rollback or partial success
```

**Use Cases:**
- Bulk favorite operations
- Multiple session updates
- Batch analytics logging

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt database operation
   └─> Network error detected
       ├─> If write operation:
       │   └─> Queue operation
       │       └─> Show "Saved offline" message
       └─> If read operation:
           ├─> Try local cache
           │   ├─> Cache hit → Return cached data
           │   └─> Cache miss → Show error
           └─> Show "No internet connection" message
```

**User Experience:**
- Write operations queued automatically
- Read operations use cache if available
- Clear error messages
- Automatic retry when online

---

### Validation Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Submit invalid data
   └─> Validation fails
       ├─> Client-side validation → Show error immediately
       └─> Server-side validation → Show error after submit
           └─> Highlight invalid fields
               └─> Allow correction
```

**Error Messages:**
- Field-specific validation errors
- Clear guidance on how to fix
- No technical jargon

---

### RLS Policy Violation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt unauthorized access
   └─> RLS policy blocks operation
       └─> Return permission error
           └─> Show "Access denied" message
               └─> Log security event
```

**Security:**
- User data isolated by user_id
- No cross-user access possible
- Errors logged for security monitoring

---

### Storage Quota Exceeded Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt storage write
   └─> Storage quota exceeded
       └─> Log error
           └─> Keep data in cache
               └─> Show warning (if applicable)
                   └─> Suggest clearing cache
```

**Recovery:**
- Data remains in cache
- User can clear old data
- Automatic cleanup of expired data

---

## 🔄 State Transitions

### Database Connection States

```
Disconnected → Connecting → Connected
     │              │            │
     │              └─> Error   │
     │                          │
     └─> Reconnecting ←─────────┘
```

### Offline Queue States

```
Empty → Queued → Processing → Synced
  │       │          │           │
  │       │          └─> Failed  │
  │       │              │        │
  │       └─> Retry ←───┘        │
  │                              │
  └─> Cleared ←──────────────────┘
```

### Local Storage States

```
Uninitialized → Initializing → Initialized
      │              │              │
      │              └─> Error     │
      │                             │
      └─> Failed ←─────────────────┘
```

---

## 📊 Flow Diagrams

### Complete Data Flow (Online)

```
User Action
    │
    └─> Component
        │
        ├─> ProductionBackendService
        │   └─> Supabase Client
        │       └─> Database
        │           └─> Return Data
        │               └─> Update Cache
        │
        └─> AWAVEStorage / storage
            └─> AsyncStorage
                └─> Return Data
```

### Complete Data Flow (Offline)

```
User Action
    │
    └─> Component
        │
        ├─> ProductionBackendService
        │   └─> Network Check
        │       └─> Offline
        │           └─> OfflineQueueService
        │               └─> AsyncStorage (Queue)
        │
        └─> AWAVEStorage / storage
            └─> AsyncStorage (Cache)
                └─> Return Cached Data

Network Restore
    │
    └─> NetInfo Listener
        └─> OfflineQueueService.processQueue()
            └─> Supabase Client
                └─> Database
                    └─> Sync Complete
```

---

## 🎯 User Goals

### Goal: Fast Data Access
- **Path:** Cache-first reads
- **Time:** < 1ms (from cache)
- **Fallback:** Database query (< 3 seconds)

### Goal: Reliable Data Persistence
- **Path:** Online writes + offline queue
- **Time:** Immediate (queued) or < 3 seconds (online)
- **Reliability:** > 99% success rate

### Goal: Seamless Offline Experience
- **Path:** Local cache + offline queue
- **Time:** Instant (from cache)
- **Sync:** Automatic when online

---

## 🔄 Synchronization Patterns

### Immediate Sync
- User actions trigger immediate database operations
- Used for: Critical data, user preferences
- Error handling: Queue if offline

### Background Sync
- Operations performed in background
- Used for: Analytics, non-critical updates
- Error handling: Silent retry

### Batch Sync
- Multiple operations grouped and synced together
- Used for: Bulk operations, analytics
- Error handling: Partial success handling

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
