# Supabase Integration - Services Documentation

## 🔧 Service Layer Overview

The Supabase integration uses a service-oriented architecture with clear separation of concerns. Services handle all database operations, real-time subscriptions, storage management, and data synchronization.

---

## 📦 Services

### Supabase Client
**File:** `src/config/productionConfig.ts`  
**Type:** Singleton Client Instance  
**Purpose:** Main Supabase database connection

#### Configuration
```typescript
export const supabase: SupabaseClient = createClient(
  ENV_CONFIG.SUPABASE_URL,
  ENV_CONFIG.SUPABASE_ANON_KEY,
  {
    auth: {
      storage: isolatedStorage,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
      flowType: 'pkce',
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
    global: {
      headers: {
        'X-Client-Info': 'awave-advanced-react-native',
      },
    },
  },
);
```

#### Methods

**Database Operations:**
- `supabase.from(table).select()` - Query data
- `supabase.from(table).insert()` - Insert data
- `supabase.from(table).update()` - Update data
- `supabase.from(table).delete()` - Delete data
- `supabase.from(table).upsert()` - Insert or update

**Auth Operations:**
- `supabase.auth.signUp()` - User registration
- `supabase.auth.signInWithPassword()` - Email/password sign in
- `supabase.auth.signOut()` - Sign out
- `supabase.auth.getSession()` - Get current session
- `supabase.auth.refreshSession()` - Refresh session
- `supabase.auth.onAuthStateChange()` - Auth state listener

**Storage Operations:**
- `supabase.storage.from(bucket).upload()` - Upload file
- `supabase.storage.from(bucket).download()` - Download file
- `supabase.storage.from(bucket).getPublicUrl()` - Get public URL
- `supabase.storage.from(bucket).createSignedUrl()` - Create signed URL
- `supabase.storage.from(bucket).list()` - List files
- `supabase.storage.from(bucket).remove()` - Delete file

**Realtime Operations:**
- `supabase.channel(name).on().subscribe()` - Subscribe to changes
- `supabase.removeChannel(channel)` - Unsubscribe from channel

**RPC Operations:**
- `supabase.rpc(functionName, params)` - Call RPC function

#### Dependencies
- `@supabase/supabase-js`
- `@react-native-async-storage/async-storage`
- `react-native-url-polyfill`
- `react-native-get-random-values`

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Main database API service layer

#### Database Methods

**Authentication:**
- `signUp(email, password, firstName?, lastName?)` - User registration
- `signIn(email, password)` - User authentication
- `signOut()` - User sign out
- `getCurrentUser()` - Get current authenticated user
- `getSession()` - Get current session
- `updateEmail(email)` - Update user email
- `updatePassword(password)` - Update user password
- `setAuthSession(accessToken, refreshToken)` - Set session from tokens
- `resendVerificationEmail(email)` - Resend verification email

**Profile:**
- `getUserProfile(userId)` - Get user profile
- `createUserProfile(userId, profileData)` - Create user profile
- `updateUserProfile(userId, updates)` - Update user profile

**Sessions:**
- `startSession(userId, sessionType, soundsConfig?)` - Start session
- `endSession(sessionId, userId, durationMinutes)` - End session
- `getUserSessions(userId)` - Get user sessions

**Favorites:**
- `getUserFavorites(userId)` - Get user favorites
- `addFavorite(userId, favoriteData)` - Add favorite
- `removeFavorite(favoriteId, userId)` - Remove favorite
- `updateFavoriteUsage(favoriteId, userId, currentUseCount)` - Update usage

**Sound Metadata:**
- `getSoundMetadata()` - Get all sound metadata
- `searchSounds(keyword)` - Search sounds by keyword
- `getAllSoundMetadata()` - Get all metadata (alias)

**Subscriptions:**
- `getUserSubscription(userId)` - Get user subscription
- `createSubscription(userId, planType)` - Create subscription
- `checkTrialDaysRemaining(userId)` - Check trial days (RPC)

