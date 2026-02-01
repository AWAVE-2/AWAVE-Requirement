# Authentication System - Feature Documentation

**Feature Name:** Authentication & Account Management
**Status:** ⚠️ Partially Complete (Core features done, OAuth and email verification pending)
**Priority:** High
**Last Updated:** 2026-01-29

## 📋 Feature Overview

The Authentication system provides secure user authentication and account management for the AWAVE app. It supports multiple authentication methods including email/password, Google Sign-In, and Apple Sign-In, with comprehensive password management, email verification, and session management capabilities.

### Description

The authentication system is built on Supabase Auth and provides:
- **Multi-provider authentication** (Email/Password, Google, Apple)
- **Secure password management** with strength validation
- **Email verification** workflow
- **Password reset** functionality
- **Session management** with automatic token refresh
- **Registration flow** with onboarding integration
- **User profile** creation and management

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
- [ ] **Google Sign-In** - Native Google authentication (placeholder only)
- [ ] **Apple Sign-In** - Native Apple authentication (placeholder only)
- [ ] Automatic profile creation
- [ ] Avatar and name sync

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
- **Backend:** Supabase Auth
- **OAuth Libraries:**
  - `@react-native-google-signin/google-signin` - Google Sign-In
  - `react-native-apple-authentication` - Apple Sign-In
- **Storage:** AsyncStorage for local caching
- **State Management:** React Context API

### Key Components
- `AuthContext` - Global authentication state
- `AuthScreen` - Main authentication UI
- `AuthForm` - Reusable form component
- `OAuthService` - OAuth provider abstraction
- `SessionManagementService` - Session lifecycle management

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
- Supabase Auth (authentication backend)
- Google OAuth (Google Sign-In)
- Apple OAuth (Apple Sign-In)
- Email service (verification and reset emails)

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

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google Sign-In for React Native](https://github.com/react-native-google-signin/google-signin)
- [Apple Sign-In for React Native](https://github.com/invertase/react-native-apple-authentication)

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
