# Registration Flows – Functional Requirements

**Scope:** High-level flow requirements from app launch to main app (preloader, onboarding, optional auth, email verification).  
**Detail:** Sign-up/sign-in and onboarding screens are specified in [Authentication](../Authentication/requirements.md) and [User Onboarding Screens](../User%20Onboarding%20Screens/requirements.md). This document ties flows together and lists flow-level requirements.  
**Last updated:** 2026-02-16  

---

## 1. Launch and Preloader

| Requirement | Status | Notes |
|-------------|--------|------|
| Preloader shown on first paint | ✓ | RootView, PreloaderView |
| Preloader duration (e.g. 3 s) | ✓ | Start Screens requirements |
| After preloader: route by onboarding state | ✓ | `!appState.hasCompletedOnboarding` → OnboardingView else MainTabView |
| Auth loading state does not block preloader end | ✓ | Separate `appState.isLoading`; timeout continues as guest |

---

## 2. Onboarding Flow

| Requirement | Status | Notes |
|-------------|--------|------|
| Show onboarding when not completed | ✓ | User Onboarding Screens |
| Slides: welcome, features, category selection | ✓ | OnboardingSlide.allSlides, CategorySelectionView |
| Category options: Besser Schlafen, Weniger Stress, Mehr Flow | ✓ | OnboardingCategory: sleep, calm, flow |
| Require category selection before completion | ✓ | "Get Started" disabled until selection |
| Persist completion and category | ✓ | OnboardingStorageService, AppState |
| Navigate to Main Tabs after completion | ✓ | hasCompletedOnboarding = true → MainTabView |
| Initial tab reflects selected category | ✓ | TabSelectionService / MainTabView |
| Sync onboarding data for authenticated users | ✓ | FirestoreUserRepository (onboarding_completed, category, etc.) |
| Guest can complete without signing in | ✓ | hasCompletedOnboarding set; isGuestMode |

---

## 3. Authentication (Registration / Sign-In)

| Requirement | Status | Notes |
|-------------|--------|------|
| User can sign up with email/password | ✓ | AuthView, AuthService; see Authentication requirements |
| User can sign in with email/password | ✓ | Authentication requirements |
| User can sign in with Apple | ✓ | AppleSignInHelper, AuthViewModel |
| Password strength and validation | ✓ | PasswordValidator, AuthViewModel |
| Session creation and persistence | ✓ | Firebase Auth, AppState |
| Auth entry point (e.g. from Profile) | ✓ | ProfileAuthCard, AuthView |
| Email auth can be deprioritized | ✓ | Known issue PRD 07/08 |

---

## 4. Email Verification Flow

| Requirement | Status | Notes |
|-------------|--------|------|
| After sign-up: show email verification screen | ✓ | EmailVerificationView; sheet when needsEmailVerification |
| Verification email sent | ✓ | AuthService.sendEmailVerification |
| Resend with cooldown | ✓ | EmailVerificationView, 60 s cooldown |
| Deep link: open app from verification link | ✓ | RootView.onOpenURL, handleEmailVerificationDeepLink |
| Apply token and mark verified | ✓ | authService.applyEmailVerificationActionCode |
| Navigate away after success | ✓ | needsEmailVerification cleared, sheet dismissed |

---

## 5. Entry to Main App

| Requirement | Status | Notes |
|-------------|--------|------|
| Main tabs shown when onboarding completed | ✓ | MainTabView |
| Tabs: category tabs + Profile (e.g. Schlaf, Stress, Im Fluss, Profile) | ✓ | MainTabView |
| Email verification sheet when authenticated but unverified | ✓ | RootView sheet binding to needsEmailVerification |
| Guest and authenticated users both reach MainTabView | ✓ | No forced auth gate after onboarding |

---

## 6. Registration Flow Integration (Authentication §6)

| Requirement | Status | Notes |
|-------------|--------|------|
| Category preference saved during signup/onboarding | ✓ | OnboardingStorageService, sync to Firestore |
| Onboarding completion status tracked | ✓ | OnboardingStorageService.hasCompletedOnboarding |
| Trial subscription if plan selected | ✗ | Not implemented (Authentication requirements) |

---

## 7. References

| Document | Content |
|----------|---------|
| [Authentication/requirements.md](../Authentication/requirements.md) | Sign up, sign in, OAuth, email verification, session management |
| [User Onboarding Screens/requirements.md](../User%20Onboarding%20Screens/requirements.md) | Slides, category selection, preloader, state, backend sync |
| [Start Screens/requirements.md](../Start%20Screens/requirements.md) | Preloader content and timing |
| [Category Screens/requirements.md](../Category%20Screens/requirements.md) | Category tabs, initial tab from onboarding |
| [Navigation/requirements.md](../Navigation/requirements.md) | MainTabView, routing |
