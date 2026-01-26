# Authentication System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase Auth** - Primary authentication service
  - Email/password authentication
  - OAuth provider integration
  - Session management
  - Token refresh
  - Email verification
  - Password reset

#### OAuth Providers
- **Google Sign-In**
  - Library: `@react-native-google-signin/google-signin`
  - iOS Client ID required
  - Web Client ID required
  - Google Play Services required (Android)

- **Apple Sign-In**
  - Library: `react-native-apple-authentication`
  - iOS only
  - Native Apple authentication
  - Private relay email support

#### State Management
- **React Context API** - `AuthContext` for global auth state
- **Custom Hooks** - `useAuth`, `useOAuth`, `useProductionAuth`, `useAuthForm`
- **AsyncStorage** - Local caching and persistence

#### Services Layer
- `OAuthService` - OAuth provider abstraction
- `SessionManagementService` - Session lifecycle management
- `ProductionBackendService` - Supabase integration
- `RegistrationCacheService` - Registration flow caching

---

## 📁 File Structure

```
src/
├── screens/
│   ├── AuthScreen.tsx              # Main auth screen
│   ├── SignupScreen.tsx            # Dedicated signup
│   ├── EmailVerificationScreen.tsx  # Email verification
│   ├── ForgotPasswordScreen.tsx    # Password reset request
│   └── ResetPasswordScreen.tsx     # Password reset
├── components/
│   └── auth/
│       ├── AuthForm.tsx                    # Reusable auth form
│       ├── SocialAuthButton.tsx            # OAuth buttons
│       ├── PasswordStrengthIndicator.tsx   # Password validation UI
│       ├── AppleLogo.tsx                  # Apple logo component
│       └── GoogleLogo.tsx                 # Google logo component
├── services/
│   ├── auth.ts                      # Basic auth functions
│   ├── OAuthService.ts              # OAuth provider service
│   ├── SessionManagementService.ts  # Session management
│   ├── ProductionBackendService.ts  # Supabase integration
│   └── RegistrationCacheService.ts  # Registration caching
├── hooks/
│   ├── useAuthForm.ts               # Auth form logic
│   ├── useOAuth.ts                  # OAuth hook
│   ├── useProductionAuth.ts         # Production auth hook
│   └── useRegistrationFlow.ts       # Registration flow
├── contexts/
│   └── AuthContext.tsx              # Global auth context
└── utils/
    ├── passwordSecurity.ts          # Password validation
    └── errorHandler.ts              # Error handling
```

---

## 🔧 Components

### AuthScreen
**Location:** `src/screens/AuthScreen.tsx`

**Purpose:** Main authentication screen with login/signup toggle

**Props:**
```typescript
interface AuthScreenProps {
  onBack?: () => void;
}
```

**Features:**
- Login/signup mode toggle
- Email/password form
- OAuth buttons (Google, Apple)
- Navigation handling
- Loading states

**State:**
- `isLogin: boolean` - Current mode (login/signup)

**Dependencies:**
- `AuthForm` component
- `useOAuth` hook
- `useTheme` hook

---

### SignupScreen
**Location:** `src/screens/SignupScreen.tsx`

**Purpose:** Dedicated signup screen with OAuth options

**Features:**
- User ID generation (AWAVE-XXXXXXXX format)
- OAuth signup buttons
- Email signup navigation
- Terms and conditions links
- Error handling

**State:**
- `loading: boolean`
- `errors: Record<string, string>`
- `userId: string` - Generated user ID

**Dependencies:**
- `SocialAuthButton` component
- `OAuthService`
- `useAuth` context

---

### EmailVerificationScreen
**Location:** `src/screens/EmailVerificationScreen.tsx`

**Purpose:** Email verification status and resend

**Features:**
- Verification status tracking (pending, verifying, success, error)
- Deep link handling for verification
- Resend functionality with cooldown
- Email display
- Status-based UI updates

