# Major Audioplayer System - Feature Documentation

**Feature Name:** Major Audioplayer & Multi-Track Audio System
**Status:** ⚠️ Partially Complete (Basic 3-track mixer done, advanced features pending)
**Priority:** High
**Last Updated:** 2026-02-06
**Swift Implementation:** Basic mixer with 3 tracks (vs. required 7 tracks)

### Full-Player Screen Design (Swift UI)

The Major Audio Player is presented as a **full-screen cover** (no tab bar). One screen contains **two components**:

1. **Upper area (session playback):** Full-bleed visualization, session/track title, progress slider, and transport (Play, Nächste Session, Letzte Session in session mode). No navigation or share/options buttons in the player.
2. **Lower area (mixer):** Reachable by **swipe-up** or tap on „Mehr anzeigen“. An in-screen drawer shows the same mixer content as `MixerSheetView` (mode picker, track slots, Mix speichern). Swipe-down on the drawer closes it; swipe-down on the main area closes the full player.

**Gestures:**

- **Swipe-down** on the main area: closes the full player; **playback continues** and is handed over to the mini-player strip.
- **Swipe-up** (or tap „Mehr anzeigen“): reveals the mixer drawer.
- **Swipe-down** on the mixer drawer: closes the drawer only.

**Session Generator:** After generating a session, the generator dismisses and the full player opens automatically („sofort starten“).

## 📋 Feature Overview

The Major Audioplayer system provides comprehensive audio playback capabilities for the AWAVE app. It implements a **multiplayer-only architecture** supporting dynamic multi-track mixing with up to 7 track mixers or a single track mixer. Users can dynamically add, delete, or mute sounds during playback. The system includes advanced features such as waveform visualization, procedural sound generation, and session tracking.

### Description

The audio player system is built on a **multiplayer architecture**:

- **Track Mixer System**: Multi-track playback using `react-native-track-player`
  - Up to 7 track mixers OR one track mixer per sound journey
  - Dynamic track management (add, remove, toggle/mute tracks)
  - Individual volume control per track
  - **Time control calculated by total length of loaded sounds**
  - **Dynamically calculated based on longest sound file integrated into the mix**
  - Track mixer tiles always based on multi-sound playing system
  - Session tracking and background audio support
  - **Play button controls the complete sound system** - starts/stops all sounds
  - **Journey freezes where stopped (gets stored) and continues when started again**

### User Value

- **Multi-Sound Playback** - Always plays multiple sounds simultaneously (multiplayer setup only)
- **Dynamic Customization** - Add, delete, or mute sounds dynamically during playback
- **Flexible Mixing** - Up to 7 track mixers or a single track mixer per journey
- **Immersive Experience** - Waveform visualization and audio effects enhance the listening experience
- **Offline Support** - Procedural sound generation and local caching for offline playback
- **Session Tracking** - Automatic tracking of listening sessions for analytics
- **Background Playback** - Continue listening while using other apps
- **Journey Persistence** - Playback state freezes and resumes exactly where stopped

---

## 🎯 Core Features

### 1. Multiplayer Architecture (Multi-Sound System Only)
- **Track Mixer System**: Always based on multi-sound playing system
- Up to 7 track mixers OR one track mixer per sound journey
- Users can dynamically add sounds to the mix
- Users can dynamically delete sounds from the mix
- Users can dynamically mute/unmute sounds during playback
- All track mixer tiles operate on multi-sound playing system

### 2. Dynamic Track Management
- Add sounds to tracks dynamically during playback
- Remove sounds from tracks dynamically
- Toggle tracks on/off (mute/unmute) without stopping playback
- Replace sounds while others continue playing
- Mixer state persistence across sessions
- Track mixer tiles always reflect multi-sound system

### 3. Time Control & Playback Duration
- **Time control calculated by total length of loaded sounds**
- **Dynamically calculated based on longest sound file integrated into the mix**
- Progress tracking reflects the complete mix duration
- Playback position synchronized across all active tracks

### 4. Audio Waveform Visualization
- Animated waveform bars during playback
- Purple gradient background with floating orbs
- Title and description display when paused
- Toggle between visualization modes
- Real-time animation synchronized with playback

### 5. Procedural Sound Generation
- **Wave Sounds**: Ocean, Lake, River
- **Rain Sounds**: Light, Medium, Heavy
- **Noise Sounds**: White, Pink, Brown
- On-device generation using native modules
- Automatic cache management (7-day retention)

### 6. Session Tracking
- Automatic session creation on playback start
- Progress updates every 30 seconds
- Session completion on stop or close
- Duration tracking based on active tracks
- Integration with analytics system

### 7. Background Audio Support
- Continue playback when app goes to background
- Media controls in lock screen and control center
- Notification controls for playback
- Automatic pause/resume handling

