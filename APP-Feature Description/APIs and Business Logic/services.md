# APIs and Business Logic - Services Documentation

## 🔧 Service Layer Overview

The APIs and Business Logic system uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, data processing, business logic, and state management.

---

## 📦 Core Services

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Unified API service layer - single source of truth for all backend operations

#### Authentication Methods

**`signUp(email, password, firstName?, lastName?): Promise<AuthResponse>`**
- Creates new user account in Supabase Auth
- Creates user profile in database
- Sends verification email
- Returns auth response with user data

**`signIn(email, password): Promise<AuthResponse>`**
- Authenticates user with credentials
- Creates session
- Returns auth response with session

**`signOut(): Promise<void>`**
- Signs out current user
- Clears session
- Removes tokens

**`getCurrentUser(): Promise<User | null>`**
- Gets current authenticated user
- Returns user data or null

**`getSession(): Promise<Session | null>`**
- Gets current session
- Returns session or null

**`updateEmail(email): Promise<void>`**
- Updates user email address
- Requires re-authentication

**`updatePassword(password): Promise<void>`**
- Updates user password
- Requires current password

**`resendVerificationEmail(email): Promise<void>`**
- Resends email verification
- Throws error on failure

**`setAuthSession(accessToken, refreshToken): Promise<void>`**
- Sets session with provided tokens
- Used for deep link authentication

#### User Profile Methods

**`getUserProfile(userId): Promise<UserProfile | null>`**
- Gets user profile by ID
- Returns profile or null
- Handles NOT_FOUND error gracefully

**`createUserProfile(userId, profileData): Promise<UserProfile>`**
- Creates new user profile
- Sets initial profile data
- Returns created profile

**`updateUserProfile(userId, updates): Promise<UserProfile>`**
- Updates user profile
- Merges updates with existing data
- Updates `updated_at` timestamp
- Returns updated profile

#### Session Tracking Methods

**`startSession(userId, sessionType, soundsConfig?): Promise<UserSession>`**
- Creates new session record
- Stores session type, sound IDs, category ID
- Captures device information
- Sets initial progress to 0%
- Returns session data with ID

**`endSession(sessionId, userId, durationMinutes): Promise<UserSession>`**
- Completes a session
- Sets session end timestamp
- Calculates duration in minutes
- Marks session as completed
- Returns updated session

**`getUserSessions(userId): Promise<UserSession[]>`**
- Gets all user sessions
- Ordered by created_at descending
- Returns array of sessions

#### Sound Metadata Methods

**`getSoundMetadata(): Promise<SoundMetadata[]>`**
- Gets all sound metadata
- Public access (no auth required)
- Ordered by category_id
- Returns array of sounds

**`searchSounds(keyword): Promise<SoundMetadata[]>`**
- Searches sounds by keyword
- Searches in title, keywords, tags
- Ordered by search_weight descending
- Returns matching sounds

**`getAllSoundMetadata(): Promise<SoundMetadata[]>`**
- Gets all sound metadata (alternative method)
- Returns complete sound catalog

#### Subscription Methods

**`getUserSubscription(userId): Promise<Subscription | null>`**
- Gets user subscription
- Returns subscription or null
- Handles NOT_FOUND error

**`createSubscription(userId, planType): Promise<Subscription>`**
- Creates trial subscription
- Sets 7-day trial period
- Sets subscription status to 'trialing'
- Returns subscription data

**`checkTrialDaysRemaining(userId): Promise<number>`**
- Calculates remaining trial days
- Uses RPC function
- Returns number of days

#### Favorites Methods

**`getUserFavorites(userId): Promise<UserFavorite[]>`**
- Gets all user favorites
- Ordered by last_used descending
- Returns array of favorites

**`addFavorite(userId, favoriteData): Promise<UserFavorite>`**
- Adds new favorite
- Sets initial use_count to 0
- Sets date_added timestamp
- Returns created favorite

**`removeFavorite(favoriteId, userId): Promise<void>`**
- Removes favorite by ID
- Validates user ownership
- Deletes favorite record

**`updateFavoriteUsage(favoriteId, userId, useCount): Promise<UserFavorite>`**
- Updates favorite usage tracking
- Increments use_count
- Updates last_used timestamp
- Returns updated favorite

#### Custom Sound Sessions Methods

**`getCustomSoundSessions(userId): Promise<CustomSoundSession[]>`**
- Gets all custom sound sessions
- Ordered by created_at descending
- Returns array of sessions

