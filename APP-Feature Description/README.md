# AWAVE App Feature Documentation

This directory contains structured documentation for all features and functionalities of the AWAVE iOS (Swift/SwiftUI) application.

## 📁 Folder Structure

### Core User Flows

- **`Authentication/`** - User authentication and account management
  - Sign in / Sign up
  - Email verification
  - Password reset
  - OAuth (Google, Apple)
  - Session management

- **`Onboarding/`** - First-time user experience
  - 6-slide onboarding flow
  - Category selection
  - Feature introduction

- **`Index & Landing/`** - Entry point and landing screens
  - Index screen
  - Initial app state
  - Route handling

### Main Navigation & Content

- **`Navigation/`** - Navigation structure and routing
  - Tab navigator
  - Bottom navigation bar
  - Stack navigation
  - Route definitions

- **`Category Screens/`** - Main content category screens
  - Schlaf (Sleep) screen
  - Ruhe (Rest/Stress) screen
  - Im Fluss (Flow/Lightness) screen
  - Category-specific functionality

- **`Start Screens/`** - Home screen variations
  - Category carousel
  - Featured content
  - Quick access

### Audio Features

- **`Major Audioplayer/`** - Core audio playback functionality
  - Audio Wave Generation/
  - Multi Trackplayer Setup/
  - Player Funktionality/
  - Audio controls
  - Playback management
  - Multi-track mixing

- **`Klangwelten/`** - Sound world exploration
  - Category-based sound browsing
  - Sound carousel
  - Category navigation

- **`Library/`** - User's audio library
  - Saved sounds
  - Custom sounds
  - Favorites collection
  - Playlists

- **`Seach Drawer/`** - Search Drawer (sound discovery and search). *Note: folder name is "Seach Drawer"; feature is Search Drawer.*
  - Search functionality
  - Intelligent search
  - Search results
  - Sound filtering

- **`Background Audio/`** - Background playback support
  - Background audio handling
  - Lock screen controls
  - Audio session management

### User Features

- **`Profile View/`** - User profile and account
  - Profile information
  - User settings access
  - Account management

- **`Favorite Functionality/`** - Favorites management
  - Add/remove favorites
  - Favorites list
  - Favorite synchronization

- **`Stats & Analytics/`** - User statistics and insights
  - Meditation stats
  - Usage analytics
  - Health stats
  - Mood tracking
  - Most used sounds
  - Time period analysis

- **`Session Tracking/`** - Session management
  - Session recording
  - Session statistics
  - Session phases
  - Activity tracking

### Support & Emergency

- **`SOS Screen/`** - Crisis support resources
  - Emergency resources
  - Crisis support
  - SOS drawer functionality

- **`Support/`** - Help and support
  - Support screen
  - Help resources
  - Contact information

### Monetization

- **`Subscription & Payment/`** - Subscription management
  - Subscription plans
  - Payment processing
  - Trial management
  - Downsell screens
  - In-app purchases

### Settings & Preferences

- **`Settings/`** - App settings and preferences
  - Account settings
  - Privacy settings
  - Notification preferences
  - App configuration

- **`Legal & Privacy/`** - Legal documentation
  - Terms and conditions
  - Privacy policy
  - Data privacy
  - Legal information

### Technical Features

- **`Visual Effects/`** - Visual enhancements
  - Animations
  - Visual effects
  - UI enhancements
  - Transitions

- **`Notifications/`** - Push notifications
  - Notification service
  - Notification preferences
  - Notification handling

- **`Offline Support/`** - Offline functionality
  - Offline mode
  - Cached content
  - Sync management
  - Background downloads

### Parity backlog (Android baseline)

- **`Backlog-Parity-OLD-APP-and-Web/`** – Single backlog of features from OLD-APP (V.1) or Web App not yet in the current iOS app. The **current iOS app is the baseline for Android**; this folder lists candidate features to add for parity. Do not use the deprecated "missing migration from OLD-APP" or "missing migration from React APP (Lovalbe)" folders as primary reference.

## 📝 Documentation Template

Each feature folder should contain:

1. **`README.md`** - Feature overview and description
2. **`requirements.md`** - Functional requirements
3. **`technical-spec.md`** - Technical implementation details
4. **`user-flows.md`** - User interaction flows
5. **`components.md`** - Component inventory
6. **`services.md`** - Service dependencies
7. **`screenshots/`** - Visual references (optional)
8. **`test-cases.md`** - Test scenarios (optional)

## 🎯 Purpose

This structure enables:
- **Structured documentation** of all app features
- **Requirement gathering** and specification
- **Technical documentation** for developers
- **Feature parity tracking** and **Android baseline** (current iOS = baseline; Backlog-Parity for candidate features)
- **Testing documentation** and test case management
- **Onboarding** for new team members

## 🔄 Maintenance

- Keep documentation up-to-date with code changes
- Add screenshots for visual features
- Document edge cases and error handling
- Include API dependencies and integrations
- Note platform-specific implementations (iOS vs Android)

## 📊 Feature Status

Track feature completion status in each folder's README:
- ✅ Complete
- 🔵 In Progress
- ⚪ Planned
- 🐛 Known Issues

---

*Last Updated: 2026-02-16*
