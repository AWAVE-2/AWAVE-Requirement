# User Onboarding Screens - Services Documentation

## 🔧 Service Layer Overview

The User Onboarding Screens feature uses a service-oriented architecture for state persistence and backend synchronization. Services handle all storage operations, profile updates, and state management.

---

## 📦 Services

### onboardingStorage
**File:** `src/hooks/useOnboardingStorage.ts`  
**Type:** Static Service Object  
**Purpose:** Onboarding state persistence and management

#### Storage Keys
- `awaveOnboardingCompleted` - Completion flag ('true' | null)
- `awaveOnboardingProfile` - Profile JSON string
- `awaveSelectedCategory` - Category ID string ('schlafen' | 'stress' | 'leichtigkeit')

#### Methods

**`loadOnboardingState(): Promise<{completed: boolean, profile: string | null}>`**
- Loads completion flag and profile from storage
- Returns parsed state object
- Used by IndexScreen for routing decisions
- Returns `{completed: false, profile: null}` if no data exists

**Usage:**
```typescript
const { completed, profile } = await onboardingStorage.loadOnboardingState();
if (completed) {
  // Navigate to main app
}
```

**`saveOnboardingCompleted(): Promise<void>`**
- Saves completion flag as 'true' string
- Called on onboarding completion
- Persists across app restarts

**`saveOnboardingProfile(profile: string): Promise<void>`**
- Saves profile JSON string
- Profile structure:
  ```typescript
  {
    primaryCategory: 'schlafen' | 'stress' | 'leichtigkeit',
    createdAt: ISO8601 string
  }
  ```
- Called on onboarding completion

**`getSelectedCategory(): Promise<string | null>`**
- Gets saved category preference
- Returns category ID or null
- Used to retrieve user's category choice

**`setSelectedCategory(category: string): Promise<void>`**
- Saves category preference immediately
- Called when user selects a category
- Supports anonymous users (no auth required)
- Category values: 'schlafen', 'stress', 'leichtigkeit'

**`clearOnboardingFlags(): Promise<void>`**
- Removes completion flag and profile
- Used for reset functionality
- Clears both keys in parallel

**`resetOnboardingToQuestionnaire(): Promise<void>`**
- Removes only completion flag
- Keeps profile data intact
- Used when user wants to change preference
- Enables questionnaire-only mode (slide 5 only)

#### Dependencies
- `storageBridge` - AsyncStorage abstraction layer
- AsyncStorage - React Native storage API

#### Error Handling
- All methods are async and may throw
- Errors should be caught by calling code
- Storage failures don't block navigation

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Backend profile synchronization

#### Methods Used

**`updateUserProfile(userId: string, updates: ProfileUpdate): Promise<ProfileResult>`**
- Updates user profile in Supabase
- Called after onboarding completion for authenticated users
- Non-blocking: errors don't prevent navigation

**Profile Update Structure:**
```typescript
{
  onboarding_completed: true,
  onboarding_category_preference: 'schlafen' | 'stress' | 'leichtigkeit',
  onboarding_data: {
    steps_completed: ['welcome', 'klangwelten', 'wirksamkeit', 'wachstum', 'choice'],
    category_preference: string,
    completed_at: ISO8601 string,
    preferred_session_type: 'sleep' | 'meditation' | 'focus'
  },
  metadata: {
    primary_category: string,
    onboarding_completed_at: ISO8601 string
  }
}
```

**Category to Session Type Mapping:**
- `schlafen` → `sleep`
- `stress` → `meditation`
- `leichtigkeit` → `focus`

**Usage:**
```typescript
if (userId) {
  await ProductionBackendService.updateUserProfile(userId, {
    onboarding_completed: true,
    onboarding_category_preference: selectedChoice,
    onboarding_data: { /* ... */ },
    metadata: { /* ... */ }
  });
}
```

#### Error Handling
- Non-blocking: continues with local data on failure
- Logs warnings but doesn't throw errors
- Guest users skip backend sync (userId is undefined)

#### Dependencies
- Supabase client
- User authentication context

---

### useProductionAuth
**File:** `src/hooks/useProductionAuth.ts`  
**Type:** React Hook  
**Purpose:** Get current user ID for backend sync

#### Returns
```typescript
{
  userId: string | undefined;
  // ... other auth properties
}
```

#### Usage
- Check if user is authenticated
- Get userId for backend profile updates
- Guest mode: userId is undefined (skip backend sync)

**Example:**
```typescript
const { userId } = useProductionAuth();

if (userId) {
  // User is authenticated - sync to backend
} else {
  // Guest user - local storage only
}
```

#### Dependencies
- Supabase Auth
- AuthContext

---

## 🔗 Service Dependencies