**`createCustomSoundSession(userId, sessionData): Promise<CustomSoundSession>`**
- Creates new custom sound session
- Sets tracks_config and swiper_positions
- Returns created session

**`updateCustomSoundSession(sessionId, userId, updates): Promise<CustomSoundSession>`**
- Updates custom sound session
- Updates last_used timestamp
- Returns updated session

**`deleteCustomSoundSession(sessionId, userId): Promise<void>`**
- Deletes custom sound session
- Validates user ownership

**`loadCustomSoundSessions(userId): Promise<CustomSoundSession[]>`**
- Loads custom sound sessions (alternative method)
- Ordered by last_used and updated_at

**`saveCustomSoundSession(session): Promise<CustomSoundSession>`**
- Saves custom sound session (upsert)
- Returns saved session

**`deleteCustomSoundSessions(userId): Promise<void>`**
- Deletes all user's custom sound sessions

#### Notification Methods

**`getNotificationPreferences(userId): Promise<NotificationPreferences | null>`**
- Gets notification preferences
- Returns preferences or null

**`updateNotificationPreferences(userId, preferences): Promise<NotificationPreferences>`**
- Updates notification preferences
- Upserts if not exists
- Returns updated preferences

#### Audio Storage Methods

**`getSignedAudioUrl(category, soundId, ttlSeconds): Promise<{url, expiresAt}>`**
- Gets signed URL for private audio file
- Calls Edge Function
- TTL max 1 hour
- Returns URL and expiration

**`getPublicAudioUrl(category, soundId): string`**
- Gets public URL for audio file
- Direct storage URL
- No authentication required

#### SOS & Search Methods

**`getActiveSOSConfig(): Promise<SosConfig | null>`**
- Gets active SOS configuration
- Explicit column selection
- Filters by active flag
- Returns most recent if no active
- Caches result

**`logSearchAnalytics(userId, query, resultsCount, sosTriggered): Promise<void>`**
- Logs search query to analytics
- Tracks SOS triggers
- Non-blocking operation

#### Business Logic Methods

**`checkRegistrationStatus(userId): Promise<boolean>`**
- Checks if user needs registration
- Uses RPC function
- Returns boolean

**`checkUserNeedsRegistration(userId): Promise<boolean>`**
- Alternative method for registration check
- Uses RPC function

**`healthCheck(): Promise<{status, data?}>`**
- Health check endpoint
- Tests Supabase connection
- Returns health status

**`deleteUserAccount(userId): Promise<void>`**
- Deletes all user data
- Deletes custom sessions, sessions, favorites, preferences, profile
- Note: Auth user deletion requires admin privileges

#### Real-time Subscriptions

**`subscribeToProfileChanges(userId, callback): () => void`**
- Subscribes to profile changes
- Returns cleanup function
- Calls callback on changes

**`subscribeToSubscriptionChanges(userId, callback): () => void`**
- Subscribes to subscription changes
- Returns cleanup function
- Calls callback on changes

#### Testing Utilities

**`testPublicAccess(): Promise<TestResult>`**
- Tests public data access
- Tests sound metadata access
- Returns test results

**`testAuthenticatedAccess(userId): Promise<TestResult>`**
- Tests authenticated data access
- Tests profile and subscription access
- Returns test results

#### Dependencies
- `supabase` client
- `safeApiCall` utility
- `backendConstants`
- `productionConfig`

---

### SubscriptionService
**File:** `src/services/SubscriptionService.ts`  
**Type:** Service Object  
**Purpose:** Subscription management operations

#### Methods

**`getUserSubscription(userId): Promise<SubscriptionDetails | null>`**
- Gets current subscription details
- Transforms database row to SubscriptionDetails
- Returns subscription or null

**`getPaymentHistory(userId, limit): Promise<PaymentHistory[]>`**
- Gets payment history
- Ordered by created_at descending
- Returns array of payments

**`changePlan(userId, newPlan): Promise<SubscriptionUpdateResponse>`**
- Changes subscription plan
- Calls RPC function `change_subscription_plan`
- Returns update response

**`cancelSubscription(userId, request): Promise<SubscriptionUpdateResponse>`**
- Cancels subscription
- Calls RPC function `cancel_subscription`
- Supports immediate or end-of-period cancellation
- Returns update response

**`reactivateSubscription(userId): Promise<SubscriptionUpdateResponse>`**
- Reactivates cancelled subscription
- Calls RPC function `reactivate_subscription`
- Returns update response