**State:**
- `verificationStatus: 'pending' | 'verifying' | 'success' | 'error'`
- `userEmail: string`
- `isResending: boolean`
- `resendCooldown: number` - Seconds remaining

**Deep Link Handling:**
- Listens for `email-verification` URLs
- Extracts tokens from hash or query params
- Creates session with tokens
- Navigates on success

**Dependencies:**
- `ProductionBackendService`
- `AsyncStorage`
- `Linking` API

---

### ForgotPasswordScreen
**Location:** `src/screens/ForgotPasswordScreen.tsx`

**Purpose:** Password reset request

**Features:**
- Email input
- Reset link sending
- Resend with cooldown
- Status tracking
- Success/error states

**State:**
- `resetStatus: 'pending' | 'sending' | 'success' | 'error'`
- `email: string`
- `isSending: boolean`
- `resendCooldown: number`

**Dependencies:**
- `ProductionBackendService`
- `Input` component

---

### ResetPasswordScreen
**Location:** `src/screens/ResetPasswordScreen.tsx`

**Purpose:** New password entry after reset link

**Features:**
- Deep link handling for reset link
- Password input with visibility toggle
- Password confirmation
- Real-time strength validation
- Password match validation

**State:**
- `resetStatus: 'pending' | 'verifying' | 'success' | 'error'`
- `password: string`
- `confirmPassword: string`
- `showPassword: boolean`
- `showConfirmPassword: boolean`
- `isUpdating: boolean`
- `passwordStrength: PasswordStrength`

**Deep Link Handling:**
- Listens for `password-reset` URLs
- Extracts tokens
- Creates session
- Allows password update

**Dependencies:**
- `ProductionBackendService`
- `PasswordStrengthIndicator`
- `checkPasswordStrength` utility

---

### AuthForm Component
**Location:** `src/components/auth/AuthForm.tsx`

**Purpose:** Reusable authentication form

**Props:**
```typescript
interface AuthFormProps {
  mode: 'login' | 'signup';
  onSuccess?: () => void;
  toggleMode: () => void;
  children?: React.ReactNode;
}
```

**Features:**
- Email input
- Password input with visibility toggle
- Full name input (signup only)
- Submit button
- Mode toggle link
- Loading states

**Dependencies:**
- `useAuth` context
- `Input` component
- `AnimatedButton` component

---

### SocialAuthButton Component
**Location:** `src/components/auth/SocialAuthButton.tsx`

**Purpose:** OAuth provider button

**Props:**
```typescript
interface SocialAuthButtonProps {
  provider: 'apple' | 'google' | 'email';
  onPress: () => void;
  disabled?: boolean;
}
```

**Features:**
- Provider-specific styling
- Icon display (Apple, Google, Email)
- Disabled state
- Touch feedback

---

### PasswordStrengthIndicator Component
**Location:** `src/components/auth/PasswordStrengthIndicator.tsx`

**Purpose:** Real-time password strength feedback

**Props:**
```typescript
interface PasswordStrengthIndicatorProps {
  strength: 'weak' | 'medium' | 'strong';
  password: string;
}
```

**Features:**
- Progress bar visualization
- Strength label
- Criteria checklist
- Real-time updates

**Criteria:**
- Minimum 8 characters
- Uppercase letter
- Lowercase letter
- Number
- Special character (recommended)

---

## 🔌 Services

### OAuthService
**Location:** `src/services/OAuthService.ts`

**Class:** Singleton service

**Methods:**
- `initialize()` - Initialize Google Sign-In
- `isGoogleConfigured()` - Check configuration
- `signInWithGoogle()` - Google authentication
- `signInWithApple()` - Apple authentication
- `handleSuccessfulOAuth()` - Post-auth processing
- `signOut()` - Sign out from providers
- `isGoogleSignedIn()` - Check Google sign-in status
- `getCurrentGoogleUser()` - Get current Google user

