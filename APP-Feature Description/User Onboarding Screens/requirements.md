# User Onboarding Screens - Functional Requirements

## 📋 Core Requirements

### 1. Onboarding Slides

#### Slide Presentation
- [x] Display 5 slides in sequence
- [x] Support swipe gestures for navigation (left/right)
- [x] Show pagination dots indicating current slide
- [x] Smooth fade transitions between slides (300ms)
- [x] Prevent navigation beyond slide boundaries
- [x] Support skip functionality to jump to last slide

#### Slide Content
- [x] **Slide 1: Welcome** - Display welcome message and description
- [x] **Slide 2: Klangwelten** - Display feature: Variety of sounds
- [x] **Slide 3: Wirksamkeit** - Display feature: Effectiveness
- [x] **Slide 4: Wachstum** - Display feature: Personal growth
- [x] **Slide 5: Category Selection** - Display choice interface

#### Visual Elements
- [x] Custom SVG icons for each slide (Welcome, Klangwelten, Wirksamkeit, Wachstum)
- [x] Animated background blobs with gradient effects
- [x] Icon containers with blur and gradient styling
- [x] Responsive layout for different screen sizes
- [x] Dark theme with white text for readability

### 2. Category Selection

#### Choice Interface
- [x] Display three category options:
  - Besser Schlafen (schlafen)
  - Weniger Stress (stress)
  - Mehr Flow (leichtigkeit)
- [x] Show category images from Unsplash
- [x] Display category labels and descriptions
- [x] Radio button selection interface
- [x] Visual feedback on selection (border, shadow, gradient)
- [x] Scale animation on selection (1.02x)
- [x] Audio wave visualization on choice slide

#### Selection Requirements
- [x] Require category selection before completion
- [x] Disable "Get Started" button until selection made
- [x] Save selection immediately when chosen
- [x] Persist selection in local storage
- [x] Sync selection to backend for authenticated users

### 3. Navigation and Routing

#### Entry Point (IndexScreen)
- [x] Display preloader for 3 seconds
- [x] Animated favicon with pulsating effect
- [x] AWAVE logo fade-in animation
- [x] Tagline display
- [x] Background ripple animations (3 concentric circles)
- [x] Check onboarding completion status
- [x] Route based on completion state:
  - Completed → Navigate to MainTabs
  - Profile exists but not completed → Navigate to slide 5 only
  - No profile → Navigate to full onboarding

#### Onboarding Completion
- [x] Navigate to MainTabs after completion
- [x] Pass selected category as initial tab parameter
- [x] Reset navigation stack to prevent back navigation
- [x] Handle navigation errors gracefully

### 4. State Management

#### Local Storage
- [x] Save onboarding completion flag (OnboardingStorageService)
- [x] Save onboarding profile data (JSON) (OnboardingStorageService)
- [x] Save selected category preference (OnboardingStorageService)
- [x] Load onboarding state on app start (OnboardingStorageService)
- [x] Clear onboarding flags (reset functionality) (OnboardingStorageService)
- [x] Reset to questionnaire only (keep profile, remove completion) (OnboardingStorageService)

#### Backend Sync
- [x] Sync onboarding data for authenticated users (FirestoreUserRepository)
- [x] Update user profile with: (FirestoreUserRepository)
  - `onboarding_completed: true`
  - `onboarding_category_preference: selectedChoice`
  - `onboarding_data` object with steps and preferences
  - `metadata.primary_category`
  - `metadata.onboarding_completed_at`
- [x] Map category to session type:
  - `schlafen` → `sleep`
  - `stress` → `meditation`
  - `leichtigkeit` → `focus`
- [x] Non-blocking sync (continue on failure)
- [x] Guest mode support (skip backend sync)

### 5. Animations and Interactions

#### Slide Transitions
- [x] Fade out current slide (200ms)
- [x] Fade in next slide (300ms)
- [x] Smooth opacity transitions
- [x] Prevent rapid slide changes

#### Background Animations
- [x] Animated blobs with scale, opacity, and rotation
- [x] Continuous loop animations
- [x] Staggered delays for visual interest
- [x] Gradient color transitions

#### Wave Visualization
- [x] 60 wave bars with varying heights
- [x] Progressive left-to-right wave animation
- [x] 3x slower animation duration (4.5s cycle)
- [x] Gradient colors (primary to secondary)
- [x] Smooth height transitions

#### Choice Button Animations
- [x] Scale animation on selection (1.02x)
- [x] Border color change on selection
- [x] Shadow effects on selection
- [x] Gradient overlay on selected state
- [x] Radio button fill animation

### 6. Preloader Screen