**`calculateProration(userId, newPlan): Promise<PlanChangeRequest>`**
- Calculates proration for plan change
- Basic calculation (should be done on backend)
- Returns proration details

#### Dependencies
- `supabase` client
- `executeWithConnectivity` utility
- `handleSupabaseError` utility

---

### SearchService
**File:** `src/services/SearchService.ts`  
**Type:** Static Class  
**Purpose:** Search functionality and SOS detection

#### Configuration
- SOS config cache duration: 1 hour
- Search result limit: 50
- Suggestions limit: 5

#### Methods

**`loadSOSConfig(): Promise<SOSConfig | null>`**
- Loads SOS configuration from database
- Caches result for 1 hour
- Transforms database format to service format
- Returns config or null

**`checkForSOSTrigger(query): Promise<SOSConfig | null>`**
- Checks if search query contains SOS trigger keywords
- Loads config if not cached
- Returns config if triggered, null otherwise

**`searchSounds(query, filters?): Promise<SoundMetadata[]>`**
- Searches sounds with filters
- Supports category, brainwave type, duration, public/private filters
- Returns matching sounds

**`getSearchSuggestions(query): Promise<SearchSuggestion[]>`**
- Gets autocomplete suggestions
- Minimum 2 characters
- Returns top 5 suggestions

**`searchByCategory(categoryId): Promise<SoundMetadata[]>`**
- Searches sounds by category
- Returns all sounds in category

**`getPopularSearches(limit): Promise<string[]>`**
- Gets popular search terms
- Ordered by results_count
- Returns array of search terms

**`logSearch(userId, query, resultsCount, sosTriggered): Promise<void>`**
- Logs search query to analytics
- Includes SOS trigger flag
- Non-blocking operation

**`trackSearch(userId, query, resultsCount): Promise<void>`**
- Tracks search (deprecated)
- Delegates to logSearch

#### Dependencies
- `supabase` client

---

### CategoryService
**File:** `src/services/CategoryService.ts`  
**Type:** Static Service Class  
**Purpose:** Category and sound data fetching

#### Primary Categories
- `schlafen` - Sleep category
- `stress` - Stress category
- `leichtigkeit` - Lightness category

#### Methods

**`fetchPrimaryCategories(): Promise<Category[]>`**
- Fetches all three primary categories
- Fetches category metadata from `audio_categories` table
- Fetches sound metadata from `sound_metadata` table
- Merges backend data with fallback data
- Returns ordered categories array
- Handles errors gracefully with fallback mechanism

#### Fallback Mechanism
- Uses `majorCategories` from `exactDataStructures.ts` if backend unavailable
- Provides default category structure
- Ensures app functionality without backend

#### Dependencies
- `supabase` client
- `exactDataStructures` (fallback data)

---

### SessionTrackingService
**File:** `src/services/SessionTrackingService.ts`  
**Type:** Static Class  
**Purpose:** Session tracking and analytics

#### Methods

**`startSession(config): Promise<UserSession | null>`**
- Creates new session record
- Stores session type, sound IDs, category ID
- Captures device information
- Sets initial progress to 0%
- Returns session data with ID

**`updateProgress(sessionId, progress): Promise<void>`**
- Updates session progress
- Calculates progress percentage
- Caps progress at 100%
- Silent error handling

**`completeSession(sessionId, durationSeconds): Promise<void>`**
- Completes a session
- Sets session end timestamp
- Calculates duration in minutes
- Marks session as completed
- Triggers daily analytics update

**`cancelSession(sessionId, reason?): Promise<void>`**
- Cancels/abandons a session
- Sets session end timestamp
- Marks as not completed
- Stores cancellation reason

**`getSessionStats(userId): Promise<SessionStats>`**
- Gets session statistics
- Calculates total sessions, completed sessions
- Calculates total minutes, average session length
- Calculates current streak
- Returns statistics object

**`getMostPlayedSounds(userId, limit): Promise<MostPlayedSound[]>`**
- Gets most played sounds
- Extracts sound IDs from sessions
- Counts plays per sound
- Fetches sound metadata
- Returns top N sounds with play counts

**`getWeeklyActivity(userId): Promise<ActivityData[]>`**
- Gets weekly activity data
- Groups sessions by day
- Calculates daily statistics
- Returns array of daily activity

**`calculateStreak(sessions): number`**
- Calculates current streak
- Finds consecutive days with completed sessions
- Returns streak count

#### Dependencies
- `supabase` client
- `Platform` API

---

### OfflineQueueService
**File:** `src/services/OfflineQueueService.ts`  
**Type:** Static Class  
**Purpose:** Offline operation queue management

