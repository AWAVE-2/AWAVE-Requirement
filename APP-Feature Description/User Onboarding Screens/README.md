# User Onboarding Screens - Feature Documentation

**Feature Name:** User Onboarding Screens  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The User Onboarding Screens feature provides a comprehensive first-time user experience that introduces the AWAVE app, explains its core benefits, and collects user preferences for personalized content delivery. The onboarding flow consists of 5 slides with smooth animations, swipe gestures, and a final category selection step.

### Description

The onboarding system guides new users through:
- **Welcome and introduction** - App purpose and value proposition
- **Feature highlights** - Core benefits (Klangwelten, Wirksamkeit, Wachstum)
- **Category selection** - Personalization based on user goals (Sleep, Stress, Flow)
- **State management** - Local storage with backend sync for authenticated users
- **Navigation integration** - Seamless routing to main app after completion

### User Value

- **Clear value proposition** - Users understand app benefits immediately
- **Personalization** - Category selection enables tailored content
- **Smooth experience** - Beautiful animations and intuitive navigation
- **Offline support** - Works without network connection
- **Flexible flow** - Supports full onboarding or questionnaire-only mode

---

## 🎯 Core Features

### 1. Onboarding Slides
- **5-slide presentation** with animated transitions
- **Swipe gestures** for navigation between slides
- **Skip functionality** to jump to category selection
- **Pagination indicators** showing current position
- **Fade animations** for smooth slide transitions

### 2. Slide Content
- **Slide 1: Welcome** - Introduction to AWAVE
- **Slide 2: Individuelle Klangwelten** - Feature: Variety of sounds
- **Slide 3: Spürbare Wirksamkeit** - Feature: Effectiveness
- **Slide 4: Inneres Wachstum** - Feature: Personal growth
- **Slide 5: Category Selection** - User preference collection

### 3. Category Selection
- **Three options:**
  - Besser Schlafen (Better Sleep) - `schlafen`
  - Weniger Stress (Less Stress) - `stress`
  - Mehr Flow (More Flow) - `leichtigkeit`
- **Visual selection** with images and descriptions
- **Radio button interface** with selection feedback
- **Audio wave visualization** on choice slide
- **Required selection** before completion

### 4. State Management
- **Local storage** - AsyncStorage for offline support
- **Backend sync** - Profile updates for authenticated users
- **State persistence** - Onboarding completion tracking
- **Profile creation** - User profile with category preference
- **Reset capability** - Ability to reset and redo onboarding

### 5. Navigation Integration
- **Preloader screen** - 3-second animated intro
- **Conditional routing** - Based on onboarding completion status
- **Direct navigation** - To MainTabs after completion
- **Initial tab selection** - Opens selected category tab
- **Questionnaire-only mode** - For users with existing profile

### 6. Visual Design
- **Animated background blobs** - Subtle gradient animations
- **Icon components** - Custom SVG icons for each slide
- **Linear gradients** - Modern gradient backgrounds
- **Blur effects** - Glassmorphism design elements
- **Wave visualization** - Audio wave bars on choice slide

---

## 🏗️ Architecture

### Technology Stack
- **React Native** - Core framework
- **React Native Reanimated** - Smooth animations
- **React Native Gesture Handler** - Swipe gestures
- **React Native Linear Gradient** - Gradient backgrounds
- **React Native Blur** - Blur effects
- **AsyncStorage** - Local state persistence
- **Supabase** - Backend profile sync

### Key Components
- `OnboardingSlidesScreen` - Main onboarding screen
- `IndexScreen` - Entry point with preloader
- `OnboardingIcons` - SVG icon components
- `onboardingStorage` - Storage service
- `Preloader` - Animated intro component

---

## 📱 Screens

1. **IndexScreen** (`/`) - App entry point with preloader
2. **OnboardingSlidesScreen** (`/onboarding-slides`) - Main onboarding flow

---

## 🔄 User Flows

### Primary Flows
1. **First-Time User Flow** - Preloader → Full Onboarding → Category Selection → Main App
2. **Returning User Flow** - Preloader → Main App (skip onboarding)
3. **Profile Exists Flow** - Preloader → Questionnaire Only → Main App
4. **Guest User Flow** - Onboarding → Local Storage Only → Main App

### Alternative Flows
- **Skip Onboarding** - Jump directly to category selection
- **Reset Onboarding** - Clear state and restart flow
- **Backend Sync** - Sync preferences when user authenticates

---

## 🎨 Visual Features

### Animations
- **Slide transitions** - Fade in/out animations (300ms)
- **Background blobs** - Continuous scale/opacity/rotation animations
- **Wave bars** - Progressive left-to-right wave animation
- **Choice buttons** - Scale animation on selection
- **Icon containers** - Blur and gradient effects

### Design Elements
- **Gradient backgrounds** - AWAVE brand colors
- **Glassmorphism** - Blur effects with transparency
- **Pagination dots** - Current slide indicator
- **Radio buttons** - Selection feedback
- **Custom icons** - SVG icons for each slide

---

## 📊 Integration Points

### Related Features
- **Authentication** - Sync onboarding data after signup
- **Category Screens** - Navigate to selected category
- **Profile** - Store onboarding preferences
- **Navigation** - Route protection and initial tab selection

### External Services
- Supabase (user profile updates)
- AsyncStorage (local persistence)
- Navigation system (routing)

---

## 🧪 Testing Considerations

### Test Cases
- First-time user onboarding flow
- Returning user skip flow
- Category selection and persistence
- Backend sync for authenticated users
- Offline functionality
- Reset onboarding functionality
- Swipe gesture navigation
- Skip button functionality

### Edge Cases
- Network connectivity issues during sync
- Storage failures
- Navigation state conflicts
- Partial onboarding completion
- Multiple rapid slide changes

---

## 📚 Additional Resources

- [React Native Reanimated Documentation](https://docs.swmansion.com/react-native-reanimated/)
- [React Native Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/)
- [AsyncStorage Documentation](https://react-native-async-storage.github.io/async-storage/)

---

## 📝 Notes

- Onboarding completion is stored locally and synced to backend
- Category selection is required before completing onboarding
- Users can reset onboarding from profile settings
- Guest users can complete onboarding without authentication
- Backend sync is non-blocking (continues on failure)
- Initial tab selection is passed to MainTabs navigation

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
