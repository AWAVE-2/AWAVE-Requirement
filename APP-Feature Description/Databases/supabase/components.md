# Supabase Integration - Components Inventory

## 📱 Services

### Supabase Client
**File:** `src/config/productionConfig.ts`  
**Type:** Singleton Client Instance  
**Purpose:** Main Supabase database connection

**Configuration:**
- Production URL: `https://api.dripin.ai`
- Isolated storage adapter
- PKCE authentication flow
- Real-time WebSocket connection
- Custom headers for client identification

**Features:**
- Database operations (CRUD)
- Authentication operations
- Storage operations
- Real-time subscriptions
- RPC function calls

**Dependencies:**
- `@supabase/supabase-js`
- `@react-native-async-storage/async-storage`
- `react-native-url-polyfill`
- `react-native-get-random-values`

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Main database API service layer

**Method Categories:**
- Authentication (9 methods)
- Profile Management (3 methods)
- Session Tracking (3 methods)
- Favorites Management (4 methods)
- Sound Metadata (3 methods)
- Subscription Management (3 methods)
- Custom Sound Sessions (5 methods)
- Notification Preferences (2 methods)
- Analytics (1 method)
- Audio Storage (2 methods)
- Business Logic (3 methods)
- Real-Time Subscriptions (2 methods)
- Testing (3 methods)

**Features:**
- Type-safe database operations
- Error handling with safeApiCall wrapper
- Automatic error logging
- RLS policy enforcement
- Real-time subscriptions

**Dependencies:**
- `supabase` client
- `backendConstants` (TABLES, RPC_FUNCTIONS, ERROR_CODES)
- `errorHandler` utilities

---

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Audio file download and local storage management

**Storage Configuration:**
- Bucket: `awave-audio`
- Local Directory: `Documents/audio`
- Max Cache Size: 2GB
- Download Timeout: 30 seconds

**Features:**
- Audio metadata loading
- File download management
- Local cache optimization
- Progress tracking
- Real-time metadata sync
- Cache statistics

**Storage Keys:**
- `awave.dev.downloadedFiles` - Downloaded file IDs
- `awave.dev.lastCacheCleanup` - Last cleanup timestamp

**Dependencies:**
- `supabase` client
- `AsyncStorage`
- `react-native-fs`

---

### useRealtimeSync Hook
**File:** `src/hooks/useRealtimeSync.ts`  
**Type:** React Hook  
**Purpose:** Real-time data synchronization

**Options:**
- `userId: string` - User ID for filtering
- `enableFavorites?: boolean` - Enable favorites sync
- `enableSessions?: boolean` - Enable sessions sync
- `enableSubscription?: boolean` - Enable subscription sync
- `enableCustomSounds?: boolean` - Enable custom sounds sync
- `onError?: (error: Error) => void` - Error callback

**Features:**
- Automatic subscription setup
- React Query cache invalidation
- Error handling with callbacks
- Automatic cleanup on unmount
- Performance optimization

**Subscriptions:**
1. `user_favorites` - Favorite changes
2. `user_sessions` - Session updates
3. `subscriptions` - Subscription status changes
4. `custom_sound_sessions` - Custom mix updates
5. `user_profiles` - Profile updates
6. `sound_metadata` - Global sound updates

**Dependencies:**
- `supabase` client
- `@tanstack/react-query`
- React hooks

---

### useProfileSync Hook
**File:** `src/hooks/useRealtimeSync.ts`  
**Type:** React Hook  
**Purpose:** User profile real-time synchronization

**Parameters:**
- `userId: string` - User ID
- `onProfileUpdate?: (profile: any) => void` - Update callback

**Features:**
- Real-time profile updates
- React Query cache invalidation
- Automatic cleanup

---

### useSoundMetadataSync Hook
**File:** `src/hooks/useRealtimeSync.ts`  
**Type:** React Hook  
**Purpose:** Global sound metadata synchronization

**Parameters:**
- `onSoundUpdate?: () => void` - Update callback

**Features:**
- Global sound metadata updates
- React Query cache invalidation
- Automatic cleanup

---

## 🔗 Component Relationships

### Supabase Client Architecture
```
Supabase Client
├── Auth API
│   ├── signUp
│   ├── signIn
│   ├── signOut
│   ├── getSession
│   └── refreshSession
├── Database API
│   ├── from(table).select()
│   ├── from(table).insert()
│   ├── from(table).update()
│   └── from(table).delete()
├── Storage API
│   ├── from(bucket).upload()
│   ├── from(bucket).download()
│   ├── from(bucket).getPublicUrl()
│   └── from(bucket).createSignedUrl()
├── Realtime API
│   ├── channel(name).on()
│   └── removeChannel(channel)
└── Functions API
    └── rpc(functionName, params)
```

