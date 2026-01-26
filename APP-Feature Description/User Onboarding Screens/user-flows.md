# User Onboarding Screens - User Flows

## 🔄 Primary User Flows

### 1. First-Time User Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen loads
       └─> Show Preloader
           ├─> Display favicon (fade in, pulsate)
           ├─> Display logo (fade in after 300ms)
           ├─> Display tagline (fade in after 500ms)
           ├─> Animate background circles (ripple effect)
           └─> Wait 3 seconds
               └─> Fade out preloader
                   └─> Check onboarding state
                       ├─> No completion flag found
                       └─> Navigate to OnboardingSlidesScreen (slide 0)

2. Slide 1: Welcome
   └─> Display welcome slide
       ├─> Show WelcomeIcon
       ├─> Show title: "Schön, dass du hier bist!"
       ├─> Show description
       ├─> Show pagination dots (1/5 active)
       └─> Show "Weiter" button
           │
           └─> User swipes left or taps "Weiter"
               └─> Fade out slide (200ms)
                   └─> Fade in next slide (300ms)

3. Slide 2: Klangwelten
   └─> Display feature slide
       ├─> Show KlangweltenIcon
       ├─> Show title: "Individuelle Klangwelten."
       ├─> Show description
       ├─> Show pagination dots (2/5 active)
       └─> Show "Weiter" button and "Überspringen" button
           │
           └─> User swipes left or taps "Weiter"
               └─> Transition to slide 3

4. Slide 3: Wirksamkeit
   └─> Display feature slide
       ├─> Show WirksamkeitIcon
       ├─> Show title: "Spürbare Wirksamkeit."
       ├─> Show description
       ├─> Show pagination dots (3/5 active)
       └─> Show "Weiter" button and "Überspringen" button
           │
           └─> User swipes left or taps "Weiter"
               └─> Transition to slide 4

5. Slide 4: Wachstum
   └─> Display feature slide
       ├─> Show WachstumIcon
       ├─> Show title: "Inneres Wachstum."
       ├─> Show description
       ├─> Show pagination dots (4/5 active)
       └─> Show "Weiter" button and "Überspringen" button
           │
           └─> User swipes left or taps "Weiter"
               └─> Transition to slide 5

