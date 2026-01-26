# Authentication System - User Flows

## 🔄 Primary User Flows

### 1. Email/Password Sign Up Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Auth Screen
   └─> Display Auth Form
       └─> Show Login/Signup Toggle

2. Toggle to Signup Mode
   └─> Display Signup Form
       └─> Show: Name, Email, Password fields

3. Enter Name
   └─> Validate input

4. Enter Email
   └─> Validate email format

5. Enter Password
   └─> Show password strength indicator
       └─> Real-time validation
           └─> Display criteria checklist

6. Click "Konto erstellen"
   └─> Validate all fields
       └─> Check password strength
           ├─> Weak password → Show error
           └─> Valid → Continue
               └─> Show loading state
                   └─> Call signUp API
                       ├─> Error → Show error message
                       └─> Success → Continue
                           └─> Create user profile
                               └─> Store email in AsyncStorage
                                   └─> Navigate to EmailVerificationScreen
```

**Success Path:**
- User completes signup
- Email verification sent
- Navigate to verification screen

**Error Paths:**
- Invalid email → Show validation error
- Weak password → Show strength requirements
- Network error → Show connectivity error
- Email already exists → Show error message

---

### 2. Email/Password Sign In Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Auth Screen
   └─> Display Auth Form (Login mode)

2. Enter Email
   └─> Validate email format

3. Enter Password
   └─> Toggle visibility available

4. Click "Anmelden"
   └─> Validate fields
       └─> Check network connectivity
           ├─> Offline → Show error
           └─> Online → Continue
               └─> Show loading state
                   └─> Call signIn API
                       ├─> Invalid credentials → Show error
                       ├─> Network error → Show error
                       └─> Success → Continue
                           └─> Load user profile
                               └─> Sync onboarding data
                                   └─> Navigate to Main App
```

**Success Path:**
- Valid credentials
- Session created
- Profile loaded
- Navigate to main app

**Error Paths:**
- Invalid email/password → Show error
- Network error → Show connectivity error
- Account not verified → Prompt verification

---

### 3. Google Sign-In Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Auth/Signup Screen
   └─> Display Google Sign-In button

2. Click "Mit Google anmelden"
   └─> Check Google configuration
       ├─> Not configured → Show error
       └─> Configured → Continue
           └─> Check Google Play Services (Android)
               ├─> Not available → Show error
               └─> Available → Continue
                   └─> Show loading state
                       └─> Open Google Sign-In native flow
                           ├─> User cancels → Return silently
                           └─> User approves → Continue
                               └─> Receive user data
                                   └─> Create OAuth user object
                                       └─> Handle successful OAuth
                                           └─> Create/update user profile
                                               └─> Create trial subscription (if plan selected)
                                                   └─> Navigate to Main App
```

**Success Path:**
- Google authentication succeeds
- Profile created
- Navigate to main app

**Error Paths:**
- User cancels → No error shown, return to screen
- Play Services unavailable → Show error
- Configuration missing → Show warning
- Network error → Show error

---

### 4. Apple Sign-In Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Auth/Signup Screen
   └─> Display Apple Sign-In button (iOS only)

2. Click "Mit Apple anmelden"
   └─> Check Apple Sign-In availability
       ├─> Not available → Show error
       └─> Available → Continue
           └─> Show loading state
               └─> Open Apple Sign-In native flow
                   ├─> User cancels → Return silently
                   └─> User approves → Continue
                       └─> Receive user data
                           └─> Handle private relay email
                               └─> Create OAuth user object
                                   └─> Handle successful OAuth
                                       └─> Create/update user profile
                                           └─> Create trial subscription (if plan selected)
                                               └─> Navigate to Main App
```

**Success Path:**
- Apple authentication succeeds
- Profile created (with private relay email if used)
- Navigate to main app

**Error Paths:**
- User cancels → No error shown, return to screen
- Not available on device → Show error
- Network error → Show error

---

### 5. Email Verification Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Complete Signup
   └─> Navigate to EmailVerificationScreen
       └─> Display verification status (pending)
           └─> Show user email
               └─> Show "Resend" button

2. Check Email
   └─> User clicks verification link
       └─> App opens via deep link
           └─> Parse URL for tokens
               ├─> Invalid/expired → Show error
               └─> Valid → Continue
                   └─> Update status (verifying)
                       └─> Create session with tokens
                           ├─> Error → Show error
                           └─> Success → Continue
                               └─> Update status (success)
                                   └─> Auto-navigate to Main App (2s delay)

3. Alternative: Resend Email
   └─> Click "Resend" button
       └─> Check cooldown
           ├─> In cooldown → Show countdown
           └─> Available → Continue
               └─> Send verification email
                   └─> Set 60s cooldown
                       └─> Show success message
```

**Success Path:**
- Verification link clicked
- Session created
- Navigate to main app

**Error Paths:**
- Expired link → Show error, offer resend
- Invalid token → Show error
- Network error → Show error

---

### 6. Password Reset Flow

#### 6a. Request Reset

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to ForgotPasswordScreen
   └─> Display email input

2. Enter Email
   └─> Validate email format

3. Click "Reset-Link senden"
   └─> Validate email
       └─> Check cooldown
           ├─> In cooldown → Show countdown
           └─> Available → Continue
               └─> Show loading state
                   └─> Send reset email
                       ├─> Error → Show error
                       └─> Success → Continue
                           └─> Update status (success)
                               └─> Show email confirmation
                                   └─> Set 60s cooldown
```

#### 6b. Reset Password

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click Reset Link in Email
   └─> App opens via deep link
       └─> Navigate to ResetPasswordScreen
           └─> Parse URL for tokens
               ├─> Invalid/expired → Show error
               └─> Valid → Continue
                   └─> Create session with tokens
                       └─> Display password form

