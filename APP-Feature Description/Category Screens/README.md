# Category Screens - Feature Documentation

**Feature Name:** Category Screens & Content Browsing
**Status:** 🚧 Partial (Swift iOS Implementation)
**Priority:** High
**Last Updated:** 2026-02-01

## Implementation Status (Swift iOS)

### ✅ Implemented
- ✅ Category Sessions Generation (CategorySessionGenerator)
- ✅ Category Sessions ViewModel (CategorySessionsViewModel)
- ✅ Category Sessions View (CategorySessionsView)
- ✅ Firestore Session Repository with category methods
- ✅ Navigation integration (HomeView → Categories)
- ✅ Comprehensive test coverage (30 tests)
  - ✅ CategorySessionsViewModelTests (14 tests)
  - ✅ CategorySessionGeneratorTests (16 tests)
  - ✅ MockSessionRepository extension

### 🚧 Partial / In Progress
- 🚧 Full category browsing UI (basic grid view implemented)
- 🚧 Category theming and branding
- 🚧 Custom sounds integration
- 🚧 Klangwelten navigation

### ❌ Not Yet Implemented (from React Native app)
- ❌ Category hero header with gradients
- ❌ Airplane window sound card design
- ❌ Sound grid virtualization
- ❌ "Weitere Sessions" button
- ❌ "Eigene Klangwelt" section
- ❌ Backend category fetching (Firestore only, no Supabase)
- ❌ Category selection persistence across app restarts
- ❌ Bottom tab navigation between categories

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
- Backend category fetching via Supabase
- Fallback to local category data
- Category ordering and persistence
- Sound metadata integration
- Category content configuration

---

## 🏗️ Architecture

### Technology Stack
- **Backend:** Supabase (audio_categories, sound_metadata tables)
- **State Management:** React Context API (CategoryContext)
- **Navigation:** Custom Tab Navigator with bottom navigation
- **Data Layer:** CategoryService for backend integration
- **UI Components:** Reusable CategoryScreenBase component

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
- Supabase (category and sound metadata)
- Audio playback services
- Storage services (favorites, custom sounds)

---

## 🧪 Testing Considerations

### ✅ Implemented Tests (Swift iOS - Phase 1)

**CategorySessionsViewModelTests** (14 tests):
- ✅ loadSessions() with authenticated user and existing sessions
- ✅ loadSessions() with authenticated user but empty Firestore
- ✅ loadSessions() when not authenticated (offline mode)
- ✅ loadSessions() when Firestore fails (error handling)
- ✅ loadSessions() concurrent calls guard
- ✅ generateSessions() when authenticated
- ✅ generateSessions() when not authenticated
- ✅ generateSessions() when save fails
- ✅ generateSessions() concurrent calls guard
- ✅ isLoading flag cleared on success
- ✅ isLoading flag cleared on error
- ✅ Error message set correctly (German)
- ✅ Multiple categories use different sessions
- ✅ Background save does not block UI

**CategorySessionGeneratorTests** (16 tests):
- ✅ Generates exactly 5 sessions for each category
- ✅ Voice rotation cycles through all 4 voices correctly
- ✅ Voice distribution balanced across sessions
- ✅ Sleep category maps to sleep topic
- ✅ Stress category maps to stress topic
- ✅ Flow category maps to meditation topic
- ✅ Sessions vary with different timestamps
- ✅ All sessions have valid structure
- ✅ Session IDs are unique within batch
- ✅ Voice distribution even across multiple generations
- ✅ SeededRandomNumberGenerator consistency
- ✅ SeededRandomNumberGenerator different seeds
- ✅ Expected phase structure
- ✅ Text content paths include voice and topic
- ✅ Performance test (< 3 seconds)
- ✅ Reasonable durations

### 🚧 Pending Tests (Phase 2 - Not Implemented)

**Integration Tests** (5 tests):
- ❌ End-to-end: Load → Display → Regenerate → Persist
- ❌ Offline mode: Generate → Go online → Sync
- ❌ User switches: Auth change during operation
- ❌ Error recovery: Firestore fails → Retry succeeds
- ❌ Data consistency: Sessions persist across app restarts

**Repository Tests** (8 tests):
- ❌ Fetch from nested collection path
- ❌ Save batch operation atomicity
- ❌ Delete batch operation completeness
- ❌ Empty collection handling
- ❌ Decode failure resilience
- ❌ Batch commit failure rollback
- ❌ Concurrent saves to same category
- ❌ Timestamp consistency

### Edge Cases
- ✅ Network connectivity issues (tested with mock failures)
- ✅ Empty category data (tested with empty Firestore)
- ❌ Missing sound metadata
- ❌ Category selection persistence
- ❌ Navigation state management

### Known Issues
- 🔴 FirestoreSessionTracker conformance error (pre-existing, blocks test execution)
- See: `TESTING_IMPLEMENTATION_SUMMARY.md` for details

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [React Navigation Documentation](https://reactnavigation.org/)
- [React Native Linear Gradient](https://github.com/react-native-linear-gradient/react-native-linear-gradient)

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
