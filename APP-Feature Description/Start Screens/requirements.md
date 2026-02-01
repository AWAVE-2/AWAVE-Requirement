# Start Screens System - Functional Requirements

## 📋 Core Requirements

### 1. IndexScreen (Entry Point)

#### Preloader Display
- [x] Preloader displays on app launch
- [x] AWAVE favicon shown with pulsating animation
- [x] AWAVE logo displayed with fade-in animation
- [x] Tagline displayed with translation support
- [x] Three concentric ripple circles with synchronized animations
- [x] Preloader duration is exactly 3 seconds
- [x] Smooth fade-out transition after 3 seconds
- [x] Navigation delay of 500ms after fade-out

#### Routing Logic
- [x] Check onboarding completion status from storage (OnboardingStorageService)
- [x] Check user profile existence from storage (FirestoreUserRepository)
- [x] Route to MainTabs if onboarding completed (Implemented)
- [x] Route to OnboardingSlides (slide 5) if profile exists but onboarding incomplete (Implemented)
- [x] Route to OnboardingSlides (full) if first-time user (Implemented)
- [x] Fallback to full onboarding on error (Implemented)
- [x] Prevent black screen during navigation transitions (Implemented)

#### State Management
- [x] Load onboarding state asynchronously
- [x] Handle storage errors gracefully
- [x] Display loading state during navigation
- [x] Error logging for debugging

### 2. OnboardingSlidesScreen (Onboarding Flow)

#### Slide Structure
- [x] 5 slides total (Welcome, 3 Features, Choice)
- [x] Slide 1: Welcome message with icon
- [x] Slide 2: Individual Sound Worlds feature
- [x] Slide 3: Effectiveness feature
- [x] Slide 4: Inner Growth feature
- [x] Slide 5: Category preference selection

#### Navigation
- [x] Swipe left to go to next slide
- [x] Swipe right to go to previous slide
- [x] Next button advances to next slide
- [x] Skip button jumps to last slide
- [x] Pagination dots show current slide
- [x] Smooth fade transitions between slides
- [x] Prevent navigation past boundaries

#### Category Selection (Slide 5)
- [x] Three category options displayed:
  - Better Sleep (schlafen)
  - Less Stress (stress)
  - More Flow (leichtigkeit)
- [x] Each option shows image, label, and description
- [x] Visual selection feedback (border, shadow, gradient)
- [x] Radio button indicator for selected option
- [x] Wave visualization animation
- [x] Selection saved immediately on tap
- [x] Next button disabled until selection made
- [x] Button text changes based on selection state

#### Visual Design
- [x] Gradient background matching app theme
- [x] Icon containers with blur and gradient effects
- [x] Animated background blobs (optional)
- [x] Wave visualization on choice slide
- [x] Responsive layout for all screen sizes
- [x] Theme-aware styling

#### State Persistence
- [x] Save onboarding completion status (OnboardingStorageService)
- [x] Save user profile with category preference (OnboardingStorageService + FirestoreUserRepository)
- [x] Save selected category separately (OnboardingStorageService)
- [x] Sync to backend if user authenticated (FirestoreUserRepository)
- [x] Handle offline mode (local storage only) (OnboardingStorageService)
- [x] Error handling for storage failures (Implemented)

### 3. Onboarding Storage Service

#### Storage Operations
- [x] Save onboarding completion flag
- [x] Load onboarding completion status
- [x] Save onboarding profile data
- [x] Load onboarding profile data
- [x] Save selected category
- [x] Load selected category
- [x] Clear onboarding flags
- [x] Reset onboarding to questionnaire only

#### State Loading
- [x] Load onboarding state asynchronously
- [x] Return completion status and profile
- [x] Handle missing data gracefully
- [x] Error handling for storage operations

### 4. Backend Synchronization

#### Profile Sync
- [x] Sync onboarding completion to backend
- [x] Sync category preference to backend
- [x] Sync onboarding data structure to backend
- [x] Update user profile with onboarding metadata
- [x] Handle sync failures gracefully
- [x] Continue with local data if sync fails
- [x] Support guest mode (no sync)

#### Data Structure
- [x] Store steps_completed array
- [x] Store category_preference
- [x] Store completed_at timestamp
- [x] Store preferred_session_type
- [x] Store primary_category in metadata

---

## 🎯 User Stories

