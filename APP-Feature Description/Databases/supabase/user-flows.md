# Supabase Integration - User Flows

## 🔄 Primary User Flows

### 1. Database Query Flow (Online)

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

### 2. Real-Time Data Synchronization Flow

```
Database Change                System Response
─────────────────────────────────────────────────────────
1. User adds favorite on Device A
   └─> Supabase database updated
       └─> Supabase Realtime detects change
           └─> WebSocket event sent
               └─> Device B receives event
                   └─> useRealtimeSync hook processes event
                       └─> React Query cache invalidated
                           └─> Component re-renders with new data
```

**Success Path:**
- Database change detected
- WebSocket event received
- Cache invalidated
- UI updated automatically

**Error Paths:**
- WebSocket disconnected → Automatic reconnection
- Event processing error → Log error, continue
- Cache invalidation fails → Manual refresh

---

### 3. Audio File Download Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User requests audio file
   └─> SupabaseAudioLibraryManager.downloadFile()
       ├─> Check if file already downloaded
       │   ├─> Yes → Return local path
       │   └─> No → Continue
       │       └─> Get file metadata from database
       │           └─> Check if premium content
       │               ├─> Premium → Generate signed URL
       │               └─> Free → Get public URL
       │                   └─> Download file with progress
       │                       └─> Save to local storage
       │                           └─> Update downloaded files set
       │                               └─> Return local path
```

**Success Path:**
- File metadata retrieved
- Download URL generated
- File downloaded successfully
- Saved to local storage
- Local path returned

**Error Paths:**
- File not found → Show error
- Download fails → Retry or show error
- Storage quota exceeded → Show warning
- Network error → Queue for later

---

### 4. Real-Time Subscription Setup Flow

```
Component Mount                System Response
─────────────────────────────────────────────────────────
1. Component uses useRealtimeSync hook
   └─> Hook checks if userId provided
       ├─> No userId → Skip setup
       └─> Has userId → Continue
           └─> Create subscription channels
               ├─> user_favorites channel
               ├─> user_sessions channel
               ├─> subscriptions channel
               └─> custom_sound_sessions channel
                   └─> Subscribe to each channel
                       └─> Setup event handlers
                           └─> Channels active
```

**Success Path:**
- Channels created
- Subscriptions active
- Events received and processed
- Cache invalidated on changes

**Error Paths:**
- Connection fails → Automatic retry
- Subscription fails → Log error, continue
- Channel cleanup fails → Manual cleanup

---

### 5. Storage Upload Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User uploads audio file
   └─> SupabaseAudioLibraryManager.uploadFile()
       ├─> Validate file (size, type)
       ├─> Generate storage path
       ├─> Upload to Supabase Storage
       │   └─> Track upload progress
       ├─> Insert metadata into database
       └─> Return file metadata
```

**Success Path:**
- File validated
- Uploaded to storage
- Metadata saved
- File available for download

**Error Paths:**
- File too large → Show error
- Invalid file type → Show error
- Upload fails → Retry or show error
- Database insert fails → Rollback upload

---

### 6. Signed URL Generation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User requests premium audio
   └─> ProductionBackendService.getSignedAudioUrl()
       ├─> Check user subscription status
       ├─> If subscribed:
       │   └─> Call Supabase function
       │       └─> Generate signed URL (1-hour TTL)
       │           └─> Return URL and expiration
       └─> If not subscribed:
           └─> Return error
```

**Success Path:**
- User has active subscription
- Signed URL generated
- URL valid for 1 hour
- File accessible

**Error Paths:**
- No subscription → Show upgrade prompt
- Function call fails → Show error
- URL expired → Regenerate URL

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

### Real-Time Subscription Error Flow

```
Subscription Error            System Response
─────────────────────────────────────────────────────────
1. WebSocket disconnects
   └─> Supabase client detects disconnection
       └─> Automatic reconnection attempt
           ├─> Success → Resume subscriptions
           └─> Failure → Continue retrying
               └─> Log error for monitoring
```

**Recovery:**
- Automatic reconnection
- Subscriptions restored
- No data loss
- Transparent to user

---

### Storage Error Flow

```
Storage Operation             System Response
─────────────────────────────────────────────────────────
1. File download fails
   └─> Error detected
       ├─> Network error → Queue for retry
       ├─> File not found → Show error
       ├─> Storage quota exceeded → Show warning
       └─> Other error → Log and show error
           └─> Provide retry option
```

**Error Messages:**
- "File not found"
- "Storage quota exceeded"
- "Download failed, please try again"
- Retry button available

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

## 🔄 State Transitions

### Database Connection States

```
Disconnected → Connecting → Connected
     │              │            │
     │              └─> Error   │
     │                          │
     └─> Reconnecting ←─────────┘
```

### Real-Time Subscription States

```
Unsubscribed → Subscribing → Subscribed
      │              │             │
      │              └─> Error     │
      │                            │
      └─> Reconnecting ←───────────┘
```

### File Download States

```
Not Downloaded → Downloading → Downloaded
      │              │              │
      │              └─> Failed    │
      │                            │
      └─> Retrying ←───────────────┘
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
        └─> useRealtimeSync
            └─> Real-Time Subscription
                └─> WebSocket Event
                    └─> Cache Invalidation
                        └─> Component Re-render
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
        └─> Local Cache
            └─> Return Cached Data

Network Restore
    │
    └─> NetInfo Listener
        └─> OfflineQueueService.processQueue()
            └─> Supabase Client
                └─> Database
                    └─> Sync Complete
```

### Real-Time Synchronization Flow

```
Device A: User Action
    │
    └─> Database Update
        └─> Supabase Realtime
            └─> WebSocket Broadcast
                │
                ├─> Device A: useRealtimeSync
                │   └─> Cache Invalidation
                │       └─> UI Update
                │
                └─> Device B: useRealtimeSync
                    └─> Cache Invalidation
                        └─> UI Update
```

---

## 🎯 User Goals

### Goal: Fast Data Access
- **Path:** Cache-first reads
- **Time:** < 1ms (from cache)
- **Fallback:** Database query (< 3 seconds)

### Goal: Real-Time Updates
- **Path:** WebSocket subscriptions
- **Latency:** < 1 second
- **Reliability:** > 99% uptime

### Goal: Offline File Access
- **Path:** Local download and cache
- **Time:** Instant (from cache)
- **Sync:** Automatic when online

---

## 🔄 Synchronization Patterns

### Immediate Sync
- User actions trigger immediate database operations
- Used for: Critical data, user preferences
- Error handling: Queue if offline

### Real-Time Sync
- Database changes broadcast via WebSocket
- Used for: Multi-device synchronization
- Error handling: Automatic reconnection

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
