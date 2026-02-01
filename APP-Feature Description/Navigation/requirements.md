# Navigation System - Functional Requirements

## 📋 Core Requirements

### 1. Stack Navigation

#### Root Stack Navigator
- [x] Navigation container wraps entire app
- [x] Stack navigator with 20+ screens
- [x] Initial route set to 'Index'
- [x] Header hidden by default (headerShown: false)
- [x] Gesture navigation enabled (swipe-back)
- [x] Horizontal gesture direction
- [x] Theme-based background colors
- [x] Screen transitions with animations

#### Route Definitions
- [ ] Type-safe route parameter definitions (RootStackParamList) (Not applicable - Swift uses NavigationStack, not React Navigation)
- [x] Route names match blueprint exactly (Implemented)
- [x] Optional route parameters supported (Implemented)
- [x] Route parameter validation (Implemented)
- [ ] TypeScript type checking for navigation (Not applicable - Swift uses Swift types)

#### Screen Registration
- [x] All screens registered in stack navigator
- [x] Screen components properly imported
- [x] Modal presentation for Downsell screen
- [x] Custom screen options per route
- [x] Route parameter passing to screens

### 2. Tab Navigation

#### Custom Tab Navigator
- [ ] Custom tab navigator replaces React Navigation bottom tabs (Not applicable - Swift uses TabView)
- [x] Tab state managed locally (MainTabView)
- [x] Initial tab determination from onboarding (OnboardingStorageService)
- [x] Tab persistence across app lifecycle (Implemented)
- [x] Tab switching with screen rendering (TabView)
- [x] Active tab state tracking (Implemented)

#### Category Tabs
- [x] 3 category tabs (schlafen, stress, leichtigkeit)
- [x] Category tabs dynamically built from CategoryContext
- [x] Tab labels from translations
- [x] Tab icons from category IDs
- [x] Tab press navigates to category screen
- [x] Active tab visual indication

#### Utility Tabs
- [x] Search tab opens SearchDrawer
- [x] Profile tab navigates to ProfileScreen
- [x] Tab press triggers modal/screen navigation
- [x] Tab state preserved during modal open

#### Tab State Management
- [x] Initial tab loaded from onboarding storage (OnboardingStorageService)
- [x] Initial tab can be passed as route parameter (Implemented)
- [x] Default tab fallback to 'schlafen' (Implemented)
- [x] Tab state updates on tab press (TabView)
- [x] Last active tab tracking before modal (Implemented)

### 3. Modal & Drawer Navigation

#### SearchDrawer
- [x] Opens as bottom sheet from search tab
- [x] Saves current active tab before opening
- [x] Closes and returns to last active tab
- [x] Supports SOS drawer overlay
- [x] Sound selection handling
- [x] Close button returns to last tab

#### SOSDrawer
- [x] Opens as full-height bottom sheet
- [x] Overlays SearchDrawer when triggered
- [x] Closes and returns to SearchDrawer
- [x] SOS config passed as parameter
- [x] Smooth transition animations

#### Library Modal
- [x] Opens as modal from library tab
- [x] Uses formSheet presentation on iOS
- [x] Slide animation on open/close
- [x] Close button functionality
- [x] Modal state management

#### Downsell Modal
- [x] Opens as modal from stack navigation
- [x] Modal presentation style
- [x] Gesture disabled (gestureEnabled: false)
- [x] Close functionality

### 4. Deep Linking

#### URL Scheme
- [x] App registers `awave://` URL scheme
- [x] Deep link handling on app launch
- [x] Deep link handling during app runtime
- [x] URL parsing and token extraction

