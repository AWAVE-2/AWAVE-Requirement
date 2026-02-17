# Requirements Files Update Guide

## Overview

The requirements files were originally written for a React Native/TypeScript app using Supabase, but the **actual implementation is a native Swift app (SwiftUI, iOS 26.2) using Firebase**. This app is the **baseline (North Star) for the Android app**. This guide outlines what needs to be updated across all requirements files and points Android to the correct reference.

## Key Differences

### Technology Stack
- **Requirements say:** React Native, TypeScript, Supabase, AsyncStorage, React hooks
- **Actual implementation:** Swift, SwiftUI, Firebase (Firestore, Storage, Auth), UserDefaults, FileManager

### Architecture
- **Requirements say:** React hooks (useProductionAuth, useUserProfile, etc.), ProductionBackendService
- **Actual implementation:** Protocol-oriented architecture with repositories (AuthService, FirestoreUserRepository, etc.)

## What to Uncheck

### 1. React/TypeScript Specific Features
- All React hooks (useProductionAuth, useUserProfile, useSessionTracking, etc.)
- ProductionBackendService (TypeScript service)
- AsyncStorage (React Native storage)
- TypeScript-specific features

### 2. Supabase References
- Supabase client configuration
- Supabase database tables
- Supabase Storage
- Supabase Auth
- Supabase RLS (Row-Level Security)
- Supabase real-time subscriptions
- Supabase Edge Functions
- Supabase RPC functions

### 3. Features Not Implemented
- Offline queue service
- Search analytics
- SOS keyword detection
- Notification preferences (database)
- Real-time subscriptions
- Most analytics features
- Background download service
- Download progress tracking
- Session import/export
- Multi-phase sessions
- Frequency generation
- Noise generation
- Procedural sound generation

## What to Keep Checked

### Actually Implemented in Swift
- Firebase Auth (AuthService)
- Firestore repositories (FirestoreUserRepository, FirestoreSoundRepository, etc.)
- Firebase Storage (FirebaseStorageRepository)
- Session tracking (FirestoreSessionTracker)
- Favorites management (FirestoreFavoritesRepository)
- Custom mixes (FirestoreCustomMixRepository)
- Basic search (client-side filtering)
- Onboarding storage (OnboardingStorageService)
- StoreKit integration (StoreKitManager)
- Basic audio playback (AWAVEAudioEngine)

## Update Pattern

For each requirements file:

1. **Find React/TypeScript references:**
   - Search for: `use[A-Z]`, `ProductionBackendService`, `AsyncStorage`, `Supabase`
   - Uncheck all items referencing these

2. **Find Supabase references:**
   - Search for: `Supabase`, `RLS`, `RPC`, `Edge Function`
   - Replace with Firebase equivalents or uncheck

3. **Verify implementation:**
   - Check if feature exists in Swift codebase
   - If yes, keep checked and note Swift implementation
   - If no, uncheck

4. **Add Swift implementation notes:**
   - When unchecking TypeScript/React items, add Swift equivalent if it exists
   - Example: `- [ ] ProductionBackendService (TypeScript - not in Swift)`
   - Example: `- [x] FirestoreUserRepository (Swift implementation)`

## Files That Need Updates

### High Priority (Many incorrect checkboxes)
1. ✅ APIs and Business Logic/requirements.md - UPDATED
2. ✅ Databases/requirements.md - UPDATED
3. Databases/supabase/requirements.md - Needs full update
4. Session Based Asynch Download of Audiofiles/requirements.md - Many Supabase references
5. Seach Drawer/requirements.md - Supabase references
6. Library/requirements.md - Supabase references
7. Offline Support/requirements.md - AsyncStorage, Supabase references
8. Notifications/requirements.md - Supabase references
9. MiniPlayer Strip/requirements.md - Supabase references
10. Klangwelten/requirements.md - AsyncStorage references

### Medium Priority
- Settings/requirements.md
- Profile View/requirements.md
- Subscription & Payment/requirements.md
- Navigation/requirements.md
- Styles and UI/requirements.md

### Low Priority (Mostly correct)
- Authentication/requirements.md
- Background Audio/requirements.md
- Session Tracking/requirements.md
- Stats & Analytics/requirements.md

## Quick Reference: Swift Implementations

| Feature | Swift Implementation |
|---------|---------------------|
| Authentication | `AuthService` (Firebase Auth) |
| User Profile | `FirestoreUserRepository` |
| Sounds | `FirestoreSoundRepository` |
| Favorites | `FirestoreFavoritesRepository` |
| Sessions | `FirestoreSessionTracker` |
| Custom Mixes | `FirestoreCustomMixRepository` |
| Guided Sessions | `FirestoreGuidedSessionRepository` |
| Audio Storage | `FirebaseStorageRepository` |
| Audio Playback | `AWAVEAudioEngine` |
| Subscriptions | `StoreKitManager` |
| Onboarding | `OnboardingStorageService` |

## Notes

- The app uses **Firebase** (Firestore, Storage, Auth), not Supabase
- The app uses **Swift/SwiftUI** (iOS 26.2) with protocol-oriented architecture, not React/TypeScript
- The app uses **UserDefaults** and **FileManager** for local storage, not AsyncStorage
- **iOS is the baseline for Android:** see `docs/ANDROID-NORDSTERN.md` for feature list and tech mapping
- Many analytics and advanced features are not yet implemented (see Backlog-Parity)
- Real-time subscriptions are not implemented
- Offline queue is not implemented
