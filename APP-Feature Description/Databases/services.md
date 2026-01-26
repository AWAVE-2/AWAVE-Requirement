# Database System - Services Documentation

## 🔧 Service Layer Overview

The database system uses a service-oriented architecture with clear separation of concerns. Services handle all database operations, local storage, offline synchronization, and data management.

---

## 📦 Services

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Main database API service layer

#### Configuration
- Uses Supabase client from `productionConfig.ts`
- Production URL: `https://api.dripin.ai`
- Isolated storage adapter for session management
- PKCE flow for authentication

#### Authentication Methods

**`signUp(email, password, firstName?, lastName?): Promise<AuthResponse>`**
- Creates new user account
- Creates user profile
- Returns auth response with user data
- Handles email verification

**`signIn(email, password): Promise<AuthResponse>`**
- Authenticates user with credentials
- Returns auth response with session
- Handles invalid credentials

**`signOut(): Promise<void>`**
- Signs out current user
- Clears session
- Handles errors gracefully

**`getCurrentUser(): Promise<User | null>`**
- Gets current authenticated user
- Returns user data or null
- Handles session expiry

**`getSession(): Promise<Session | null>`**
- Gets current session
- Returns session or null
- Handles session expiry

**`updateEmail(email): Promise<void>`**
- Updates user email address
- Requires re-authentication
- Handles validation errors

**`updatePassword(password): Promise<void>`**
- Updates user password
- Requires current password (handled by Supabase)
- Handles validation errors

**`setAuthSession(accessToken, refreshToken): Promise<void>`**
- Sets session with provided tokens
- Used for deep link authentication
- Handles token validation

**`resendVerificationEmail(email): Promise<void>`**
- Resends email verification
- Handles rate limiting

#### Profile Methods

**`getUserProfile(userId): Promise<UserProfile | null>`**
- Gets user profile by ID
- Returns profile or null if not found
- Handles RLS policy enforcement

**`createUserProfile(userId, profileData): Promise<UserProfile>`**
- Creates user profile
- Sets initial profile data
- Returns created profile
- Handles duplicate key errors

**`updateUserProfile(userId, updates): Promise<UserProfile>`**
- Updates user profile
- Merges updates with existing data
- Updates `updated_at` timestamp
- Returns updated profile

#### Session Methods

**`startSession(userId, sessionType, soundsConfig?): Promise<UserSession>`**
- Starts new session
- Records session start time
- Stores device info
- Returns session data

**`endSession(sessionId, userId, durationMinutes): Promise<UserSession>`**
- Ends session
- Records session end time
- Calculates duration
- Marks as completed
- Returns updated session

**`getUserSessions(userId): Promise<UserSession[]>`**
- Gets all user sessions
- Ordered by created_at (descending)
- Returns array of sessions

#### Favorite Methods

**`getUserFavorites(userId): Promise<UserFavorite[]>`**
- Gets all user favorites
- Ordered by last_used (descending)
- Returns array of favorites

**`addFavorite(userId, favoriteData): Promise<UserFavorite>`**
- Adds new favorite
- Sets date_added timestamp
- Initializes use_count to 0
- Returns created favorite

**`removeFavorite(favoriteId, userId): Promise<void>`**
- Removes favorite
- Validates user ownership (RLS)
- Handles not found errors

**`updateFavoriteUsage(favoriteId, userId, currentUseCount): Promise<UserFavorite>`**
- Updates favorite usage tracking
- Increments use_count
- Updates last_used timestamp
- Returns updated favorite

#### Sound Metadata Methods

**`getSoundMetadata(): Promise<SoundMetadata[]>`**
- Gets all sound metadata
- Ordered by category_id
- Public access (no authentication)
- Returns array of metadata

**`searchSounds(keyword): Promise<SoundMetadata[]>`**
- Searches sounds by keyword
- Searches in title, keywords, tags
- Ordered by search_weight
- Returns matching sounds

**`getAllSoundMetadata(): Promise<SoundMetadata[]>`**
- Alias for getSoundMetadata()
- Returns all sound metadata

#### Subscription Methods

**`getUserSubscription(userId): Promise<Subscription | null>`**
- Gets user subscription
- Returns subscription or null
- Handles not found errors

**`createSubscription(userId, planType): Promise<Subscription>`**
- Creates trial subscription
- Sets 7-day trial period
- Sets status to 'trialing'
- Returns created subscription