#### Email Verification Links
- [x] Handles `awave://email-verification` URLs
- [x] Extracts access_token from URL
- [x] Extracts refresh_token from URL
- [x] Supports hash fragment tokens (#)
- [x] Supports query parameter tokens (?)
- [x] Creates session with tokens
- [x] Navigates after successful verification

#### Password Reset Links
- [x] Handles `awave://password-reset` URLs
- [x] Extracts tokens from URL
- [x] Creates session with tokens
- [x] Navigates to reset password screen
- [x] Handles expired/invalid links

#### Link Processing
- [x] Listens for incoming links
- [x] Checks initial URL on app launch
- [x] Parses URL parameters correctly
- [x] Error handling for invalid links
- [x] User-friendly error messages

### 5. Route Protection

#### Authentication Guards
- [x] Checks authentication state before protected routes
- [x] Redirects to Auth screen if not authenticated
- [x] Preserves intended destination
- [x] Handles session expiry

#### Onboarding Guards
- [x] Checks onboarding completion status
- [x] Redirects to onboarding if not completed
- [x] Preserves navigation state
- [x] Handles partial onboarding completion

#### Subscription Guards
- [x] Checks subscription access for premium features
- [x] Redirects to Subscribe screen if no access
- [x] Handles subscription expiry
- [x] Dev bypass for testing

### 6. Navigation State Management

#### Tab State
- [x] Active tab state stored in component
- [x] Tab state persists during modal open
- [x] Tab state recovery on app restart
- [x] Initial tab loaded from storage

#### Navigation History
- [x] Last active tab before search tracked (Implemented)
- [ ] Navigation stack maintained by React Navigation (Not applicable - Swift uses NavigationStack)
- [x] Back button functionality (NavigationStack)
- [x] Navigation history preserved (NavigationStack)

#### State Persistence
- [ ] Onboarding state loaded from AsyncStorage (Not applicable - uses OnboardingStorageService)
- [x] Category selection loaded from storage (OnboardingStorageService)
- [x] Navigation state recovery on app launch (Implemented)
- [x] State synchronization with backend (FirestoreUserRepository)

---

## 🎯 User Stories

### As a new user, I want to:
- Navigate through onboarding slides smoothly
- See clear navigation options after onboarding
- Access main features through bottom tabs
- Return to previous screens easily

### As an existing user, I want to:
- Resume where I left off when reopening the app
- Switch between categories quickly
- Access search and profile from anywhere
- Navigate back using gestures or buttons

### As a user accessing via link, I want to:
- Open the app directly to the intended screen
- Complete email verification seamlessly
- Reset my password without confusion
- See clear error messages if links are invalid

### As a user with limited access, I want to:
- Be redirected to subscription screen when needed
- Understand why I can't access certain features
- Complete authentication when required
- See clear navigation paths

---

## ✅ Acceptance Criteria

### Stack Navigation
- [x] All screens accessible via navigation
- [x] Back button works on all stack screens
- [x] Gesture navigation works on iOS/Android
- [x] Screen transitions are smooth (< 300ms)
- [x] Route parameters passed correctly

### Tab Navigation
- [x] Tabs switch instantly (< 100ms)
- [x] Active tab clearly indicated
- [x] Tab state persists across app lifecycle
- [x] Initial tab loaded correctly
- [x] Tab icons and labels display correctly

### Modal Navigation
- [x] Modals open with smooth animations
- [x] Modals close correctly
- [x] Modal state doesn't interfere with tabs
- [x] Backdrop dims appropriately
- [x] Modal gestures work (where enabled)

### Deep Linking
- [x] Deep links open app correctly
- [x] Tokens extracted from URLs
- [x] Navigation happens after link processing
- [x] Error handling for invalid links
- [x] Deep links work on app launch and runtime

### Route Protection
- [x] Protected routes redirect when needed
- [x] Authentication state checked correctly
- [x] Onboarding state validated
- [x] Subscription access verified
- [x] Redirects preserve user intent

### Navigation State
- [x] Tab state persists correctly
- [x] Navigation history maintained
- [x] State recovery works on app restart
- [x] State synchronization with storage
- [x] No state loss during navigation

---

## 🚫 Non-Functional Requirements

### Performance
- Navigation transitions complete in < 300ms
- Tab switching happens in < 100ms
- Deep link processing in < 500ms
- State loading in < 200ms

### Usability
- Intuitive navigation patterns
- Clear visual feedback for active states
- Consistent navigation behavior
- Accessible navigation (screen readers)

### Reliability
- Navigation state persists across app restarts
- Deep links work reliably
- Route protection works consistently
- No navigation state corruption

### Security
- Protected routes properly guarded
- Deep link tokens validated
- Navigation state doesn't expose sensitive data
- Route parameters sanitized

---

## 🔄 Edge Cases

### Deep Link Edge Cases
- [x] Invalid token format
- [x] Expired tokens
- [x] Missing tokens
- [x] Malformed URLs
- [x] App not running when link received

### Navigation Edge Cases
- [x] Navigation during app backgrounding
- [x] Navigation during modal open
- [x] Multiple rapid navigation actions
- [x] Navigation with invalid route parameters
- [x] Navigation stack overflow

### State Edge Cases
- [x] Tab state lost on app crash
- [x] Navigation state corruption
- [x] Stale state after app update
- [x] Concurrent state updates
- [x] State recovery failure

### Route Protection Edge Cases
- [x] Session expiry during navigation
- [x] Authentication state change during navigation
- [x] Subscription status change during navigation
- [x] Onboarding state inconsistency
- [x] Protected route access race conditions

---

## 📊 Success Metrics

- Navigation success rate > 99%
- Tab switching time < 100ms
- Deep link success rate > 95%
- Route protection accuracy > 99%
- Navigation state recovery rate > 98%
- User navigation error rate < 1%

---

## 🔧 Technical Constraints

### Platform Requirements
- iOS 13+ for gesture navigation
- Android API 21+ for deep linking
- React Navigation v6 compatibility
- React Native 0.76.9 compatibility

### Performance Constraints
- Navigation state size < 1MB
- Deep link processing timeout < 5s
- Tab state updates < 16ms (60fps)
- Navigation stack depth < 50 screens

### Security Constraints
- Deep link tokens validated before use
- Route parameters sanitized
- Navigation state encrypted in storage
- Protected routes require authentication

---

*For technical implementation details, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*
