# APIs and Business Logic - User Flows

## 🔄 Primary Business Logic Flows

### 1. User Authentication Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Signs In
   └─> useProductionAuth.signIn()
       └─> ProductionBackendService.signIn()
           └─> supabase.auth.signInWithPassword()
               ├─> Error → Transform Error → Show Message
               └─> Success → Continue
                   └─> Get Session
                       └─> Load User Profile
                           └─> useUserProfile.loadUserData()
                               ├─> Load Profile
                               ├─> Load Subscription
                               └─> Load Notification Preferences
                                   └─> Update Component State
```

**Success Path:**
- Authentication succeeds
- Session created
- Profile loaded
- Component state updated

**Error Paths:**
- Invalid credentials → Show error message
- Network error → Show connectivity error
- Account not verified → Prompt verification

---

### 2. User Profile Loading Flow

```
Component Mount / User Changes
    │
    └─> useUserProfile.loadUserData(userId)
        ├─> ProductionBackendService.getUserProfile(userId)
        │   └─> supabase.from('user_profiles').select()
        │       └─> Return Profile Data
        ├─> ProductionBackendService.getUserSubscription(userId)
        │   └─> supabase.from('subscriptions').select()
        │       └─> Return Subscription Data
        └─> ProductionBackendService.getNotificationPreferences(userId)
            └─> supabase.from('notification_preferences').select()
                └─> Return Preferences or Create Defaults
                    └─> Update Hook State
                        └─> Component Re-render
```

**Success Path:**
- All data loaded successfully
- State updated
- Component displays data

**Error Paths:**
- Profile not found → Create default profile
- Subscription not found → Show no subscription
- Preferences not found → Create defaults

---

### 3. Session Tracking Flow

```
User Starts Audio Playback
    │
    └─> useSessionTracking.startSession(soundIds, categoryId)
        └─> SessionTrackingService.startSession(config)
            └─> ProductionBackendService.startSession()
                └─> supabase.from('user_sessions').insert()
                    └─> Return Session with ID
                        └─> Store in Hook Ref
                            └─> Start Progress Tracking
                                └─> Update Progress Every 30s
                                    └─> SessionTrackingService.updateProgress()
                                        └─> supabase.from('user_sessions').update()

User Completes Playback
    │
    └─> useSessionTracking.completeSession(durationSeconds)
        └─> SessionTrackingService.completeSession()
            └─> ProductionBackendService.endSession()
                └─> supabase.from('user_sessions').update()
                    └─> Mark as Completed
                        └─> Update Daily Analytics
                            └─> Clear Session Ref
```

**Success Path:**
- Session created
- Progress tracked
- Session completed
- Analytics updated

**Error Paths:**
- Session creation fails → Log error, continue playback
- Progress update fails → Silent error, continue tracking
- Completion fails → Log error, session remains incomplete

---

### 4. Search Flow with SOS Detection

```
User Enters Search Query
    │
    └─> useIntelligentSearch.search(query)
        ├─> checkForSOSTrigger(query)
        │   └─> SearchService.checkForSOSTrigger()
        │       └─> Load SOS Config (cached or fresh)
        │           └─> Check Keywords
        │               ├─> Match → Return Config
        │               └─> No Match → Return Null
        │
        ├─> If SOS Triggered
        │   └─> Set showSOSScreen = true
        │       └─> logSearch(query, 0, true)
        │           └─> ProductionBackendService.logSearchAnalytics()
        │               └─> supabase.from('search_analytics').insert()
        │
        └─> If Not SOS
            └─> ProductionBackendService.searchSounds(query)
                └─> supabase.from('sound_metadata').select()
                    └─> Filter and Score Results
                        └─> logSearch(query, resultsCount, false)
                            └─> Return Ranked Results
```

**Success Path:**
- Query processed
- SOS detected if applicable
- Search results returned
- Analytics logged

**Error Paths:**
- SOS config load fails → Continue with search
- Search fails → Return empty results
- Analytics log fails → Silent error, continue

---

### 5. Favorites Management Flow

```
User Adds Favorite
    │
    └─> useFavoritesManagement.addFavorite(favoriteData)
        ├─> ProductionBackendService.addFavorite(userId, favoriteData)
        │   └─> supabase.from('user_favorites').insert()
        │       └─> Return Created Favorite
        └─> AWAVEStorage.addFavorite(favoriteData) [Offline Backup]
            └─> AsyncStorage.setItem()
                └─> Update Hook State
                    └─> Component Re-render

User Removes Favorite
    │
    └─> useFavoritesManagement.removeFavorite(favoriteId)
        ├─> ProductionBackendService.removeFavorite(favoriteId, userId)
        │   └─> supabase.from('user_favorites').delete()
        └─> AWAVEStorage.removeFavorite(favoriteId) [Offline Backup]
            └─> AsyncStorage.removeItem()
                └─> Update Hook State
                    └─> Component Re-render