### 4. Playback Control System
- **Play button always controls the complete sound system**
- Starts all active sounds simultaneously
- Stops all sounds when paused
- **Journey freezes where stopped (gets stored)**
- **Journey continues when started again from the stored position**
- This play control rule applies to all player integrations:
  - Klangwelten
  - Background play
  - Phone Saving Screen
  - Miniplayer

---

## 🏗️ Architecture

### Technology Stack
- **Track Player**: `react-native-track-player` - Multi-track playback engine
- **Native Audio Module**: `AWAVEAudioModule` - Native audio processing
- **Visualization**: `react-native-reanimated` - Smooth animations
- **Storage**: AsyncStorage for mixer state persistence and journey freeze state
- **Session Tracking**: `SessionTrackingService` - Analytics integration

### Key Components
- `AudioPlayerEnhanced` - Main audio player component
- `AudioPlayerLayout` - Layout structure matching React web
- `AudioPlayerVisualization` - Waveform visualization
- `useAudioPlayer` - Track player hook
- `useMultiTrackMixer` - Multi-track mixer hook
- `NativeMultiTrackAudioService` - Multi-track service layer
- `SoundGenerationService` - Procedural sound generation

---

## 📱 Screens

1. **AudioPlayerEnhanced** - Main audio player screen with full controls
2. **AudioPlayerScreen** - Full-screen audio player view
3. **KlangweltenScreen** - Sound world mixer screen (Player 2)
4. **Category Screens** - Entry points for sound journeys (Player 1)

---

## 🔄 User Flows

### Primary Flows
1. **Sound Journey Flow** - Select sound → Load tracks → Play sequentially → Track management
2. **Sound World Flow** - Open mixer → Select sounds → Adjust volumes → Play simultaneously
3. **Procedural Sound Flow** - Select generated sound → Generate on-device → Play
4. **Background Playback Flow** - Start playback → Background app → Continue listening

### Alternative Flows
- **Track Management** - Add/remove tracks during playback
- **Volume Adjustment** - Individual track volume control
- **Visualization Toggle** - Switch between waveform and metadata view
- **Session Recovery** - Resume interrupted sessions

---

## 🎨 Audio Features

### Playback Controls
- Play/Pause/Stop
- Seek to position
- Volume control (master and per-track)
- Pan control (multi-track only)
- Track toggle (activate/deactivate)

### Audio Effects (Multi-Track Only)
- Reverb (room size, damping, wet/dry mix)
- Delay (delay time, feedback, wet/dry mix)
- EQ (frequency bands, gain)
- Compression (threshold, ratio, attack, release)
- Filter (low-pass, high-pass, band-pass)

### Visualization
- Animated waveform bars (7 bars)
- Floating orbs animation
- Gradient overlay sweep
- Title and description display
- Real-time animation updates

---

## 📊 Integration Points

### Related Features
- **Category Screens** - Entry points for sound journeys
- **Favorites** - Favorite sounds integration
- **Library** - Sound library management
- **Offline Support** - Local caching and download
- **Session Tracking** - Analytics integration
- **Subscription** - Premium feature access

### External Services
- Firebase Storage (audio file streaming; Google Cloud)
- Native Audio Engine (iOS/Android)
- Session Tracking Service (analytics)
- Audio Library Manager (download management)

---

## 🧪 Testing Considerations

### Test Cases
- Single sound playback
- Multi-track sequential playback
- Multi-track simultaneous playback
- Track management (add, remove, toggle)
- Volume and pan control
- Procedural sound generation
- Session tracking
- Background playback
- Media controls
- Error handling (network, file not found, etc.)

### Edge Cases
- Network connectivity issues during playback
- File download failures
- Invalid audio files
- App backgrounding during playback
- Multiple simultaneous playback attempts
- Track switching during playback
- Session interruption and recovery

---

## 📚 Additional Resources

- [react-native-track-player Documentation](https://github.com/doublesymmetry/react-native-track-player)
- [React Native Reanimated Documentation](https://docs.swmansion.com/react-native-reanimated/)
- [AVAudioEngine Documentation (iOS)](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- [AudioTrack Documentation (Android)](https://developer.android.com/reference/android/media/AudioTrack)

---

## 📝 Notes

- **Multiplayer setup only** - All playback is multi-sound based
- Track mixer system supports up to 7 track mixers OR one track mixer
- Track mixer tiles are always based on multi-sound playing system
- Time control is calculated by total length of loaded sounds, dynamically based on longest sound file
- Play button controls the complete sound system (starts/stops all sounds)
- Journey freezes where stopped (gets stored) and continues when started again
- This play control rule applies to: Klangwelten, Background play, Phone Saving Screen, Miniplayer
- Generated sounds are cached for 7 days before cleanup
- Mixer state and journey freeze state are automatically saved to AsyncStorage
- Session tracking updates every 30 seconds during playback
- Background audio requires proper native configuration
- Media controls require Track Player service registration

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
