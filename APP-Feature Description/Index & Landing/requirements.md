# Index & Landing Screen - Functional Requirements

## 📋 Core Requirements

### 1. Preloader Display

#### Visual Elements
- [x] Display AWAVE favicon (80x80px) from CDN
- [x] Display AWAVE logo (200x60px) from CDN
- [x] Display translated tagline text
- [x] Show three concentric ripple circles in background
- [x] All elements centered on screen
- [x] Theme-aware background color

#### Animations
- [x] Favicon fades in immediately (800ms duration)
- [x] Favicon pulsates continuously (scale: 0.8 → 1.2 → 0.8, 1500ms cycle)
- [x] Logo fades in after 300ms delay (800ms duration)
- [x] Logo translates up from 20px offset
- [x] Tagline fades in after 500ms delay (800ms duration)
- [x] Tagline translates up from 20px offset
- [x] Three ripple circles animate with different timings:
  - Circle 1: Scale 1 → 1.4 → 1, Opacity 0.3 → 0 → 0.3, 3s duration
  - Circle 2: Scale 1 → 1.3 → 1, Opacity 0.4 → 0 → 0.4, 2.5s duration, 0.5s delay
  - Circle 3: Scale 1 → 1.2 → 1, Opacity 0.5 → 0 → 0.5, 2s duration, 1s delay
- [x] Preloader displays for exactly 3 seconds
- [x] Fade-out animation (500ms) after 3 seconds
- [x] Navigation callback triggered 500ms after fade-out completes

#### Timing Requirements
- [x] Total preloader duration: 3 seconds
- [x] Fade-out duration: 500ms
- [x] Navigation delay: 500ms after fade-out
- [x] Total time to navigation: ~4 seconds

### 2. Routing Logic

#### State Checking
- [x] Load onboarding state from local storage asynchronously (OnboardingStorageService)
- [x] Check onboarding completion flag (OnboardingStorageService)
- [x] Check user profile existence (FirestoreUserRepository)
- [x] Handle storage read errors gracefully (Implemented)

#### Navigation Rules
- [x] **If onboarding completed:**
  - Navigate to `MainTabs` (home screen)
  - No parameters passed

- [x] **If profile exists but onboarding incomplete:**
  - Navigate to `OnboardingSlides`
  - Pass `startAtSlide: 4` parameter (slide 5, 0-based index)
  - Show only questionnaire slide

- [x] **If first-time user (no profile, no completion):**
  - Navigate to `OnboardingSlides`
  - No parameters (starts from slide 1)
  - Show full onboarding flow

- [x] **If storage error occurs:**
  - Log error to console
  - Fallback to full onboarding (navigate to `OnboardingSlides`)

#### Error Handling
- [x] Catch and log storage errors
- [x] Provide fallback navigation on errors
- [x] Prevent app crash on storage failures
- [x] Display loading state during navigation transition

### 3. State Management

#### Onboarding State
- [x] Read `awaveOnboardingCompleted` from storage (OnboardingStorageService)
- [x] Read `awaveOnboardingProfile` from storage (OnboardingStorageService)
- [x] Parse completion flag (string 'true' → boolean) (OnboardingStorageService)
- [x] Handle null/undefined values (Implemented)
- [ ] Use Promise.all for parallel reads (Not applicable - Swift uses async/await)

#### Storage Keys
- [x] `awaveOnboardingCompleted` - Boolean flag (OnboardingStorageService)
- [x] `awaveOnboardingProfile` - JSON string of profile data (OnboardingStorageService)

### 4. Visual Design

#### Layout
- [x] Full-screen container
- [x] Centered content (flexbox)
- [x] Theme-aware background color
- [x] Relative positioning for overlay elements

#### Styling
- [x] Use unified theme system
- [x] Responsive to theme changes
- [x] Consistent typography
- [x] Proper spacing and margins

#### Images
- [x] Favicon: 80x80px, contain resize mode
- [x] Logo: 200x60px, contain resize mode
- [x] Load images from CDN URLs
- [x] Handle image load failures gracefully

### 5. Loading States

#### Transition States
- [x] Show preloader initially
- [x] Hide preloader after completion
- [x] Show minimal loading view during navigation
- [x] Prevent black screen during transitions

#### Loading View
- [x] Full-screen container
- [x] Centered "Loading..." text
- [x] Theme-aware text color
- [x] Displayed only during navigation transition

---

## 🎯 User Stories

### As a new user, I want to:
- See a branded loading screen when I first open the app
- Be automatically directed to onboarding after the preloader
- Experience smooth animations that match the web app

### As a returning user, I want to:
- Skip the preloader quickly if I've completed onboarding
- Be taken directly to the main app if I'm already set up
- Resume onboarding if I didn't complete it previously

