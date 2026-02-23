# Authentication System - Functional Requirements

## 📋 Core Requirements

### 1. Email/Password Authentication

#### Sign Up
- [x] User can create account with email and password
- [x] Password must meet strength requirements (8+ chars, uppercase, lowercase, number, special char)
- [x] Real-time password strength validation
- [x] Email validation (format check)
- [x] Full name collection (optional during signup)
- [x] Automatic user profile creation
- [x] Email verification email sent automatically
- [x] Navigation to email verification screen after signup

#### Sign In
- [x] User can sign in with email and password
- [x] Credential validation
- [x] Error handling for invalid credentials
- [x] Network connectivity check before authentication
- [x] Session creation on successful sign in
- [x] Navigation to main app after sign in

### 2. OAuth Authentication

#### Google Sign-In
- [ ] Google Sign-In button available (Not implemented)
- [ ] Native Google authentication flow (Not implemented)
- [ ] Google Play Services availability check (Android) (Not implemented)
- [ ] User profile data extraction (email, name, avatar) (Not implemented)
- [ ] Automatic profile creation in Firestore (Not implemented - Google Sign-In not implemented)
- [ ] Error handling for cancelled/failed authentication (Not implemented)
- [ ] Configuration check (warns if credentials not set) (Not implemented)

#### Apple Sign-In
- [x] Apple Sign-In button available (iOS only) (AppleSignInHelper implemented)
- [x] Native Apple authentication flow (AppleSignInHelper implemented)
- [x] Device support check (Implemented)
- [x] User profile data extraction (email, name) (AppleSignInHelper implemented)
- [ ] Private relay email handling (Not fully implemented)
- [x] Automatic profile creation in Firestore (FirestoreUserRepository; profile created on Apple Sign-In)
- [x] Error handling for cancelled/failed authentication (AppleSignInHelper implemented)

#### OAuth Profile Creation
- [x] User profile created automatically after OAuth success (FirestoreUserRepository)
- [x] Display name set from OAuth provider (Implemented)
- [ ] Avatar URL stored if available (Not implemented)
- [ ] Registration flow state set to 'trial_active' (Not implemented)
- [ ] Onboarding marked as completed (Not implemented)
- [ ] Trial subscription creation if plan was selected (Not implemented)

### 3. Email Verification

#### Verification Email
- [x] Verification email sent automatically after signup
- [x] Email address displayed on verification screen
- [x] Resend verification email functionality
- [x] 60-second cooldown between resend requests
- [x] Cooldown timer display
- [x] Status tracking (pending, verifying, success, error)

#### Deep Link Handling
- [x] App opens verification link from email
- [x] Token extraction from URL (hash or query params)
- [x] Session creation with verification tokens
- [x] Automatic navigation after successful verification
- [x] Error handling for expired/invalid links

#### Verification Status
- [x] Real-time status updates
- [x] Visual feedback (icons, loading states)
- [x] Success state with auto-navigation
- [x] Error state with retry options

### 4. Password Management

#### Forgot Password
- [x] Email input for password reset request (AuthView "Passwort vergessen?" in sign-in mode; uses same email field)
- [x] Email format validation (AuthViewModel.sendPasswordReset validates non-empty and contains "@")
- [x] Reset link email sent to user (AuthService.sendPasswordReset → Firebase Auth)
- [x] Success confirmation (Alert "E-Mail gesendet" after successful send)
- [ ] Resend functionality with cooldown (Not implemented; user can tap again to resend)
- [x] Error handling (userFacingMessage for rate limit, network, etc.)

#### Reset Password
- [x] Reset flow: user clicks link in email → Firebase-hosted page (not in-app) → enters new password → signs in (Firebase handles reset page)
- [ ] In-app deep link / in-app reset UI (Not implemented; optional; Firebase hosted page is standard)
- [x] User can sign in with new password after reset (via Firebase page then return to app)

### 5. Session Management

#### Session Creation
- [x] Session created on successful authentication
- [x] Session stored securely
- [x] User profile loaded after session creation
- [x] Onboarding data synced from local storage

#### Session Refresh
- [x] Automatic token refresh before expiry (Firebase Auth handles automatically)
- [ ] Background refresh monitoring (every minute) (Not implemented - Firebase handles automatically)
- [ ] Manual refresh capability (Not implemented)
- [ ] Refresh listener system for components (Not implemented - Firebase authStateChanges used)
- [x] Error handling for refresh failures (Firebase Auth handles)