### As a new user, I want to:
- See a professional branded preloader when the app launches
- Be introduced to the app's features through onboarding
- Select my primary interest (Sleep, Stress, or Flow)
- Have my preferences saved automatically
- Skip onboarding if I'm in a hurry
- Complete onboarding even without internet connection

### As a returning user, I want to:
- Skip the preloader and go directly to the app
- Not see onboarding again if I completed it
- Be able to change my category preference if needed
- Have my preferences persist across app restarts

### As a user experiencing issues, I want to:
- Still be able to use the app if storage fails
- See clear error messages if something goes wrong
- Have my data sync when network is available

---

## ✅ Acceptance Criteria

### Preloader
- [x] Preloader displays for exactly 3 seconds
- [x] All animations complete smoothly
- [x] Navigation occurs within 500ms after fade-out
- [x] No black screen during transitions

### Routing
- [x] First-time users see full onboarding
- [x] Returning users with completed onboarding go to MainTabs
- [x] Users with profile but incomplete onboarding see questionnaire only
- [x] Errors fallback to full onboarding

### Onboarding Slides
- [x] All 5 slides display correctly
- [x] Swipe gestures work in both directions
- [x] Next/Skip buttons function correctly
- [x] Pagination dots update correctly
- [x] Category selection is required on last slide
- [x] Selection persists after navigation

### State Management
- [x] Onboarding state persists across app restarts
- [x] Category preference is saved immediately
- [x] Backend sync works for authenticated users
- [x] Offline mode works with local storage only

---

## 🚫 Non-Functional Requirements

### Performance
- Preloader completes in < 3.5 seconds total
- Slide transitions complete in < 300ms
- Storage operations complete in < 100ms
- Backend sync doesn't block navigation
- Animations run at 60fps

### Security
- No sensitive data in local storage
- Backend sync uses authenticated requests
- Storage keys follow naming convention
- Error messages don't expose sensitive data

### Usability
- Clear visual feedback for all interactions
- Intuitive navigation (swipe and buttons)
- Accessible touch targets (min 44x44)
- Readable text with proper contrast
- Smooth animations without jank

### Reliability
- Graceful error handling for all failures
- Offline support with local storage
- Backend sync retries on failure
- State recovery after app restart
- No data loss on errors

---

## 🔄 Edge Cases

### Network Issues
- [x] CDN image loading failures handled gracefully
- [x] Backend sync failures don't block navigation
- [x] Offline mode works with local storage
- [x] Network errors logged but don't crash app

### Storage Issues
- [x] Storage read errors handled gracefully
- [x] Storage write errors logged
- [x] Missing data defaults to first-time user
- [x] Corrupted data handled with fallback

### Navigation Issues
- [x] Navigation failures fallback to safe route
- [x] App restart during onboarding handled
- [x] Deep link conflicts resolved
- [x] Navigation stack properly managed

### User Interaction Issues
- [x] Rapid button taps handled (debouncing)
- [x] Swipe gestures don't conflict with scrolling
- [x] Category selection can be changed before completion
- [x] Skip functionality works from any slide

### State Management Issues
- [x] Concurrent storage operations handled
- [x] State corruption detected and handled
- [x] Partial data saved correctly
- [x] State recovery after errors

---

## 📊 Success Metrics

- Preloader completion rate: 100%
- Onboarding completion rate: > 80%
- Category selection rate: > 95%
- Average onboarding time: < 2 minutes
- Backend sync success rate: > 95%
- Storage operation success rate: > 99%
- User satisfaction with onboarding: > 4/5

---

## 🔄 State Transitions

### Onboarding State
```
No State → First Launch → Onboarding In Progress → Completed
   │            │                  │                    │
   │            │                  │                    └─> MainTabs
   │            │                  └─> Profile Exists → Questionnaire Only
   │            └─> Error → Full Onboarding
   └─> Error → Full Onboarding
```

### Category Selection State
```
No Selection → Selection Made → Saved Locally → Synced to Backend
     │              │                │                  │
     │              │                │                  └─> Complete
     │              │                └─> Offline → Complete (Local Only)
     │              └─> Changed → Update
     └─> Required for Completion
```

---

## 📝 Implementation Notes

- Preloader timing matches React web app exactly
- Onboarding slides match React web app content
- Storage keys use `awave*` prefix
- Backend sync is optional (local storage is primary)
- Guest mode supported (no authentication required)
- Translation keys follow `t.onboarding.*` pattern
- Icons are SVG components for scalability
- Animations use React Native Reanimated for performance
