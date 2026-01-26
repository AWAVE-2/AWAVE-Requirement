# Start Screens System - User Flows

## 🔄 Primary User Flows

### 1. First Launch Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen renders
       └─> Preloader displays
           ├─> Favicon fades in and pulsates
           ├─> Logo fades in (300ms delay)
           ├─> Tagline fades in (500ms delay)
           └─> Ripple circles animate

2. Preloader Completes (3 seconds)
   └─> Fade out animation (500ms)
       └─> Check onboarding state
           ├─> No state found → Continue
           └─> Load onboarding state
               └─> { completed: false, profile: null }
                   └─> Navigate to OnboardingSlides (full)

3. OnboardingSlidesScreen Loads
   └─> Display Slide 1 (Welcome)
       └─> Show icon, title, description
           └─> Display Next button and pagination dots

4. User Swipes Left or Taps Next
   └─> Fade out current slide (200ms)
       └─> Fade in next slide (300ms)
           └─> Display Slide 2 (Sound Worlds)

5. User Continues Through Slides
   └─> Slide 2 → Slide 3 → Slide 4
       └─> Each slide fades in/out smoothly

6. User Reaches Slide 5 (Choice Selection)
   └─> Display wave visualization
       └─> Show three category options
           ├─> Better Sleep
           ├─> Less Stress
           └─> More Flow
       └─> Next button disabled (gray)

7. User Selects Category
   └─> Visual feedback (border, shadow, gradient)
       └─> Save selection immediately
           ├─> onboardingStorage.setSelectedCategory()
           └─> Update UI (enable Next button)

8. User Taps "Get Started"
   └─> Save onboarding completion
       ├─> onboardingStorage.saveOnboardingCompleted()
       ├─> onboardingStorage.saveOnboardingProfile()
       └─> Check authentication
           ├─> Authenticated → Sync to backend
           │   └─> ProductionBackendService.updateUserProfile()
           └─> Not authenticated → Skip sync
       └─> Navigate to MainTabs
           └─> Pass selected category as initialTab
```

**Success Path:**
- User completes full onboarding
- Category selected and saved
- Navigation to MainTabs with selected category

**Error Paths:**
- Storage error → Continue with navigation
- Backend sync error → Continue with local data
- Navigation error → Fallback to MainTabs

---

### 2. Returning User (Completed Onboarding) Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen renders
       └─> Preloader displays
           └─> Same animations as first launch

2. Preloader Completes (3 seconds)
   └─> Fade out animation (500ms)
       └─> Check onboarding state
           └─> Load onboarding state
               └─> { completed: true, profile: {...} }
                   └─> Navigate directly to MainTabs
                       └─> Skip onboarding entirely
```

**Success Path:**
- Preloader shows briefly
- Direct navigation to MainTabs
- No onboarding interruption

**Error Paths:**
- Storage read error → Fallback to full onboarding
- Navigation error → Loading state display

---

### 3. Returning User (Incomplete Onboarding) Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen renders
       └─> Preloader displays

2. Preloader Completes (3 seconds)
   └─> Check onboarding state
       └─> Load onboarding state
           └─> { completed: false, profile: {...} }
               └─> Navigate to OnboardingSlides
                   └─> Start at Slide 5 (index 4)
                       └─> Show questionnaire only

3. OnboardingSlidesScreen Loads
   └─> Display Slide 5 (Choice Selection)
       └─> Load previous selection if exists
           └─> Pre-select category if available

4. User Selects/Changes Category
   └─> Save selection
       └─> Update UI

5. User Taps "Get Started"
   └─> Complete onboarding
       └─> Navigate to MainTabs
```

**Success Path:**
- User sees only questionnaire
- Can change previous selection
- Completes onboarding quickly

**Error Paths:**
- Profile missing → Show full onboarding
- Selection error → Continue with navigation

---

## 🔀 Alternative Flows

### Skip Onboarding Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User on Any Slide (1-4)
   └─> Taps "Skip" button
       └─> Jump to Slide 5 (Choice Selection)
           └─> Display category options
               └─> User must select to continue
```

**Use Cases:**
- User familiar with app
- User wants to skip feature introduction
- Quick onboarding completion

---

### Swipe Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Swipes Left
   └─> GestureDetector detects swipe
       └─> Check if swipe threshold met (>30px)
           ├─> Threshold not met → No action
           └─> Threshold met → Continue
               └─> Go to next slide
                   └─> Fade transition

2. User Swipes Right
   └─> GestureDetector detects swipe
       └─> Check if swipe threshold met (>30px)
           └─> Go to previous slide
               └─> Fade transition
```

**Features:**
- Intuitive gesture navigation
- Smooth transitions
- Threshold prevents accidental navigation

---

### Category Selection Change Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User on Slide 5
   └─> Category already selected
       └─> User taps different category
           └─> Deselect previous
               └─> Select new category
                   └─> Save immediately
                       └─> Update UI
```

