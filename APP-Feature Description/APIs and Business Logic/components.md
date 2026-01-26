# APIs and Business Logic - Hooks and Utilities Documentation

## 🪝 Business Logic Hooks

### useProductionAuth
**File:** `src/hooks/useProductionAuth.ts`  
**Type:** Custom React Hook  
**Purpose:** Authentication state and operations - source of truth for auth

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

#### Features
- Direct Supabase integration
- Session state management
- Profile management
- Subscription integration
- Automatic session monitoring
- Loading state tracking

#### Dependencies
- `ProductionBackendService`
- `supabase` client
- `useState`, `useEffect`, `useCallback`

---

### useUserProfile
**File:** `src/hooks/useUserProfile.ts`  
**Type:** Custom React Hook  
**Purpose:** Comprehensive user data management

#### Parameters
```typescript
useUserProfile(user: User | null)
```

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

#### Features
- Comprehensive user data loading
- Profile, subscription, notification preferences
- Default preference creation
- Category preference application
- Profile update operations
- Subscription status tracking

#### Data Loading Flow
1. Load user profile from `user_profiles` table
2. Load subscription from `subscriptions` table
3. Load notification preferences from `notification_preferences` table
4. Create default preferences if not exists
5. Apply category preference to AsyncStorage

#### Dependencies
- `supabase` client
- `AsyncStorage`
- `useState`, `useEffect`, `useCallback`

---

### useSessionTracking
**File:** `src/hooks/useSessionTracking.ts`  
**Type:** Custom React Hook  
**Purpose:** Session lifecycle management for audio playback

#### Parameters
```typescript
useSessionTracking({
  userId: string | null;
  sessionType?: 'meditation' | 'sleep' | 'focus' | 'custom';
  autoStart?: boolean;
})
```

#### Returns
```typescript
{
  currentSession: UserSession | null;
  startSession: (soundIds?, categoryId?) => Promise<UserSession | null>;
  updateProgress: (currentTime, totalDuration) => Promise<void>;
  completeSession: (durationSeconds) => Promise<void>;
  cancelSession: (reason?) => Promise<void>;
  startProgressTracking: (getCurrentTime, getTotalDuration) => void;
  stopProgressTracking: () => void;
  loading: boolean;
}
```

#### Features
- Session creation and management
- Progress tracking with periodic updates (30s interval)
- Session completion
- Session cancellation
- Automatic progress updates
- Session state persistence

#### Progress Tracking
- Updates every 30 seconds
- Calculates progress percentage
- Caps progress at 100%
- Works during background playback

#### Dependencies
- `SessionTrackingService`
- `useRef`, `useCallback`, `useState`

---

### useIntelligentSearch
**File:** `src/hooks/useIntelligentSearch.ts`  
**Type:** Custom React Hook  
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

#### Features
- Advanced search functionality
- SOS keyword detection
- Search result scoring and ranking
- Search analytics logging
- SOS configuration loading
- Search suggestions

#### Search Flow
1. Check for SOS trigger keywords
2. If triggered, show SOS screen and log
3. Otherwise, perform Supabase search
4. Score and rank results client-side
5. Log search analytics
6. Return ranked results

#### Dependencies
- `ProductionBackendService`
- `SearchService`
- `useState`, `useCallback`, `useMemo`

---

### useFavoritesManagement
**File:** `src/hooks/useFavoritesManagement.ts`  
**Type:** Custom React Hook  
**Purpose:** Favorites CRUD operations

#### Parameters
```typescript
useFavoritesManagement(categoryId?: string)
```

#### Returns
```typescript
{
  favorites: FavoriteItem[];
  isLoading: boolean;
  addFavorite: (favoriteData) => Promise<void>;
  removeFavorite: (favoriteId) => Promise<void>;
  updateFavoriteUsage: (favoriteId) => Promise<void>;
  refreshFavorites: () => Promise<void>;
}
```

#### Features
- Favorites list retrieval (Supabase + local storage)
- Add favorite operation
- Remove favorite operation
- Update favorite usage tracking
- Favorites state management
- Category filtering
- Offline support with local storage

#### Data Sources
- Primary: Supabase `user_favorites` table
- Fallback: Local AsyncStorage via `AWAVEStorage`

#### Dependencies
- `ProductionBackendService`
- `AWAVEStorage`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`, `useMemo`

---

### useSubscriptionManagement
**File:** `src/hooks/useSubscriptionManagement.ts`  
**Type:** Custom React Hook  
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

#### Features
- Subscription data loading
- Plan change operations
- Subscription cancellation
- Subscription reactivation
- Payment history retrieval
- Proration calculation

#### Dependencies
- `SubscriptionService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useCustomSounds
**File:** `src/hooks/useCustomSounds.ts`  
**Type:** Custom React Hook  
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