**`checkTrialDaysRemaining(userId): Promise<number>`**
- Calculates remaining trial days
- Uses RPC function
- Returns number of days

#### Custom Sound Session Methods

**`getCustomSoundSessions(userId): Promise<CustomSoundSession[]>`**
- Gets all custom sound sessions
- Ordered by created_at (descending)
- Returns array of sessions

**`createCustomSoundSession(userId, sessionData): Promise<CustomSoundSession>`**
- Creates custom sound session
- Validates tracks_config
- Sets swiper_positions defaults
- Returns created session

**`updateCustomSoundSession(sessionId, userId, updates): Promise<CustomSoundSession>`**
- Updates custom sound session
- Updates updated_at timestamp
- Updates last_used timestamp
- Returns updated session

**`deleteCustomSoundSession(sessionId, userId): Promise<void>`**
- Deletes custom sound session
- Validates user ownership (RLS)
- Handles not found errors

#### Notification Methods

**`getNotificationPreferences(userId): Promise<NotificationPreferences | null>`**
- Gets notification preferences
- Returns preferences or null
- Handles not found errors

**`updateNotificationPreferences(userId, preferences): Promise<NotificationPreferences>`**
- Updates notification preferences
- Uses upsert (create or update)
- Returns updated preferences

#### Analytics Methods

**`logSearchAnalytics(userId, query, resultsCount, sosTriggered): Promise<void>`**
- Logs search analytics
- Records search query
- Tracks results count
- Tracks SOS triggers

#### Audio Storage Methods

**`getSignedAudioUrl(category, soundId, ttlSeconds?): Promise<{url, expiresAt}>`**
- Gets signed audio URL
- Uses Supabase function
- TTL max 1 hour
- Returns URL and expiration

**`getPublicAudioUrl(category, soundId): string`**
- Gets public audio URL
- Constructs URL from endpoints
- Returns public URL string

#### Business Logic Methods

**`checkRegistrationStatus(userId): Promise<boolean>`**
- Checks if user needs registration
- Uses RPC function
- Returns boolean

**`checkUserNeedsRegistration(userId): Promise<boolean>`**
- Alias for checkRegistrationStatus()
- Returns boolean

**`getActiveSOSConfig(): Promise<SosConfig | null>`**
- Gets active SOS configuration
- Filters by active flag
- Returns most recent active config
- Handles errors gracefully

#### Real-time Methods

**`subscribeToProfileChanges(userId, callback): () => void`**
- Subscribes to profile changes
- Returns unsubscribe function
- Handles INSERT, UPDATE, DELETE events

**`subscribeToSubscriptionChanges(userId, callback): () => void`**
- Subscribes to subscription changes
- Returns unsubscribe function
- Handles INSERT, UPDATE, DELETE events

#### Testing Methods

**`healthCheck(): Promise<{status, data?, error?}>`**
- Health check for database connection
- Tests session retrieval
- Returns health status

**`testPublicAccess(): Promise<{soundsAccessible, soundsError?, sampleData?}>`**
- Tests public access to sound_metadata
- Returns access status and sample data

**`testAuthenticatedAccess(userId): Promise<{profileAccessible, subscriptionAccessible, errors?}>`**
- Tests authenticated access
- Tests profile and subscription access
- Returns access status

#### Dependencies
- `supabase` client
- `backendConstants` (TABLES, RPC_FUNCTIONS, ERROR_CODES)
- `errorHandler` utilities (safeApiCall)

#### Error Handling
- All methods wrapped in safeApiCall
- Automatic error logging
- User-friendly error messages
- RLS policy error handling

---

### AWAVEStorage
**File:** `src/services/AWAVEStorage.ts`  
**Type:** Static Service Class  
**Purpose:** Local storage abstraction layer

#### Storage Keys
- `awaveOnboardingCompleted` - Boolean
- `awaveOnboardingProfile` - JSON (OnboardingProfile)
- `awaveLastPlayedSound` - JSON (Sound)
- `awaveMixerTracks` - JSON (Track[])
- `awaveFavorites` - JSON (UserFavorite[])
- `awavePrivacyPreferences` - JSON (PrivacyPreferences)
- `awaveSelectedCategory` - String
- `awaveOrderedCategories` - JSON (string[])
- `awaveSessionData` - JSON (any)
- `awaveAudioSettings` - JSON (AudioSettings)

