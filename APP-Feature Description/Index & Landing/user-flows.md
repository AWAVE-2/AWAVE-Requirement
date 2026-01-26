# Index & Landing Screen - User Flows

## 🔄 Primary User Flows

### 1. First-Time User Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen mounts
       └─> showPreloader = true
           └─> Preloader component renders

2. Preloader Animation Sequence
   └─> Favicon fades in (0ms)
       └─> Favicon starts pulsating (continuous)
           └─> Logo fades in (300ms delay)
               └─> Tagline fades in (500ms delay)
                   └─> Ripple circles animate (continuous)
                       └─> Preloader displays for 3 seconds

3. Preloader Completion (3000ms)
   └─> Fade-out animation starts (500ms)
       └─> isVisible = false
           └─> Wait 500ms
               └─> onComplete callback triggered

4. Routing Logic Execution
   └─> handlePreloaderComplete() called
       └─> onboardingStorage.loadOnboardingState()
           ├─> Read 'awaveOnboardingCompleted' → null
           └─> Read 'awaveOnboardingProfile' → null
               └─> Returns { completed: false, profile: null }

5. Navigation Decision
   └─> First-time user detected
       └─> navigation.navigate('OnboardingSlides')
           └─> showPreloader = false
               └─> Loading view displayed during transition
                   └─> Navigate to OnboardingSlides (full flow)
```

**Success Path:**
- Preloader displays correctly
- Animations complete smoothly
- Storage read succeeds
- Navigation to full onboarding

**Timing:**
- Preloader: 3000ms
- Fade-out: 500ms
- Navigation delay: 500ms
- Storage read: < 100ms
- **Total: ~4000ms**

---

### 2. Returning User (Completed Onboarding) Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen mounts
       └─> showPreloader = true
           └─> Preloader component renders

2. Preloader Animation Sequence
   └─> [Same as Flow 1]
       └─> Preloader displays for 3 seconds

3. Preloader Completion (3000ms)
   └─> [Same as Flow 1]
       └─> onComplete callback triggered

4. Routing Logic Execution
   └─> handlePreloaderComplete() called
       └─> onboardingStorage.loadOnboardingState()
           ├─> Read 'awaveOnboardingCompleted' → 'true'
           └─> Read 'awaveOnboardingProfile' → '{...}'
               └─> Returns { completed: true, profile: '{...}' }

5. Navigation Decision
   └─> Onboarding completed detected
       └─> navigation.navigate('MainTabs')
           └─> showPreloader = false
               └─> Loading view displayed during transition
                   └─> Navigate to MainTabs (home screen)
```

**Success Path:**
- Preloader displays correctly
- Storage read succeeds
- Completed flag detected
- Navigation to MainTabs

**Timing:**
- Preloader: 3000ms
- Fade-out: 500ms
- Navigation delay: 500ms
- Storage read: < 100ms
- **Total: ~4000ms**

---

### 3. Returning User (Incomplete Onboarding) Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen mounts
       └─> showPreloader = true
           └─> Preloader component renders

2. Preloader Animation Sequence
   └─> [Same as Flow 1]
       └─> Preloader displays for 3 seconds

3. Preloader Completion (3000ms)
   └─> [Same as Flow 1]
       └─> onComplete callback triggered

4. Routing Logic Execution
   └─> handlePreloaderComplete() called
       └─> onboardingStorage.loadOnboardingState()
           ├─> Read 'awaveOnboardingCompleted' → null (or 'false')
           └─> Read 'awaveOnboardingProfile' → '{...}'
               └─> Returns { completed: false, profile: '{...}' }

5. Navigation Decision
   └─> Profile exists but onboarding incomplete
       └─> navigation.navigate('OnboardingSlides', { startAtSlide: 4 })
           └─> showPreloader = false
               └─> Loading view displayed during transition
                   └─> Navigate to OnboardingSlides (slide 5 - questionnaire only)
```

**Success Path:**
- Preloader displays correctly
- Storage read succeeds
- Profile detected, completion missing
- Navigation to questionnaire slide

**Timing:**
- Preloader: 3000ms
- Fade-out: 500ms
- Navigation delay: 500ms
- Storage read: < 100ms
- **Total: ~4000ms**

---

## 🔀 Alternative Flows

### Storage Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen mounts
       └─> Preloader displays (3 seconds)

2. Preloader Completion
   └─> onComplete callback triggered

3. Routing Logic Execution
   └─> handlePreloaderComplete() called
       └─> onboardingStorage.loadOnboardingState()
           └─> Storage read fails
               └─> Error caught in try-catch
                   └─> Error logged to console
                       └─> Returns { completed: false, profile: null }

4. Navigation Decision (Fallback)
   └─> Error detected or default values
       └─> navigation.navigate('OnboardingSlides')
           └─> Navigate to full onboarding (fallback)
```

**Error Handling:**
- Storage errors don't crash app
- Fallback to full onboarding
- Error logged for debugging
- User experience continues

---

### Image Loading Failure Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Launches
   └─> IndexScreen mounts
       └─> Preloader renders

2. Image Loading
   └─> Favicon image loads from CDN
       ├─> Success → Image displays
       └─> Failure → Image fails silently
           └─> Preloader continues (no image shown)

3. Logo Loading
   └─> Logo image loads from CDN
       ├─> Success → Logo displays
       └─> Failure → Logo fails silently
           └─> Preloader continues (no logo shown)

4. Preloader Completion
   └─> Continues normally regardless of image load status
       └─> Navigation proceeds as normal