#### Features
- Custom sound sessions loading
- Session creation
- Session updates
- Session deletion
- Session state management

#### Dependencies
- `ProductionBackendService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useSessionStats
**File:** `src/hooks/useSessionStats.ts`  
**Type:** Custom React Hook  
**Purpose:** Session statistics and analytics

#### Returns
```typescript
{
  stats: SessionStats | null;
  loading: boolean;
  refreshStats: () => Promise<void>;
}
```

#### Features
- Session statistics calculation
- Total sessions, completed sessions
- Total minutes, average session length
- Current streak calculation

#### Dependencies
- `SessionTrackingService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useMostPlayedSounds
**File:** `src/hooks/useMostPlayedSounds.ts`  
**Type:** Custom React Hook  
**Purpose:** Most played sounds retrieval

#### Returns
```typescript
{
  sounds: MostPlayedSound[];
  loading: boolean;
  refreshSounds: () => Promise<void>;
}
```

#### Features
- Most played sounds retrieval
- Play count aggregation
- Sound metadata fetching
- Top N sounds (default 5)

#### Dependencies
- `SessionTrackingService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useWeeklyActivity
**File:** `src/hooks/useWeeklyActivity.ts`  
**Type:** Custom React Hook  
**Purpose:** Weekly activity data

#### Returns
```typescript
{
  activity: ActivityData[];
  loading: boolean;
  refreshActivity: () => Promise<void>;
}
```

#### Features
- Weekly activity data retrieval
- Daily statistics grouping
- Session count per day
- Minutes per day

#### Dependencies
- `SessionTrackingService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useCategoryManagement
**File:** `src/hooks/useCategoryManagement.ts`  
**Type:** Custom React Hook  
**Purpose:** Category data management

#### Returns
```typescript
{
  categories: Category[];
  loading: boolean;
  refreshCategories: () => Promise<void>;
}
```

#### Features
- Primary categories fetching
- Sound metadata per category
- Fallback data handling
- Error recovery

#### Dependencies
- `CategoryService`
- `useState`, `useCallback`, `useEffect`

---

### useSoundSearch
**File:** `src/hooks/useSoundSearch.ts`  
**Type:** Custom React Hook  
**Purpose:** Sound search functionality

#### Returns
```typescript
{
  results: SoundMetadata[];
  loading: boolean;
  search: (query, filters?) => Promise<void>;
  clearResults: () => void;
}
```

#### Features
- Sound search with filters
- Search suggestions
- Result state management
- Loading state tracking

#### Dependencies
- `SearchService`
- `useState`, `useCallback`

---

### useSubscriptionForm
**File:** `src/hooks/useSubscriptionForm.ts`  
**Type:** Custom React Hook  
**Purpose:** Subscription form state and logic

#### Returns
```typescript
{
  selectedPlan: SubscriptionPeriod;
  setSelectedPlan: (plan) => void;
  discountActivated: boolean;
  activateDiscount: () => void;
  loading: boolean;
  submitSubscription: () => Promise<void>;
}
```

#### Features
- Plan selection state
- Discount activation
- Form submission
- Loading state management

#### Dependencies
- `subscriptionStorage`
- `useState`, `useCallback`

---

### useTrialManagement
**File:** `src/hooks/useTrialManagement.ts`  
**Type:** Custom React Hook  
**Purpose:** Trial status and management

#### Returns
```typescript
{
  trialDaysRemaining: number | null;
  isTrialActive: boolean;
  loading: boolean;
  refreshTrialStatus: () => Promise<void>;
}
```

#### Features
- Trial days calculation
- Trial status checking
- Trial expiration handling

#### Dependencies
- `ProductionBackendService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useTrialStatus
**File:** `src/hooks/useTrialStatus.ts`  
**Type:** Custom React Hook  
**Purpose:** Trial status display

#### Returns
```typescript
{
  daysRemaining: number;
  isActive: boolean;
  isExpired: boolean;
  loading: boolean;
}
```

#### Features
- Trial status calculation
- Expiration checking
- Status display helpers

#### Dependencies
- `useTrialManagement`
- `useMemo`

---

### useUserSessions
**File:** `src/hooks/useUserSessions.ts`  
**Type:** Custom React Hook  
**Purpose:** User sessions list

#### Returns
```typescript
{
  sessions: UserSession[];
  loading: boolean;
  refreshSessions: () => Promise<void>;
}
```

#### Features
- User sessions retrieval
- Session list management
- Loading state tracking

#### Dependencies
- `ProductionBackendService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