**Features:**
- Can change selection before completion
- Immediate visual feedback
- Selection saved on change

---

### Backend Sync Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Onboarding Completed
   └─> Check authentication
       ├─> Not authenticated → Skip sync
       └─> Authenticated → Continue
           └─> Prepare onboarding data
               └─> Call ProductionBackendService.updateUserProfile()
                   ├─> Success → Log success
                   └─> Error → Log warning, continue
                       └─> Local data is primary
```

**Features:**
- Optional backend sync
- Local storage is primary
- Errors don't block navigation
- Retry on next authentication

---

## 🚨 Error Flows

### Storage Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Storage Operation
   └─> storageBridge.getItem/setItem()
       └─> Error occurs
           └─> Catch error
               ├─> Log error for debugging
               └─> Fallback to default state
                   └─> Continue with navigation
                       └─> User experience not blocked
```

**Error Handling:**
- Graceful degradation
- Default to first-time user
- Error logging
- User experience preserved

---

### Network Error Flow (Backend Sync)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Backend Sync
   └─> ProductionBackendService.updateUserProfile()
       └─> Network error occurs
           └─> Catch error
               ├─> Log warning
               └─> Continue with local data
                   └─> Navigation proceeds
                       └─> Sync will retry on next auth
```

**Error Handling:**
- Non-blocking errors
- Local data preserved
- Retry on next opportunity
- User experience not affected

---

### Navigation Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Navigation
   └─> navigation.navigate/reset()
       └─> Navigation error occurs
           └─> Catch error
               ├─> Log error
               └─> Fallback navigation
                   └─> Navigate to MainTabs (safe route)
```

**Error Handling:**
- Safe fallback route
- Error logging
- User can still use app
- Recovery on next launch

---

## 🔄 State Transitions

### Onboarding State Machine

```
Initial State
    │
    ├─> First Launch
    │   └─> No State
    │       └─> Onboarding In Progress
    │           └─> Category Selected
    │               └─> Completed
    │                   └─> MainTabs
    │
    ├─> Returning User (Completed)
    │   └─> Completed State
    │       └─> MainTabs (Direct)
    │
    └─> Returning User (Incomplete)
        └─> Profile Exists
            └─> Onboarding In Progress (Slide 5)
                └─> Category Selected
                    └─> Completed
                        └─> MainTabs
```

### Category Selection State

```
No Selection
    │
    └─> Selection Made
        ├─> Saved Locally
        │   └─> Synced to Backend (if authenticated)
        │       └─> Complete
        │
        └─> Selection Changed
            └─> New Selection Saved
                └─> Complete
```

### Slide Navigation State

```
Slide 1
    │
    ├─> Swipe Left / Next → Slide 2
    │   └─> Swipe Left / Next → Slide 3
    │       └─> Swipe Left / Next → Slide 4
    │           └─> Swipe Left / Next → Slide 5
    │               └─> Select Category → Complete
    │
    └─> Skip → Slide 5
        └─> Select Category → Complete
```

---

## 📊 Flow Diagrams

### Complete First Launch Journey

```
App Launch
    │
    └─> IndexScreen
        └─> Preloader (3 seconds)
            └─> Check State
                └─> No State Found
                    └─> OnboardingSlidesScreen
                        ├─> Slide 1: Welcome
                        │   └─> Next
                        ├─> Slide 2: Sound Worlds
                        │   └─> Next
                        ├─> Slide 3: Effectiveness
                        │   └─> Next
                        ├─> Slide 4: Growth
                        │   └─> Next
                        └─> Slide 5: Category Selection
                            ├─> Select Category
                            └─> Get Started
                                └─> MainTabs (with selected category)
```

### Returning User Journey

```
App Launch
    │
    └─> IndexScreen
        └─> Preloader (3 seconds)
            └─> Check State
                ├─> Completed → MainTabs (Direct)
                └─> Profile Exists → OnboardingSlidesScreen (Slide 5)
                    └─> Select/Change Category
                        └─> Get Started
                            └─> MainTabs
```

---

## 🎯 User Goals

### Goal: Quick Onboarding
- **Path:** Skip to last slide → Select category → Complete
- **Time:** < 30 seconds
- **Steps:** 3 taps

### Goal: Learn About App
- **Path:** Full onboarding → All slides → Select category → Complete
- **Time:** ~2 minutes
- **Steps:** 6-7 taps/swipes

### Goal: Change Preference
- **Path:** App launch → Questionnaire only → Change selection → Complete
- **Time:** < 20 seconds
- **Steps:** 2-3 taps

---

## 📝 Flow Notes

- Preloader always shows for 3 seconds (branding)
- Onboarding can be skipped to last slide
- Category selection is required to complete
- Backend sync is optional (local storage is primary)
- Errors don't block user experience
- State persists across app restarts
- Guest mode supported (no authentication required)

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
