# Background Audio System - Feature Documentation

**Feature Name:** Background Audio & Playback Management  
**Status:** ✅ Complete  
**Priority:** High  
**Last Updated:** 2025-01-27

## 📋 Feature Overview

The Background Audio system enables continuous audio playback when the app is in the background, locked, or minimized. It provides lock screen controls, media notifications, and seamless playback continuation across app state changes.

### Description

The background audio system is built on `react-native-track-player` and native audio modules, providing:
- **Continuous playback** when app is backgrounded or locked
- **Lock screen controls** for play, pause, stop, and seek
- **Media notifications** with track information and artwork
- **Remote control support** for Bluetooth devices and headphones
- **Session persistence** across app restarts
- **Multi-track support** for sequential and simultaneous playback

### User Value

- **Uninterrupted listening** - Audio continues when app is minimized or locked
- **Convenience** - Control playback from lock screen and notification center
- **Flexibility** - Use other apps while listening to meditation sounds
- **Accessibility** - Control playback from Bluetooth devices and car systems
- **Reliability** - Playback persists across app restarts and state changes

---

## 🎯 Core Features

### 1. Background Playback
- Continuous audio playback when app is backgrounded
- Audio continues when device is locked
- Playback persists across app state changes
- Automatic resume after interruptions

### 2. Lock Screen Controls
- Play/Pause controls on lock screen
- Track information display (title, artist, artwork)
- Seek controls for navigation
- Stop button for ending playback

### 3. Media Notifications
- Notification with playback controls
- Track metadata display
- Artwork visualization
- Quick access from notification center

### 4. Remote Control Support
- Bluetooth device controls
- Headphone button support
- Car system integration
- AirPods controls

### 5. App State Management
- Automatic pause/resume handling
- Background state detection
- Foreground restoration
- State synchronization

### 6. Multiplayer Support (Multi-Sound System Only)
- **Audioplayer** (Track Mixer System) - Multi-sound playback with background support
  - Up to 7 track mixers OR one track mixer
  - Dynamic track management (add, remove, toggle/mute tracks)
  - Individual volume control per track
  - **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**
  - **Play button controls the complete sound system** (starts/stops all sounds)
  - **Journey freezes where stopped (gets stored) and continues when started again**
- **Klangwelten** (Native Multi-Track) - 3 sounds from carousel with background support
  - Exactly 3 tracks mixing simultaneously (chosen from carousel)
  - Individual volume control per track
  - Track toggle (mute/unmute without stopping)
  - **Play button controls the complete sound system** (starts/stops all 3 sounds)
  - **Journey freezes where stopped (gets stored) and continues when started again**
- **MiniPlayer** - Follows same play control rules
- **Phone Saving Screen** - Follows same play control rules
- Unified playback service routing

---

## 🏗️ Architecture

### Technology Stack
- **Primary:** `react-native-track-player` - Background audio playback
- **Native iOS:** `AVAudioSession` - Audio session management
- **Native Android:** Media session API
- **State Management:** React hooks and context
- **Storage:** AsyncStorage for session persistence

### Key Components
- `TrackPlayerService` - Background playback service
- `UnifiedAudioPlaybackService` - Audio source routing
- `useAudioPlayer` - Playback state hook
- `AudioPlayerEnhanced` - Main player component
- `NativeMultiTrackAudioService` - Multi-track playback

---

## 📱 Platform Support

### iOS
- ✅ Background audio mode enabled (`UIBackgroundModes: audio`)
- ✅ `AVAudioSessionCategoryPlayback` configuration
- ✅ Lock screen controls
- ✅ Control Center integration
- ✅ AirPods controls

### Android
- ✅ Media session API
- ✅ Lock screen controls
- ✅ Notification controls
- ✅ Bluetooth device support

---

## 🔄 User Flows

### Primary Flows
1. **Background Playback** - Start playback → Background app → Audio continues
2. **Lock Screen Control** - Lock device → Use controls → Playback responds
3. **Notification Control** - Pull down notification → Use controls → Playback responds
4. **Remote Control** - Connect Bluetooth → Use device controls → Playback responds

### Alternative Flows
- **App Restart** - Restart app → Playback state restored
- **Interruption Handling** - Phone call → Auto pause → Resume after call
- **State Transition** - Background → Foreground → Playback continues

---

## 🔐 Platform Configuration

### iOS Configuration
- `UIBackgroundModes: audio` in Info.plist
- `AVAudioSessionCategoryPlayback` category
- Audio session activation on initialization

### Android Configuration
- Media session service registration
- Notification channel for media controls
- Foreground service for background playback

---

## 📊 Integration Points

### Related Features
- **Audio Player** - Main playback interface
- **Session Tracking** - Playback session management
- **Offline Support** - Local file playback
- **Multi-Track Mixer** - Simultaneous playback

### External Services
- `react-native-track-player` (background playback engine)
- Native audio modules (iOS/Android)
- System media controls (lock screen, notifications)

---

## 🧪 Testing Considerations

### Test Cases
- Background playback continuation
- Lock screen control functionality
- Notification control functionality
- Remote control support
- App state transitions
- Interruption handling
- Multi-track background playback

### Edge Cases
- App killed while playing
- Network interruption during streaming
- Multiple audio sources
- System audio interruptions (calls, alarms)
- Bluetooth disconnection

---

## 📚 Additional Resources

- [react-native-track-player Documentation](https://react-native-track-player.js.org/)
- [iOS AVAudioSession Guide](https://developer.apple.com/documentation/avfaudio/avaudiosession)
- [Android Media Session Guide](https://developer.android.com/guide/topics/media-apps/audio-app/building-a-mediabrowserservice)

---

## 📝 Notes

- **Multiplayer setup only** - All playback is multi-sound based
- **Play button controls the complete sound system** - applies to all player integrations:
  - Klangwelten (3 sounds from carousel)
  - Background play
  - Phone Saving Screen
  - Miniplayer
- **Journey freezes where stopped (gets stored) and continues when started again** - applies to all integrations
- **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**
- Background audio requires `UIBackgroundModes: audio` in iOS Info.plist
- Track Player must be initialized before use
- Media controls are automatically configured by Track Player
- Background downloads are handled separately by `BackgroundDownloadService`
- Native multi-track player also supports background playback via `AVAudioSession`

---

*For detailed technical specifications, see `technical-spec.md`*  
*For user flow diagrams, see `user-flows.md`*  
*For component details, see `components.md`*  
*For service dependencies, see `services.md`*
