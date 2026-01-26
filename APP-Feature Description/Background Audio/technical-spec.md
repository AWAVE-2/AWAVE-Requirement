# Background Audio System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Primary Background Playback Engine
- **react-native-track-player** - Main background audio playback library
  - Handles background playback automatically
  - Provides lock screen controls
  - Manages media notifications
  - Supports remote controls
  - Queue and playlist management

#### Native Audio Modules
- **iOS:** `AWAVEAudioModule` - Native audio engine
  - `AVAudioEngine` for audio processing
  - `AVAudioSession` for background playback
  - Background audio queue configuration
- **Android:** Media session API
  - Foreground service for background playback
  - Media session for controls

#### State Management
- **React Hooks** - `useAudioPlayer`, `usePlaybackState`, `useProgress`
- **Track Player Events** - Playback state changes, errors, remote events
- **React Context** - Global playback state (if needed)
- **AsyncStorage** - Session persistence

#### Services Layer
- `TrackPlayerService` - Background playback service registration
- `UnifiedAudioPlaybackService` - Audio source routing
- `NativeMultiTrackAudioService` - Multi-track background playback
- `BackgroundDownloadService` - Background audio downloads

---

## 📁 File Structure

```
src/
├── services/
│   ├── TrackPlayerService.ts              # Background playback service
│   ├── UnifiedAudioPlaybackService.ts     # Audio source routing
│   ├── NativeMultiTrackAudioService.ts    # Multi-track playback
│   └── BackgroundDownloadService.ts       # Background downloads
├── hooks/
│   ├── useAudioPlayer.ts                  # Playback state hook
│   └── useMultiTrackMixer.ts              # Multi-track mixer hook
├── components/
│   ├── AudioPlayerEnhanced.tsx            # Main player component
│   └── audio-player/                      # Player sub-components
├── native-modules/
│   └── NativeAudioBridge.ts               # Native module bridge
└── types/
    └── audio.ts                           # Audio type definitions

ios/
├── AWAVEAdvanced/
│   ├── Info.plist                         # UIBackgroundModes: audio
│   └── NativeModules/
│       └── AWAVEAudioModule.m             # Native audio engine
└── Podfile                                # Track Player dependency

android/
└── app/
    └── src/main/
        └── AndroidManifest.xml            # Foreground service config

index.js                                   # Track Player service registration
```

---

## 🔧 Components

### TrackPlayerService
**Location:** `src/services/TrackPlayerService.ts`

**Purpose:** Background playback service registration for react-native-track-player

**Used By:**
- **Audioplayer (Track Mixer System)**: Multi-sound playback (multiplayer setup only)
  - Up to 7 track mixers OR one track mixer
  - Dynamic track management (add, remove, toggle/mute tracks)
  - Individual volume control per track
  - **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**
  - **Play button controls the complete sound system** (starts/stops all sounds)
  - **Journey freezes where stopped (gets stored) and continues when started again**

**Implementation:**
```typescript
export async function PlaybackService() {
  TrackPlayer.addEventListener(Event.RemotePlay, () => {
    TrackPlayer.play();
  });

  TrackPlayer.addEventListener(Event.RemotePause, () => {
    TrackPlayer.pause();
  });

  TrackPlayer.addEventListener(Event.RemoteStop, () => {
    TrackPlayer.stop();
  });

  TrackPlayer.addEventListener(Event.RemoteSeek, ({ position }) => {
    TrackPlayer.seekTo(position);
  });
}
```

**Features:**
- Remote play event handling
- Remote pause event handling
- Remote stop event handling
- Remote seek event handling
- Automatic registration on app startup
- Support for up to 7 multitrack player mixers

**Registration:**
- Registered in `index.js` on app startup
- Required for background playback functionality
- Handles all remote control events

---

### UnifiedAudioPlaybackService
**Location:** `src/services/UnifiedAudioPlaybackService.ts`

**Purpose:** Unified service for routing audio to appropriate playback engine

**Methods:**
- `initialize()` - Initialize audio managers
- `playSound(sound)` - Route sound to appropriate player
- `playGeneratedSound(sound)` - Play generated sounds
- `playLocalFile(sound, filePath)` - Play local files via Track Player
- `playStream(sound)` - Play streaming audio via Track Player
- `detectSoundSource(sound)` - Detect sound source type
- `isAvailableOffline(sound)` - Check offline availability

**Playback Priority:**
1. Generated sounds (via SoundGenerationService)
2. Local files (downloaded, via Track Player)
3. Streaming (via Track Player)

**Track Player Integration:**
```typescript
const track: Track = {
  id: sound.id,
  url: `file://${filePath}`,
  title: sound.title || 'Untitled Sound',
  artist: sound.description || '',
  artwork: sound.imageUrl,
  duration: 300,
};