#### Session Expiry
- [x] Session expiry detection
- [x] Automatic sign out on expiry
- [x] User notification on session expiry
- [x] Navigation to auth screen on expiry

#### Multi-Device Support
- [ ] Device ID generation and storage (Not implemented)
- [ ] Session info tracking (device, platform, last active) (Not implemented)
- [ ] Current session info retrieval (Not implemented)
- [ ] Session revocation capability (future: multi-device management) (Not implemented)

### 6. Registration Flow Integration

#### Registration Cache
- [ ] Cache sound selection before authentication (Not implemented)
- [ ] Cache category selection before authentication (Not implemented)
- [ ] Cache navigation target (Not implemented)
- [ ] 30-minute cache expiration (Not implemented)
- [ ] Cache retrieval after authentication (Not implemented)
- [ ] Cache clearing after use (Not implemented)

#### Onboarding Integration
- [x] Category preference saved during signup (OnboardingStorageService)
- [x] Onboarding profile data synced to backend (FirestoreUserRepository)
- [x] Onboarding completion status tracked (OnboardingStorageService)
- [ ] Trial subscription creation if plan selected (Not implemented)

---

## 🎯 User Stories

### As a new user, I want to:
- Sign up quickly using my Google/Apple account so I don't have to create a new password
- See password strength in real-time so I can create a secure password
- Verify my email address so my account is secure
- Reset my password if I forget it so I can regain access to my account

### As an existing user, I want to:
- Sign in quickly with my saved credentials
- Have my session persist across app restarts
- Be automatically signed in if my session is still valid
- Sign out securely when I'm done

### As a user experiencing issues, I want to:
- See clear error messages when authentication fails
- Resend verification emails if I didn't receive one
- Get help if I'm stuck in the authentication flow

---

## ✅ Acceptance Criteria

### Sign Up
- [x] User can complete signup in < 30 seconds
- [x] Password strength indicator provides real-time feedback
- [x] Email verification email sent within 5 seconds
- [x] User redirected to verification screen after signup

### Sign In
- [x] User can sign in in < 10 seconds
- [x] Invalid credentials show clear error message
- [x] Network errors show user-friendly message
- [x] User redirected to main app after signin

### OAuth
- [x] OAuth flow completes in < 15 seconds
- [x] User profile created automatically
- [x] Cancelled OAuth doesn't show error
- [x] Failed OAuth shows helpful error message

### Email Verification
- [x] Verification link opens app and verifies email
- [x] Resend button has 60-second cooldown
- [x] Status updates in real-time
- [x] User redirected after successful verification

### Password Reset
- [x] Reset link sent within 5 seconds
- [x] Reset link opens app and allows password reset
- [x] New password meets strength requirements
- [x] User can sign in with new password immediately

### Session Management
- [x] Session persists across app restarts
- [x] Session refreshes automatically before expiry
- [x] Expired sessions trigger sign out
- [x] User notified of session expiry

---

## 🚫 Non-Functional Requirements

### Performance
- Authentication requests complete in < 3 seconds
- Session refresh doesn't block UI
- OAuth flow completes in < 15 seconds

### Security
- Passwords never stored in plain text
- Tokens stored securely
- Network requests use HTTPS
- OAuth credentials stored securely

### Usability
- Clear error messages for all failure cases
- Loading states for all async operations
- Intuitive navigation flow
- Accessible UI components

### Reliability
- Network errors handled gracefully
- Automatic retry for transient failures
- Offline state detection
- Session recovery after app restart

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before authentication
- [x] User-friendly error messages
- [x] Retry capability
- [x] Network status display

### Invalid Input
- [x] Email format validation
- [x] Password strength validation
- [x] Required field validation
- [x] Clear validation error messages

### Expired Links
- [x] Detection of expired verification links
- [x] Detection of expired reset links
- [x] Option to request new link
- [x] Clear error messages

### OAuth Cancellation
- [x] Graceful handling of user cancellation
- [x] No error shown on cancellation
- [x] User can retry OAuth

### Session Edge Cases
- [x] Multiple simultaneous refresh attempts
- [x] Session expiry during active use
- [x] App restart with expired session
- [x] Network loss during refresh

---

## 📊 Success Metrics

- Signup completion rate > 80%
- OAuth adoption rate > 60%
- Email verification rate > 90%
- Password reset success rate > 95%
- Session refresh success rate > 99%
- Average authentication time < 5 seconds