**Configuration:**
- `GOOGLE_WEB_CLIENT_ID` - Environment variable
- `GOOGLE_IOS_CLIENT_ID` - Environment variable

**Error Handling:**
- Cancellation detection (no error shown)
- Play Services availability check
- Configuration validation

---

### SessionManagementService
**Location:** `src/services/SessionManagementService.ts`

**Class:** Singleton service

**Methods:**
- `initialize()` - Setup session monitoring
- `cleanup()` - Cleanup resources
- `getCurrentSession()` - Get session with auto-refresh
- `refreshSession()` - Manual refresh
- `isSessionValid()` - Check validity
- `isSessionExpiringSoon()` - Check expiry threshold
- `handleSessionExpiry()` - Handle expiry
- `getSessionInfo()` - Get stored session info
- `addRefreshListener()` - Add refresh listener
- `removeRefreshListener()` - Remove listener
- `getActiveSessions()` - Get all sessions (future)
- `revokeSession()` - Revoke session (future)

**Configuration:**
- `REFRESH_THRESHOLD_MS: 5 * 60 * 1000` - 5 minutes before expiry
- Refresh check interval: 60 seconds

**Storage:**
- `awave.session.info` - Session metadata
- `awave.device.id` - Device identifier

---

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Purpose:** Supabase integration layer

**Auth Methods:**
- `signUp(email, password, firstName?, lastName?)`
- `signIn(email, password)`
- `signOut()`
- `getCurrentUser()`
- `updateEmail(email)`
- `updatePassword(password)`
- `resendVerificationEmail(email)`
- `resetPasswordForEmail(email)`
- `setAuthSession(accessToken, refreshToken)`

**Profile Methods:**
- `createUserProfile(userId, profileData)`
- `getUserProfile(userId)`
- `updateUserProfile(userId, updates)`

---

### RegistrationCacheService
**Location:** `src/services/RegistrationCacheService.ts`

**Class:** Static service

**Methods:**
- `cacheSoundSelection(soundId)` - Cache sound selection
- `cacheCategorySelection(categoryId)` - Cache category selection
- `getCachedSelection()` - Get cached data
- `clearCache()` - Clear all cache
- `hasCachedSelection()` - Check if cache exists

**Storage Keys:**
- `registration_cache_sound_id`
- `registration_cache_category_id`
- `registration_cache_nav_target`
- `registration_cache_timestamp`

**Expiration:** 30 minutes

---

## 🪝 Hooks

### useAuth
**Location:** `src/contexts/AuthContext.tsx`

**Purpose:** Global authentication context hook

**Returns:**
```typescript
{
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  signIn: (email, password) => Promise<{data, error}>;
  signUp: (email, password, fullName?) => Promise<{data, error}>;
  signOut: () => Promise<void>;
  updateProfile: (updates) => Promise<void>;
  updateEmail: (email) => Promise<{data, error}>;
  updatePassword: (password) => Promise<{data, error}>;
}
```

**Features:**
- Automatic session monitoring
- User profile hydration
- Network connectivity checks
- Onboarding data sync
- Trial reminder checks

---

### useOAuth
**Location:** `src/hooks/useOAuth.ts`

**Purpose:** OAuth authentication hook

**Returns:**
```typescript
{
  loading: boolean;
  signInWithGoogle: () => Promise<void>;
  signInWithApple: () => Promise<void>;
  handleSuccessfulOAuth: (user) => Promise<void>;
  signOut: () => Promise<void>;
  isGoogleSignedIn: () => Promise<boolean>;
  getCurrentGoogleUser: () => Promise<OAuthUser | null>;
}
```

**Features:**
- OAuth provider abstraction
- Profile creation
- Trial subscription handling
- Error handling
- Navigation management

---

### useProductionAuth
**Location:** `src/hooks/useProductionAuth.ts`

**Purpose:** Production authentication hook (source of truth)

