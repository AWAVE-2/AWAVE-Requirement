# Database System - Components Inventory

## 📱 Services

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Main database API service layer

**Methods:**
- Authentication: `signUp`, `signIn`, `signOut`, `getCurrentUser`, `getSession`, `updateEmail`, `updatePassword`
- Profile: `getUserProfile`, `createUserProfile`, `updateUserProfile`
- Sessions: `startSession`, `endSession`, `getUserSessions`
- Favorites: `getUserFavorites`, `addFavorite`, `removeFavorite`, `updateFavoriteUsage`
- Sound Metadata: `getSoundMetadata`, `searchSounds`, `getAllSoundMetadata`
- Subscriptions: `getUserSubscription`, `createSubscription`, `checkTrialDaysRemaining`
- Custom Sessions: `getCustomSoundSessions`, `createCustomSoundSession`, `updateCustomSoundSession`, `deleteCustomSoundSession`
- Notifications: `getNotificationPreferences`, `updateNotificationPreferences`
- Analytics: `logSearchAnalytics`
- Audio Storage: `getSignedAudioUrl`, `getPublicAudioUrl`
- Business Logic: `checkRegistrationStatus`, `checkUserNeedsRegistration`, `getActiveSOSConfig`
- Real-time: `subscribeToProfileChanges`, `subscribeToSubscriptionChanges`
- Testing: `healthCheck`, `testPublicAccess`, `testAuthenticatedAccess`

**Dependencies:**
- `supabase` client
- `backendConstants` (TABLES, RPC_FUNCTIONS, ERROR_CODES)
- `errorHandler` utilities

**Features:**
- Type-safe database operations
- Error handling with safeApiCall wrapper
- Automatic error logging
- RLS policy enforcement
- Real-time subscriptions

---

### AWAVEStorage
**File:** `src/services/AWAVEStorage.ts`  
**Type:** Static Service Class  
**Purpose:** Local storage abstraction layer

**Storage Keys:**
- `awaveOnboardingCompleted` - Onboarding completion status
- `awaveOnboardingProfile` - Onboarding profile data
- `awaveLastPlayedSound` - Last played sound
- `awaveMixerTracks` - Mixer tracks configuration
- `awaveFavorites` - Local favorites cache
- `awavePrivacyPreferences` - Privacy preferences
- `awaveSelectedCategory` - Selected category
- `awaveOrderedCategories` - Ordered categories
- `awaveSessionData` - Session data
- `awaveAudioSettings` - Audio settings

**Methods:**
- Onboarding: `setOnboardingCompleted`, `getOnboardingCompleted`, `setOnboardingProfile`, `getOnboardingProfile`
- Audio: `setLastPlayedSound`, `getLastPlayedSound`, `setMixerTracks`, `getMixerTracks`
- Preferences: `setFavorites`, `getFavorites`, `setPrivacyPreferences`, `getPrivacyPreferences`
- Categories: `setSelectedCategory`, `getSelectedCategory`, `setOrderedCategories`, `getOrderedCategories`
- Session: `setSessionData`, `getSessionData`
- Audio Settings: `setAudioSettings`, `getAudioSettings`
- Batch: `setMultipleItems`, `getMultipleItems`, `clearAllData`
- Migration: `migrateFromLocalStorage`

**Dependencies:**
- `@react-native-async-storage/async-storage`

**Features:**
- AsyncStorage wrapper
- JSON serialization/deserialization
- Batch operations
- Migration utilities
- Clear all data functionality

---

### OfflineQueueService
**File:** `src/services/OfflineQueueService.ts`  
**Type:** Static Service Class  
**Purpose:** Offline operation queue management

**Configuration:**
- `QUEUE_KEY = 'offline_action_queue'`
- `MAX_RETRIES = 3`

**Queue Structure:**
```typescript
interface QueuedAction {
  id: string;
  action: 'create' | 'update' | 'delete';
  table: string;
  data: Record<string, unknown>;
  timestamp: number;
  retryCount: number;
  maxRetries: number;
}
```

**Methods:**
- `addToQueue(action, table, data)` - Add operation to queue
- `processQueue()` - Process all queued operations
- `processQueueIfOnline()` - Process if online
- `getQueueStatus()` - Get queue statistics
- `clearQueue()` - Clear entire queue
- `setupNetworkListener()` - Setup network listener
- `initialize()` - Initialize service

**Dependencies:**
- `@react-native-async-storage/async-storage`
- `@react-native-community/netinfo`
- `supabase` client

**Features:**
- Automatic queue processing when online
- Retry logic with max retries
- Network state monitoring
- Queue persistence across app restarts
- Status tracking

---

### storage utility
**File:** `src/utils/storage.ts`  
**Type:** Synchronous Storage API  
**Purpose:** localStorage-compatible wrapper

**Initialization:**
- `initStorage()` - Initialize storage (load cache from AsyncStorage)
- `isStorageInitialized()` - Check initialization status