#### Configuration
- Queue key: `offline_action_queue`
- Max retries: 3

#### Methods

**`addToQueue(action, table, data): Promise<void>`**
- Adds operation to offline queue
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

**`getQueueStatus(): Promise<QueueStatus>`**
- Returns queue statistics
- Count, oldest timestamp, action types
- Used for debugging and status display

**`initialize(): Promise<() => void>`**
- Initializes service
- Processes pending queue
- Sets up network listener
- Returns cleanup function

#### Storage
- `offline_action_queue` - Queued operations (AsyncStorage)

#### Error Handling
- Network errors: Queue remains, retry on connection
- Operation errors: Increment retry, retry up to max
- Max retries exceeded: Discard action, log error

#### Dependencies
- `@react-native-async-storage/async-storage`
- `@react-native-community/netinfo`
- `supabase` client

---

## 🔗 Service Dependencies

### Dependency Graph
```
ProductionBackendService
├── supabase client
├── safeApiCall utility
├── backendConstants
└── productionConfig

SubscriptionService
├── supabase client
├── executeWithConnectivity
└── handleSupabaseError

SearchService
└── supabase client

CategoryService
├── supabase client
└── exactDataStructures (fallback)

SessionTrackingService
├── supabase client
└── Platform API

OfflineQueueService
├── AsyncStorage
├── NetInfo
└── supabase client
```

### External Dependencies

#### Supabase
- **Database API:** All data operations
- **Storage API:** Audio file access
- **Auth API:** User authentication
- **Realtime API:** Live data updates
- **Edge Functions:** Serverless functions

#### React Native
- **AsyncStorage:** Local persistence
- **NetInfo:** Network monitoring
- **Platform API:** Device information

---

## 🔄 Service Interactions

### Data Fetching Flow
```
Component
    │
    └─> Hook (useUserProfile)
        └─> ProductionBackendService.getUserProfile()
            └─> supabase client
                └─> Database Query
                    └─> Transform Data
                        └─> Return to Hook
                            └─> Update State
                                └─> Component Re-render
```

### Offline Operation Flow
```
User Action (Offline)
    │
    └─> OfflineQueueService.addToQueue()
        └─> AsyncStorage.setItem()
            │
            └─> Network Reconnects
                └─> OfflineQueueService.processQueue()
                    └─> Execute Queued Actions
                        └─> ProductionBackendService
                            └─> supabase client
                                └─> Database Operation
```

### Real-time Update Flow
```
Supabase Database Change
    │
    └─> Supabase Realtime
        └─> ProductionBackendService.subscribeToProfileChanges()
            └─> Callback Function
                └─> Hook State Update
                    └─> Component Re-render
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Data transformation
- Cache behavior
- Queue processing

### Integration Tests
- Supabase API calls
- Real-time subscriptions
- Offline queue processing
- Network error handling
- Cache expiration

### Mocking
- Supabase client
- AsyncStorage
- NetInfo
- Database responses

---

## 📊 Service Metrics

### Performance
- **API Calls:** < 3 seconds
- **Cache Lookups:** < 100ms
- **Queue Processing:** < 5 seconds
- **Real-time Updates:** < 1 second latency

### Reliability
- **API Success Rate:** > 99%
- **Queue Processing Success:** > 95%
- **Cache Hit Rate:** > 80%
- **Error Recovery Rate:** > 90%

### Error Rates
- **Network Errors:** < 1%
- **API Errors:** < 2%
- **Queue Failures:** < 5%

---

## 🔐 Security Considerations

### Data Security
- All API calls use HTTPS
- RLS policies enforced on all tables
- Input validation before API calls
- No sensitive data in logs

### Token Security
- Tokens stored in isolated AsyncStorage
- Automatic token refresh
- Secure token transmission

### Storage Security
- Signed URLs for private files
- Storage quota management
- Secure file access

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **Authentication Errors:** Invalid credentials
- **Database Errors:** Query failures
- **Storage Errors:** File access issues
- **Validation Errors:** Invalid input

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=https://api.dripin.ai
SUPABASE_ANON_KEY=...
API_BASE_URL=https://api.dripin.ai
SITE_URL=https://dripin.ai
```

### Service Initialization
```typescript
// App startup
await OfflineQueueService.initialize();
```

### Service Cleanup
```typescript
// App shutdown
const cleanup = await OfflineQueueService.initialize();
cleanup();
```

---

*For component usage, see `components.md`*  
*For business logic flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
