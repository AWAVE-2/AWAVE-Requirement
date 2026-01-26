# APIs and Business Logic - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase** - Complete backend infrastructure
  - PostgreSQL Database - Primary data store
  - Supabase Storage - Audio file storage (S3-compatible)
  - Supabase Auth - JWT-based authentication
  - Supabase Realtime - WebSocket subscriptions
  - Supabase Edge Functions - Serverless functions

#### API Client
- **@supabase/supabase-js** - Official Supabase JavaScript client
  - Type-safe database queries
  - Real-time subscriptions
  - Storage operations
  - Auth management
  - Edge function invocations

#### State Management
- **React Hooks** - Component state and side effects
- **React Context API** - Global state management
- **Custom Hooks** - Business logic encapsulation
- **AsyncStorage** - Local persistence and caching

#### Error Handling
- **Custom Error Handler** - Centralized error management
- **Network Diagnostics** - Connectivity monitoring
- **Retry Logic** - Automatic retry with backoff
- **Error Transformation** - User-friendly error messages

#### Storage
- **AsyncStorage** - Key-value storage for app data
- **React Native FS** - File system for audio downloads
- **Supabase Storage** - Cloud storage for audio files

---

## 📁 File Structure

```
src/
├── services/
│   ├── ProductionBackendService.ts    # Main API service layer
│   ├── backendConstants.ts            # Table names, RPC functions, error codes
│   ├── SubscriptionService.ts        # Subscription operations
│   ├── SearchService.ts               # Search and SOS functionality
│   ├── CategoryService.ts             # Category data fetching
│   ├── SessionTrackingService.ts      # Session analytics
│   ├── OfflineQueueService.ts         # Offline operation queue
│   ├── OAuthService.ts                # OAuth provider abstraction
│   ├── SessionManagementService.ts    # Session lifecycle
│   └── [other domain services]
├── hooks/
│   ├── useProductionAuth.ts           # Authentication hook
│   ├── useUserProfile.ts              # User profile hook
│   ├── useSessionTracking.ts          # Session tracking hook
│   ├── useIntelligentSearch.ts        # Search hook
│   ├── useFavoritesManagement.ts      # Favorites hook
│   ├── useSubscriptionManagement.ts  # Subscription hook
│   ├── useCustomSounds.ts             # Custom sounds hook
│   └── [other business logic hooks]
├── utils/
│   ├── errorHandler.ts                # Error handling utilities
│   ├── networkDiagnostics.ts          # Network monitoring
│   ├── storage.ts                     # Storage utilities
│   └── [other utility functions]
├── integrations/
│   └── supabase/
│       └── client.ts                  # Supabase client configuration
└── config/
    └── productionConfig.ts            # Production backend configuration
```

---

