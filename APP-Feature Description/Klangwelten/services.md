# Klangwelten System - Services Documentation

## 🔧 Service Layer Overview

The Klangwelten system uses a service-oriented architecture with clear separation between audio playback, state management, and UI components. Services handle all audio operations, state persistence, and native module interactions.

---

## 📦 Services

### NativeMultiTrackAudioService
**File:** `src/services/NativeMultiTrackAudioService.ts`  
**Type:** Singleton Class  
**Purpose:** Native multi-track audio playback management

#### Configuration
```typescript
class NativeMultiTrackAudioService {
  private static instance: NativeMultiTrackAudioService;
  private tracks: Map<string, AudioTrack> = new Map();
  private isInitialized: boolean = false;
}
```

#### Methods

**`getInstance(): NativeMultiTrackAudioService`**
- Returns singleton instance
- Creates instance if not exists
- Ensures single audio service instance

**`initialize(): Promise<void>`**
- Initializes native audio engine
- Sets up AVAudioEngine (iOS) or equivalent (Android)
- Prepares audio session
- Called automatically on first track add
- Throws error on initialization failure

**`addTrack(trackId: string, soundUri: string, volume: number = 0.8): Promise<void>`**
- Adds new track to mixer
- Loads audio file into native module
- Sets initial volume
- Creates track object in map
- Throws error on failure

**`removeTrack(trackId: string): Promise<void>`**
- Removes track from mixer
- Stops track if playing
- Unloads audio from native module
- Removes from tracks map
- Logs warning if track not found

**`playTrack(trackId: string): Promise<void>`**
- Plays specific track
- Starts audio playback
- Updates track isPlaying state
- Throws error on failure

**`pauseTrack(trackId: string): Promise<void>`**
- Pauses specific track
- Stops audio playback (paused state)
- Updates track isPlaying state
- Throws error on failure

**`stopTrack(trackId: string): Promise<void>`**
- Stops specific track
- Stops audio playback and resets position
- Updates track isPlaying state
- Throws error on failure

**`playAll(): Promise<void>`**
- Plays all tracks in mixer
- Iterates through all tracks
- Calls playTrack for each
- Logs operation

**`pauseAll(): Promise<void>`**
- Pauses all tracks in mixer
- Iterates through all tracks
- Calls pauseTrack for each
- Logs operation

**`stopAll(): Promise<void>`**
- Stops all tracks in mixer
- Iterates through all tracks
- Calls stopTrack for each
- Logs operation

**`setTrackVolume(trackId: string, volume: number): Promise<void>`**
- Sets volume for specific track (0-1)
- Clamps volume to 0-1 range
- Updates volume in native module
- Updates track volume in map
- Throws error on failure

**`setTrackPan(trackId: string, pan: number): Promise<void>`**
- Sets pan for specific track (-1 to 1)
- Clamps pan to -1 to 1 range
- Updates pan in native module
- Updates track pan in map
- Throws error on failure

**`getTracks(): AudioTrack[]`
- Returns array of all tracks
- Converts map values to array
- Returns current track states

**`getTrack(trackId: string): AudioTrack | null`**
- Gets specific track by ID
- Returns track or null if not found
- Returns current track state

**`getTrackCount(): number`**
- Returns number of active tracks
- Returns tracks map size

**`cleanup(): Promise<void>`**
- Cleans up audio engine
- Stops all tracks
- Removes all tracks
- Resets initialization state
- Logs cleanup operation

#### Error Handling
- All async methods throw errors on failure
- Errors logged with context
- User-friendly error messages in UI layer
- Graceful degradation when service unavailable

#### Dependencies
- `NativeAudioBridge` - Native module bridge
- Native AWAVEAudioModule (iOS/Android)
- AVAudioEngine (iOS)

---

### useMultiTrackMixer Hook
**File:** `src/hooks/useMultiTrackMixer.ts`  
**Type:** React Hook  
**Purpose:** Multi-track mixer state management and UI integration

#### Configuration
```typescript
const MIXER_STATE_KEY = 'awaveMixerState';

const createDefaultMixerState = (): MixerState => ({
  tracks: [
    { id: 'track-1', sound: null, volume: 80, isActive: false, isPlaying: false },
    { id: 'track-2', sound: null, volume: 80, isActive: false, isPlaying: false },
    { id: 'track-3', sound: null, volume: 80, isActive: false, isPlaying: false },
  ],
  masterVolume: 100,
  isPlaying: false,
});
```

#### State
- `mixerState: MixerState` - Current mixer state
- `isLoading: boolean` - Loading state
- `error: string | null` - Error state

#### Methods

**`setTrackSound(trackId: string, sound: Sound): Promise<void>`**
- Assigns sound to track
- Updates track in state
- Loads sound into audio service
- Sets track as active
- Handles errors

**`setTrackVolume(trackId: string, volume: number): Promise<void>`**
- Sets track volume (0-100)
- Clamps volume to 0-100
- Updates state
- Updates audio service
- Handles errors

**`toggleTrack(trackId: string): Promise<void>`**
- Toggles track active state
- Plays/pauses track in audio service
- Updates state
- Handles errors

**`clearTrack(trackId: string): Promise<void>`**
- Removes sound from track
- Removes track from audio service
- Resets track state
- Handles errors

**`playAll(): Promise<void>`**
- Plays all active tracks
- Checks for active tracks
- Calls audio service playAll
- Updates playing states
- Handles errors

**`pauseAll(): Promise<void>`**
- Pauses all tracks
- Calls audio service pauseAll
- Updates playing states
- Handles errors

**`stopAll(): Promise<void>`**
- Stops all tracks
- Calls audio service stopAll
- Updates playing states
- Handles errors