await TrackPlayer.reset();
await TrackPlayer.add(track);
await TrackPlayer.play();
```

---

### useAudioPlayer Hook
**Location:** `src/hooks/useAudioPlayer.ts`

**Purpose:** React hook for Track Player playback state and controls

**Returns:**
```typescript
{
  // State
  isPlaying: boolean;
  isPaused: boolean;
  isStopped: boolean;
  currentTrack: Track | null;
  position: number;
  duration: number;

  // Actions
  play: (sound: Sound) => Promise<void>;
  pause: () => Promise<void>;
  resume: () => Promise<void>;
  stop: () => Promise<void>;
  seekTo: (position: number) => Promise<void>;
  setVolume: (volume: number) => Promise<void>;

  // Status
  isLoading: boolean;
  error: string | null;
}
```

**Initialization:**
```typescript
await TrackPlayer.setupPlayer({
  waitForBuffer: true,
});

await TrackPlayer.updateOptions({
  capabilities: [
    Capability.Play,
    Capability.Pause,
    Capability.Stop,
    Capability.SeekTo
  ],
  compactCapabilities: [
    Capability.Play,
    Capability.Pause,
    Capability.Stop
  ],
  notificationCapabilities: [
    Capability.Play,
    Capability.Pause,
    Capability.Stop
  ],
});
```

**Features:**
- Automatic Track Player initialization
- Playback state tracking
- Progress tracking
- Error handling
- Event listeners

---

### AudioPlayerEnhanced Component
**Location:** `src/components/AudioPlayerEnhanced.tsx`

**Purpose:** Main audio player component with background playback support

**App State Handling:**
```typescript
useEffect(() => {
  const subscription = AppState.addEventListener('change', (nextAppState: AppStateStatus) => {
    if (nextAppState === 'background' || nextAppState === 'inactive') {
      if (isPlaying) {
        audio.pause().catch((error) => {
          console.error('[AudioPlayer] Failed to pause audio on background:', error);
        });
      }
    }
  });

  return () => {
    subscription.remove();
  };
}, [isPlaying, audio]);
```

**Note:** This component currently pauses on background, but Track Player handles background playback automatically. This may need adjustment for full background support.

**Features:**
- Track Player integration
- Session tracking
- Progress updates
- App state monitoring
- Cleanup on unmount

---

### NativeMultiTrackAudioService
**Location:** `src/services/NativeMultiTrackAudioService.ts`

**Purpose:** Multi-track simultaneous playback with background support

**Used By:**
- **Klangwelten**: Exactly 3 tracks mixing simultaneously (chosen from carousel)
  - Individual volume control per track
  - Track toggle (mute/unmute without stopping)
  - **Play button controls the complete sound system** (starts/stops all 3 sounds)
  - **Journey freezes where stopped (gets stored) and continues when started again**
  - Sound world creation

**Background Configuration:**
- Uses native `AWAVEAudioModule` with `AVAudioSession`
- Audio session configured for background playback
- Dedicated audio queue for background processing

**iOS Configuration:**
```objective-c
// Set up audio session for background playback
AVAudioSession *session = [AVAudioSession sharedInstance];
[session setCategory:AVAudioSessionCategoryPlayback error:&error];
[session setActive:YES error:&error];
```

**Features:**
- Simultaneous multi-track playback (3 tracks for Klangwelten)
- Individual volume control
- Pan control
- Audio effects
- Background playback support

---

## 🔌 Services

### Track Player Service Registration
**Location:** `index.js`

**Registration:**
```javascript
// Register TrackPlayer playback service (for background audio)
try {
  const TrackPlayer = require('react-native-track-player');
  const { PlaybackService } = require('./src/services/TrackPlayerService');

  if (TrackPlayer && typeof TrackPlayer.registerPlaybackService === 'function') {
    TrackPlayer.registerPlaybackService(() => PlaybackService);
    console.log('[TrackPlayer] 🎵 Background playback service registered');
  }
} catch (e) {
  console.warn('[TrackPlayer] Failed to register playback service:', e.message);
}
```

**Requirements:**
- Must be registered before app component
- Required for background playback
- Handles all remote control events

---

## 🔐 Platform Configuration

### iOS Configuration

#### Info.plist
**Location:** `ios/AWAVEAdvanced/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

**Required for:**
- Background audio playback
- Lock screen controls
- Control Center integration

#### Native Audio Module
**Location:** `ios/AWAVEAdvanced/NativeModules/AWAVEAudioModule.m`

```objective-c
// Set up audio session for background playback
NSError *error;
AVAudioSession *session = [AVAudioSession sharedInstance];
[session setCategory:AVAudioSessionCategoryPlayback error:&error];
[session setActive:YES error:&error];

// Create dedicated audio queue for background processing
_audioQueue = dispatch_queue_create("com.awave.audio", DISPATCH_QUEUE_SERIAL);
```

**Audio Session Category:**
- `AVAudioSessionCategoryPlayback` - Allows background playback
- Prevents audio from being interrupted by other apps
- Enables lock screen controls

---

### Android Configuration

#### AndroidManifest.xml
**Location:** `android/app/src/main/AndroidManifest.xml`