## 🔧 Core Services

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`  
**Type:** Static Service Class  
**Purpose:** Unified API service layer for all backend operations

#### Authentication Methods
- `signUp(email, password, firstName?, lastName?)` - User registration
- `signIn(email, password)` - User authentication
- `signOut()` - User sign out
- `getCurrentUser()` - Get current authenticated user
- `getSession()` - Get current session
- `updateEmail(email)` - Update user email
- `updatePassword(password)` - Update user password
- `resendVerificationEmail(email)` - Resend verification email
- `setAuthSession(accessToken, refreshToken)` - Set session from tokens

#### User Profile Methods
- `getUserProfile(userId)` - Get user profile
- `createUserProfile(userId, profileData)` - Create user profile
- `updateUserProfile(userId, updates)` - Update user profile

#### Session Tracking Methods
- `startSession(userId, sessionType, soundsConfig?)` - Start new session
- `endSession(sessionId, userId, durationMinutes)` - End session
- `getUserSessions(userId)` - Get all user sessions

#### Sound Metadata Methods
- `getSoundMetadata()` - Get all sound metadata
- `searchSounds(keyword)` - Search sounds by keyword
- `getAllSoundMetadata()` - Get all sounds (alternative method)

#### Subscription Methods
- `getUserSubscription(userId)` - Get user subscription
- `createSubscription(userId, planType)` - Create subscription
- `checkTrialDaysRemaining(userId)` - Calculate trial days

#### Favorites Methods
- `getUserFavorites(userId)` - Get user favorites
- `addFavorite(userId, favoriteData)` - Add favorite
- `removeFavorite(favoriteId, userId)` - Remove favorite
- `updateFavoriteUsage(favoriteId, userId, useCount)` - Update usage

#### Custom Sound Sessions Methods
- `getCustomSoundSessions(userId)` - Get custom sessions
- `createCustomSoundSession(userId, sessionData)` - Create session
- `updateCustomSoundSession(sessionId, userId, updates)` - Update session
- `deleteCustomSoundSession(sessionId, userId)` - Delete session
- `loadCustomSoundSessions(userId)` - Load sessions (alternative)
- `saveCustomSoundSession(session)` - Save session (alternative)
- `deleteCustomSoundSessions(userId)` - Delete all sessions

#### Notification Methods
- `getNotificationPreferences(userId)` - Get preferences
- `updateNotificationPreferences(userId, preferences)` - Update preferences

#### Audio Storage Methods
- `getSignedAudioUrl(category, soundId, ttlSeconds)` - Get signed URL
- `getPublicAudioUrl(category, soundId)` - Get public URL

#### SOS & Search Methods
- `getActiveSOSConfig()` - Get active SOS configuration
- `logSearchAnalytics(userId, query, resultsCount, sosTriggered)` - Log search

#### Business Logic Methods
- `checkRegistrationStatus(userId)` - Check registration status
- `checkUserNeedsRegistration(userId)` - Check if user needs registration
- `healthCheck()` - Health check endpoint
- `deleteUserAccount(userId)` - Delete user account

#### Real-time Subscriptions
- `subscribeToProfileChanges(userId, callback)` - Subscribe to profile changes
- `subscribeToSubscriptionChanges(userId, callback)` - Subscribe to subscription changes

#### Testing Utilities
- `testPublicAccess()` - Test public data access
- `testAuthenticatedAccess(userId)` - Test authenticated access

---

### backendConstants
**Location:** `src/services/backendConstants.ts`  
**Type:** Constants Module  
**Purpose:** Centralized constants for database operations

#### Table Names
```typescript
TABLES = {
  USER_PROFILES: 'user_profiles',
  USER_SESSIONS: 'user_sessions',
  SUBSCRIPTIONS: 'subscriptions',
  USER_FAVORITES: 'user_favorites',
  CUSTOM_SOUND_SESSIONS: 'custom_sound_sessions',
  SOUND_METADATA: 'sound_metadata',
  NOTIFICATION_PREFERENCES: 'notification_preferences',
  APP_USAGE_ANALYTICS: 'app_usage_analytics',
  SEARCH_ANALYTICS: 'search_analytics',
  NOTIFICATION_LOGS: 'notification_logs',
  SOS_CONFIG: 'sos_config',
}
```

#### RPC Functions
```typescript
RPC_FUNCTIONS = {
  CALCULATE_TRIAL_DAYS_REMAINING: 'calculate_trial_days_remaining',
  USER_NEEDS_REGISTRATION: 'user_needs_registration',
}
```

#### Error Codes
```typescript
ERROR_CODES = {
  NOT_FOUND: 'PGRST116',
  PERMISSION_DENIED: '42501',
  ROW_LEVEL_SECURITY: 'row_level_security',
  INVALID_GRANT: 'invalid_grant',
  DUPLICATE_KEY: '23505',
  NETWORK_ERROR: 'NETWORK_ERROR',
}
```

---

### SubscriptionService
**Location:** `src/services/SubscriptionService.ts`  
**Type:** Service Object  
**Purpose:** Subscription management operations

#### Methods
- `getUserSubscription(userId)` - Get subscription details
- `getPaymentHistory(userId, limit)` - Get payment history
- `changePlan(userId, newPlan)` - Change subscription plan
- `cancelSubscription(userId, request)` - Cancel subscription
- `reactivateSubscription(userId)` - Reactivate subscription
- `calculateProration(userId, newPlan)` - Calculate proration

---

### SearchService
**Location:** `src/services/SearchService.ts`  
**Type:** Static Class  
**Purpose:** Search functionality and SOS detection

#### Methods
- `loadSOSConfig()` - Load SOS configuration (cached)
- `checkForSOSTrigger(query)` - Check if query triggers SOS
- `searchSounds(query, filters?)` - Search sounds with filters
- `getSearchSuggestions(query)` - Get autocomplete suggestions
- `searchByCategory(categoryId)` - Search by category
- `getPopularSearches(limit)` - Get popular search terms
- `logSearch(userId, query, resultsCount, sosTriggered)` - Log search analytics
- `trackSearch(userId, query, resultsCount)` - Track search (deprecated)

#### Configuration
- SOS config cache duration: 1 hour
- Search result limit: 50
- Suggestions limit: 5

---

### CategoryService
**Location:** `src/services/CategoryService.ts`  
**Type:** Static Service Class  
**Purpose:** Category and sound data fetching

#### Methods
- `fetchPrimaryCategories()` - Fetch primary categories with sounds

#### Primary Categories
- `schlafen` - Sleep category
- `stress` - Stress category
- `leichtigkeit` - Lightness category

#### Fallback Mechanism
- Uses `majorCategories` from `exactDataStructures.ts` if backend unavailable
- Merges backend data with fallback data
- Handles missing data gracefully

---

### SessionTrackingService
**Location:** `src/services/SessionTrackingService.ts`  
**Type:** Static Class  
**Purpose:** Session tracking and analytics

#### Methods
- `startSession(config)` - Start new session
- `updateProgress(sessionId, progress)` - Update session progress
- `completeSession(sessionId, durationSeconds)` - Complete session
- `cancelSession(sessionId, reason?)` - Cancel session
- `getSessionStats(userId)` - Get session statistics
- `getMostPlayedSounds(userId, limit)` - Get most played sounds
- `getWeeklyActivity(userId)` - Get weekly activity data
- `calculateStreak(sessions)` - Calculate current streak

#### Session Types
- `meditation` - Meditation session
- `sleep` - Sleep session
- `focus` - Focus session
- `custom` - Custom session

---

### OfflineQueueService
**Location:** `src/services/OfflineQueueService.ts`  
**Type:** Static Class  
**Purpose:** Offline operation queue management

#### Methods
- `addToQueue(action, table, data)` - Add operation to queue
- `processQueue()` - Process queued operations
- `getQueueStatus()` - Get queue statistics
- `initialize()` - Initialize service

#### Configuration
- Queue key: `offline_action_queue`
- Max retries: 3
- Automatic processing on network reconnect

---

## 🪝 Business Logic Hooks

### useProductionAuth
**Location:** `src/hooks/useProductionAuth.ts`  
**Purpose:** Authentication state and operations

#### Returns
```typescript
{
  session: Session | null;
  loading: boolean;
  isAuthenticated: boolean;
  userId: string | undefined;
  userEmail: string | undefined;
  signUp: (email, password, firstName?, lastName?) => Promise<{data, error}>;
  signIn: (email, password) => Promise<{data, error}>;
  signOut: () => Promise<{error}>;
  getCurrentUser: () => Promise<User | null>;
  getUserProfile: () => Promise<Profile | null>;
  updateUserProfile: (updates) => Promise<void>;
  checkRegistrationStatus: () => Promise<boolean>;
  getUserSubscription: () => Promise<Subscription | null>;
  checkTrialDaysRemaining: () => Promise<number>;
}
```

---

### useUserProfile
**Location:** `src/hooks/useUserProfile.ts`  
**Purpose:** Comprehensive user data management

#### Returns
```typescript
{
  userProfile: UserProfile | null;
  subscription: Subscription | null;
  notificationPreferences: NotificationPreferences | null;
  loading: boolean;
  loadUserData: (userId) => Promise<void>;
  updateProfile: (updates) => Promise<void>;
  updateSubscription: (updates) => Promise<void>;
  updateNotificationPreferences: (preferences) => Promise<void>;
}
```

---

### useSessionTracking
**Location:** `src/hooks/useSessionTracking.ts`  
**Purpose:** Session lifecycle management

#### Returns
```typescript
{
  currentSession: UserSession | null;
  startSession: (config) => Promise<UserSession | null>;
  updateProgress: (progress) => Promise<void>;
  completeSession: (durationSeconds) => Promise<void>;
  cancelSession: (reason?) => Promise<void>;
  loading: boolean;
}
```

---

### useIntelligentSearch
**Location:** `src/hooks/useIntelligentSearch.ts`  
**Purpose:** Advanced search with SOS detection

#### Returns
```typescript
{
  searchResults: SearchResult[];
  isLoading: boolean;
  showSOSScreen: boolean;
  search: (query) => Promise<SearchResult[]>;
  loadSOSConfig: () => Promise<void>;
  checkForSOSTrigger: (query) => boolean;
  logSearch: (query, resultsCount, sosTriggered) => Promise<void>;
}
```

---

### useFavoritesManagement
**Location:** `src/hooks/useFavoritesManagement.ts`  
**Purpose:** Favorites CRUD operations

#### Returns
```typescript
{
  favorites: UserFavorite[];
  loading: boolean;
  addFavorite: (favoriteData) => Promise<void>;
  removeFavorite: (favoriteId) => Promise<void>;
  updateFavoriteUsage: (favoriteId) => Promise<void>;
  refreshFavorites: () => Promise<void>;
}
```

---

### useSubscriptionManagement
**Location:** `src/hooks/useSubscriptionManagement.ts`  
**Purpose:** Subscription operations

#### Returns
```typescript
{
  subscription: SubscriptionDetails | null;
  loading: boolean;
  changePlan: (newPlan) => Promise<void>;
  cancelSubscription: (request) => Promise<void>;
  reactivateSubscription: () => Promise<void>;
  getPaymentHistory: (limit?) => Promise<PaymentHistory[]>;
}
```

---

### useCustomSounds
**Location:** `src/hooks/useCustomSounds.ts`  
**Purpose:** Custom sound session management

#### Returns
```typescript
{
  sessions: CustomSoundSession[];
  loading: boolean;
  createSession: (sessionData) => Promise<void>;
  updateSession: (sessionId, updates) => Promise<void>;
  deleteSession: (sessionId) => Promise<void>;
  refreshSessions: () => Promise<void>;
}
```

---

## 🔧 Utility Functions

### errorHandler
**Location:** `src/utils/errorHandler.ts`  
**Purpose:** Centralized error handling

#### Functions
- `handleSupabaseError(error)` - Transform Supabase errors to user messages
- `reportSupabaseError(error)` - Show error alert
- `retryWithBackoff(fn, maxRetries, initialDelay)` - Retry with exponential backoff
- `checkConnectivity()` - Check network connectivity
- `executeWithConnectivity(fn)` - Execute with connectivity check
- `safeApiCall(fn)` - Safe API call wrapper

---

### networkDiagnostics
**Location:** `src/utils/networkDiagnostics.ts`  
**Purpose:** Network monitoring and diagnostics

#### Functions
- `testSupabaseConnection()` - Test Supabase connectivity
- `getNetworkStatus()` - Get current network status
- `monitorNetworkStatus(callback)` - Monitor network changes

---

## 🔐 Security Implementation

### Authentication
- JWT tokens managed by Supabase client
- Tokens stored in isolated AsyncStorage
- Automatic token refresh
- PKCE flow for OAuth

### Data Security
- Row-level security (RLS) policies
- HTTPS-only API communication
- Signed URLs for private audio files
- Input validation and sanitization

### Storage Security
- Isolated storage keys per feature
- Secure token storage
- No sensitive data in logs

---

## 🔄 State Management

### Service State
- Services are stateless (static methods)
- State managed in hooks and components
- Cache managed in services (e.g., SOS config)

### Hook State
- Local state with `useState`
- Derived state with `useMemo`
- Side effects with `useEffect`
- Cleanup in `useEffect` return

### Global State
- React Context for global state
- AsyncStorage for persistence
- Supabase session for auth state

---

## 🌐 API Integration

### Supabase Client Configuration
- URL: `https://api.dripin.ai`
- Custom storage adapter for isolation
- Auto-refresh enabled
- Real-time subscriptions enabled

