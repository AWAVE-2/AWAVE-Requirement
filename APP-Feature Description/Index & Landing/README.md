# Index & Landing Screen - Feature Documentation

**Feature Name:** Index Screen & Landing Experience  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Index & Landing screen is the entry point of the AWAVE app, providing a branded preloader experience and intelligent routing logic that determines the user's next destination based on their onboarding state. It serves as the app's first impression and ensures users are directed to the appropriate screen based on their previous interactions.

### Description

The Index screen is the initial route (`/`) that users encounter when launching the app. It features:
- **Animated Preloader** - Branded loading experience with AWAVE logo, favicon, and tagline
- **Intelligent Routing** - Determines navigation based on onboarding completion status
- **State Management** - Checks local storage for onboarding state
- **Smooth Transitions** - Animated fade-in/fade-out effects matching the React web app

### User Value

- **Branded Experience** - Professional first impression with animated logo and tagline
- **Seamless Navigation** - Automatic routing based on user state (new vs. returning)
- **Fast Loading** - Optimized animations and state checks
- **Consistent UX** - Matches the web app experience for familiarity

---

## 🎯 Core Features

### 1. Animated Preloader
- Branded AWAVE favicon with pulsating animation
- AWAVE logo with fade-in animation
- Tagline display with translation support
- Three concentric ripple circles with synchronized animations
- 3-second display duration with fade-out transition

### 2. Intelligent Routing Logic
- **Completed Onboarding** → Navigate to MainTabs (home screen)
- **Profile Exists, Onboarding Incomplete** → Navigate to OnboardingSlides (slide 5 - questionnaire only)
- **First Time User** → Navigate to OnboardingSlides (full onboarding from start)
- **Error Handling** → Fallback to full onboarding

### 3. State Management
- Checks onboarding completion status from local storage
- Loads user profile data if available
- Handles storage errors gracefully
- Prevents black screen during navigation transitions

### 4. Visual Design
- Theme-aware styling using unified theme system
- Responsive layout with centered content
- Smooth animations using React Native Reanimated
- Background animations with concentric circles

---

## 🏗️ Architecture

### Technology Stack
- **React Native** - Core framework
- **React Native Reanimated** - Advanced animations
- **React Native Animated** - Basic animations
- **AsyncStorage** - Local state persistence
- **React Navigation** - Navigation routing

### Key Components
- `IndexScreen` - Main screen component
- `Preloader` - Animated preloader component (internal)
- `onboardingStorage` - Storage service for onboarding state

---

## 📱 Screens

1. **IndexScreen** (`/`) - Entry point with preloader and routing logic

---

## 🔄 User Flows

### Primary Flows
1. **First Launch** - Preloader → Full Onboarding
2. **Returning User (Completed)** - Preloader → MainTabs
3. **Returning User (Incomplete)** - Preloader → OnboardingSlides (Questionnaire)

### Alternative Flows
- **Storage Error** - Fallback to full onboarding
- **Navigation Error** - Loading state display

---

## 🎨 Visual Elements

### Preloader Components
- **Favicon** - 80x80px, pulsating scale animation (0.8 → 1.2 → 0.8)
- **Logo** - 200x60px AWAVE logo, fade-in with translate animation
- **Tagline** - Translated text, fade-in with translate animation
- **Ripple Circles** - Three concentric circles with scale and opacity animations

### Animation Timing
- **Favicon** - Immediate fade-in (800ms), continuous pulsation
- **Logo** - 300ms delay, fade-in (800ms)
- **Tagline** - 500ms delay, fade-in (800ms)
- **Preloader Duration** - 3 seconds total
- **Fade-out** - 500ms after 3 seconds
- **Navigation Delay** - 500ms after fade-out

---

## 📊 Integration Points

### Related Features
- **Onboarding** - Routes to OnboardingSlides based on state
- **Main Navigation** - Routes to MainTabs for completed users
- **Storage** - Uses onboardingStorage for state persistence

### External Services
- **CDN** - Loads favicon and logo from web CDN
- **Translation Service** - Uses LanguageContext for tagline

---

## 🧪 Testing Considerations

### Test Cases
- Preloader displays correctly on first launch
- Routing logic works for all user states
- Animations complete smoothly
- Storage errors handled gracefully
- Navigation transitions work correctly

### Edge Cases
- Network failure during CDN image loading
- Storage read errors
- Navigation failures
- App restart during preloader
- Low memory scenarios

---

## 📚 Additional Resources

- [React Native Reanimated Documentation](https://docs.swmansion.com/react-native-reanimated/)
- [React Navigation Documentation](https://reactnavigation.org/)

---

## 📝 Notes

- Preloader duration is fixed at 3 seconds (matching React web app)
- Images are loaded from CDN (no local assets)
- Onboarding state is checked asynchronously
- Navigation uses React Navigation stack navigator
- Theme system provides consistent styling
- Translation system supports multiple languages

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
