# Navigation System - Feature Documentation

**Feature Name:** Navigation & Routing  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Navigation system provides comprehensive routing and navigation capabilities for the AWAVE app. It implements a hierarchical navigation structure using React Navigation, supporting stack navigation, tab navigation, modal presentations, and deep linking. The system ensures seamless user experience with gesture-based navigation, route protection, and intelligent navigation state management.

### Description

The navigation system is built on React Navigation and provides:
- **Stack Navigation** - Hierarchical screen navigation with back button support
- **Tab Navigation** - Custom bottom tab bar with category and utility tabs
- **Modal Navigation** - Modal presentations for drawers and overlays
- **Deep Linking** - URL-based navigation for email verification and password reset
- **Route Protection** - Authentication-based route guards
- **Gesture Navigation** - Swipe-back gestures for iOS/Android
- **Navigation State Management** - Intelligent tab state and navigation history

### User Value

- **Intuitive Navigation** - Familiar navigation patterns matching web app
- **Seamless Transitions** - Smooth animations and gesture support
- **Context Preservation** - Maintains navigation state across app lifecycle
- **Deep Link Support** - Direct navigation from external links
- **Accessibility** - Screen reader support and keyboard navigation
- **Performance** - Optimized navigation with lazy loading

---

## 🎯 Core Features

### 1. Stack Navigation
- Root stack navigator with 20+ screens
- Initial route determination based on onboarding state
- Screen transitions with animations
- Back button handling
- Route parameter passing

### 2. Tab Navigation
- Custom bottom tab bar (replaces React Navigation tabs)
- 3 category tabs (Schlafen, Stress, Leichtigkeit)
- 2 utility tabs (Search, Profile)
- Active tab state management
- Tab switching with screen rendering

### 3. Modal & Drawer Navigation
- **SearchDrawer** - Bottom sheet search interface
- **SOSDrawer** - Full-height emergency resources drawer
- **Library Modal** - Half-screen library modal (formSheet on iOS)
- **Downsell Modal** - Subscription downsell modal
- Modal state management and transitions

### 4. Deep Linking
- Email verification link handling
- Password reset link handling
- URL scheme: `awave://`
- Token extraction from hash/query params
- Automatic navigation after deep link processing

### 5. Route Protection
- Authentication-based navigation guards
- Onboarding state checks
- Subscription access validation
- Automatic redirects for protected routes

### 6. Navigation State Management
- Tab state persistence
- Navigation history tracking
- Last active tab before modal/drawer
- Initial tab determination from onboarding

---

## 🏗️ Architecture

### Technology Stack
- **Navigation Library:** React Navigation v6
  - `@react-navigation/native` - Core navigation
  - `@react-navigation/stack` - Stack navigator
  - `@react-navigation/bottom-tabs` - Tab navigator (used for type definitions)
- **State Management:** React Context API + Local State
- **Deep Linking:** React Native Linking API

### Key Components
- `Navigation` - Main navigation container
- `MainNavigator` - Root stack navigator
- `TabNavigator` - Custom tab navigator component
- `CustomNavbar` - Bottom navigation bar
- `UnifiedHeader` - Consistent header component

---

## 📱 Navigation Structure

### Stack Routes (20+ screens)

1. **Index** (`/`) - Entry point with preloader
2. **OnboardingSlides** (`/onboarding-slides`) - 6-slide onboarding
3. **MainTabs** - Main app with tab navigation
4. **Auth** (`/auth`) - Login/signup screen
5. **Signup** (`/signup`) - User registration
6. **EmailVerification** (`/email-verification`) - Email verification
7. **Library** - Sound library
8. **Subscribe** (`/subscribe`) - Subscription plans
9. **Downsell** (`/downsell`) - Subscription downsell (modal)
10. **Stats** (`/stats`) - Analytics dashboard
11. **AccountSettings** (`/account-settings`) - Account management
12. **PrivacySettings** (`/profile/privacy-settings`) - Privacy settings
13. **Legal** (`/profile/legal`) - Legal information
14. **DataPrivacy** (`/profile/legal/data-privacy`) - Data privacy
15. **TermsAndConditions** (`/profile/legal/terms`) - Terms of service
16. **AppPrivacyPolicy** (`/profile/legal/privacy-policy`) - Privacy policy
17. **Support** (`/support`) - Support and help
18. **NotificationPreferences** (`/notification-preferences`) - Notification settings
19. **Klangwelten** - Category detail screen with parameters
20. **NotFound** (`*`) - 404 error page

### Tab Navigation

**Category Tabs:**
- `schlafen` - Sleep category screen
- `stress` - Stress category screen
- `leichtigkeit` - Lightness category screen

**Utility Tabs:**
- `search` - Opens SearchDrawer (modal)
- `profile` - Profile screen

---

## 🔄 Navigation Flows

### Primary Flows
1. **App Launch Flow** - Index → Onboarding/MainTabs
2. **Onboarding Flow** - Index → OnboardingSlides → MainTabs
3. **Authentication Flow** - Auth → EmailVerification → MainTabs
4. **Tab Navigation Flow** - Tab press → Screen switch
5. **Modal Flow** - Tab press → Modal/Drawer open

### Alternative Flows
- **Deep Link Flow** - External link → Parse → Navigate
- **Protected Route Flow** - Route access → Auth check → Redirect
- **Tab State Recovery** - App restart → Load saved tab → Resume

---

## 🔐 Route Protection

- Authentication checks before protected routes
- Onboarding completion validation
- Subscription access validation
- Automatic redirects to auth/subscribe screens
- Session-based route access

---

## 📊 Integration Points

### Related Features
- **Authentication** - Route protection and redirects
- **Onboarding** - Initial route determination
- **Subscription** - Access validation
- **Profile** - Tab navigation integration
- **Audio Player** - Navigation on access denial

### External Services
- React Navigation (navigation library)
- React Native Linking (deep links)
- AsyncStorage (navigation state persistence)

---

## 🧪 Testing Considerations

### Test Cases
- Stack navigation transitions
- Tab navigation switching
- Modal/drawer open/close
- Deep link handling
- Route protection
- Navigation state persistence
- Back button behavior
- Gesture navigation

### Edge Cases
- Deep link with invalid tokens
- Navigation during app backgrounding
- Tab state recovery after app restart
- Modal state during navigation
- Protected route access without auth

---

## 📚 Additional Resources

- [React Navigation Documentation](https://reactnavigation.org/)
- [React Native Linking API](https://reactnative.dev/docs/linking)
- [Deep Linking Guide](https://reactnavigation.org/docs/deep-linking/)

---

## 📝 Notes

- Custom tab navigator replaces React Navigation's bottom tabs
- Navigation state persists across app restarts
- Deep links use `awave://` URL scheme
- Modal presentations use native formSheet on iOS
- Gesture navigation enabled for stack screens
- Tab state loaded from onboarding storage on app launch

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