**Custom Sound Sessions:**
- `getCustomSoundSessions(userId)` - Get custom sessions
- `createCustomSoundSession(userId, sessionData)` - Create session
- `updateCustomSoundSession(sessionId, userId, updates)` - Update session
- `deleteCustomSoundSession(sessionId, userId)` - Delete session

**Notifications:**
- `getNotificationPreferences(userId)` - Get preferences
- `updateNotificationPreferences(userId, preferences)` - Update preferences

**Analytics:**
- `logSearchAnalytics(userId, query, resultsCount, sosTriggered)` - Log search

**Audio Storage:**
- `getSignedAudioUrl(category, soundId, ttlSeconds?)` - Get signed URL
- `getPublicAudioUrl(category, soundId)` - Get public URL

**Business Logic:**
- `checkRegistrationStatus(userId)` - Check registration (RPC)
- `checkUserNeedsRegistration(userId)` - Check needs registration (RPC)
- `getActiveSOSConfig()` - Get active SOS config

**Real-Time:**
- `subscribeToProfileChanges(userId, callback)` - Subscribe to profile
- `subscribeToSubscriptionChanges(userId, callback)` - Subscribe to subscription

**Testing:**
- `healthCheck()` - Health check
- `testPublicAccess()` - Test public access
- `testAuthenticatedAccess(userId)` - Test authenticated access

#### Error Handling
- All methods wrapped in `safeApiCall`
- Automatic error logging
- User-friendly error messages
- RLS policy error handling

#### Dependencies
- `supabase` client
- `backendConstants` (TABLES, RPC_FUNCTIONS, ERROR_CODES)
- `errorHandler` utilities

---

### SupabaseAudioLibraryManager
**File:** `src/services/SupabaseAudioLibraryManager.ts`  
**Type:** Singleton Class  
**Purpose:** Audio file download and local storage management

#### Configuration
- `STORAGE_BUCKET = 'awave-audio'` - Supabase storage bucket
- `LOCAL_AUDIO_DIR = 'Documents/audio'` - Local storage directory
- `MAX_CACHE_SIZE = 2GB` - Maximum cache size
- `DOWNLOAD_TIMEOUT = 30000` - Download timeout (30 seconds)

#### Methods

**Initialization:**
- `initialize()` - Initialize manager
- `ensureLocalDirectoryExists()` - Create directories
- `loadCachedData()` - Load cached data
- `loadAudioMetadata()` - Load metadata from Supabase
- `setupRealTimeSync()` - Setup real-time subscriptions
- `optimizeCache()` - Optimize cache

**Metadata Management:**
- `loadAudioMetadata()` - Load all audio metadata
- `getAudioFile(fileId)` - Get audio file by ID
- `getAudioFilesByCategory(categoryId)` - Get files by category
- `searchAudioFiles(query)` - Search audio files
- `getAllCategories()` - Get all categories

**Download Management:**
- `downloadFile(fileId, onProgress?)` - Download file
- `performDownload(file, onProgress?)` - Perform download
- `getStreamingUrl(fileId)` - Get streaming URL
- `getLocalAudioPath(fileId)` - Get local file path
- `isFileAvailableLocally(fileId)` - Check if file is local

**Cache Management:**
- `optimizeCache()` - Optimize cache size
- `clearCache()` - Clear all cache
- `getCacheStats()` - Get cache statistics
- `getDownloadedFiles()` - Get downloaded files list

**Real-Time Sync:**
- `setupRealTimeSync()` - Setup subscriptions
- `handleMetadataUpdate(payload)` - Handle metadata updates

#### Storage Keys
- `awave.dev.downloadedFiles` - List of downloaded file IDs
- `awave.dev.lastCacheCleanup` - Last cleanup timestamp

#### Dependencies
- `supabase` client
- `AsyncStorage`
- `react-native-fs`

---

### useRealtimeSync Hook
**File:** `src/hooks/useRealtimeSync.ts`  
**Type:** React Hook  
**Purpose:** Real-time data synchronization