#### Methods

**Onboarding Methods:**
- `setOnboardingCompleted(value: boolean): Promise<void>`
- `getOnboardingCompleted(): Promise<boolean>`
- `setOnboardingProfile(profile: OnboardingProfile): Promise<void>`
- `getOnboardingProfile(): Promise<OnboardingProfile | null>`

**Audio Methods:**
- `setLastPlayedSound(sound: Sound): Promise<void>`
- `getLastPlayedSound(): Promise<Sound | null>`
- `setMixerTracks(tracks: Track[]): Promise<void>`
- `getMixerTracks(): Promise<Track[]>`

**Preferences Methods:**
- `setFavorites(favorites: UserFavorite[]): Promise<void>`
- `getFavorites(): Promise<UserFavorite[]>`
- `setPrivacyPreferences(preferences: PrivacyPreferences): Promise<void>`
- `getPrivacyPreferences(): Promise<PrivacyPreferences | null>`

**Category Methods:**
- `setSelectedCategory(categoryId: string): Promise<void>`
- `getSelectedCategory(): Promise<string | null>`
- `setOrderedCategories(categories: string[]): Promise<void>`
- `getOrderedCategories(): Promise<string[]>`

**Session Methods:**
- `setSessionData(sessionData: any): Promise<void>`
- `getSessionData(): Promise<any>`

**Audio Settings Methods:**
- `setAudioSettings(settings: AudioSettings): Promise<void>`
- `getAudioSettings(): Promise<AudioSettings>` (with defaults)

**Batch Methods:**
- `setMultipleItems(items: {[key: string]: string}): Promise<void>`
- `getMultipleItems(keys: string[]): Promise<{[key: string]: string | null}>`
- `clearAllData(): Promise<void>`

**Migration Methods:**
- `migrateFromLocalStorage(localStorageData: {[key: string]: string}): Promise<void>`

#### Dependencies
- `@react-native-async-storage/async-storage`

#### Error Handling
- Try-catch blocks for all operations
- Error logging for failures
- Returns null/empty on errors
- No exceptions thrown

---

### OfflineQueueService
**File:** `src/services/OfflineQueueService.ts`  
**Type:** Static Service Class  
**Purpose:** Offline operation queue management

#### Configuration
- `QUEUE_KEY = 'offline_action_queue'`
- `MAX_RETRIES = 3`

#### Queue Structure
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

#### Methods

**`addToQueue(action, table, data): Promise<void>`**
- Adds operation to queue
- Generates unique action ID
- Stores in AsyncStorage
- Attempts immediate processing if online

**`processQueue(): Promise<number>`**
- Processes all queued actions
- Checks network connectivity
- Executes actions in order
- Handles retries and failures
- Returns count of processed actions
- Prevents concurrent processing

**`processQueueIfOnline(): Promise<void>`**
- Checks network state
- Processes queue if online
- No-op if offline

**`getQueueStatus(): Promise<QueueStatus>`**
- Returns queue statistics
- Count, oldest timestamp, action types
- Used for debugging and status display

**`clearQueue(): Promise<void>`**
- Clears entire queue
- Removes from AsyncStorage

**`setupNetworkListener(): () => void`**
- Sets up network state listener
- Auto-processes queue when online
- Returns unsubscribe function

**`initialize(): Promise<() => void>`**
- Initializes service
- Processes pending queue
- Sets up network listener
- Returns cleanup function

#### Operation Execution

**`executeAction(action: QueuedAction): Promise<void>`**
- Executes single queued action
- Routes to appropriate handler
- Handles errors

**`executeCreate(table, data): Promise<void>`**
- Executes create operation
- Uses supabase.from(table).insert(data)

**`executeUpdate(table, data): Promise<void>`**
- Executes update operation
- Requires id field
- Uses supabase.from(table).update(data).eq('id', data.id)

**`executeDelete(table, data): Promise<void>`**
- Executes delete operation
- Requires id field
- Uses supabase.from(table).delete().eq('id', data.id)

#### Dependencies
- `@react-native-async-storage/async-storage`
- `@react-native-community/netinfo`
- `supabase` client