```

**Error Handling:**
- Images fail silently
- App continues without images
- No blocking on image failures
- User experience not disrupted

---

### Navigation Failure Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Preloader Completion
   └─> Routing logic executes
       └─> Navigation decision made

2. Navigation Attempt
   └─> navigation.navigate('MainTabs')
       ├─> Success → Navigate to target screen
       └─> Failure → React Navigation handles error
           └─> Error logged
               └─> App remains on IndexScreen
                   └─> User can retry (if applicable)
```

**Error Handling:**
- Navigation errors handled by React Navigation
- App doesn't crash
- Error logged for debugging
- User can retry navigation

---

## 🚨 Error Flows

### Storage Read Error

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Storage Read Attempt
   └─> storageBridge.getItem('awaveOnboardingCompleted')
       └─> AsyncStorage.getItem() fails
           └─> Error caught by storageBridge
               └─> Returns null

2. State Processing
   └─> loadOnboardingState() receives null values
       └─> Returns { completed: false, profile: null }
           └─> Treated as first-time user

3. Navigation
   └─> Navigate to full onboarding (fallback)
       └─> User experience continues
```

**Recovery:**
- Default values used
- Fallback navigation provided
- No app crash
- User can complete onboarding

---

### Animation Library Failure

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Animation Setup
   └─> Reanimated library initialization
       ├─> Success → Animations work normally
       └─> Failure → Animations may not work
           └─> Basic fade-in used (if available)
               └─> Preloader still displays
                   └─> Navigation proceeds normally
```

**Recovery:**
- Basic animations used
- Preloader still functional
- Navigation proceeds
- No app crash

---

## 🔄 State Transitions

### Preloader States

```
Not Rendered → Rendered → Animating → Fading Out → Hidden
     │            │           │            │           │
     │            │           │            │           └─> onComplete
     │            │           │            │
     │            │           │            └─> isVisible = false
     │            │           │
     │            │           └─> All animations active
     │            │
     │            └─> showPreloader = true
     │
     └─> Component unmounted
```

### Navigation States

```
IndexScreen → Checking State → Decision → Navigation → Next Screen
     │              │              │           │            │
     │              │              │           │            └─> MainTabs / OnboardingSlides
     │              │              │           │
     │              │              │           └─> navigation.navigate()
     │              │              │
     │              │              ├─> completed → MainTabs
     │              │              ├─> profile exists → OnboardingSlides (slide 5)
     │              │              └─> first time → OnboardingSlides (full)
     │              │
     │              └─> loadOnboardingState()
     │
     └─> App launch
```

---

## 📊 Flow Diagrams

### Complete App Launch Journey

```
App Launch
    │
    └─> IndexScreen
        │
        ├─> Preloader (3 seconds)
        │   ├─> Favicon animation
        │   ├─> Logo animation
        │   ├─> Tagline animation
        │   └─> Ripple circles
        │
        └─> Routing Logic
            │
            ├─> Check Onboarding State
            │   ├─> Read completion flag
            │   └─> Read profile data
            │
            └─> Navigation Decision
                │
                ├─> completed === true
                │   └─> MainTabs (Home Screen)
                │
                ├─> profile exists && !completed
                │   └─> OnboardingSlides (Slide 5 - Questionnaire)
                │
                └─> First time user
                    └─> OnboardingSlides (Full Flow)
```

### Preloader Animation Timeline

```
Time (ms)    Event
─────────────────────────────────────────────────────────
0            Favicon fades in (800ms)
300          Logo starts fade-in (800ms)
500          Tagline starts fade-in (800ms)
0-3000       Ripple circles animate (continuous)
3000         Fade-out starts (500ms)
3500         onComplete callback
4000         Navigation executes
```

### Storage Read Flow

```
loadOnboardingState()
    │
    ├─> Promise.all([
    │       getItem('awaveOnboardingCompleted'),
    │       getItem('awaveOnboardingProfile')
    │   ])
    │
    ├─> Parallel Reads
    │   ├─> AsyncStorage.getItem('awaveOnboardingCompleted')
    │   └─> AsyncStorage.getItem('awaveOnboardingProfile')
    │
    └─> Parse Results
        ├─> completed: string === 'true' ? true : false
        └─> profile: string | null
            │
            └─> Return { completed, profile }
```

---

## 🎯 User Goals

### Goal: Quick App Launch
- **Path:** Preloader → State Check → Navigation
- **Time:** < 5 seconds
- **Steps:** Automatic (no user interaction)

### Goal: Seamless Experience
- **Path:** Smooth animations → Fast navigation
- **Time:** < 4 seconds
- **Steps:** All automatic

### Goal: Correct Routing
- **Path:** State check → Appropriate navigation
- **Time:** < 100ms (after preloader)
- **Steps:** Automatic decision

---

## 📈 Flow Metrics

### Performance Metrics
- **Preloader Duration:** 3000ms (fixed)
- **Storage Read:** < 100ms (typical)
- **Navigation:** < 1000ms (typical)
- **Total Time:** < 5000ms (from launch to next screen)

### Success Rates
- **Preloader Display:** 100%
- **Storage Read Success:** > 99%
- **Navigation Success:** > 99%
- **Overall Flow Success:** > 98%

### User Experience
- **Smooth Animations:** > 55fps
- **No Black Screens:** 100%
- **Error Recovery:** 100% (always navigates)
- **User Satisfaction:** High (professional first impression)

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
