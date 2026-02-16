# Category Screens - Feature Documentation

**Feature Name:** Category Screens & Content Browsing  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Category Screens feature provides dedicated screens for browsing and interacting with audio content organized by three main categories: Sleep (Schlafen), Stress (Ruhe), and Flow (Im Fluss). Each category screen displays category-specific sounds, favorites, custom sounds, and provides navigation to related features like Klangwelten (Sound Worlds) and the audio player.

### Description

The Category Screens system consists of:
- **Three dedicated category screens** (SchlafScreen, RuheScreen, ImFlussScreen)
- **Reusable base component** (CategoryScreenBase) for shared functionality
- **Category context management** for state and data synchronization
- **Category service** for backend data fetching
- **Hero header component** with category-specific branding
- **Sound grid** for displaying sounds in a visually appealing layout
- **Integration with audio player**, favorites, custom sounds, and navigation

### User Value

- **Organized content** - Clear categorization makes it easy to find relevant audio content
- **Personalized experience** - Category selection during onboarding customizes the initial view
- **Quick access** - Direct navigation to category screens via bottom navigation
- **Rich content** - Each category displays sounds, favorites, and custom sounds
- **Seamless playback** - Direct integration with audio player for instant playback
- **Visual consistency** - Category-specific theming and branding

---

## 🎯 Core Features

### 1. Category Screens
- **SchlafScreen** - Sleep category with meditation, dream journeys, theta waves, white noise
- **RuheScreen** - Stress/rest category with relaxation exercises, breathing techniques, calming sounds
- **ImFlussScreen** - Flow/lightness category with motivating sounds, energy sounds, focus audio

### 2. Category Content Display
- Category hero header with icon, headline, and description
- Category-specific gradient theming
- Sound grid with airplane window design
- Custom sounds integration
- Favorites display and management

### 3. Category Navigation
- Bottom tab navigation between categories
- Category selection persistence
- Onboarding integration for initial category
- Navigation to Klangwelten (Sound Worlds)
- Navigation to audio player

### 4. Sound Interaction
- Sound selection and playback
- Add to mix functionality
- Favorite sounds management
- Custom sounds support
- "Weitere Sessions" (More Sessions) button
- "Eigene Klangwelt" (Own Sound World) creation

### 5. Category Data Management
- Backend category fetching via Firestore (FirestoreSoundRepository)
- Fallback to local category data where applicable
- Category ordering and persistence (OnboardingStorageService)
- Sound metadata integration (Firestore `sounds` collection)
- Category content configuration

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Firestore (sounds collection, FirestoreSoundRepository)
- **State Management:** SwiftUI, @Observable (ViewModels)
- **Navigation:** TabView with category tabs
- **Data Layer:** FirestoreSoundRepository for backend integration
- **UI Components:** Category screens (SchlafScreen, StressScreen, ImFlussScreen)

### Key Components
- `CategoryScreenBase` - Reusable base component for all category screens
- `CategoryHeroHeader` - Category-specific header with branding
- `SoundGrid` - Grid layout for displaying sounds
- `CategoryContext` - Global category state management
- `CategoryService` - Backend data fetching service

---

## 📱 Screens

1. **SchlafScreen** (`/schlafen`) - Sleep category screen
2. **RuheScreen** (`/stress`) - Stress/rest category screen
3. **ImFlussScreen** (`/leichtigkeit`) - Flow/lightness category screen

---

## 🔄 User Flows

### Primary Flows
1. **Category Selection** - Onboarding → Category Selection → Category Screen
2. **Category Navigation** - Bottom Tab → Category Screen → Content Display
3. **Sound Playback** - Sound Selection → Audio Player → Playback
4. **Klangwelten Navigation** - Category Screen → Klangwelten → Sound World Creation

### Alternative Flows
- **Category Persistence** - App Restart → Load Saved Category → Display
- **Sound Mixing** - Sound Selection → Add to Mix → Multi-track Playback
- **Custom Sounds** - Category Screen → Add Sound → Custom Sound Creation

---

## 🎨 Visual Design

### Category Theming
- **Schlafen (Sleep):** Purple gradient (`#7D5BA6` to `#A78BCD`), Sparkles icon
- **Stress (Rest):** Blue gradient (`#4E7A8A` to `#6B9BAD`), Activity icon
- **Leichtigkeit (Flow):** Emerald gradient, Sparkles icon

### Sound Card Design
- Airplane window design with image
- Gradient backgrounds
- Category-specific color schemes
- Smooth animations and transitions

---

## 📊 Integration Points

### Related Features
- **Onboarding** - Category selection during registration
- **Audio Player** - Direct sound playback integration
- **Favorites** - Favorite sounds management
- **Custom Sounds** - User-created sounds
- **Klangwelten** - Sound world creation and exploration
- **Navigation** - Tab navigation and routing
- **Search** - Sound search and discovery

### External Services
- Firebase / Firestore (category and sound metadata)
- Audio playback services (AWAVEAudio, Firebase Storage for files)
- Firestore (favorites, custom mixes)

---

## 🧪 Testing Considerations

### Test Cases
- Category screen rendering
- Category navigation
- Sound selection and playback
- Favorites management
- Custom sounds display
- Klangwelten navigation
- Category persistence
- Backend data fetching and fallback

### Edge Cases
- Network connectivity issues
- Empty category data
- Missing sound metadata
- Category selection persistence
- Navigation state management

---

## 📚 Additional Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [SwiftUI Navigation](https://developer.apple.com/documentation/swiftui/navigationstack)
- AWAVEDesign package (in repo)

---

## 📝 Notes

- Categories are fixed in order (schlafen, stress, leichtigkeit) to maintain icon positions
- Category selection is persisted in onboarding storage
- Backend data fetching has fallback to local category data
- Sound grid uses airplane window design matching React web app
- Category screens support both regular sounds and custom sounds
- Mini player strip appears when audio is playing

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