```

**Success Path:**
- Favorite added/removed
- State updated
- UI reflects change

**Error Paths:**
- Backend fails → Use local storage
- Local storage fails → Show error
- Network error → Queue for sync

---

### 6. Subscription Management Flow

```
User Changes Plan
    │
    └─> useSubscriptionManagement.changePlan(newPlan)
        └─> SubscriptionService.changePlan(userId, newPlan)
            └─> supabase.rpc('change_subscription_plan')
                └─> Update Subscription Record
                    └─> Return Updated Subscription
                        └─> Update Hook State
                            └─> Component Re-render

User Cancels Subscription
    │
    └─> useSubscriptionManagement.cancelSubscription(request)
        └─> SubscriptionService.cancelSubscription(userId, request)
            └─> supabase.rpc('cancel_subscription')
                └─> Update Subscription Status
                    └─> Return Updated Subscription
                        └─> Update Hook State
                            └─> Component Re-render
```

**Success Path:**
- Plan changed/cancelled
- Subscription updated
- State synchronized

**Error Paths:**
- RPC function fails → Show error
- Network error → Show connectivity error
- Invalid plan → Show validation error

---

### 7. Offline Operation Flow

```
User Action (Offline)
    │
    └─> OfflineQueueService.addToQueue(action, table, data)
        └─> AsyncStorage.setItem('offline_action_queue')
            └─> Check Network Status
                ├─> Online → Process Immediately
                │   └─> Execute Action
                │       └─> ProductionBackendService
                │           └─> Remove from Queue
                └─> Offline → Queue for Later
                    └─> Network Reconnects
                        └─> OfflineQueueService.processQueue()
                            └─> Process All Queued Actions
                                ├─> Success → Remove from Queue
                                └─> Failure → Retry (max 3 times)
                                    └─> Max Retries → Remove from Queue
```

**Success Path:**
- Operation queued
- Processed on reconnect
- Data synchronized

**Error Paths:**
- Queue full → Show error
- Max retries exceeded → Discard action
- Network never reconnects → Action remains queued

---

### 8. Real-time Update Flow

```
Supabase Database Change
    │
    └─> Supabase Realtime Event
        └─> ProductionBackendService.subscribeToProfileChanges()
            └─> Callback Function
                └─> Update Hook State
                    └─> Component Re-render
                        └─> User Sees Updated Data

Example: Profile Update
    │
    └─> Another Device Updates Profile
        └─> Database Change Event
            └─> Realtime Subscription Fires
                └─> useUserProfile Hook Receives Update
                    └─> Update userProfile State
                        └─> Component Re-renders
                            └─> User Sees Updated Profile
```

**Success Path:**
- Real-time update received
- State updated
- UI reflects change

**Error Paths:**
- Subscription fails → Silent error, manual refresh needed
- Network disconnects → Reconnect automatically
- Invalid data → Ignore update

---

### 9. Session Statistics Flow

```
Component Mounts / User Views Stats
    │
    └─> useSessionStats Hook
        └─> SessionTrackingService.getSessionStats(userId)
            └─> ProductionBackendService.getUserSessions(userId)
                └─> supabase.from('user_sessions').select()
                    └─> Filter Completed Sessions
                        └─> Calculate Statistics
                            ├─> Total Sessions
                            ├─> Completed Sessions
                            ├─> Total Minutes
                            ├─> Average Session Length
                            └─> Current Streak
                                └─> Return Statistics
                                    └─> Update Hook State
                                        └─> Component Displays Stats
```

**Success Path:**
- Statistics calculated
- State updated
- UI displays data

**Error Paths:**
- No sessions → Show zero stats
- Calculation error → Show default values
- Network error → Show cached data

---

### 10. Custom Sound Session Flow

```
User Creates Custom Session
    │
    └─> useCustomSounds.createSession(sessionData)
        └─> ProductionBackendService.createCustomSoundSession(userId, sessionData)
            └─> supabase.from('custom_sound_sessions').insert()
                └─> Return Created Session
                    └─> Update Hook State
                        └─> Component Re-render

User Updates Custom Session
    │
    └─> useCustomSounds.updateSession(sessionId, updates)
        └─> ProductionBackendService.updateCustomSoundSession(sessionId, userId, updates)
            └─> supabase.from('custom_sound_sessions').update()
                └─> Return Updated Session
                    └─> Update Hook State
                        └─> Component Re-render
```

**Success Path:**
- Session created/updated
- State synchronized
- UI reflects change

**Error Paths:**
- Creation fails → Show error
- Update fails → Show error
- Network error → Queue for sync

---

## 🔀 Alternative Flows

### Data Loading with Fallback

```
Component Requests Data
    │
    └─> Service Method
        └─> Supabase Query
            ├─> Success → Return Data
            └─> Error → Continue
                └─> Check for Fallback Data
                    ├─> Fallback Exists → Return Fallback
                    └─> No Fallback → Return Empty/Default
                        └─> Log Error (Non-blocking)
