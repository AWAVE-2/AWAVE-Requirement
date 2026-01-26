# Start Screens System - Feature Documentation

**Feature Name:** Start Screens & Onboarding Flow  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Start Screens system provides the initial user experience when launching the AWAVE app. It includes an animated preloader, intelligent routing logic, and a comprehensive onboarding flow that introduces users to the app's features and collects their preferences. The system ensures a smooth first-time experience while respecting returning users' previous interactions.

### Description

The Start Screens system consists of two main components:
- **IndexScreen** - Entry point with branded preloader and intelligent routing
- **OnboardingSlidesScreen** - Multi-slide onboarding experience with feature introduction and preference selection

The system provides:
- **Branded preloader** with animated AWAVE logo and tagline
- **Intelligent routing** based on user onboarding state
- **5-slide onboarding flow** introducing app features
- **Category preference selection** (Sleep, Stress, Flow)
- **State persistence** for offline support and backend sync
- **Smooth animations** and transitions matching the React web app

### User Value

- **Professional first impression** - Branded preloader creates polished experience
- **Guided introduction** - Onboarding explains app value and features
- **Personalized experience** - Category selection customizes initial content
- **Seamless transitions** - Smooth animations and state management
- **Offline support** - Local storage ensures functionality without network
- **Returning user respect** - Skips onboarding for users who completed it

---

## 🎯 Core Features

### 1. IndexScreen (Entry Point)
- Animated preloader with AWAVE branding
- Intelligent routing based on onboarding state
- State management and error handling
- Smooth navigation transitions

### 2. OnboardingSlidesScreen (Onboarding Flow)
- **5 slides total:**
  - Slide 1: Welcome message
  - Slide 2: Individual Sound Worlds feature
  - Slide 3: Effectiveness feature
  - Slide 4: Inner Growth feature
  - Slide 5: Category preference selection
- Swipe gesture navigation
- Skip functionality
- Category selection with visual feedback
- Backend synchronization for authenticated users

### 3. State Management
- Local storage persistence
- Backend synchronization
- Onboarding completion tracking
- Category preference storage
- Profile data management

### 4. Visual Design
- Animated background blobs
- Wave visualization on choice slide
- Icon-based feature presentation
- Gradient backgrounds
- Blur effects and shadows
- Responsive layout

---

## 🏗️ Architecture

### Technology Stack
- **React Native** - Core framework
- **React Native Reanimated** - Advanced animations
- **React Native Animated** - Basic animations
- **React Native Gesture Handler** - Swipe gestures
- **React Native Linear Gradient** - Gradient backgrounds
- **React Native Blur** - Blur effects
- **AsyncStorage** - Local persistence
- **React Navigation** - Navigation routing

### Key Components
- `IndexScreen` - Entry point screen
- `OnboardingSlidesScreen` - Onboarding flow screen
- `Preloader` - Animated preloader component
- `onboardingStorage` - Storage service
- `OnboardingIcons` - SVG icon components

---

## 📱 Screens

1. **IndexScreen** (`/`) - Entry point with preloader and routing
2. **OnboardingSlidesScreen** (`/onboarding-slides`) - Multi-slide onboarding experience

---

## 🔄 User Flows

### Primary Flows
1. **First Launch** - Preloader → Full Onboarding → MainTabs
2. **Returning User (Completed)** - Preloader → MainTabs
3. **Returning User (Incomplete)** - Preloader → OnboardingSlides (Questionnaire only)

### Alternative Flows
- **Skip Onboarding** - Jump to last slide (category selection)
- **Storage Error** - Fallback to full onboarding
- **Backend Sync Failure** - Continue with local data

---

## 🎨 Visual Elements

### Preloader
- Favicon with pulsating animation
- AWAVE logo with fade-in
- Tagline with translation support
- Three concentric ripple circles

### Onboarding Slides
- Icon-based feature slides
- Wave visualization on choice slide
- Category selection buttons with images
- Pagination dots
- Next/Skip buttons

---

## 📊 Integration Points

### Related Features
- **Authentication** - Syncs onboarding data after signup
- **Main Navigation** - Routes to MainTabs with selected category
- **Category System** - Uses selected category for initial content
- **Profile** - Stores onboarding preferences in user profile

### External Services
- **CDN** - Loads images and assets
- **Backend API** - Syncs onboarding data for authenticated users
- **Translation Service** - Multi-language support

---

## 🧪 Testing Considerations

### Test Cases
- Preloader displays and animates correctly
- Routing logic for all user states
- Onboarding slides navigation (swipe and buttons)
- Category selection and persistence
- Backend synchronization
- Offline functionality
- Error handling

### Edge Cases
- Network failure during CDN loading
- Storage read/write errors
- Navigation failures
- App restart during onboarding
- Low memory scenarios
- Backend sync failures

---

## 📚 Additional Resources

- [React Native Reanimated Documentation](https://docs.swmansion.com/react-native-reanimated/)
- [React Navigation Documentation](https://reactnavigation.org/)
- [React Native Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/)

---

## 📝 Notes

- Preloader duration is fixed at 3 seconds (matching React web app)
- Onboarding can be skipped to last slide
- Category selection is required to complete onboarding
- Backend sync is optional (local storage is primary)
- Supports guest mode (no authentication required)
- Translation keys follow `t.onboarding.*` pattern

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
