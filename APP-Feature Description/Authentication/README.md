# Authentication System - Feature Documentation

**Feature Name:** Authentication & Account Management
**Status:** Implemented (Email/password, Apple Sign-In, Google Sign-In); some flows pending (email verification, forgot password UI)
**Priority:** High
**Last Updated:** 2026-03

## 📋 Feature Overview

The Authentication system provides secure user authentication and account management for the AWAVE iOS app. It is built on **Firebase Auth** and supports **email/password**, **Apple Sign-In**, and **Google Sign-In** (all implemented). Tech stack: **Swift**, **Firebase Auth**, **AuthenticationServices** (Apple), **Google Sign-In SDK**.

### Description

The authentication system is built on **Firebase Auth** and provides:
- **Multi-provider authentication** (Email/Password ✓, Apple Sign-In ✓, Google Sign-In ✓)
- **Secure password management** with strength validation
- **Email verification** workflow
- **Password reset** functionality (backend supported; UI pending)
- **Session management** with automatic token refresh
- **Registration flow** with onboarding integration
- **User profile** creation and management (Firestore)

### User Value

- **Seamless onboarding** - Multiple sign-in options reduce friction
- **Security** - Strong password requirements and email verification
- **Convenience** - OAuth providers eliminate password management
- **Reliability** - Automatic session refresh and error handling
- **Continuity** - Registration cache preserves user selections during signup

---

## 🎯 Core Features

### 1. Email/Password Authentication
- [x] Sign up with email and password
- [x] Sign in with existing credentials
- [x] Password strength validation
- [x] Secure password storage

### 2. OAuth Authentication
- [x] **Google Sign-In** - Implemented (GoogleSignInService, Firebase Auth Google provider; handleURL for callback)
- [x] **Apple Sign-In** - Implemented (AppleSignInHelper, Firebase Auth Apple provider)
- [x] Automatic profile creation (FirestoreUserRepository on Apple/Google Sign-In)
- [ ] Avatar and name sync (partial)

### 3. Email Verification
- [ ] Verification email sending
- [ ] Deep link handling for verification
- [ ] Resend functionality with cooldown
- [ ] Status tracking (pending, verifying, success, error)

### 4. Password Management
- [ ] **Forgot Password** - Request reset link via email
- [ ] **Reset Password** - Set new password with strength validation
- [x] Password visibility toggle
- [x] Real-time strength indicator

### 5. Session Management
- [x] Automatic token refresh
- [x] Session expiry handling
- [ ] Multi-device session tracking
- [x] Secure session storage

### 6. Registration Flow
- [ ] Registration cache for preserving selections
- [x] Onboarding integration
- [ ] Trial subscription creation
- [x] Profile setup

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Firebase Auth (Google Cloud)
- **Swift / Firebase:** No React/TypeScript or Supabase; all auth is native Swift with Firebase.
- **Apple Sign-In:** AuthenticationServices (native) + Firebase Auth Apple provider (AppleSignInHelper)
- **Google Sign-In:** Google Sign-In SDK + Firebase Auth Google provider (GoogleSignInService; handleURL for callback)
- **Storage:** UserDefaults, Keychain (tokens); user data in Firestore
- **State Management:** SwiftUI, @Observable

### Key Components
- `AuthService` / `AuthServiceProtocol` - Authentication and session (Firebase Auth)
- `AuthView` / `AuthViewModel` - Main authentication UI (login/signup, Apple + Google buttons)
- `AppleSignInHelper` - Apple Sign-In flow (nonce, credential, Firebase)
- `GoogleSignInService` - Google Sign-In flow (presenting UI, credential, Firebase)
- `FirestoreUserRepository` - User profile creation/update after sign-in
- Session lifecycle via Firebase Auth

---

## 📱 Screens

1. **AuthScreen** (`/auth`) - Main authentication screen with login/signup toggle
2. **SignupScreen** (`/signup`) - Dedicated signup screen with OAuth options
3. **EmailVerificationScreen** (`/email-verification`) - Email verification status
4. **ForgotPasswordScreen** (`/forgot-password`) - Password reset request
5. **ResetPasswordScreen** (`/reset-password`) - New password entry

---

## 🔄 User Flows

### Primary Flows
1. **Sign Up Flow** - Email/Password → Email Verification → Onboarding
2. **Sign In Flow** - Credentials → Session → Main App
3. **OAuth Flow** - Provider Selection → Native Auth → Profile Creation → Main App
4. **Password Reset Flow** - Request → Email Link → Reset → Sign In

### Alternative Flows
- **Registration Cache** - Browse → Select → Sign Up → Resume Selection
- **Session Refresh** - Expired Session → Auto Refresh → Continue
- **Email Resend** - Verification Failed → Resend → Verify

---

## 🔐 Security Features

- Password strength validation (8+ chars, uppercase, lowercase, numbers, special chars)
- Secure token storage
- Automatic session refresh
- Email verification requirement
- OAuth token management
- Network connectivity checks

---

## 📊 Integration Points

### Related Features
- **Onboarding** - Category selection during registration
- **Subscription** - Trial creation after signup
- **Profile** - User profile creation and updates
- **Navigation** - Route protection and redirects

### External Services
- Firebase Auth (authentication backend; runs on Google Cloud)
- Apple Sign-In (AuthenticationServices + Firebase Auth Apple provider)
- Google Sign-In (Google Sign-In SDK + Firebase Auth Google provider; implemented)
- Email service (verification and reset emails via Firebase Auth; backend supported, UI pending where noted)

---

## 🧪 Testing Considerations

### Test Cases
- Email/password signup and signin
- OAuth provider authentication
- Email verification flow
- Password reset flow
- Session refresh and expiry
- Registration cache functionality
- Error handling (network, invalid credentials, etc.)

### Edge Cases
- Network connectivity issues
- Expired verification links
- Invalid OAuth credentials
- Session expiry during app use
- Multiple device sessions

---

## 📚 Additional Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Apple Sign-In (AuthenticationServices)](https://developer.apple.com/documentation/authenticationservices)
- [Firebase Auth Apple Provider](https://firebase.google.com/docs/auth/ios/apple)
- [Firebase Auth Google Provider](https://firebase.google.com/docs/auth/ios/google-signin) (for when Google Sign-In is implemented)

---

## 📝 Notes

- OAuth credentials must be configured in environment variables
- Email verification is required for email/password signups
- Session tokens are automatically refreshed before expiry
- Registration cache expires after 30 minutes
- Password strength indicator provides real-time feedback

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