### useUserStats
**File:** `src/hooks/useUserStats.ts`  
**Type:** Custom React Hook  
**Purpose:** User statistics aggregation

#### Returns
```typescript
{
  stats: UserStats | null;
  loading: boolean;
  refreshStats: () => Promise<void>;
}
```

#### Features
- User statistics calculation
- Aggregated data from sessions
- Statistics state management

#### Dependencies
- `SessionTrackingService`
- `useAuth` context
- `useState`, `useCallback`, `useEffect`

---

## 🛠️ Utility Functions

### errorHandler
**File:** `src/utils/errorHandler.ts`  
**Type:** Utility Module  
**Purpose:** Centralized error handling

#### Functions

**`handleSupabaseError(error): string`**
- Transforms Supabase errors to user-friendly messages
- Maps error codes to messages
- Returns user-friendly error string

**`reportSupabaseError(error): void`**
- Shows error alert to user
- Uses `handleSupabaseError` for message

**`retryWithBackoff(fn, maxRetries, initialDelay): Promise<T>`**
- Retries function with exponential backoff
- Default: 3 retries, 1s initial delay
- Returns result or throws error

**`checkConnectivity(): Promise<boolean>`**
- Checks network connectivity
- Uses NetInfo
- Returns boolean

**`executeWithConnectivity(fn): Promise<T>`**
- Executes function with connectivity check
- Throws error if offline
- Retries with backoff

**`safeApiCall(fn): Promise<T>`**
- Wraps API call with error handling
- Transforms errors to user messages
- Throws transformed error

---

### networkDiagnostics
**File:** `src/utils/networkDiagnostics.ts`  
**Type:** Utility Module  
**Purpose:** Network monitoring and diagnostics

#### Functions

**`testSupabaseConnection(): Promise<ConnectionTestResult>`**
- Tests Supabase connectivity
- Returns connection status
- Tests database access

**`getNetworkStatus(): Promise<NetworkStatus>`**
- Gets current network status
- Returns connection type and status

**`monitorNetworkStatus(callback): () => void`**
- Monitors network status changes
- Calls callback on changes
- Returns cleanup function

---

### storage
**File:** `src/utils/storage.ts`  
**Type:** Utility Module  
**Purpose:** Storage utilities

#### Functions

**`getItem(key): Promise<string | null>`**
- Gets item from AsyncStorage
- Returns value or null

**`setItem(key, value): Promise<void>`**
- Sets item in AsyncStorage
- Stores string value

**`removeItem(key): Promise<void>`**
- Removes item from AsyncStorage
- Clears key

**`clear(): Promise<void>`**
- Clears all AsyncStorage
- Removes all keys

---

### subscriptionStorage
**File:** `src/utils/subscriptionStorage.ts`  
**Type:** Utility Module  
**Purpose:** Subscription storage management

#### Functions

**`saveSelectedPlan(selection): Promise<void>`**
- Saves plan selection
- Stores in AsyncStorage

**`getSelectedPlan(): Promise<PlanSelection | null>`**
- Gets saved plan selection
- Returns selection or null

**`clearSelectedPlan(): Promise<void>`**
- Clears plan selection
- Removes from AsyncStorage

**`isDiscountActivated(): Promise<boolean>`**
- Checks discount activation status
- Returns boolean

**`setDiscountActivated(activated): Promise<void>`**
- Sets discount activation status
- Stores in AsyncStorage

---

## 🔗 Hook Relationships

### Authentication Flow
```
useProductionAuth
    ├─> ProductionBackendService
    │   └─> supabase client
    └─> useUserProfile
        └─> ProductionBackendService
            └─> supabase client
```

### Session Tracking Flow
```
useSessionTracking
    └─> SessionTrackingService
        └─> supabase client
            └─> useSessionStats
                └─> SessionTrackingService
```

### Search Flow
```
useIntelligentSearch
    ├─> SearchService
    │   └─> supabase client
    └─> ProductionBackendService
        └─> supabase client
```

### Favorites Flow
```
useFavoritesManagement
    ├─> ProductionBackendService
    │   └─> supabase client
    └─> AWAVEStorage
        └─> AsyncStorage
```

---

## 🧪 Testing Considerations

### Hook Tests
- State management
- Side effects
- Error handling
- Loading states
- Data transformation

### Utility Tests
- Error transformation
- Network checks
- Storage operations
- Retry logic

---

## 📊 Hook Metrics

### Performance
- Hook initialization: < 10ms
- Data loading: < 3 seconds
- State updates: < 100ms
- Side effect execution: < 1 second

### Reliability
- Hook success rate: > 99%
- Error recovery: > 90%
- State consistency: 100%

---

*For service dependencies, see `services.md`*  
*For business logic flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