#### Error Handling
- Network errors: Queue remains, retry on connection
- Operation errors: Increment retry, retry up to max
- Max retries exceeded: Discard action, log error
- Concurrent processing: Prevented with flag

---

### storage utility
**File:** `src/utils/storage.ts`  
**Type:** Synchronous Storage API  
**Purpose:** localStorage-compatible wrapper

#### Initialization

**`initStorage(): Promise<void>`**
- Initializes storage on app startup
- Loads all AsyncStorage data into memory cache
- Must be called before any component renders
- Idempotent (safe to call multiple times)

**`isStorageInitialized(): boolean`**
- Checks if storage is initialized
- Returns boolean status

#### Core API (localStorage-compatible)

**`storage.setItem(key, value): void`**
- Sets item synchronously
- Updates cache immediately
- Persists to AsyncStorage in background
- Fire-and-forget persistence

**`storage.getItem(key): string | null`**
- Gets item synchronously
- Returns from cache
- No async needed

**`storage.removeItem(key): void`**
- Removes item synchronously
- Removes from cache immediately
- Persists removal to AsyncStorage in background

**`storage.clear(): void`**
- Clears all items synchronously
- Clears cache immediately
- Persists clear to AsyncStorage in background

**`storage.key(index): string | null`**
- Gets key at index
- Returns from cache keys
- Order not guaranteed

**`storage.length: number`**
- Gets number of items
- Returns cache length

#### Helper Methods

**`storageHelpers.getJSON<T>(key): T | null`**
- Gets item and parses as JSON
- Returns typed value or null
- Handles parse errors

**`storageHelpers.setJSON<T>(key, value): void`**
- Sets item as JSON
- Serializes value to JSON string

**`storageHelpers.getBoolean(key): boolean`**
- Gets item as boolean
- Returns true if value is 'true'

**`storageHelpers.setBoolean(key, value): void`**
- Sets item as boolean
- Converts boolean to string

**`storageHelpers.getNumber(key): number | null`**
- Gets item as number
- Parses float value
- Returns null if invalid

**`storageHelpers.setNumber(key, value): void`**
- Sets item as number
- Converts number to string

#### Debug Utilities

**`storageDebug.getCachedKeys(): string[]`**
- Gets all cached keys
- Returns array of keys

**`storageDebug.getPendingWrites(): number`**
- Gets number of pending writes
- Returns count

**`storageDebug.getCacheSnapshot(): Record<string, string | null>`**
- Gets cache snapshot
- Returns copy of cache

**`storageDebug.waitForWrites(timeoutMs): Promise<void>`**
- Waits for pending writes to complete
- Useful before testing or shutdown
- Timeout after specified ms

#### Dependencies
- `@react-native-async-storage/async-storage`

#### Error Handling
- Warnings in dev mode for uninitialized access
- Errors logged but don't throw
- Cache preserved even if persistence fails

---

## 🔗 Service Dependencies

### Dependency Graph
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

AWAVEStorage
└── AsyncStorage

OfflineQueueService
├── AsyncStorage
├── NetInfo
└── supabase client

storage utility
└── AsyncStorage
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
- **NetInfo:** `@react-native-community/netinfo`

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

### Offline Operation Flow
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
            └─> Update queue
```

### Local Storage Flow
```
Component Request
    │
    └─> AWAVEStorage.method() or storage.getItem()
        ├─> Read from AsyncStorage (async)
        └─> Return data
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Data validation
- Type checking

### Integration Tests
- Supabase API calls
- Local storage operations
- Offline queue processing
- Synchronization

### Mocking
- Supabase client
- AsyncStorage
- NetInfo
- Network requests

---

## 📊 Service Metrics

### Performance
- **Database Queries:** < 3 seconds
- **Local Storage Reads:** < 1ms (synchronous)
- **Queue Processing:** < 1 second per operation
- **Storage Writes:** Background (non-blocking)

### Reliability
- **Database Connection:** > 99% success rate
- **Queue Sync:** > 95% success rate
- **Storage Operations:** > 99% success rate
- **Error Recovery:** Automatic retry

---

## 🔐 Security Considerations

### Data Privacy
- RLS policies on all user tables
- User data isolated by user_id
- Secure token storage
- No sensitive data in local storage

### Data Integrity
- Input validation before storage
- Type checking for all operations
- JSONB structure validation
- Foreign key constraints

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