```xml
<service
    android:name="com.doublesymmetry.trackplayer.service.MusicService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="false" />
```

**Foreground Service:**
- Required for reliable background playback
- Media playback foreground service type
- Handles media session

#### Media Session
- Automatically configured by Track Player
- Provides lock screen controls
- Handles remote control events

---

## 🔄 State Management

### Track Player State
```typescript
State.None        // No track loaded
State.Ready       // Track loaded, ready to play
State.Playing     // Currently playing
State.Paused      // Paused
State.Stopped     // Stopped
State.Buffering   // Buffering
State.Loading     // Loading track
State.Error       // Error state
```

### Playback State Flow
```
None → Loading → Ready → Playing
                          ↓
                      Paused
                          ↓
                      Playing
                          ↓
                      Stopped → None
```

### Background State Management
- Track Player maintains state in background
- State is synchronized on foreground return
- Playback position is preserved
- Queue state is maintained

---

## 🌐 API Integration

### Track Player API

#### Initialization
```typescript
await TrackPlayer.setupPlayer({
  waitForBuffer: true,
});
```

#### Playback Control
```typescript
await TrackPlayer.play();
await TrackPlayer.pause();
await TrackPlayer.stop();
await TrackPlayer.seekTo(position);
await TrackPlayer.setVolume(volume);
```

#### Queue Management
```typescript
await TrackPlayer.add(track);
await TrackPlayer.remove(trackId);
await TrackPlayer.reset();
await TrackPlayer.skip(trackId);
```

#### State Queries
```typescript
const state = await TrackPlayer.getPlaybackState();
const position = await TrackPlayer.getPosition();
const duration = await TrackPlayer.getDuration();
const volume = await TrackPlayer.getVolume();
```

#### Events
```typescript
TrackPlayer.addEventListener(Event.PlaybackState, handler);
TrackPlayer.addEventListener(Event.PlaybackTrackChanged, handler);
TrackPlayer.addEventListener(Event.PlaybackError, handler);
TrackPlayer.addEventListener(Event.RemotePlay, handler);
TrackPlayer.addEventListener(Event.RemotePause, handler);
TrackPlayer.addEventListener(Event.RemoteStop, handler);
TrackPlayer.addEventListener(Event.RemoteSeek, handler);
```

---

## 📱 Platform-Specific Notes

### iOS

#### Background Modes
- `UIBackgroundModes: audio` required in Info.plist
- Enables background audio playback
- Required for lock screen controls

#### Audio Session
- `AVAudioSessionCategoryPlayback` category
- Audio session must be activated
- Background audio queue for processing

#### Lock Screen Controls
- Automatically provided by Track Player
- Uses MPNowPlayingInfoCenter
- Updates track information automatically

#### Control Center
- Integrated automatically
- Shows current track information
- Provides playback controls

### Android

#### Foreground Service
- Required for background playback
- Media playback service type
- Handles media session

#### Media Session
- Automatically configured by Track Player
- Provides lock screen controls
- Handles remote control events

#### Notification
- Media notification with controls
- Shows track information
- Provides quick access to controls

---

## 🧪 Testing Strategy

### Unit Tests
- Track Player service registration
- Audio source routing logic
- State management functions
- Event handler functions

### Integration Tests
- Background playback continuation
- Lock screen control functionality
- Notification control functionality
- Remote control functionality
- App state transitions

### E2E Tests
- Complete background playback flow
- Lock screen control flow
- Notification control flow
- Remote control flow
- Interruption handling flow

### Manual Testing
- Extended background playback (> 30 minutes)
- Lock screen control responsiveness
- Notification control functionality
- Bluetooth device controls
- Car system integration
- App state transitions

---

## 🐛 Error Handling

### Error Types
- Track Player initialization errors
- Playback errors
- Network errors (streaming)
- File access errors (local files)
- Audio session errors (iOS)
- Media session errors (Android)

### Error Handling Strategy
- Try-catch blocks around all audio operations
- Error state in hooks and components
- User-friendly error messages
- Automatic retry for transient failures
- Fallback to alternative audio sources

### Error Recovery
- Automatic retry for network errors
- Fallback to local files if available
- State preservation on errors
- Graceful degradation

---

## 📊 Performance Considerations

### Optimization
- Lazy initialization of Track Player
- Efficient state updates
- Debounced progress updates
- Cached track metadata
- Background audio queue for processing

### Battery Optimization
- Efficient audio processing
- Minimal background activity
- Proper audio session management
- Background task optimization

### Memory Management
- Track metadata caching
- Queue size limits
- Proper cleanup on unmount
- Audio file cleanup

---

## 🔄 Background Download Integration

### BackgroundDownloadService
**Location:** `src/services/BackgroundDownloadService.ts`

**Purpose:** Background downloads of audio files for offline playback

**Features:**
- Category-based downloads
- Favorites download
- Queue management
- Priority-based downloads

**Integration:**
- Works alongside background playback
- Downloads don't interfere with playback
- Downloads continue in background
- Automatic retry on failure

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
