# Registration Flows – Feature Overview

**Feature:** End-to-end flows from app launch through preloader, onboarding, optional authentication, and email verification into the main app.  
**Status:** Implemented in Swift. Email auth can be deprioritized (see PRD 07).  
**Last updated:** 2026-02-16  

---

## Purpose

Registration Flows cover:

1. **Launch → Preloader** – Splash/preloader (e.g. 3 s), then routing based on onboarding state.
2. **Onboarding** – Slides (welcome, features, category selection); completion stored locally and synced for authenticated users.
3. **Authentication** – Optional sign-in/sign-up (email/password, Apple); can be reached from Profile or before/after onboarding depending on product.
4. **Email verification** – Post sign-up verification screen, deep link handling, resend.
5. **Entry to main app** – MainTabView with category-based initial tab; guest vs authenticated.

This folder does **not** replace the detailed requirements in **Authentication** or **User Onboarding Screens**; it provides a single place for flow-level requirements and cross-references.

---

## Flow Summary (Swift)

| Step | Implementation | Reference |
|------|----------------|------------|
| App launch | RootView, PreloaderView | Start Screens |
| Preloader end | `showPreloader = false` | Start Screens |
| Onboarding check | `appState.hasCompletedOnboarding` | User Onboarding Screens |
| Onboarding UI | OnboardingView, OnboardingViewModel, CategorySelectionView | User Onboarding Screens |
| Category selection | OnboardingCategory (sleep, calm, flow); stored via OnboardingStorageService | User Onboarding Screens, Category Screens |
| Completion | OnboardingStorageService, AppState; sync for authenticated users | Authentication requirements §6 |
| Auth entry | AuthView from Profile (e.g. ProfileAuthCard) or post-onboarding if required | Authentication |
| Email verification | EmailVerificationView, deep link `onOpenURL`, applyEmailVerificationActionCode | Authentication requirements §3 |
| Main app | MainTabView; initial tab from selected category | Navigation, Category Screens |
| Guest path | `appState.isGuestMode`; no auth required to use app | Authentication, User Onboarding |

---

## Documentation in This Folder

| Document | Content |
|----------|---------|
| **README.md** | This overview. |
| **requirements.md** | Flow-level requirements and references to Authentication and User Onboarding. |

---

## Related Feature Folders

| Feature | Folder | Content |
|---------|--------|---------|
| Authentication | [../Authentication/](../Authentication/) | Sign up, sign in, email verification, session management |
| User Onboarding Screens | [../User Onboarding Screens/](../User%20Onboarding%20Screens/) | Slides, category selection, preloader, state persistence |
| Start Screens | [../Start Screens/](../Start%20Screens/) | Preloader, launch |
| Profile View | [../Profile View/](../Profile%20View/) | Entry to Auth (e.g. sign in / account) |
| Navigation | [../Navigation/](../Navigation/) | MainTabView, tab order |

---

## Cross-Check

For a cross-check of registration flows and session generation against the codebase and requirements, see:

- [../../SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md](../../SESSION-GENERATION-AND-REGISTRATION-CROSSCHECK.md)