6. Slide 5: Category Selection
   └─> Display choice slide
       ├─> Show wave visualization (60 animated bars)
       ├─> Show title: "Schreib deinen Soundtrack."
       ├─> Show description: "Wie können wir dir helfen wieder zu dir selbst zu finden?"
       ├─> Show 3 category options:
       │   ├─> "Besser Schlafen" (schlafen)
       │   ├─> "Weniger Stress" (stress)
       │   └─> "Mehr Flow" (leichtigkeit)
       ├─> Show pagination dots (5/5 active)
       └─> Show "Wähle eine Option" button (disabled)
           │
           └─> User selects category
               └─> Save selection immediately
                   ├─> onboardingStorage.setSelectedCategory(choiceId)
                   ├─> Update button text to "Los geht's"
                   ├─> Enable "Los geht's" button
                   ├─> Animate selection (scale 1.02x)
                   ├─> Show border highlight
                   └─> Show shadow effect
                       │
                       └─> User taps "Los geht's"
                           └─> completeOnboarding()
                               ├─> Create user profile object
                               ├─> Save to local storage:
                               │   ├─> onboardingStorage.saveOnboardingCompleted()
                               │   ├─> onboardingStorage.saveOnboardingProfile(profile)
                               │   └─> onboardingStorage.setSelectedCategory(choice)
                               │
                               ├─> [If userId exists - authenticated user]
                               │   └─> Sync to backend:
                               │       └─> ProductionBackendService.updateUserProfile(userId, {
                               │           ├─> onboarding_completed: true
                               │           ├─> onboarding_category_preference: choice
                               │           ├─> onboarding_data: { ... }
                               │           └─> metadata: { ... }
                               │
                               └─> Navigate to MainTabs
                                   └─> Pass initialTab parameter
                                       └─> Open selected category tab
```

**Success Path:**
- User completes all 5 slides
- Selects a category
- Onboarding data saved locally
- Backend sync completes (if authenticated)
- Navigate to MainTabs with selected category

**Error Paths:**
- Storage failure → Log error, continue navigation
- Backend sync failure → Log warning, continue with local data
- Navigation error → Fallback to MainTabs

---

### 2. Returning User Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen loads
       └─> Show Preloader (3 seconds)
           └─> Check onboarding state
               └─> onboardingStorage.loadOnboardingState()
                   ├─> Get 'awaveOnboardingCompleted' → 'true'
                   └─> Return {completed: true, profile: '...'}
                       │
                       └─> Navigate directly to MainTabs
                           └─> Skip onboarding entirely
```

**Success Path:**
- Onboarding completed flag found
- Navigate directly to main app
- No onboarding screens shown

---

### 3. Profile Exists But Not Completed Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen loads
       └─> Show Preloader (3 seconds)
           └─> Check onboarding state
               └─> onboardingStorage.loadOnboardingState()
                   ├─> Get 'awaveOnboardingCompleted' → null
                   └─> Get 'awaveOnboardingProfile' → '{"primaryCategory":"schlafen",...}'
                       │
                       └─> Return {completed: false, profile: '...'}
                           │
                           └─> Navigate to OnboardingSlidesScreen
                               └─> Pass startAtSlide: 4 (slide 5, 0-based)
                                   │
                                   └─> Show only category selection slide
                                       └─> User can change preference
                                           └─> Complete onboarding
```

**Use Case:**
- User previously started onboarding but didn't complete
- Profile exists but completion flag missing
- Show only questionnaire (category selection)
- Allow user to complete or change preference

---

### 4. Guest User Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Complete Onboarding (No Authentication)
   └─> User selects category
       └─> completeOnboarding()
           ├─> Check userId
           │   └─> userId is undefined (guest mode)
           │
           ├─> Save to local storage:
           │   ├─> onboardingStorage.saveOnboardingCompleted()
           │   ├─> onboardingStorage.saveOnboardingProfile(profile)
           │   └─> onboardingStorage.setSelectedCategory(choice)
           │
           └─> Skip backend sync (no userId)
               └─> Navigate to MainTabs
                   └─> Use local storage only
```

**Success Path:**
- Guest user completes onboarding
- Data saved locally only
- No backend sync attempted
- Navigate to main app

---

## 🔀 Alternative Flows

### Skip Onboarding Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User on Slide 2, 3, or 4
   └─> Tap "Überspringen" button
       └─> skipToLastSlide()
           └─> setCurrentSlide(totalSlides - 1)
               └─> Jump directly to Slide 5 (Category Selection)
                   └─> User must select category to complete
```

**Use Case:**
- User wants to skip informational slides
- Jump directly to category selection
- Still requires category selection

---

### Swipe Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User swipes left (next slide)
   └─> GestureDetector detects pan gesture
       └─> Check translationX > threshold (30px)
           └─> If translationX < 0 (swipe left)
               └─> goToNextSlide()
                   ├─> Check if not on last slide
                   ├─> Fade out current slide (200ms)
                   └─> Fade in next slide (300ms)

2. User swipes right (previous slide)
   └─> GestureDetector detects pan gesture
       └─> Check translationX > threshold (30px)
           └─> If translationX > 0 (swipe right)
               └─> goToPrevSlide()
                   ├─> Check if not on first slide
                   ├─> Fade out current slide (200ms)
                   └─> Fade in previous slide (300ms)
```

**Gesture Details:**
- Threshold: 30px horizontal movement
- Active offset: [-10, 10] pixels
- Fail offset: [-10, 10] pixels vertical (prevents vertical swipes)

---

### Reset Onboarding Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User in Profile Settings
   └─> Tap "Onboarding zurücksetzen"
       └─> Show confirmation dialog
           └─> User confirms
               └─> onboardingStorage.clearOnboardingFlags()
                   ├─> Remove 'awaveOnboardingCompleted'
                   └─> Remove 'awaveOnboardingProfile'
                       └─> Restart app or navigate to onboarding
                           └─> Show full onboarding from start
```

**Use Case:**
- User wants to see onboarding again
- User wants to change category preference
- Testing/debugging purposes

---

### Reset to Questionnaire Only Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User wants to change category preference
   └─> onboardingStorage.resetOnboardingToQuestionnaire()
       ├─> Remove 'awaveOnboardingCompleted'
       └─> Keep 'awaveOnboardingProfile'
           └─> Next app launch
               └─> IndexScreen detects profile but no completion
                   └─> Navigate to slide 5 only
                       └─> User can change preference
```

**Use Case:**
- User wants to change category without full onboarding
- Keep existing profile data
- Show only questionnaire slide

---

## 🚨 Error Flows

### Storage Failure Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User completes onboarding
   └─> completeOnboarding()
       └─> Try to save to storage
           └─> Storage operation fails
               ├─> Log error to console
               └─> Continue with navigation
                   └─> Navigate to MainTabs anyway
                       └─> User can still use app
                           └─> Onboarding may show again on next launch
```

**Error Handling:**
- Non-blocking: Continue navigation
- Log errors for debugging
- User experience not interrupted

---

### Backend Sync Failure Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Authenticated user completes onboarding
   └─> completeOnboarding()
       ├─> Save to local storage (success)
       └─> Try to sync to backend
           └─> ProductionBackendService.updateUserProfile() fails
               ├─> Log warning to console
               ├─> Don't throw error
               └─> Continue with navigation
                   └─> Navigate to MainTabs
                       └─> Local data is primary source of truth
                           └─> Backend sync can retry later
```

**Error Handling:**
- Non-blocking: Don't prevent navigation
- Log warnings for monitoring
- Local storage is primary
- Backend sync is secondary

---

### Navigation Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User completes onboarding
   └─> completeOnboarding()
       └─> Try to navigate to MainTabs
           └─> Navigation fails
               ├─> Catch error
               ├─> Log error to console
               └─> Fallback navigation
                   └─> navigation.reset() with MainTabs
                       └─> Ensure user reaches main app
```

**Error Handling:**
- Try-catch around navigation
- Fallback navigation ensures user reaches app
- Log errors for debugging

---

## 🔄 State Transitions

### Onboarding State Machine

```
[Initial State]
    │
    ├─> No completion flag
    │   └─> [First-Time User]
    │       └─> Show full onboarding
    │           └─> Complete → [Completed State]
    │
    ├─> Completion flag = 'true'
    │   └─> [Completed State]
    │       └─> Navigate to MainTabs
    │
    └─> Profile exists, no completion flag
        └─> [Incomplete State]
            └─> Show questionnaire only
                └─> Complete → [Completed State]
```

### Slide Navigation State

```
[Slide 0] ←→ [Slide 1] ←→ [Slide 2] ←→ [Slide 3] ←→ [Slide 4]
                                                          │
                                                          ↓
                                                    [Category Selection]
                                                          │
                                                          ↓
                                                    [Selection Made]
                                                          │
                                                          ↓
                                                    [Complete Onboarding]
                                                          │
                                                          ↓
                                                    [MainTabs]
```

### Category Selection State

```
[No Selection]
    │
    └─> User selects category
        │
        └─> [Selection Made]
            ├─> Save to storage
            ├─> Update UI (enable button)
            └─> User taps "Get Started"
                │
                └─> [Completing]
                    ├─> Save completion flag
                    ├─> Save profile
                    ├─> Sync to backend (if authenticated)
                    └─> Navigate to MainTabs
```

---

## 📊 Flow Diagrams

### Complete Onboarding Journey

```
App Launch
    │
    └─> IndexScreen (Preloader)
        │
        ├─> [Completed] → MainTabs
        │
        ├─> [Profile Exists] → OnboardingSlides (slide 5)
        │   └─> Category Selection
        │       └─> Complete → MainTabs
        │
        └─> [First-Time] → OnboardingSlides (slide 0)
            │
            ├─> Slide 1: Welcome
            │   └─> Next
            │
            ├─> Slide 2: Klangwelten
            │   └─> Next or Skip
            │
            ├─> Slide 3: Wirksamkeit
            │   └─> Next or Skip
            │
            ├─> Slide 4: Wachstum
            │   └─> Next or Skip
            │
            └─> Slide 5: Category Selection
                └─> Select Category
                    └─> Get Started
                        └─> Complete Onboarding
                            ├─> Save Locally
                            ├─> Sync Backend (if authenticated)
                            └─> MainTabs (selected category)
```

---

## 🎯 User Goals

### Goal: Quick Onboarding
- **Path:** Skip to category selection
- **Time:** < 15 seconds
- **Steps:** Skip → Select → Complete

### Goal: Learn About App
- **Path:** Full onboarding flow
- **Time:** ~60 seconds
- **Steps:** All 5 slides → Select → Complete

### Goal: Change Preference
- **Path:** Questionnaire only
- **Time:** < 10 seconds
- **Steps:** Select new category → Complete

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
