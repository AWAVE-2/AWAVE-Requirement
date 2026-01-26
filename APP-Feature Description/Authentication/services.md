# Authentication System - Services Documentation

## 🔧 Service Layer Overview

The authentication system uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, OAuth providers, session management, and caching.

---

## 📦 Services

### OAuthService
**File:** `src/services/OAuthService.ts`  
**Type:** Singleton Class  
**Purpose:** OAuth provider abstraction and management

#### Configuration
```typescript
const GOOGLE_WEB_CLIENT_ID = process.env.GOOGLE_WEB_CLIENT_ID;
const GOOGLE_IOS_CLIENT_ID = process.env.GOOGLE_IOS_CLIENT_ID;
```

#### Methods

**`initialize(): Promise<void>`**
- Initializes Google Sign-In configuration
- Checks if credentials are configured
- Sets up OAuth providers
- Called once at app startup

**`isGoogleConfigured(): boolean`**
- Checks if Google OAuth is properly configured
- Returns false if credentials are missing

**`signInWithGoogle(): Promise<OAuthUser | null>`**
- Initiates Google Sign-In flow
- Checks Google Play Services (Android)
- Handles user cancellation gracefully
- Returns OAuth user data or null if cancelled
- Throws error on failure

**`signInWithApple(): Promise<OAuthUser | null>`**
- Initiates Apple Sign-In flow
- Checks device support
- Handles private relay emails
- Returns OAuth user data or null if cancelled
- Throws error on failure

**`handleSuccessfulOAuth(oauthUser: OAuthUser): Promise<void>`**
- Creates/updates user profile in Supabase
- Creates trial subscription if plan was selected
- Cleans up stored plan selection
- Sets onboarding completion status

**`signOut(): Promise<void>`**
- Signs out from Google (if signed in)
- Note: Apple doesn't require explicit sign out

**`isGoogleSignedIn(): Promise<boolean>`**
- Checks if user is currently signed in to Google
- Returns boolean status

**`getCurrentGoogleUser(): Promise<OAuthUser | null>`**
- Gets current Google user information
- Returns user data or null

#### Error Handling
- Cancellation: Returns null (no error)
- Play Services unavailable: Throws error
- Configuration missing: Throws error with message
- Network errors: Throws error

#### Dependencies
- `@react-native-google-signin/google-signin`
- `react-native-apple-authentication`
- `supabase` client
- `ProductionBackendService`
- `AsyncStorage`

---

### SessionManagementService
**File:** `src/services/SessionManagementService.ts`  
**Type:** Singleton Class Instance  
**Purpose:** Session lifecycle management and token refresh

#### Configuration
```typescript
REFRESH_THRESHOLD_MS = 5 * 60 * 1000; // 5 minutes
REFRESH_CHECK_INTERVAL = 60 * 1000; // 1 minute
```

#### Storage Keys
- `awave.session.info` - Session metadata
- `awave.device.id` - Device identifier

#### Methods

**`initialize(): Promise<void>`**
- Sets up auth state change listener
- Creates or retrieves device ID
- Starts automatic refresh monitoring
- Called once at app startup

**`cleanup(): void`**
- Removes auth state listener
- Stops refresh monitoring
- Clears refresh listeners
- Called on app shutdown

**`getCurrentSession(): Promise<Session | null>`**
- Gets current session from Supabase
- Checks if session is expiring soon
- Automatically refreshes if needed
- Returns session or null

**`refreshSession(): Promise<SessionRefreshResult>`**
- Manually refreshes the current session
- Prevents duplicate refresh attempts
- Returns refresh result with session or error
- Notifies all refresh listeners

**`isSessionValid(session: Session | null): boolean`**
- Checks if session is not expired
- Compares expiry time with current time
- Returns boolean

**`isSessionExpiringSoon(session: Session | null): boolean`**
- Checks if session expires within threshold (5 min)
- Returns boolean

**`handleSessionExpiry(): Promise<void>`**
- Clears session storage
- Stops refresh monitoring
- Called on session expiry

**`getSessionInfo(): Promise<SessionInfo | null>`**
- Gets stored session metadata
- Returns session info or null

**`addRefreshListener(listener: (session) => void): void`**
- Adds listener for session refresh events
- Called when session is refreshed

**`removeRefreshListener(listener: (session) => void): void`**
- Removes refresh listener

**`getActiveSessions(): Promise<SessionInfo[]>`**
- Gets all active sessions (future: multi-device)
- Currently returns only current device session