**Core API (localStorage-compatible):**
- `storage.setItem(key, value)` - Set item (synchronous cache, async persistence)
- `storage.getItem(key)` - Get item (synchronous from cache)
- `storage.removeItem(key)` - Remove item (synchronous cache, async persistence)
- `storage.clear()` - Clear all (synchronous cache, async persistence)
- `storage.key(index)` - Get key at index
- `storage.length` - Get item count

**Helper Methods:**
- `storageHelpers.getJSON<T>(key)` - Get as JSON
- `storageHelpers.setJSON<T>(key, value)` - Set as JSON
- `storageHelpers.getBoolean(key)` - Get as boolean
- `storageHelpers.setBoolean(key, value)` - Set as boolean
- `storageHelpers.getNumber(key)` - Get as number
- `storageHelpers.setNumber(key, value)` - Set as number

**Debug Utilities:**
- `storageDebug.getCachedKeys()` - Get all cached keys
- `storageDebug.getPendingWrites()` - Get pending write count
- `storageDebug.getCacheSnapshot()` - Get cache snapshot
- `storageDebug.waitForWrites(timeoutMs)` - Wait for pending writes

**Dependencies:**
- `@react-native-async-storage/async-storage`

**Features:**
- Synchronous API (localStorage-compatible)
- In-memory cache for instant reads
- Background writes to AsyncStorage
- Type-safe helpers
- Debug utilities

---

## 🔗 Component Relationships

### Database Service Layer
```
ProductionBackendService
├── supabase client
│   ├── Auth API
│   ├── Database API
│   ├── Storage API
│   └── Realtime API
├── backendConstants
│   ├── TABLES
│   ├── RPC_FUNCTIONS
│   └── ERROR_CODES
└── errorHandler
    └── safeApiCall
```

### Local Storage Layer
```
AWAVEStorage
└── AsyncStorage
    └── Platform Storage (NSUserDefaults / SharedPreferences)

storage utility
├── In-Memory Cache
└── AsyncStorage (background writes)
```

### Offline Queue Layer
```
OfflineQueueService
├── AsyncStorage (queue persistence)
├── NetInfo (network monitoring)
└── supabase client (operation execution)
```

---

## 🎨 Storage Architecture

### Storage Initialization Flow
```
App Startup
    │
    └─> initStorage()
        ├─> AsyncStorage.getAllKeys()
        ├─> AsyncStorage.multiGet(keys)
        └─> Load into memory cache
            └─> Mark initialized
```

### Read Flow
```
Component Request
    │
    └─> storage.getItem(key)
        └─> Return from cache (synchronous)
```

### Write Flow
```
Component Request
    │
    └─> storage.setItem(key, value)
        ├─> Update cache (synchronous)
        └─> AsyncStorage.setItem() (background)
```

### Offline Queue Flow
```
User Action (Offline)
    │
    └─> OfflineQueueService.addToQueue()
        ├─> Create QueuedAction
        ├─> Store in AsyncStorage
        └─> Attempt processQueueIfOnline()
            ├─> Online → Process immediately
            └─> Offline → Queue for later

Network Restore
    │
    └─> NetInfo listener triggers
        └─> OfflineQueueService.processQueue()
            ├─> Get queue from AsyncStorage
            ├─> Process each action
            ├─> Retry on failure (max 3)
            └─> Update queue
```

---

## 🔄 State Management

### Database State
- Managed by Supabase client
- Automatic session refresh
- Real-time subscriptions
- Connection state tracking

### Local Storage State
- In-memory cache (synchronous reads)
- AsyncStorage persistence (background writes)
- Cache invalidation on app restart
- Initialization on app startup

### Offline Queue State
- Stored in AsyncStorage
- Processed when online
- Retry logic with exponential backoff
- Status tracking

---

## 🧪 Testing Considerations

### Service Tests
- Mock Supabase client
- Mock AsyncStorage
- Mock NetInfo
- Test error handling
- Test retry logic

### Integration Tests
- Real Supabase connection
- Real AsyncStorage operations
- Network state changes
- Queue processing

### E2E Tests
- Complete data flows
- Offline/online transitions
- Error scenarios
- Performance testing

---

## 📊 Component Metrics

### Complexity
- **ProductionBackendService:** High (many methods, complex logic)
- **AWAVEStorage:** Medium (simple wrapper, many keys)
- **OfflineQueueService:** Medium (queue management, network monitoring)
- **storage utility:** Low (simple wrapper, cache management)

### Reusability
- **ProductionBackendService:** High (used throughout app)
- **AWAVEStorage:** High (used for local preferences)
- **OfflineQueueService:** Medium (used for offline operations)
- **storage utility:** High (localStorage-compatible API)

### Dependencies
- All services depend on AsyncStorage
- ProductionBackendService depends on Supabase
- OfflineQueueService depends on NetInfo
- All services use TypeScript for type safety

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
