# Start Screens System - Services Documentation

## 🔧 Service Layer Overview

The Start Screens system uses a service-oriented architecture with clear separation of concerns. Services handle storage operations, backend synchronization, and state management.

---

## 📦 Services

### onboardingStorage
**File:** `src/hooks/useOnboardingStorage.ts`  
**Type:** Static Service Object  
**Purpose:** Local storage operations for onboarding state

#### Storage Keys
- `awaveOnboardingCompleted` - Completion flag ('true' or null)
- `awaveOnboardingProfile` - Profile JSON string
- `awaveSelectedCategory` - Category preference ('schlafen' | 'stress' | 'leichtigkeit')

#### Methods

**`loadOnboardingState(): Promise<{completed: boolean, profile: string | null}>`**
- Loads onboarding completion status and profile
- Returns both values asynchronously
- Handles missing data gracefully
- Used by IndexScreen for routing decisions

**`saveOnboardingCompleted(): Promise<void>`**
- Saves completion flag as 'true'
- Called when onboarding is finished
- Used to mark onboarding as complete

**`saveOnboardingProfile(profile: string): Promise<void>`**
- Saves profile JSON string
- Stores user preferences and metadata
- Used to persist onboarding data

**`setSelectedCategory(category: string): Promise<void>`**
- Saves selected category preference
- Called immediately on category selection
- Used for quick preference storage

**`getSelectedCategory(): Promise<string | null>`**
- Retrieves selected category
- Returns null if not set
- Used to restore category preference

**`clearOnboardingFlags(): Promise<void>`**
- Removes completion flag and profile
- Clears all onboarding data
- Used for reset functionality

**`resetOnboardingToQuestionnaire(): Promise<void>`**
- Removes only completion flag
- Keeps profile data
- Used for partial reset (show questionnaire only)

#### Storage Structure
```typescript
// Completion flag
awaveOnboardingCompleted: 'true' | null

// Profile JSON
awaveOnboardingProfile: string (JSON) | null
// Structure: { primaryCategory: string, createdAt: string }

// Category preference
awaveSelectedCategory: 'schlafen' | 'stress' | 'leichtigkeit' | null
```

#### Dependencies
- `storageBridge` - Storage abstraction layer
- `AsyncStorage` - Native storage implementation

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Backend synchronization for onboarding data

#### Methods Used

**`updateUserProfile(userId: string, updates: ProfileUpdates): Promise<Result>`**
- Updates user profile with onboarding data
- Includes completion status, category preference, metadata
- Returns result with data or error
- Used after onboarding completion

#### Onboarding Data Structure
```typescript
{
  onboarding_completed: boolean;
  onboarding_category_preference: string;
  onboarding_data: {
    steps_completed: string[];
    category_preference: string;
    completed_at: string;
    preferred_session_type: 'sleep' | 'meditation' | 'focus';
  };
  metadata: {
    primary_category: string;
    onboarding_completed_at: string;
  };
}
```

#### Sync Flow
1. User completes onboarding
2. Data saved locally first
3. If authenticated, sync to backend
4. Backend sync is optional (local is primary)
5. Errors don't block navigation

#### Dependencies
- Supabase client
- Authentication service
- User profile API

---

### storageBridge
**File:** `src/hooks/useAsyncStorageBridge.ts`  
**Type:** Storage Abstraction Layer  
**Purpose:** Unified storage interface

#### Methods
- `getItem(key: string): Promise<string | null>`
- `setItem(key: string, value: string): Promise<void>`
- `removeItem(key: string): Promise<void>`

#### Purpose
- Abstracts storage implementation
- Provides consistent API
- Handles platform differences
- Error handling

---

## 🔗 Service Dependencies

### Dependency Graph
```
IndexScreen
├── onboardingStorage
│   └── storageBridge
│       └── AsyncStorage
└── Navigation Service

OnboardingSlidesScreen
├── onboardingStorage
│   └── storageBridge
│       └── AsyncStorage
├── ProductionBackendService (if authenticated)
│   └── Supabase Client
└── useProductionAuth
    └── AuthContext
```

### External Dependencies

#### AsyncStorage
- **Purpose:** Local persistence
- **Platform:** React Native
- **Usage:** Storage operations
- **Keys:** `awave*` prefix