#### Options
```typescript
interface RealtimeSyncOptions {
  userId: string;
  enableFavorites?: boolean;
  enableSessions?: boolean;
  enableSubscription?: boolean;
  enableCustomSounds?: boolean;
  onError?: (error: Error) => void;
}
```

#### Features
- **Automatic subscriptions** - Sets up subscriptions based on options
- **Cache invalidation** - Invalidates React Query cache on changes
- **Error handling** - Graceful error handling with callbacks
- **Cleanup** - Automatic channel cleanup on unmount

#### Subscriptions
1. **user_favorites** - Favorite changes
2. **user_sessions** - Session updates
3. **subscriptions** - Subscription status changes
4. **custom_sound_sessions** - Custom mix updates
5. **user_profiles** - Profile updates
6. **sound_metadata** - Global sound updates

#### Usage
```typescript
useRealtimeSync({
  userId: user.id,
  enableFavorites: true,
  enableSessions: true,
  enableSubscription: true,
  onError: (error) => console.error('Realtime error:', error),
});
```

#### Dependencies
- `supabase` client
- `@tanstack/react-query`
- React hooks

---

## 🔗 Service Dependencies

### Dependency Graph
```
Supabase Client
├── @supabase/supabase-js
├── AsyncStorage (isolated storage)
└── URL polyfills

ProductionBackendService
├── supabase client
├── backendConstants
└── errorHandler

SupabaseAudioLibraryManager
├── supabase client
├── AsyncStorage
└── react-native-fs

useRealtimeSync
├── supabase client
└── React Query
```

### External Dependencies

#### Supabase
- **Database:** PostgreSQL with RLS
- **Auth:** User authentication
- **Storage:** Audio file storage
- **Realtime:** Live updates
- **Functions:** Serverless functions

#### Native Modules
- **AsyncStorage:** `@react-native-async-storage/async-storage`
- **File System:** `react-native-fs`
- **URL Polyfill:** `react-native-url-polyfill`
- **Random Values:** `react-native-get-random-values`

---

## 🔄 Service Interactions

### Database Operation Flow
```
User Action
    │
    └─> ProductionBackendService.method()
        ├─> Check network (if needed)
        ├─> Execute Supabase query
        ├─> Handle response
        └─> Return data/error
```

### Real-Time Sync Flow
```
Database Change
    │
    └─> Supabase Realtime
        └─> WebSocket Event
            └─> useRealtimeSync Hook
                └─> React Query Invalidation
                    └─> Component Re-render
```

### Storage Operation Flow
```
File Request
    │
    └─> SupabaseAudioLibraryManager
        ├─> Check local cache
        ├─> If not cached:
        │   └─> Download from Supabase Storage
        │       └─> Save to local storage
        └─> Return file path
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Data validation
- Type checking
- Subscription setup/teardown

### Integration Tests
- Supabase API calls
- Real-time subscriptions
- Storage operations
- RLS policy enforcement
- Token refresh

### Mocking
- Supabase client
- AsyncStorage
- File system
- Network requests

---

## 📊 Service Metrics

### Performance
- **Database Queries:** < 3 seconds
- **Storage Operations:** < 5 seconds
- **Real-Time Updates:** < 1 second latency
- **Download Speed:** Platform-dependent

### Reliability
- **Database Connection:** > 99% success rate
- **Real-Time Subscriptions:** > 99% uptime
- **Storage Operations:** > 99% success rate
- **Error Recovery:** Automatic retry

---

## 🔐 Security Considerations

### Data Privacy
- RLS policies on all user tables
- User data isolated by user_id
- Secure token storage
- No sensitive data in logs

### Data Integrity
- Input validation before storage
- Type checking for all operations
- JSONB structure validation
- Foreign key constraints

### Network Security
- All requests use HTTPS
- Token transmission encrypted
- No credentials in logs
- Secure storage adapter

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