2. Enter New Password
   └─> Show password strength indicator
       └─> Real-time validation

3. Confirm Password
   └─> Validate password match

4. Click "Passwort zurücksetzen"
   └─> Validate all fields
       ├─> Mismatch → Show error
       ├─> Weak password → Show error
       └─> Valid → Continue
           └─> Show loading state
               └─> Update password
                   ├─> Error → Show error
                   └─> Success → Continue
                       └─> Show success message
                           └─> Auto-navigate to Main App (2s delay)
```

**Success Path:**
- Reset link clicked
- New password set
- Navigate to main app

**Error Paths:**
- Expired link → Show error, offer new request
- Weak password → Show requirements
- Password mismatch → Show error

---

## 🔀 Alternative Flows

### Registration Cache Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Browse Content (Unauthenticated)
   └─> User selects sound/category
       └─> RegistrationCacheService.cacheSoundSelection()
           └─> Store selection in AsyncStorage
               └─> Navigate to Auth Screen

2. Complete Signup/Signin
   └─> After successful authentication
       └─> RegistrationCacheService.getCachedSelection()
           ├─> No cache → Navigate to Main App
           └─> Cache exists → Continue
               └─> Check cache expiration
                   ├─> Expired → Clear cache, navigate to Main App
                   └─> Valid → Continue
                       └─> Resume to cached selection
                           └─> Clear cache
```

**Use Cases:**
- User browses sounds before signup
- User selects category before signup
- Preserve user intent during authentication

---

### Session Refresh Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App Active / Session Check
   └─> SessionManagementService checks session
       └─> Check expiry time
           ├─> Valid (> 5 min remaining) → Continue
           └─> Expiring soon (< 5 min) → Continue
               └─> Trigger automatic refresh
                   └─> Call refreshSession()
                       ├─> Success → Update session
                       └─> Failure → Continue with current session
                           └─> Retry on next check

2. Background Refresh (Every 60s)
   └─> Check all active sessions
       └─> For each expiring session
           └─> Trigger refresh
               └─> Notify refresh listeners
```

**Automatic Behavior:**
- Runs in background
- No user interaction required
- Transparent to user

---

### Session Expiry Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Session Expires
   └─> SessionManagementService detects expiry
       └─> Attempt refresh
           ├─> Success → Continue
           └─> Failure → Continue
               └─> Clear session
                   └─> Update AuthContext
                       └─> Set user to null
                           └─> Navigate to Auth Screen
                               └─> Show session expired message
```

**User Experience:**
- Seamless if refresh succeeds
- Sign out and redirect if refresh fails
- Clear error message

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Authentication
   └─> NetworkDiagnosticsService.testSupabaseConnection()
       └─> Check connectivity
           ├─> Connected → Continue with auth
           └─> Not connected → Continue
               └─> Show user-friendly error
                   └─> Suggest checking connection
                       └─> Provide retry option
```

**Error Messages:**
- "Keine Internetverbindung"
- "Bitte überprüfe deine Internetverbindung"
- Retry button available

---

### Invalid Credentials Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Enter Credentials
   └─> Submit form

2. API Returns Error
   └─> Parse error type
       ├─> Invalid email/password → Show error
       │   └─> "E-Mail oder Passwort ist falsch"
       ├─> Email not verified → Show error
       │   └─> "Bitte verifiziere deine E-Mail"
       └─> Other error → Show generic error
           └─> "Ein Fehler ist aufgetreten"
```

**User Actions:**
- Retry with corrected credentials
- Navigate to forgot password
- Navigate to email verification

---

### OAuth Cancellation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click OAuth Button
   └─> Open native OAuth flow

2. User Cancels
   └─> OAuth provider returns cancellation
       └─> Detect cancellation code
           └─> Return null (no error)
               └─> Return to auth screen
                   └─> No error message shown
```

**User Experience:**
- Silent cancellation
- No error shown
- User can retry

---

## 🔄 State Transitions

### Verification Status States

```
pending → verifying → success
   │         │
   │         └─> error
   │
   └─> error (resend)
```

### Reset Status States

```
pending → sending → success
   │        │
   │        └─> error
   │
   └─> error (retry)
```

### Session States

```
No Session → Authenticating → Authenticated
     │              │              │
     │              └─> Error      │
     │                             │
     └─> Expired ←─────────────────┘
```

---

## 📊 Flow Diagrams

### Complete Signup Journey

```
Index Screen
    │
    ├─> User clicks "Get Started"
    │   └─> OnboardingSlidesScreen
    │       └─> Complete onboarding
    │           └─> Select category
    │               └─> AuthScreen (Signup mode)
    │                   ├─> Email/Password Signup
    │                   │   └─> EmailVerificationScreen
    │                   │       └─> Verify email
    │                   │           └─> Main App
    │                   ├─> Google Signup
    │                   │   └─> Main App
    │                   └─> Apple Signup
    │                       └─> Main App
    │
    └─> User browses content
        └─> Selects sound (requires auth)
            └─> Cache selection
                └─> AuthScreen
                    └─> [Same flows as above]
                        └─> Resume to cached selection
```

---

## 🎯 User Goals

### Goal: Quick Signup
- **Path:** OAuth (Google/Apple)
- **Time:** < 15 seconds
- **Steps:** 2-3 taps

### Goal: Secure Account
- **Path:** Email/Password with verification
- **Time:** ~2 minutes
- **Steps:** Signup → Verify → Use

### Goal: Recover Access
- **Path:** Password Reset
- **Time:** ~3 minutes
- **Steps:** Request → Email → Reset → Sign In

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