#### Supabase
- **Purpose:** Backend database
- **Usage:** User profile updates
- **Authentication:** Required for sync
- **Tables:** `user_profiles`

---

## 🔄 Service Interactions

### Onboarding Completion Flow
```
User Completes Onboarding
    │
    ├─> onboardingStorage.saveOnboardingCompleted()
    │   └─> storageBridge.setItem('awaveOnboardingCompleted', 'true')
    │
    ├─> onboardingStorage.saveOnboardingProfile(profile)
    │   └─> storageBridge.setItem('awaveOnboardingProfile', JSON)
    │
    ├─> onboardingStorage.setSelectedCategory(category)
    │   └─> storageBridge.setItem('awaveSelectedCategory', category)
    │
    └─> ProductionBackendService.updateUserProfile() (if authenticated)
        └─> Supabase API
            └─> Update user_profiles table
```

### State Loading Flow
```
App Launch (IndexScreen)
    │
    └─> onboardingStorage.loadOnboardingState()
        ├─> storageBridge.getItem('awaveOnboardingCompleted')
        └─> storageBridge.getItem('awaveOnboardingProfile')
            │
            └─> Return { completed, profile }
                │
                └─> Routing Decision
                    ├─> completed → MainTabs
                    ├─> profile exists → OnboardingSlides (slide 5)
                    └─> no profile → OnboardingSlides (full)
```

### Category Selection Flow
```
User Selects Category
    │
    └─> onboardingStorage.setSelectedCategory(category)
        └─> storageBridge.setItem('awaveSelectedCategory', category)
            │
            └─> Immediate Feedback (UI updates)
                │
                └─> On Completion
                    └─> ProductionBackendService.updateUserProfile() (if authenticated)
```

---

## 🧪 Service Testing

### Unit Tests
- Storage operations
- Data serialization/deserialization
- Error handling
- State transitions

### Integration Tests
- Storage persistence
- Backend synchronization
- Error recovery
- Concurrent operations

### Mocking
- AsyncStorage
- Supabase client
- Network requests
- Authentication state

---

## 📊 Service Metrics

### Performance
- **Storage Read:** < 50ms
- **Storage Write:** < 50ms
- **Backend Sync:** < 2 seconds
- **State Load:** < 100ms

### Reliability
- **Storage Success Rate:** > 99%
- **Backend Sync Success Rate:** > 95%
- **Error Recovery Rate:** 100%

### Error Rates
- **Storage Errors:** < 1%
- **Backend Sync Errors:** < 5%
- **Network Errors:** < 2%

---

## 🔐 Security Considerations

### Data Storage
- No sensitive data in local storage
- Category preferences are non-sensitive
- Profile data is user-generated
- Storage keys use consistent prefix

### Backend Sync
- Authenticated requests only
- Secure token transmission
- Error messages don't expose sensitive data
- Optional sync (local is primary)

### Network Security
- All requests use HTTPS
- Token transmission encrypted
- No credentials in logs
- Secure error handling

---

## 🐛 Error Handling

### Service-Level Errors
- Storage read/write failures
- Network connectivity issues
- Backend sync failures
- Data corruption

### Error Handling Strategy
- Graceful degradation
- Fallback to safe states
- Error logging
- User-friendly messages
- Retry mechanisms

### Error Types
- **Storage Errors:** Fallback to default state
- **Network Errors:** Continue with local data
- **Backend Errors:** Log and continue
- **Data Errors:** Validate and sanitize

---

## 📝 Service Configuration

### Storage Keys
```typescript
ONBOARDING_COMPLETED_KEY = 'awaveOnboardingCompleted'
ONBOARDING_PROFILE_KEY = 'awaveOnboardingProfile'
SELECTED_CATEGORY_KEY = 'awaveSelectedCategory'
```

### Service Initialization
```typescript
// No initialization required
// Services are static/stateless
// Ready to use immediately
```

### Service Cleanup
```typescript
// No cleanup required
// Services are stateless
// No resources to release
```

---

## 🔄 Service Updates

### Future Enhancements
- Multi-device sync
- Cloud backup
- Analytics integration
- A/B testing support
- Progressive onboarding

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