```

**Use Cases:**
- Category data with fallback categories
- Sound metadata with fallback sounds
- User preferences with defaults

---

### Cache-First Data Loading

```
Component Requests Data
    │
    └─> Check Cache
        ├─> Cache Valid → Return Cached Data
        └─> Cache Invalid/Missing → Continue
            └─> Load from Backend
                ├─> Success → Update Cache → Return Data
                └─> Error → Return Cached Data (if exists)
                    └─> Or Return Empty/Default
```

**Use Cases:**
- SOS configuration (1 hour cache)
- Sound metadata (30 minute cache)
- User profile (session cache)

---

### Progressive Data Loading

```
Component Mounts
    │
    └─> Load Critical Data First
        └─> Display UI with Critical Data
            └─> Load Secondary Data in Background
                └─> Update UI as Data Arrives
                    └─> Load Optional Data Last
                        └─> Complete UI Update
```

**Use Cases:**
- User profile (critical) → Subscription (secondary) → Preferences (optional)
- Category list (critical) → Sound metadata (secondary) → Images (optional)

---

## 🚨 Error Flows

### Network Error Flow

```
API Call Initiated
    │
    └─> checkConnectivity()
        ├─> Connected → Continue with API Call
        └─> Not Connected → Continue
            └─> executeWithConnectivity() Throws Error
                └─> safeApiCall() Catches Error
                    └─> handleSupabaseError() Transforms Error
                        └─> User-Friendly Message Displayed
                            └─> Optionally Queue for Retry
```

**Error Messages:**
- "No network connection available"
- "Please check your internet connection"
- Retry option available

---

### Authentication Error Flow

```
API Call Requires Auth
    │
    └─> Check Session
        ├─> Valid → Continue
        └─> Invalid/Expired → Continue
            └─> Attempt Refresh
                ├─> Refresh Success → Continue with API Call
                └─> Refresh Fails → Continue
                    └─> Clear Session
                        └─> Navigate to Auth Screen
                            └─> Show Session Expired Message
```

**User Experience:**
- Seamless if refresh succeeds
- Sign out and redirect if refresh fails
- Clear error message

---

### Data Validation Error Flow

```
User Input Received
    │
    └─> Validate Input
        ├─> Valid → Continue with API Call
        └─> Invalid → Continue
            └─> Show Validation Error
                └─> User Corrects Input
                    └─> Retry Validation
                        └─> Valid → Continue with API Call
```

**Validation Types:**
- Required fields
- Format validation (email, etc.)
- Range validation (numbers, etc.)
- Business rule validation

---

## 🔄 State Transitions

### Authentication States

```
No Session → Authenticating → Authenticated
     │              │              │
     │              └─> Error      │
     │                             │
     └─> Expired ←─────────────────┘
```

### Loading States

```
Idle → Loading → Success
  │       │         │
  │       │         └─> Error
  │       │
  │       └─> Error
  │
  └─> Error
```

### Session States

```
No Session → Starting → Active → Completing → Completed
     │          │         │          │           │
     │          │         │          │           └─> Cancelled
     │          │         │          │
     │          │         └─> Cancelled
     │          │
     │          └─> Error
     │
     └─> Error
```

---

## 📊 Flow Diagrams

### Complete Data Loading Journey

```
App Startup
    │
    ├─> Initialize Services
    │   └─> OfflineQueueService.initialize()
    │
    ├─> Check Authentication
    │   └─> useProductionAuth
    │       └─> Get Session
    │           ├─> Valid → Load User Data
    │           │   └─> useUserProfile.loadUserData()
    │           │       ├─> Load Profile
    │           │       ├─> Load Subscription
    │           │       └─> Load Preferences
    │           └─> Invalid → Show Auth Screen
    │
    └─> Load App Data
        ├─> CategoryService.fetchPrimaryCategories()
        └─> SearchService.loadSOSConfig()
            └─> Cache Configuration
```

---

### Complete User Action Journey

```
User Interaction
    │
    ├─> Validate Input (Client-side)
    │   └─> Invalid → Show Error → Stop
    │
    ├─> Check Network
    │   └─> Offline → Queue Action → Stop
    │
    ├─> Check Authentication
    │   └─> Not Authenticated → Show Auth → Stop
    │
    ├─> Execute Action
    │   └─> Service Method
    │       └─> API Call
    │           ├─> Success → Update State → Update UI
    │           └─> Error → Transform Error → Show Message
    │
    └─> Log Analytics (Non-blocking)
        └─> Track User Action
```

---

## 🎯 User Goals

### Goal: Fast Data Loading
- **Path:** Cache-first with background refresh
- **Time:** < 100ms for cached data
- **Steps:** Check cache → Return or load → Update cache

### Goal: Reliable Offline Support
- **Path:** Queue operations → Sync on reconnect
- **Time:** Automatic on network reconnect
- **Steps:** Queue → Monitor → Process → Sync

### Goal: Real-time Updates
- **Path:** Supabase Realtime subscriptions
- **Time:** < 1 second latency
- **Steps:** Subscribe → Receive → Update → Render

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