### As a user experiencing issues, I want to:
- Not see a black screen if something goes wrong
- Still be able to use the app even if storage fails
- Have clear visual feedback during loading

---

## ✅ Acceptance Criteria

### Preloader Display
- [x] Preloader shows for exactly 3 seconds
- [x] All animations complete smoothly
- [x] Images load from CDN successfully
- [x] Tagline displays in correct language
- [x] Ripple circles animate continuously

### Routing
- [x] New users go to full onboarding
- [x] Returning users (completed) go to MainTabs
- [x] Returning users (incomplete) go to questionnaire
- [x] Errors don't crash the app
- [x] Navigation completes within 1 second after preloader

### State Management
- [x] Storage reads complete in < 100ms
- [x] State checks happen asynchronously
- [x] Errors are caught and handled
- [x] Fallback navigation works correctly

### Visual Quality
- [x] No layout shifts during animations
- [x] Images maintain aspect ratio
- [x] Text is readable and properly sized
- [x] Animations are smooth (60fps)

---

## 🚫 Non-Functional Requirements

### Performance
- Preloader animations run at 60fps
- Storage reads complete in < 100ms
- Navigation transition completes in < 1 second
- Total time from app launch to next screen < 5 seconds

### Reliability
- App doesn't crash on storage errors
- Images load even with slow network
- Navigation always completes (with fallback)
- No memory leaks from animations

### Usability
- Smooth, professional animations
- Clear visual feedback during loading
- No jarring transitions
- Consistent with web app experience

### Accessibility
- Screen reader compatible
- High contrast for text
- Proper touch target sizes (if interactive elements added)

---

## 🔄 Edge Cases

### Network Issues
- [x] CDN images fail to load → Graceful degradation (show placeholder or skip)
- [x] Slow network → Images load progressively
- [x] No network → App still functions (uses cached images if available)

### Storage Issues
- [x] Storage read fails → Fallback to full onboarding
- [x] Storage returns null → Treated as first-time user
- [x] Storage returns invalid data → Fallback to full onboarding
- [x] Storage is slow → Loading state shown

### Navigation Issues
- [x] Navigation target doesn't exist → Error logged, fallback navigation
- [x] Navigation is slow → Loading state shown
- [x] Navigation fails → Error logged, retry or fallback

### Animation Issues
- [x] Animation library fails → Basic fade-in used
- [x] Low memory → Animations simplified
- [x] App backgrounded during animation → Resume correctly

### State Edge Cases
- [x] Onboarding completed but profile missing → Navigate to MainTabs
- [x] Profile exists but completion flag missing → Navigate to questionnaire
- [x] Both flags missing → Navigate to full onboarding
- [x] Both flags present → Navigate to MainTabs

---

## 📊 Success Metrics

- Preloader completion rate: 100% (always shows)
- Navigation success rate: > 99%
- Average time to next screen: < 5 seconds
- Animation frame rate: > 55fps
- Storage read success rate: > 99%
- User satisfaction with first impression: High

---

## 🔧 Configuration

### Timing Configuration
- Preloader duration: 3000ms (3 seconds)
- Fade-out duration: 500ms
- Navigation delay: 500ms
- Logo delay: 300ms
- Tagline delay: 500ms

### Animation Configuration
- Favicon pulsation: 1500ms cycle
- Circle 1 animation: 3000ms loop
- Circle 2 animation: 2500ms loop (500ms delay)
- Circle 3 animation: 2000ms loop (1000ms delay)

### Image URLs
- Favicon: `https://cdn.prod.website-files.com/660563701250a201ebbf40c1/660c33c36a776793b1a4c0c9_favicon.ico`
- Logo: `https://cdn.prod.website-files.com/660563701250a201ebbf40c1/66891047763b9604604c0a86_Awave.png`

### Storage Keys
- Completion: `awaveOnboardingCompleted`
- Profile: `awaveOnboardingProfile`

---

## 🧪 Testing Requirements

### Unit Tests
- [x] Preloader component renders correctly
- [x] Animations start and complete
- [x] Routing logic handles all states correctly
- [x] Storage reads work correctly
- [x] Error handling works

### Integration Tests
- [x] Full flow from app launch to next screen
- [x] Storage integration works
- [x] Navigation integration works
- [x] Theme integration works
- [x] Translation integration works

### E2E Tests
- [x] First-time user flow
- [x] Returning user (completed) flow
- [x] Returning user (incomplete) flow
- [x] Error scenarios
- [x] Network failure scenarios

---

*For technical implementation details, see `technical-spec.md`*  
*For component structure, see `components.md`*  
*For user flow diagrams, see `user-flows.md`*
