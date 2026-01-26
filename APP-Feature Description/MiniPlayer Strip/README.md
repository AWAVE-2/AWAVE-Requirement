# MiniPlayer Strip - Feature Documentation

**Feature Name:** MiniPlayer Strip  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The MiniPlayer Strip is a compact, persistent audio player component that appears at the bottom of category screens when a sound has been played. It provides quick access to resume playback and navigate to the full audio player without interrupting the user's browsing experience.

### Description

The MiniPlayer Strip is a floating UI component that:
- **Displays currently playing or last played sound** with artwork, title, and description
- **Provides quick playback controls** (play/pause button)
- **Allows expansion** to the full AudioPlayer screen
- **Supports closing** to stop playback and clear the mini player
- **Persists across navigation** within category screens
- **Integrates with audio playback services** for state management

### User Value

- **Quick Access** - Resume playback without navigating to full player
- **Context Preservation** - See what's playing while browsing sounds
- **Non-Intrusive** - Compact design doesn't block content
- **Seamless Navigation** - Tap to expand to full player experience
- **State Persistence** - Remembers last played sound across app sessions

---

## 🎯 Core Features

### 1. Sound Display
- Artwork image or placeholder icon
- Sound title (truncated if long)
- Sound description (optional, truncated)
- Visual feedback on tap

### 2. Playback Controls
- **Play Button** - Controls the complete sound system (starts/stops all sounds)
  - Resume playback from frozen position or expand to full player
  - **Journey freezes where stopped (gets stored) and continues when started again**
- **Close Button** - Stop playback and clear mini player
- Visual state indication (playing/paused)

### 3. Navigation Integration
- Tap on content area expands to full AudioPlayer
- Integrates with category screen navigation
- Maintains position at bottom of screen

### 4. State Management
- Tracks last played sound
- Persists state across app restarts
- Syncs with Supabase for authenticated users
- Clears state on close

### 5. Visual Design
- Card-based design with rounded corners
- Theme-aware styling
- Responsive layout
- Smooth animations

---

## 🏗️ Architecture

### Technology Stack
- **React Native** - Component framework
- **React Native Reanimated** - Animations (via NavBar integration)
- **useSoundPlayer Hook** - Audio state management
- **SupabasePlaybackService** - Backend sync
- **onboardingStorage** - Local persistence

### Key Components
- `MiniPlayerStrip` - Main component
- `useSoundPlayer` - Audio player hook
- Category screens (SchlafScreen, RuheScreen, ImFlussScreen)
- `AudioPlayerEnhanced` - Full player screen

---

## 📱 Integration Points

### Screens Using MiniPlayer Strip
1. **SchlafScreen** (`/schlafen`) - Sleep category
2. **RuheScreen** (`/ruhe`) - Rest category
3. **ImFlussScreen** (`/leichtigkeit`) - Flow category

### Related Features
- **AudioPlayer** - Full screen player (expanded from mini player)
- **Session Tracking** - Playback session management
- **Favorites** - Favorite sound integration
- **Category Navigation** - Category screen integration

---

## 🔄 User Flows

### Primary Flows
1. **Play Sound** - Select sound → Mini player appears → Resume playback
2. **Expand Player** - Tap mini player → Full AudioPlayer opens
3. **Close Player** - Tap close → Stop playback → Mini player disappears

### Alternative Flows
- **Resume Playback** - Tap play button → Resume from last position
- **Navigate Away** - Mini player persists when navigating between category screens
- **App Restart** - Last played sound restored from storage

---

## 🎨 Visual Design

### Layout
- **Position:** Fixed at bottom of screen
- **Size:** Compact (44px artwork, 36px controls)
- **Spacing:** 16px horizontal margin, 12px bottom margin
- **Elevation:** Above content, below modals

### Styling
- Card background with border
- Rounded corners (10px container, 12px artwork)
- Theme-aware colors
- Primary color accent for play button

---

## 🔐 State Management

### Local State
- `lastPlayedSound` - Currently displayed sound
- `currentFavoriteId` - Associated favorite ID
- `isPlaying` - Playback state

### Persistent State
- `onboardingStorage` - Local AsyncStorage
- `SupabasePlaybackService` - Cloud sync (authenticated users)

---

## 📊 Integration Points

### Related Features
- **AudioPlayer** - Full screen player expansion
- **Session Tracking** - Playback analytics
- **Favorites** - Favorite sound management
- **Category Screens** - Screen-level integration

### External Services
- Supabase (playback session tracking)
- AsyncStorage (local persistence)
- Audio playback services

---

## 🧪 Testing Considerations

### Test Cases
- Mini player appears after sound selection
- Play button resumes playback
- Close button stops and clears
- Expansion to full player
- State persistence across navigation
- State restoration on app restart

### Edge Cases
- No sound selected (should not render)
- Network connectivity issues
- Audio playback errors
- Multiple rapid taps
- App backgrounding/foregrounding

---

## 📚 Additional Resources

- [Audio Player Documentation](../Major%20Audioplayer/AUDIO_PLAYER_COMPLETE_DOCUMENTATION.md)
- [useSoundPlayer Hook](../../src/hooks/useSoundPlayer.ts)
- [SupabasePlaybackService](../../src/services/SupabasePlaybackService.ts)

---

## 📝 Notes

- **Multiplayer setup only** - Part of unified multi-sound audio system
- **Play button controls the complete sound system** (starts/stops all sounds)
- **Journey freezes where stopped (gets stored) and continues when started again**
- **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**
- Mini player only appears when `lastPlayedSound` is set
- Close button is optional (controlled by `onClose` prop)
- Play button behavior: if `onPlayPress` provided, uses it; otherwise expands
- State is cleared when user explicitly closes mini player
- Persists across category screen navigation
- Syncs with Supabase for authenticated users
- Follows same play control rules as: Klangwelten, Background play, Phone Saving Screen, Major Audioplayer

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