### Dependency Graph
```
OnboardingSlidesScreen
├── onboardingStorage
│   └── storageBridge
│       └── AsyncStorage
├── useProductionAuth
│   └── Supabase Auth
└── ProductionBackendService
    └── Supabase Client

IndexScreen
└── onboardingStorage
    └── storageBridge
        └── AsyncStorage
```

### External Dependencies

#### AsyncStorage
- **Purpose:** Local persistence
- **Keys:** Onboarding flags, profile, category
- **Abstraction:** `storageBridge` for platform compatibility

#### Supabase
- **Auth API:** User authentication status
- **Database API:** User profile updates
- **Usage:** Profile synchronization for authenticated users

---

## 🔄 Service Interactions

### Onboarding Completion Flow
```
User Completes Onboarding
    │
    ├─> onboardingStorage.saveOnboardingCompleted()
    │   └─> AsyncStorage.setItem('awaveOnboardingCompleted', 'true')
    │
    ├─> onboardingStorage.saveOnboardingProfile(profile)
    │   └─> AsyncStorage.setItem('awaveOnboardingProfile', JSON)
    │
    ├─> onboardingStorage.setSelectedCategory(choice)
    │   └─> AsyncStorage.setItem('awaveSelectedCategory', choice)
    │
    └─> [If userId exists]
        └─> ProductionBackendService.updateUserProfile(userId, updates)
            └─> Supabase Database
                └─> Update user profile
```

### App Startup Flow
```
App Starts (IndexScreen)
    │
    └─> onboardingStorage.loadOnboardingState()
        └─> AsyncStorage.getItem() (parallel)
            ├─> Get 'awaveOnboardingCompleted'
            └─> Get 'awaveOnboardingProfile'
                │
                └─> Return {completed, profile}
                    │
                    ├─> If completed → Navigate to MainTabs
                    ├─> If profile exists → Navigate to slide 5
                    └─> Otherwise → Navigate to full onboarding
```

### Category Selection Flow
```
User Selects Category
    │
    └─> onboardingStorage.setSelectedCategory(category)
        └─> AsyncStorage.setItem('awaveSelectedCategory', category)
            │
            └─> [Immediate save - no backend sync yet]
                │
                └─> [On completion]
                    └─> Sync to backend if authenticated
```

---

## 🧪 Service Testing

### Unit Tests
- Storage method calls
- State loading and saving
- Error handling
- Category mapping logic

### Integration Tests
- Complete onboarding flow
- Backend sync functionality
- State persistence across restarts
- Guest vs authenticated user flows

### Mocking
- AsyncStorage
- Supabase client
- Auth context

---

## 📊 Service Metrics

### Performance
- **Storage Operations:** < 100ms
- **Backend Sync:** < 2 seconds (non-blocking)
- **State Loading:** < 50ms

### Reliability
- **Storage Success Rate:** > 99%
- **Backend Sync Success Rate:** > 95%
- **State Persistence:** 100% (local storage)

### Error Rates
- **Storage Errors:** < 1%
- **Backend Sync Failures:** < 5% (expected for offline)
- **State Loading Failures:** < 1%

---

## 🔐 Security Considerations

### Data Storage
- Onboarding data stored locally (AsyncStorage)
- No sensitive data in onboarding state
- Category preference is non-sensitive
- Profile data is JSON string (parsed on load)

### Backend Sync
- Only for authenticated users
- Profile updates require valid session
- Non-blocking: doesn't expose errors to user
- Guest users: no backend sync (privacy)

---

## 🐛 Error Handling

### Service-Level Errors
- Storage failures: Log and continue
- Backend sync failures: Non-blocking, log warning
- State loading failures: Default to first-time user flow

### Error Types
- **Storage Errors:** AsyncStorage failures
- **Backend Errors:** Network, authentication, validation
- **State Errors:** Invalid JSON, missing keys

### Error Recovery
- Default to safe state (first-time user)
- Retry not implemented (user can restart)
- Clear error messages for debugging

---

## 📝 Service Configuration

### Storage Keys
```typescript
const ONBOARDING_COMPLETED_KEY = 'awaveOnboardingCompleted';
const ONBOARDING_PROFILE_KEY = 'awaveOnboardingProfile';
const SELECTED_CATEGORY_KEY = 'awaveSelectedCategory';
```

### Service Initialization
- No initialization required (static methods)
- Storage bridge initialized at app startup
- Backend service uses Supabase client (global)

### Service Cleanup
- No cleanup required
- Storage persists across app restarts
- Backend sync is one-time operation

---

## 🔄 Service Updates

### Future Enhancements
- Analytics tracking for onboarding completion
- A/B testing for slide content
- Remote configuration for slide order
- Multi-language support expansion
- Onboarding skip analytics

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