**`revokeSession(sessionId: string): Promise<boolean>`**
- Revokes a specific session (future: multi-device)
- Currently only supports current session

#### Automatic Refresh
- Monitors sessions every 60 seconds
- Refreshes sessions expiring within 5 minutes
- Runs in background
- Transparent to user

#### Dependencies
- `supabase` client
- `AsyncStorage`
- React Native `Platform` API

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Supabase integration layer

#### Authentication Methods

**`signUp(email, password, firstName?, lastName?): Promise<AuthResponse>`**
- Creates new user account
- Creates user profile
- Returns auth response with user data

**`signIn(email, password): Promise<AuthResponse>`**
- Authenticates user with credentials
- Returns auth response with session

**`signOut(): Promise<void>`**
- Signs out current user
- Clears session

**`getCurrentUser(): Promise<User | null>`**
- Gets current authenticated user
- Returns user data or null

**`updateEmail(email): Promise<void>`**
- Updates user email address
- Requires re-authentication

**`updatePassword(password): Promise<void>`**
- Updates user password
- Requires current password (handled by Supabase)

**`resendVerificationEmail(email): Promise<void>`**
- Resends email verification
- Throws error on failure

**`resetPasswordForEmail(email): Promise<void>`**
- Sends password reset email
- Throws error on failure

**`setAuthSession(accessToken, refreshToken): Promise<void>`**
- Sets session with provided tokens
- Used for deep link authentication
- Throws error on failure

#### Profile Methods

**`createUserProfile(userId, profileData): Promise<Profile>`**
- Creates user profile in database
- Sets initial profile data
- Returns created profile

**`getUserProfile(userId): Promise<Profile | null>`**
- Gets user profile by ID
- Returns profile or null

**`updateUserProfile(userId, updates): Promise<Profile>`**
- Updates user profile
- Merges updates with existing data
- Returns updated profile

#### Subscription Methods

**`createSubscription(userId, plan): Promise<Subscription>`**
- Creates trial subscription
- Sets subscription status
- Returns subscription data

**`getUserSubscription(userId): Promise<Subscription | null>`**
- Gets user subscription
- Returns subscription or null

**`checkTrialDaysRemaining(userId): Promise<number>`**
- Calculates remaining trial days
- Returns number of days

#### Dependencies
- `supabase` client
- Supabase Auth API
- Supabase Database API

---

### RegistrationCacheService
**File:** `src/services/RegistrationCacheService.ts`  
**Type:** Static Service Class  
**Purpose:** Registration flow caching

#### Storage Keys
- `registration_cache_sound_id` - Cached sound selection
- `registration_cache_category_id` - Cached category selection
- `registration_cache_nav_target` - Navigation target
- `registration_cache_timestamp` - Cache timestamp

#### Cache Expiration
- **Duration:** 30 minutes
- **Auto-cleanup:** On expiration check

#### Methods

**`cacheSoundSelection(soundId: string): Promise<void>`**
- Caches sound selection before authentication
- Sets navigation target to 'player'
- Stores timestamp
- Used when user selects sound while unauthenticated

**`cacheCategorySelection(categoryId: string): Promise<void>`**
- Caches category selection before authentication
- Sets navigation target to 'category'
- Stores timestamp
- Used when user selects category while unauthenticated

**`getCachedSelection(): Promise<CachedSelection | null>`**
- Gets cached selection if still valid
- Checks expiration (30 minutes)
- Clears cache if expired
- Returns cached data or null

**`clearCache(): Promise<void>`**
- Clears all cached registration data
- Removes all cache keys
- Called after successful authentication

**`hasCachedSelection(): Promise<boolean>`**
- Checks if valid cache exists
- Returns boolean

#### Usage Flow
1. User browses content (unauthenticated)
2. User selects sound/category
3. Service caches selection
4. User completes authentication
5. Service retrieves cache
6. App resumes to cached selection
7. Service clears cache

#### Dependencies
- `AsyncStorage`

---

### auth.ts (Basic Auth Service)
**File:** `src/services/auth.ts`  
**Type:** Service Functions  
**Purpose:** Basic Supabase auth operations

#### Functions

**`signUpUser(email, password, firstName, lastName): Promise<AuthResponse>`**
- Basic signup function
- Creates user with metadata
- Creates user profile
- Returns auth response

**`signInUser(email, password): Promise<AuthResponse>`**
- Basic signin function
- Authenticates user
- Returns auth response