**`setMasterVolume(volume: number): void`**
- Sets master volume (0-100)
- Clamps volume to 0-100
- Updates state
- (Future: applies to all tracks)

**`saveMixerState(): Promise<void>`**
- Saves state to AsyncStorage
- Serializes state to JSON
- Handles errors silently

**`loadMixerState(): Promise<void>`**
- Loads state from AsyncStorage
- Deserializes JSON
- Updates state
- Handles errors gracefully

**`resetMixer(): Promise<void>`**
- Resets mixer to defaults
- Cleans up audio service
- Resets state
- Handles errors

#### Lifecycle
- **Mount:** Initialize audio service, load saved state
- **Update:** Auto-save state on changes (debounced 1s)
- **Unmount:** Cleanup handled by audio service

#### Dependencies
- `NativeMultiTrackAudioService` - Audio service
- `AsyncStorage` - State persistence
- Sound data structure

---

## 🔗 Service Dependencies

### Dependency Graph
```
KlangweltenScreen
├── useMultiTrackMixer
│   ├── NativeMultiTrackAudioService
│   │   └── NativeAudioBridge
│   │       └── AWAVEAudioModule (Native)
│   └── AsyncStorage
│       └── Device Storage
└── Sound Data
    └── exactDataStructures
```

### External Dependencies

#### Native Modules
- **AWAVEAudioModule** - Native audio module (iOS/Android)
- **NativeAudioBridge** - React Native bridge to native module

#### Storage
- **AsyncStorage** - Local key-value storage for state persistence

#### Data
- **exactDataStructures** - Sound data structure definitions

---

## 🔄 Service Interactions

### Sound Selection Flow
```
User selects sound
    │
    └─> useMultiTrackMixer.setTrackSound()
        ├─> Update state (immediate)
        └─> NativeMultiTrackAudioService.addTrack()
            └─> NativeAudioBridge.loadTrack()
                └─> AWAVEAudioModule (Native)
                    └─> Load audio file
```

### Playback Flow
```
User presses play
    │
    └─> useMultiTrackMixer.playAll()
        └─> NativeMultiTrackAudioService.playAll()
            └─> For each active track:
                └─> NativeAudioBridge.playTrack()
                    └─> AWAVEAudioModule (Native)
                        └─> Start playback
```

### Volume Adjustment Flow
```
User adjusts volume
    │
    └─> useMultiTrackMixer.setTrackVolume()
        ├─> Update state (immediate)
        └─> NativeMultiTrackAudioService.setTrackVolume()
            └─> NativeAudioBridge.setVolume()
                └─> AWAVEAudioModule (Native)
                    └─> Update volume
```

### State Persistence Flow
```
State changes
    │
    └─> useEffect detects change
        └─> Debounce 1 second
            └─> useMultiTrackMixer.saveMixerState()
                └─> AsyncStorage.setItem()
                    └─> Device Storage
                        └─> Save JSON
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- State management
- Track operations
- Volume control
- Playback control

### Integration Tests
- Audio service initialization
- Track loading
- Multi-track playback
- Volume adjustment
- State persistence
- Error recovery

### Mocking
- NativeAudioBridge
- AsyncStorage
- Native modules
- Audio files

---

## 📊 Service Metrics

### Performance
- **Audio Initialization:** < 500ms
- **Track Loading:** < 1 second per track
- **Volume Adjustment:** < 50ms
- **State Save:** < 100ms
- **State Load:** < 200ms

### Reliability
- **Audio Playback Success Rate:** > 95%
- **State Persistence Success Rate:** > 99%
- **Error Recovery Rate:** > 90%

### Error Rates
- **Initialization Failures:** < 1%
- **Track Loading Failures:** < 2%
- **Playback Errors:** < 3%
- **State Persistence Errors:** < 1%

---

## 🔐 Security Considerations

### Audio File Access
- Audio files loaded from app bundle or secure storage
- No network audio loading (future: secure HTTPS)
- File path validation

### State Storage
- No sensitive data in persisted state
- Sound data serialized safely
- JSON validation on load

### Native Module Security
- Native modules handle audio securely
- No audio data exposed to JavaScript
- Secure audio session management

---

## 🐛 Error Handling

### Service-Level Errors
- Initialization failures
- Track loading failures
- Playback errors
- Volume adjustment errors
- State persistence errors

### Error Types
- **Network Errors:** Not applicable (local files)
- **File Errors:** Audio file not found, corrupted
- **Audio Errors:** Playback failures, device unavailable
- **State Errors:** Storage failures, corrupted state

### Error Recovery
- Graceful degradation
- User-friendly error messages
- Retry mechanisms where applicable
- State recovery from defaults

---

## 📝 Service Configuration

### Audio Service Configuration
```typescript
// Singleton pattern
const audioService = NativeMultiTrackAudioService.getInstance();

// Initialize on first use
await audioService.initialize();
```

### Mixer Hook Configuration
```typescript
// Default state
const defaultState = {
  tracks: [3 empty tracks],
  masterVolume: 100,
  isPlaying: false,
};

// Storage key
const MIXER_STATE_KEY = 'awaveMixerState';
```

### State Persistence Configuration
- **Debounce:** 1 second
- **Storage Key:** 'awaveMixerState'
- **Format:** JSON
- **Auto-save:** Enabled
- **Auto-load:** Enabled on mount

---

## 🔄 Service Updates

### Future Enhancements
- Pan control implementation
- Audio effects (reverb, delay, EQ)
- More than 3 tracks support
- Master volume application
- Crossfade between mixes
- Sound world presets
- Cloud state sync

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