### Service Layer Architecture
```
ProductionBackendService
├── Authentication Methods
│   └─> supabase.auth.*
├── Database Methods
│   └─> supabase.from(table).*
├── Storage Methods
│   └─> supabase.storage.*
├── Real-Time Methods
│   └─> supabase.channel().*
└── RPC Methods
    └─> supabase.rpc()

SupabaseAudioLibraryManager
├── Metadata Loading
│   └─> supabase.from('sound_metadata').select()
├── File Download
│   └─> supabase.storage.from('awave-audio').download()
├── Cache Management
│   └─> AsyncStorage + react-native-fs
└── Real-Time Sync
    └─> supabase.channel().on('sound_metadata')
```

### Hook Architecture
```
useRealtimeSync
├── Setup Subscriptions
│   ├── user_favorites channel
│   ├── user_sessions channel
│   ├── subscriptions channel
│   └── custom_sound_sessions channel
├── React Query Integration
│   └─> queryClient.invalidateQueries()
└── Cleanup
    └─> supabase.removeChannel()

useProfileSync
├── Setup Profile Subscription
│   └─> user_profiles channel
├── React Query Integration
└── Cleanup

useSoundMetadataSync
├── Setup Metadata Subscription
│   └─> sound_metadata channel
├── React Query Integration
└── Cleanup
```

---

## 🎨 Storage Architecture

### Storage Initialization Flow
```
App Startup
    │
    └─> SupabaseAudioLibraryManager.initialize()
        ├─> Ensure local directories exist
        ├─> Load cached data from AsyncStorage
        ├─> Load audio metadata from Supabase
        ├─> Setup real-time subscriptions
        └─> Optimize cache
```

### File Download Flow
```
User Request
    │
    └─> SupabaseAudioLibraryManager.downloadFile()
        ├─> Check if already downloaded
        ├─> If not:
        │   ├─> Get file metadata from database
        │   ├─> Generate download URL (public or signed)
        │   ├─> Download file with progress tracking
        │   ├─> Save to local storage
        │   └─> Update downloaded files set
        └─> Return local file path
```

### Real-Time Sync Flow
```
Database Change
    │
    └─> Supabase Realtime WebSocket
        └─> Channel Event (INSERT/UPDATE/DELETE)
            └─> useRealtimeSync Hook
                └─> React Query Cache Invalidation
                    └─> Component Re-render with New Data
```

---

## 🔄 State Management

### Database State
- Managed by Supabase client
- Automatic session refresh
- Real-time subscriptions for live updates
- Connection state tracking

### Local Storage State
- Audio file cache in `Documents/audio`
- Metadata cache in memory
- Download queue management
- Cache statistics tracking

### Real-Time State
- WebSocket connection state
- Channel subscription state
- Event processing state
- Error state tracking

---

## 🧪 Testing Considerations

### Service Tests
- Mock Supabase client
- Mock AsyncStorage
- Mock react-native-fs
- Test error handling
- Test retry logic
- Test subscription setup/teardown

### Integration Tests
- Real Supabase connection
- Real storage operations
- Real-time subscription testing
- Network state changes
- Cache operations

### E2E Tests
- Complete data flows
- Real-time synchronization
- File download and playback
- Offline/online transitions
- Error scenarios

---

## 📊 Component Metrics

### Complexity
- **Supabase Client:** Low (wrapper around library)
- **ProductionBackendService:** High (many methods, complex logic)
- **SupabaseAudioLibraryManager:** Medium (file management, caching)
- **useRealtimeSync:** Medium (subscription management)

### Reusability
- **Supabase Client:** High (used throughout app)
- **ProductionBackendService:** High (used for all database operations)
- **SupabaseAudioLibraryManager:** Medium (audio-specific)
- **useRealtimeSync:** High (used in multiple components)

### Dependencies
- All services depend on Supabase client
- Audio manager depends on file system
- Real-time hooks depend on React Query
- All services use TypeScript for type safety

---

## 🔐 Security Considerations

### Token Storage
- Supabase session tokens in isolated storage
- Storage key prefix: `awave.dev.supabase.`
- Automatic token refresh
- Secure storage adapter

### Data Privacy
- RLS policies enforced on all queries
- User data isolated by user_id
- No cross-user data access
- Secure file downloads

### Network Security
- All requests use HTTPS
- Token transmission encrypted
- No credentials in logs
- Secure WebSocket connections

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