**Returns:**
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

**Features:**
- Direct Supabase integration
- Session state management
- Profile management
- Subscription integration

---

### useAuthForm
**Location:** `src/hooks/useAuthForm.ts`

**Purpose:** Authentication form state management

**Returns:**
```typescript
{
  isLogin: boolean;
  setIsLogin: (value) => void;
  email: string;
  setEmail: (value) => void;
  password: string;
  setPassword: (value) => void;
  loading: boolean;
  passwordStrength: PasswordStrength;
  processAuth: () => Promise<void>;
}
```

**Features:**
- Form state management
- Password strength calculation
- Authentication processing
- Registration flow integration
- Error handling

---

## 🔐 Security Implementation

### Password Security
**Location:** `src/utils/passwordSecurity.ts`

**Function:** `checkPasswordStrength(password: string)`

**Returns:**
```typescript
{
  level: 'weak' | 'better' | 'perfect';
  isWeak: boolean;
  score: number;
  feedback: string[];
}
```

**Criteria:**
- Length >= 8
- Contains uppercase
- Contains lowercase
- Contains number
- Contains special character

### Token Storage
- Access tokens stored in Supabase session
- Refresh tokens stored securely
- No tokens in AsyncStorage (except session metadata)
- Automatic token refresh

### Network Security
- All requests use HTTPS
- Network connectivity checks before auth
- Error handling for network failures
- User-friendly error messages

---

## 🔄 State Management

### AuthContext State
```typescript
{
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}
```

### Session State (SessionManagementService)
```typescript
{
  sessionId: string;
  deviceId: string;
  deviceName: string;
  platform: 'ios' | 'android';
  lastActiveAt: string;
  expiresAt: number;
}
```

### Registration Cache State
```typescript
{
  soundId?: string;
  categoryId?: string;
  navigationTarget?: 'player' | 'category' | null;
  timestamp: number;
}
```

---

## 🌐 API Integration

### Supabase Auth Endpoints
- `supabase.auth.signUp()` - User registration
- `supabase.auth.signInWithPassword()` - Email/password sign in
- `supabase.auth.signOut()` - Sign out
- `supabase.auth.getSession()` - Get current session
- `supabase.auth.refreshSession()` - Refresh session
- `supabase.auth.onAuthStateChange()` - Auth state listener
- `supabase.auth.resetPasswordForEmail()` - Request password reset
- `supabase.auth.updateUser()` - Update user (email, password)

### OAuth Endpoints
- Google: Native SDK integration
- Apple: Native SDK integration
- Supabase OAuth callback handling

---

## 📱 Platform-Specific Notes

### iOS
- Apple Sign-In available
- Native authentication flow
- Private relay email support
- URL scheme handling for deep links

### Android
- Google Sign-In requires Google Play Services
- Play Services availability check
- Native authentication flow
- Intent handling for deep links

### Deep Link Handling
- URL scheme: `awave://`
- Email verification: `awave://email-verification?access_token=...`
- Password reset: `awave://password-reset?access_token=...`
- Token extraction from hash or query params

---

## 🧪 Testing Strategy

### Unit Tests
- Password strength validation
- Email validation
- Token parsing
- Cache expiration logic

### Integration Tests
- Supabase auth flow
- OAuth provider flows
- Session refresh
- Deep link handling

### E2E Tests
- Complete signup flow
- Complete signin flow
- Password reset flow
- Email verification flow
- OAuth flows

---

## 🐛 Error Handling

### Error Types
- Network errors
- Invalid credentials
- Expired tokens
- OAuth cancellation
- Configuration errors

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

---

## 📊 Performance Considerations

### Optimization
- Lazy loading of OAuth providers
- Debounced password strength checks
- Efficient session refresh (only when needed)
- Cache expiration to prevent stale data

### Monitoring
- Authentication success rate
- Average authentication time
- Session refresh success rate
- OAuth adoption rate

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