#### Animation Sequence
- [x] Favicon fade-in (800ms)
- [x] Favicon pulsating animation (1.2x ↔ 0.8x, 1.5s cycle)
- [x] Logo fade-in with delay (300ms, 800ms duration)
- [x] Tagline fade-in with delay (500ms, 800ms duration)
- [x] Background circles ripple animation:
  - Circle 1: Scale 1→1.4→1, Opacity 0.3→0→0.3 (3s cycle)
  - Circle 2: Scale 1→1.3→1, Opacity 0.4→0→0.4 (2.5s cycle, 0.5s delay)
  - Circle 3: Scale 1→1.2→1, Opacity 0.5→0→0.5 (2s cycle, 1s delay)
- [x] Fade out animation (500ms)
- [x] Total display time: 3 seconds

#### Content
- [x] AWAVE favicon (80x80px)
- [x] AWAVE logo (200px width)
- [x] Tagline text ("Dein Soundtrack für innere Ruhe")
- [x] Centered layout
- [x] Dark background

---

## 🎯 User Stories

### As a first-time user, I want to:
- See a beautiful introduction to the app so I understand its value
- Learn about the app's features through visual slides
- Select my primary goal (sleep, stress, flow) so the app can personalize my experience
- Complete onboarding quickly without friction
- Skip slides if I want to go faster

### As a returning user, I want to:
- Skip onboarding and go directly to the app
- Have my previous preferences remembered
- Change my category preference if needed

### As a user experiencing issues, I want to:
- Still be able to use the app if backend sync fails
- Have my preferences saved locally even without network
- Reset onboarding if I want to see it again

---

## ✅ Acceptance Criteria

### Onboarding Flow
- [x] User can complete onboarding in < 60 seconds
- [x] All 5 slides display correctly with proper content
- [x] Swipe gestures work smoothly in both directions
- [x] Skip button jumps to category selection
- [x] Category selection is required before completion
- [x] Navigation to MainTabs happens automatically after completion

### State Management
- [x] Onboarding completion persists across app restarts
- [x] Category preference is saved immediately on selection
- [x] Backend sync completes for authenticated users
- [x] Guest users can complete onboarding without authentication
- [x] Reset functionality clears state correctly

### Visual Quality
- [x] Animations are smooth (60fps)
- [x] Transitions are not jarring
- [x] Icons render correctly on all slides
- [x] Wave visualization animates smoothly
- [x] Choice buttons provide clear visual feedback

### Preloader
- [x] Preloader displays for exactly 3 seconds
- [x] All animations complete before navigation
- [x] Favicon, logo, and tagline appear in sequence
- [x] Background circles animate continuously
- [x] Fade out is smooth

---

## 🚫 Non-Functional Requirements

### Performance
- Slide transitions complete in < 300ms
- Animations run at 60fps
- Preloader completes in 3 seconds
- State loading completes in < 100ms

### Usability
- Clear visual feedback for all interactions
- Intuitive swipe gestures
- Accessible touch targets (min 44x44px)
- Readable text with proper contrast

### Reliability
- Works offline (local storage primary)
- Backend sync doesn't block navigation
- Graceful error handling
- State recovery after app restart

### Accessibility
- Screen reader support for slide content
- Semantic labels for interactive elements
- Color contrast compliance
- Touch target size compliance

---

## 🔄 Edge Cases

### Navigation Edge Cases
- [x] Rapid slide changes (debounce protection)
- [x] Swipe during transition (ignore until complete)
- [x] Back navigation from MainTabs (prevent return to onboarding)
- [x] App restart during onboarding (resume from last state)

### State Edge Cases
- [x] Storage write failures (graceful degradation)
- [x] Backend sync failures (continue with local data)
- [x] Partial onboarding completion (handle incomplete state)
- [x] Multiple category selections (only last one counts)

### Network Edge Cases
- [x] Offline mode (local storage only)
- [x] Slow network (non-blocking sync)
- [x] Network timeout (continue with local data)
- [x] Backend unavailable (graceful fallback)

### User Interaction Edge Cases
- [x] Rapid button taps (prevent duplicate actions)
- [x] Swipe while button pressed (gesture priority)
- [x] Screen rotation during onboarding (layout adaptation)
- [x] App backgrounding during onboarding (state preservation)

---

## 📊 Success Metrics

- Onboarding completion rate > 85%
- Average completion time < 60 seconds
- Category selection rate > 90%
- Backend sync success rate > 95%
- Animation frame rate > 55fps
- User satisfaction with onboarding experience > 4/5

---

## 🔧 Configuration

### Storage Keys
- `awaveOnboardingCompleted` - Completion flag
- `awaveOnboardingProfile` - Profile JSON data
- `awaveSelectedCategory` - Category preference

### Animation Timings
- Slide transition: 300ms
- Fade out: 200ms
- Fade in: 300ms
- Preloader duration: 3000ms
- Wave cycle: 4500ms

### Category Mappings
- `schlafen` → `sleep` session type
- `stress` → `meditation` session type
- `leichtigkeit` → `focus` session type

---

*For technical implementation details, see `technical-spec.md`*  
*For component structure, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flow diagrams, see `user-flows.md`*
