# Background Audio System - Components Inventory

## 📱 Components

### AudioPlayerEnhanced
**File:** `src/components/AudioPlayerEnhanced.tsx`  
**Purpose:** Main audio player component with background playback support

**Player Type:** Audioplayer (Player 1 - Track Player)
- Supports up to 7 multitrack player mixers
- Dynamic track management (add, remove, toggle tracks)
- Individual volume control per track
- Playtime calculation based on active tracks
- Sequential playback of active tracks

**Props:**
```typescript
interface AudioPlayerEnhancedProps {
  sound: Sound;
  favoriteId?: string;
  onClose: () => void;
}
```

**State:**
- `isPlaying: boolean` - Playback state
- `isLoaded: boolean` - Track loaded state
- `currentTime: number` - Current playback position
- `duration: number` - Track duration
- `currentSessionId: string | null` - Session tracking ID

**Components Used:**
- `AudioPlayerBackground` - Background visualization
- `AudioPlayerControls` - Playback controls
- `AudioPlayerProgress` - Progress bar
- `AudioPlayerMetadata` - Track information
- `AudioPlayerMixer` - Multi-track mixer (up to 7 tracks)

**Hooks Used:**
- `useAudioPlayer` - Track Player integration
- `usePlaybackState` - Playback state from Track Player
- `useProgress` - Progress tracking from Track Player

**Background Features:**
- Track Player integration for background playback
- Session tracking in background
- Progress updates every 30 seconds
- App state monitoring (currently pauses on background - may need adjustment)

**User Interactions:**
- Play/Pause button
- Seek controls
- Volume control
- Track selection (up to 7 multitrack mixers)
- Close player

**Background Playback:**
- Uses Track Player for background playback
- Lock screen controls automatically available
- Media notifications automatically shown
- Remote controls automatically enabled

---

### useAudioPlayer Hook
**File:** `src/hooks/useAudioPlayer.ts`  
**Type:** React Hook  
**Purpose:** Track Player playback state and controls

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

**Features:**
- Automatic Track Player initialization
- Playback state tracking
- Progress tracking via `useProgress` hook
- Error handling
- Event listeners for playback events

**Initialization:**
- Sets up Track Player on mount
- Configures capabilities for controls
- Sets up notification capabilities
- Handles initialization errors

**Background Support:**
- Track Player handles background automatically
- State persists in background
- Controls work from lock screen
- Remote events are handled

---

### TrackPlayerService
**File:** `src/services/TrackPlayerService.ts`  
**Type:** Background Service  
**Purpose:** Background playback service registration

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

**Registration:**
- Registered in `index.js` on app startup
- Required for background playback
- Handles all remote control events

**Events Handled:**
- `Event.RemotePlay` - Play from remote control
- `Event.RemotePause` - Pause from remote control
- `Event.RemoteStop` - Stop from remote control
- `Event.RemoteSeek` - Seek from remote control

---

### UnifiedAudioPlaybackService
**File:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Service Class  
**Purpose:** Unified audio source routing with background support

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
- All playback routes through Track Player
- Track Player handles background automatically
- Lock screen controls automatically available
- Media notifications automatically shown

**Background Support:**
- All audio sources support background playback
- Track Player manages background state
- No additional configuration needed

---

### NativeMultiTrackAudioService
**File:** `src/services/NativeMultiTrackAudioService.ts`  
**Type:** Service Class  
**Purpose:** Multi-track simultaneous playback with background support

**Used By:**
- **Klangwelten (Player 2)**: 3 tracks mixing simultaneously
  - Individual volume control per track
  - Track toggle (activate/deactivate without stopping)
  - Sound world creation

**Methods:**
- `initialize()` - Initialize native audio engine
- `addTrack(trackId, soundUri, volume)` - Add track
- `removeTrack(trackId)` - Remove track
- `playTrack(trackId)` - Play track
- `pauseTrack(trackId)` - Pause track
- `stopTrack(trackId)` - Stop track
- `playAll()` - Play all tracks
- `pauseAll()` - Pause all tracks
- `stopAll()` - Stop all tracks
- `setTrackVolume(trackId, volume)` - Set track volume
- `setTrackPan(trackId, pan)` - Set track pan

**Background Configuration:**
- Uses native `AWAVEAudioModule` with `AVAudioSession`
- Audio session configured for background playback
- Dedicated audio queue for background processing