### Database Operations
- Type-safe queries with TypeScript
- Explicit column selection
- RLS policy compliance
- Error handling with safeApiCall

### Storage Operations
- Public bucket access
- Signed URL generation
- File download management
- Storage quota tracking

### Real-time Subscriptions
- Profile changes subscription
- Subscription changes subscription
- Automatic cleanup on unmount
- Error handling and reconnection

---

## 📱 Platform-Specific Notes

### iOS
- Native file system access
- Background download support
- App Store receipt validation

### Android
- Google Play receipt validation
- File system permissions
- Background service support

---

## 🧪 Testing Strategy

### Unit Tests
- Service method calls
- Error handling
- Data transformation
- Cache behavior

### Integration Tests
- Supabase API calls
- Real-time subscriptions
- Offline queue processing
- Network error handling

### E2E Tests
- Complete user flows
- Error scenarios
- Offline operations
- Data synchronization

---

## 🐛 Error Handling

### Error Types
- Network errors
- Authentication errors
- Validation errors
- Database errors
- Storage errors

### Error Flow
1. Error occurs in service
2. Caught by `safeApiCall`
3. Transformed by `handleSupabaseError`
4. User-friendly message displayed
5. Error logged for debugging

---

## 📊 Performance Considerations

### Optimization
- Service-level caching (SOS config)
- Query result limits
- Lazy loading of data
- Debounced search queries
- Memoized computed values

### Monitoring
- API call success rate
- Average response time
- Cache hit rate
- Offline queue processing time
- Real-time update latency

---

*For service dependencies, see `services.md`*  
*For hooks and utilities, see `components.md`*  
*For business logic flows, see `user-flows.md`*
