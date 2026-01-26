# Account Settings - Services Documentation

## 🔧 Service Layer Overview

The Account Settings screen uses services for authentication updates, user profile management, and local preference storage.

---

## 📦 Services

### AuthContext (useAuth)
**File:** `src/contexts/AuthContext.tsx`  
**Type:** React Context  
**Purpose:** Global authentication state and methods

#### Methods Used

**`updateEmail(email: string): Promise<{data, error}>`**
- Updates user email address
- Requires re-authentication (handled by Supabase)
- Returns success/error response
- Throws error on failure

**`updatePassword(password: string): Promise<{data, error}>`**
- Updates user password
- Requires current password (handled by Supabase)
- Returns success/error response
- Throws error on failure

**`user: User | null`**
- Current authenticated user object
- Contains email, id, and other user data
- Updated automatically on email change

#### Dependencies
- Supabase Auth API
- ProductionBackendService

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Supabase integration layer

#### Methods Used

**`updateUserProfile(userId: string, updates: object): Promise<Profile>`**
- Updates user profile metadata
- Used for HealthKit preferences
- Merges updates with existing data
- Returns updated profile

#### Dependencies
- Supabase client
- Supabase Database API

---

### useDevSettings Hook
**File:** `src/hooks/useDevSettings.ts`  
**Type:** Custom Hook  
**Purpose:** Developer settings management

#### Methods

**`isPaywallBypassEnabled: boolean`**
- Current paywall bypass state
- Stored in AsyncStorage
- Only available in __DEV__ mode

**`togglePaywallBypass(): void`**
- Toggles paywall bypass state
- Updates AsyncStorage
- Triggers app-wide state update

#### Storage Keys
- `dev_paywall_bypass` - Paywall bypass flag

#### Dependencies
- AsyncStorage

---

### useToast Hook
**File:** `src/components/ui/Toast.tsx`  
**Type:** Custom Hook  
**Purpose:** Toast notification management

#### Methods

**`success(message: string): void`**
- Shows success toast notification
- Auto-dismisses after timeout
- Green color variant

**`error(message: string): void`**
- Shows error toast notification
- Auto-dismisses after timeout
- Red color variant

**`info(message: string): void`**
- Shows info toast notification
- Auto-dismisses after timeout
- Blue color variant

**`toasts: Toast[]`**
- Array of active toast notifications

**`removeToast(id: string): void`**
- Removes toast by ID
- Called automatically on dismiss

#### Dependencies
- React state management
- ToastContainer component

---

## 🔗 Service Dependencies

### Dependency Graph
```
AccountSettingsScreen
├── useAuth (AuthContext)
│   └── ProductionBackendService
│       └── Supabase Auth API
├── useDevSettings
│   └── AsyncStorage
└── useToast
    └── ToastContainer
```

### External Dependencies

#### Supabase
- **Auth API:** Email and password updates
- **Database API:** User profile updates

#### Storage
- **AsyncStorage:** Developer settings persistence

---

## 🔄 Service Interactions

### Email Update Flow
```
User Action
    │
    └─> AccountSettingsScreen.handleEmailUpdate()
        └─> Show ConfirmDialog
            └─> User Confirms
                └─> useAuth.updateEmail(newEmail)
                    └─> ProductionBackendService
                        └─> Supabase Auth API
                            ├─> Success → Toast.success()
                            └─> Error → Toast.error()
```

### Password Update Flow
```
User Action
    │
    └─> AccountSettingsScreen.handlePasswordUpdate()
        └─> useAuth.updatePassword(newPassword)
            └─> ProductionBackendService
                └─> Supabase Auth API
                    ├─> Success → Toast.success()
                    └─> Error → Toast.error()
```

### HealthKit Toggle Flow
```
User Action
    │
    └─> AccountSettingsScreen.handleHealthKitToggle()
        └─> ProductionBackendService.updateUserProfile()
            └─> Supabase Database API
                └─> Update metadata.healthkit_enabled
```

### Paywall Bypass Toggle Flow
```
User Action (Dev Only)
    │
    └─> useDevSettings.togglePaywallBypass()
        └─> AsyncStorage.setItem('dev_paywall_bypass')
            └─> Update app-wide state
```

---

## 🧪 Service Testing

### Unit Tests
- Email validation logic
- Password validation logic
- Toast notification system
- Developer settings persistence

### Integration Tests
- Supabase Auth API calls
- Profile update API calls
- AsyncStorage operations
- Error handling

### Mocking
- Supabase client
- AsyncStorage
- AuthContext
- Toast system

---

## 📊 Service Metrics

### Performance
- **Email Update:** < 3 seconds
- **Password Update:** < 3 seconds
- **Profile Update:** < 2 seconds
- **Toast Display:** Instant

### Reliability
- **Email Update Success Rate:** > 95%
- **Password Update Success Rate:** > 95%
- **Profile Update Success Rate:** > 99%

### Error Rates
- **Network Errors:** < 1%
- **Validation Errors:** ~5% (expected)
- **Update Failures:** < 1%

---

## 🔐 Security Considerations

### Email Updates
- Requires re-authentication (Supabase handles)
- Confirmation dialog prevents accidental changes
- Secure API communication (HTTPS)

### Password Updates
- Minimum 10 characters enforced
- Secure password input (secureTextEntry)
- Password never logged or displayed

### Developer Settings
- Only available in __DEV__ mode
- Stored locally in AsyncStorage
- Not synced to backend

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- User-friendly error messages
- Toast notifications for feedback
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **Validation Errors:** Invalid input format
- **Authentication Errors:** Re-authentication required
- **Update Errors:** Backend update failures

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// AuthContext initialized at app startup
// useDevSettings initialized on screen mount
// useToast initialized per screen
```

---

## 🔄 Service Updates

### Future Enhancements
- Two-factor authentication
- Password strength indicator
- Email verification after update
- Account activity log
- Session management

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