**`signOutUser(): Promise<void>`**
- Basic signout function
- Signs out user

**`getCurrentSession(): Promise<Session | null>`**
- Gets current session
- Returns session or null

#### Dependencies
- `supabase` client
- `executeWithConnectivity` utility
- `handleSupabaseError` utility

---

## 🔗 Service Dependencies

### Dependency Graph
```
AuthContext
├── useProductionAuth
│   └── ProductionBackendService
│       └── supabase client
├── OAuthService
│   ├── Google Sign-In SDK
│   ├── Apple Auth SDK
│   ├── ProductionBackendService
│   └── AsyncStorage
└── SessionManagementService
    ├── supabase client
    └── AsyncStorage

RegistrationCacheService
└── AsyncStorage
```

### External Dependencies

#### Supabase
- **Auth API:** User authentication
- **Database API:** User profiles
- **Realtime API:** Session updates (future)

#### Native Modules
- **Google Sign-In:** `@react-native-google-signin/google-signin`
- **Apple Auth:** `react-native-apple-authentication`

#### Storage
- **AsyncStorage:** Local caching and persistence

---

## 🔄 Service Interactions

### Authentication Flow
```
User Action
    │
    ├─> OAuthService.signInWithGoogle()
    │   └─> Google SDK
    │       └─> OAuthService.handleSuccessfulOAuth()
    │           ├─> ProductionBackendService.updateUserProfile()
    │           └─> ProductionBackendService.createSubscription()
    │
    ├─> ProductionBackendService.signUp()
    │   └─> Supabase Auth
    │       └─> ProductionBackendService.createUserProfile()
    │
    └─> ProductionBackendService.signIn()
        └─> Supabase Auth
            └─> SessionManagementService.handleSessionUpdate()
```

### Session Management Flow
```
App Startup
    │
    └─> SessionManagementService.initialize()
        ├─> Setup auth state listener
        └─> Start refresh monitoring
            │
            └─> Every 60 seconds
                └─> Check sessions
                    └─> Refresh if expiring soon
                        └─> Notify listeners
```

### Registration Cache Flow
```
User Selection (Unauthenticated)
    │
    └─> RegistrationCacheService.cacheSoundSelection()
        └─> AsyncStorage.setItem()
            │
            └─> User Authenticates
                └─> RegistrationCacheService.getCachedSelection()
                    ├─> Check expiration
                    └─> Return cached data
                        └─> Resume to selection
                            └─> RegistrationCacheService.clearCache()
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Cache expiration logic
- Token parsing

### Integration Tests
- Supabase API calls
- OAuth provider flows
- Session refresh
- Cache operations

### Mocking
- Supabase client
- OAuth SDKs
- AsyncStorage
- Network requests

---

## 📊 Service Metrics

### Performance
- **OAuth Flow:** < 15 seconds
- **Sign Up:** < 3 seconds
- **Sign In:** < 2 seconds
- **Session Refresh:** < 1 second
- **Cache Operations:** < 100ms

### Reliability
- **Session Refresh Success Rate:** > 99%
- **OAuth Success Rate:** > 95%
- **Cache Hit Rate:** > 80%

### Error Rates
- **Network Errors:** < 1%
- **OAuth Cancellation:** ~20% (expected)
- **Session Refresh Failures:** < 1%

---

## 🔐 Security Considerations

### Token Storage
- Access tokens: Supabase session (secure)
- Refresh tokens: Supabase session (secure)
- No tokens in AsyncStorage
- Session metadata only in AsyncStorage

### OAuth Security
- Native SDKs handle token security
- No token exposure in JavaScript
- Secure token exchange

### Network Security
- All requests use HTTPS
- Token transmission encrypted
- No credentials in logs

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
- **OAuth Errors:** Provider-specific errors
- **Session Errors:** Expiry, refresh failures
- **Cache Errors:** Storage failures

---

## 📝 Service Configuration

### Environment Variables
```typescript
GOOGLE_WEB_CLIENT_ID=your_web_client_id
GOOGLE_IOS_CLIENT_ID=your_ios_client_id
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// App startup
await OAuthService.initialize();
await sessionManagementService.initialize();
```

### Service Cleanup
```typescript
// App shutdown
sessionManagementService.cleanup();
```

---

## 🔄 Service Updates

### Future Enhancements
- Multi-device session management
- Session revocation API
- Enhanced error recovery
- Offline authentication support
- Biometric authentication

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