**iOS Background Setup:**
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

### useMultiTrackMixer Hook
**File:** `src/hooks/useMultiTrackMixer.ts`  
**Type:** React Hook  
**Purpose:** Multi-track mixer state and controls

**Returns:**
```typescript
{
  tracks: MixerTrack[];
  masterVolume: number;
  isPlaying: boolean;
  isLoading: boolean;
  error: string | null;
  
  setTrackSound: (trackId: string, sound: Sound) => Promise<void>;
  setTrackVolume: (trackId: string, volume: number) => Promise<void>;
  toggleTrack: (trackId: string) => Promise<void>;
  clearTrack: (trackId: string) => Promise<void>;
  
  playAll: () => Promise<void>;
  pauseAll: () => Promise<void>;
  stopAll: () => Promise<void>;
  setMasterVolume: (volume: number) => void;
  
  saveMixerState: () => Promise<void>;
  loadMixerState: () => Promise<void>;
  resetMixer: () => void;
}
```

**Background Support:**
- Uses NativeMultiTrackAudioService
- Background playback via native audio session
- State persists in background
- Controls work from lock screen (if configured)

---

## 🔗 Component Relationships

### Background Playback Flow
```
User Action
    │
    ├─> AudioPlayerEnhanced
    │   └─> useAudioPlayer
    │       └─> TrackPlayer.play()
    │           └─> TrackPlayerService (background service)
    │               └─> Lock Screen Controls
    │               └─> Media Notifications
    │               └─> Remote Controls
    │
    └─> UnifiedAudioPlaybackService
        └─> Route to Track Player
            └─> Background playback automatic
```

### Multi-Track Background Flow
```
User Action
    │
    └─> useMultiTrackMixer
        └─> NativeMultiTrackAudioService
            └─> NativeAudioBridge
                └─> AWAVEAudioModule (iOS)
                    └─> AVAudioSession (background)
                        └─> Background playback
```

---

## 🎨 Styling

### Theme Integration
- Components use theme system via `useTheme` hook
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Lock Screen Controls
- Automatically styled by system
- Track information from Track Player metadata
- Artwork from track artwork property
- Progress bar from Track Player

### Media Notifications
- Automatically styled by system
- Track information from Track Player metadata
- Artwork from track artwork property
- Controls from Track Player capabilities

---

## 🔄 State Management

### Local State
- Playback state (isPlaying, isPaused, etc.)
- Track information (currentTrack)
- Progress (position, duration)
- Loading states (isLoading)
- Error states (error)

### Track Player State
- Managed by Track Player library
- Persists in background
- Synchronized on foreground return
- Available via hooks (`usePlaybackState`, `useProgress`)

### Persistent State
- `AsyncStorage` - Mixer state, preferences
- Track Player - Queue state, playback position
- Native modules - Audio session state

---

## 🧪 Testing Considerations

### Component Tests
- Playback state updates
- Control button interactions
- Progress updates
- Error handling
- Background state transitions

### Integration Tests
- Track Player integration
- Background playback continuation
- Lock screen control functionality
- Notification control functionality
- Remote control functionality

### E2E Tests
- Complete background playback flow
- Lock screen control flow
- Notification control flow
- Remote control flow
- App state transitions

---

## 📊 Component Metrics

### Complexity
- **AudioPlayerEnhanced:** High (main player, multiple integrations)
- **useAudioPlayer:** Medium (Track Player integration)
- **TrackPlayerService:** Low (event handlers)
- **UnifiedAudioPlaybackService:** Medium (routing logic)
- **NativeMultiTrackAudioService:** High (native integration)

### Reusability
- **useAudioPlayer:** High (used in multiple components)
- **UnifiedAudioPlaybackService:** High (used for all playback)
- **TrackPlayerService:** Low (single registration)
- **NativeMultiTrackAudioService:** Medium (multi-track use cases)

### Dependencies
- All components depend on Track Player
- Components depend on theme system
- Components depend on navigation
- Native components depend on native modules

---

## 🔐 Background Configuration

### iOS Configuration
- `UIBackgroundModes: audio` in Info.plist
- `AVAudioSessionCategoryPlayback` in native module
- Audio session activation on initialization

### Android Configuration
- Foreground service in AndroidManifest.xml
- Media session service registration
- Notification channel for media controls

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
