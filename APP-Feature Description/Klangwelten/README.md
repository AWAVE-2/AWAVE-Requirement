# Klangwelten (Sound World) - Feature Documentation

**Feature Name:** Klangwelten / Sound World Creation  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Klangwelten (Sound World) feature enables users to create personalized audio experiences by mixing **exactly 3 sounds** chosen from a carousel. This is part of the **multiplayer-only audio system**. Users can browse sounds from different categories, select 3 tracks from the carousel, adjust individual volumes, and create their own custom soundscapes for relaxation, focus, or sleep.

### Description

Klangwelten is a **multi-track audio mixing system (multiplayer setup)** that allows users to:
- **Browse sounds** from a horizontal scrollable carousel
- **Select exactly 3 sounds** from the carousel for mixing
- **Control individual volumes** for each track
- **Toggle tracks on/off (mute/unmute)** without stopping playback
- **Play all 3 tracks simultaneously** for a layered audio experience
- **Play button controls the complete sound system** - starts/stops all 3 sounds
- **Journey freezes where stopped (gets stored) and continues when started again**
- **Save mixer state** across app sessions
- **Access from category screens** (Schlaf, Ruhe, Im Fluss)

### User Value

- **Personalization** - Create unique sound combinations tailored to individual preferences
- **Flexibility** - Mix sounds from different categories for diverse experiences
- **Control** - Fine-tune volume levels for each track independently
- **Convenience** - Quick access from category screens, state persistence
- **Creativity** - Experiment with different sound combinations

---

## 🎯 Core Features

### 1. Sound Selection
- Horizontal scrollable carousel with sound cards
- Visual selection indicators (checkmarks)
- Maximum 3 selections enforced
- Tap-to-toggle selection behavior
- Category-based sound filtering

### 2. Multi-Track Audio Playback (Multiplayer Setup)
- Simultaneous playback of exactly 3 tracks (chosen from carousel)
- Independent volume control per track (0-100%)
- Track toggle (mute/unmute without stopping)
- **Play button controls the complete sound system** - starts/stops all 3 sounds
- **Journey freezes where stopped (gets stored) and continues when started again**
- **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**
- Native audio engine for superior performance

### 3. Mixer Interface
- Bottom sheet mixer with per-track controls
- Volume sliders for each active track
- Track on/off switches
- Visual feedback for active tracks
- Empty state handling

### 4. State Management
- Mixer state persistence across sessions
- Auto-save on state changes
- Track selection tracking
- Playback state management

### 5. Navigation Integration
- Accessible from category screens (Schlaf, Ruhe, Im Fluss)
- Category context passed to screen
- Back navigation support
- Route parameter handling

---

## 🏗️ Architecture

### Technology Stack
- **Audio Engine:** NativeMultiTrackAudioService (native AWAVEAudioModule)
- **State Management:** React Hooks (useMultiTrackMixer)
- **Storage:** AsyncStorage for state persistence
- **UI Components:** React Native components with theme system
- **Navigation:** React Navigation stack

### Key Components
- `KlangweltenScreen` - Main screen for sound world creation
- `SoundCarousel` - Horizontal scrollable sound selection
- `AudioPlayerMixerSheet` - Bottom sheet mixer interface
- `useMultiTrackMixer` - Multi-track mixing hook
- `NativeMultiTrackAudioService` - Native audio service

### Swift Sound Drawer (iOS)

From category screens (Schlaf, Ruhe, Im Fluss) and Home, the **Sound Drawer** is presented as a bottom sheet when the user taps **"Klangwelten erstellen"**:

- **Selection phase:** Three horizontal carousels; one sound selectable per carousel (radio). Confirm button loads the three tracks and switches to the player phase.
- **Player phase:** Title, time display, seek slider, play/pause, stop. "Zurück zur Auswahl" returns to selection. **Swipe up** (or tap "Mehr anzeigen") reveals the **nested mixer** (`MixerEmbeddedView`) in the same drawer; swipe down or tap the handle to hide it.

**Swift components:** `KlangweltenSoundDrawerView`, `SingleSelectionCarouselView`. Handover and summary: `docs/Klangwelten-Sound-Drawer/`.

---

## 📱 Screens

1. **KlangweltenScreen** (`/Klangwelten`) - Main sound world creation screen
   - Sound carousel
   - Playback controls
   - Mixer access
   - Category information

---

## 🔄 User Flows

### Primary Flows
1. **Create Sound World** - Category Screen → Klangwelten → Select Sounds → Adjust Mix → Play
2. **Modify Existing Mix** - Open Klangwelten → Change Selections → Adjust Volumes → Play
3. **Resume Previous Mix** - Open Klangwelten → Load Saved State → Continue Playback

### Alternative Flows
- **Quick Mix** - Select sounds → Play immediately
- **Fine-Tuning** - Open mixer → Adjust volumes → Test → Save
- **Track Management** - Toggle tracks on/off during playback

---

## 🎨 UI/UX Features

- **Visual Selection** - Checkmarks and highlighted cards for selected sounds
- **Selection Counter** - Shows "X / 3 ausgewählt" in carousel
- **Empty State Handling** - Alerts when no sounds selected
- **Loading States** - Indicators during audio loading
- **Error Handling** - User-friendly error messages
- **Responsive Design** - Adapts to different screen sizes
- **Theme Integration** - Consistent with app design system

---

## 📊 Integration Points

### Related Features
- **Category Screens** - Entry point for Klangwelten
- **Audio Player** - Part of unified multiplayer audio system
- **Session Tracking** - Playback session integration
- **Favorites** - Potential integration with favorite sounds
- **Background Audio** - Follows same play control rules (complete sound system control)
- **MiniPlayer** - Follows same play control rules (complete sound system control)

### External Services
- Native AWAVEAudioModule (iOS/Android)
- AsyncStorage (local persistence)
- Sound data from exactDataStructures

---

## 🧪 Testing Considerations

### Test Cases
- Sound selection and deselection
- Maximum selection limit enforcement
- Multi-track playback
- Volume adjustment per track
- Track toggle functionality
- State persistence across app restarts
- Navigation from category screens
- Error handling (no sounds, audio failures)

### Edge Cases
- No sounds available
- Audio file loading failures
- Network issues (if sounds are remote)
- App backgrounding during playback
- Multiple rapid selections
- State corruption recovery

---

## 📚 Additional Resources

- [Native Audio Module Documentation](../../AUDIO_PLAYER_COMPLETE_DOCUMENTATION.md)
- [Multi-Track Mixer Hook](../../src/hooks/useMultiTrackMixer.ts)
- [Native Audio Service](../../src/services/NativeMultiTrackAudioService.ts)

---

## 📝 Notes

- **Multiplayer setup only** - Always plays 3 sounds simultaneously (chosen from carousel)
- Maximum 3 tracks supported (exactly 3, chosen from carousel)
- Mixer state auto-saves after 1 second debounce
- Native audio engine provides better performance than Expo AV
- **Play button controls the complete sound system** (all 3 sounds start/stop together)
- **Journey freezes where stopped (gets stored) and continues when started again**
- **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**
- Part of unified multiplayer audio system (same play control rules as Major Audioplayer, Background Audio, MiniPlayer)
- Category filtering currently loads all sounds (TODO: implement category filtering)

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
