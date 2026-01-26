# Background Audio System - Services Documentation

## 🔧 Service Layer Overview

The background audio system uses a service-oriented architecture with clear separation of concerns. Services handle background playback, audio routing, native integration, and download management.

---

## 📦 Services

### TrackPlayerService
**File:** `src/services/TrackPlayerService.ts`  
**Type:** Background Service Function  
**Purpose:** Background playback service registration for react-native-track-player

#### Registration
**Location:** `index.js`

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

#### Methods

**`PlaybackService()` - Async Function**
- Registers event listeners for remote control events
- Handles remote play, pause, stop, and seek events
- Required for background playback functionality
- Called automatically by Track Player in background

#### Event Handlers

**`Event.RemotePlay`**
- Triggered when play is requested from remote control
- Calls `TrackPlayer.play()`
- Works from lock screen, notification, Bluetooth devices

**`Event.RemotePause`**
- Triggered when pause is requested from remote control
- Calls `TrackPlayer.pause()`
- Works from lock screen, notification, Bluetooth devices

**`Event.RemoteStop`**
- Triggered when stop is requested from remote control
- Calls `TrackPlayer.stop()`
- Works from lock screen, notification, Bluetooth devices

**`Event.RemoteSeek`**
- Triggered when seek is requested from remote control
- Calls `TrackPlayer.seekTo(position)`
- Works from lock screen, notification, Bluetooth devices

#### Dependencies
- `react-native-track-player` - Background playback library
- Track Player must be initialized before service registration

#### Error Handling
- Try-catch around registration
- Warning logged if registration fails
- App continues without background service if registration fails

---

### UnifiedAudioPlaybackService
**File:** `src/services/UnifiedAudioPlaybackService.ts`  
**Type:** Singleton Class  
**Purpose:** Unified audio source routing with background playback support

#### Configuration
```typescript
class UnifiedAudioPlaybackService {
  private static instance: UnifiedAudioPlaybackService;
  private audioManager: SupabaseAudioLibraryManager;
  private generationService: SoundGenerationService;
}
```

#### Methods

**`getInstance(): UnifiedAudioPlaybackService`**
- Returns singleton instance
- Creates instance if not exists
- Thread-safe singleton pattern

**`initialize(): Promise<void>`**
- Initializes audio managers
- Cleans up old generated files
- Called on app startup
- Error handling with logging

**`playSound(sound: Sound): Promise<void>`**
- Main playback method
- Routes to appropriate source based on priority
- Priority: Generated > Local > Stream
- All routes use Track Player for background support

**`playGeneratedSound(sound: Sound): Promise<void>`**
- Plays generated sounds (wave, rain, noise)
- Uses SoundGenerationService
- Routes to Track Player for background playback
- Error handling with fallback

**`playLocalFile(sound: Sound, filePath: string): Promise<void>`**
- Plays local downloaded files
- Creates Track object with file:// URL
- Adds to Track Player queue
- Starts playback via Track Player
- Background playback automatic

**`playStream(sound: Sound): Promise<void>`**
- Plays streaming audio from server
- Gets stream URL from Supabase
- Creates Track object with stream URL
- Adds to Track Player queue
- Starts playback via Track Player
- Background playback automatic

**`getLocalSoundPath(sound: Sound): Promise<string | null>`**
- Checks if sound is available locally
- Attempts on-demand download if not local
- Returns local file path or null
- Used for playback priority routing

**`detectSoundSource(sound: Sound): Promise<'generated' | 'local' | 'stream'>`**
- Detects sound source type
- Returns source type for routing decisions
- Used for optimization and logging

**`isAvailableOffline(sound: Sound): Promise<boolean>`**
- Checks if sound is available offline
- Generated sounds always available
- Local files available if downloaded
- Streaming sounds not available offline

#### Playback Priority
1. **Generated sounds** - Always available, fastest
2. **Local files** - Downloaded, no network needed
3. **Streaming** - Requires network, fallback option

#### Track Player Integration
All playback methods use Track Player:
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

#### Background Support
- All playback routes through Track Player
- Track Player handles background automatically
- Lock screen controls automatically available
- Media notifications automatically shown
- Remote controls automatically enabled

#### Dependencies
- `react-native-track-player` - Background playback
- `SupabaseAudioLibraryManager` - Local file management
- `SoundGenerationService` - Generated sound creation
- `react-native-fs` - File system operations

---

### NativeMultiTrackAudioService
**File:** `src/services/NativeMultiTrackAudioService.ts`  
**Type:** Singleton Class  
**Purpose:** Multi-track simultaneous playback with background support

#### Configuration
```typescript
class NativeMultiTrackAudioService {
  private static instance: NativeMultiTrackAudioService;
  private tracks: Map<string, AudioTrack>;
  private isInitialized: boolean;
}
```

#### Methods

**`getInstance(): NativeMultiTrackAudioService`**
- Returns singleton instance
- Creates instance if not exists
- Thread-safe singleton pattern

**`initialize(): Promise<void>`**
- Initializes native audio bridge
- Sets up audio session for background
- Called before first use
- Error handling with logging

**`addTrack(trackId: string, soundUri: string, volume: number): Promise<void>`**
- Adds track to multi-track player
- Loads audio file via native bridge
- Sets initial volume
- Stores track in Map

**`removeTrack(trackId: string): Promise<void>`**
- Removes track from player
- Stops playback if playing
- Cleans up native resources
- Removes from Map

**`playTrack(trackId: string): Promise<void>`**
- Starts playback of specific track
- Works in background via native session
- Error handling with logging

**`pauseTrack(trackId: string): Promise<void>`**
- Pauses playback of specific track
- Preserves playback position
- Works in background

**`stopTrack(trackId: string): Promise<void>`**
- Stops playback of specific track
- Resets playback position
- Works in background

**`playAll(): Promise<void>`**
- Starts playback of all tracks simultaneously
- Works in background
- Error handling per track

**`pauseAll(): Promise<void>`**
- Pauses playback of all tracks
- Preserves playback positions
- Works in background

**`stopAll(): Promise<void>`**
- Stops playback of all tracks
- Resets playback positions
- Works in background

**`setTrackVolume(trackId: string, volume: number): Promise<void>`**
- Sets volume for specific track (0.0 - 1.0)
- Works in background
- Real-time volume adjustment

**`setTrackPan(trackId: string, pan: number): Promise<void>`**
- Sets pan for specific track (-1.0 to 1.0)
- Works in background
- Real-time pan adjustment

**`getTracks(): AudioTrack[]`**
- Returns all tracks
- Returns array of track objects
- Used for UI display

**`getTrack(trackId: string): AudioTrack | null`**
- Returns specific track
- Returns null if not found
- Used for track queries

**`getTrackCount(): number`**
- Returns number of active tracks
- Used for UI display

**`cleanup(): Promise<void>`**
- Cleans up all tracks
- Stops all playback
- Releases native resources
- Called on app shutdown

#### Background Configuration

**iOS:**
```objective-c
// Set up audio session for background playback
AVAudioSession *session = [AVAudioSession sharedInstance];
[session setCategory:AVAudioSessionCategoryPlayback error:&error];
[session setActive:YES error:&error];

// Create dedicated audio queue for background processing
_audioQueue = dispatch_queue_create("com.awave.audio", DISPATCH_QUEUE_SERIAL);
```

**Android:**
- Uses MediaPlayer/ExoPlayer with background service
- Foreground service for reliable playback
- Media session for controls

#### Dependencies
- `NativeAudioBridge` - Native module bridge
- `AWAVEAudioModule` (iOS) - Native audio engine
- Native audio module (Android) - Native audio engine

---

### BackgroundDownloadService
**File:** `src/services/BackgroundDownloadService.ts`  
**Type:** Singleton Class  
**Purpose:** Background downloads of audio files for offline playback

#### Configuration
```typescript
class BackgroundDownloadService {
  private static instance: BackgroundDownloadService;
  private audioManager: SupabaseAudioLibraryManager;
  private isDownloading: boolean;
  private downloadQueue: DownloadQueueItem[];
}
```

#### Methods

**`getInstance(): BackgroundDownloadService`**
- Returns singleton instance
- Creates instance if not exists

**`downloadFavorites(userId: string): Promise<void>`**
- Downloads user's favorite sounds
- High priority downloads
- Triggered after login
- Queue management

**`downloadCategory(categoryId: string): Promise<void>`**
- Downloads all files from category
- Priority based on Audio Inventory
- Progress tracking
- Error handling per file

**`downloadPriorityCategories(): Promise<void>`**
- Downloads priority categories
- Priority order: music > nature > noise > sound
- Sequential downloads
- Progress tracking

**`isCurrentlyDownloading(): boolean`**
- Returns download status
- Used for UI display
- Prevents duplicate downloads

**`getQueueSize(): number`**
- Returns queue size
- Used for UI display
- Progress tracking

#### Download Priority
1. **Favorites** - User's favorite sounds (highest priority)
2. **Music category** - 477 files
3. **Nature category** - 16 files
4. **Noise category** - 6 files
5. **Sound category** - 15 files

#### Background Support
- Downloads continue in background
- Doesn't interfere with playback
- Automatic retry on failure
- Progress tracking

#### Dependencies
- `SupabaseAudioLibraryManager` - Download management
- `react-native-fs` - File system operations

---

## 🔗 Service Dependencies

### Dependency Graph
```
App Startup
    │
    └─> index.js
        └─> TrackPlayerService (registration)
            └─> react-native-track-player

AudioPlayerEnhanced
    │
    ├─> useAudioPlayer
    │   └─> TrackPlayer (background playback)
    │       └─> TrackPlayerService (remote events)
    │
    └─> UnifiedAudioPlaybackService
        ├─> SupabaseAudioLibraryManager (local files)
        ├─> SoundGenerationService (generated sounds)
        └─> TrackPlayer (all playback)

useMultiTrackMixer
    │
    └─> NativeMultiTrackAudioService
        └─> NativeAudioBridge
            └─> AWAVEAudioModule (iOS)
                └─> AVAudioSession (background)
```

### External Dependencies

#### react-native-track-player
- **Purpose:** Background audio playback engine
- **Features:** Background playback, lock screen controls, media notifications, remote controls
- **Configuration:** Automatic via service registration
- **Platform Support:** iOS and Android

#### Native Audio Modules
- **iOS:** `AWAVEAudioModule` with `AVAudioEngine`
- **Android:** MediaPlayer/ExoPlayer with foreground service
- **Purpose:** Multi-track simultaneous playback
- **Background:** Via audio session configuration

#### Supabase Audio Library Manager
- **Purpose:** Local file management and downloads
- **Features:** Download management, file caching, offline availability
- **Integration:** Used by UnifiedAudioPlaybackService

#### Sound Generation Service
- **Purpose:** Procedural sound generation
- **Features:** Wave, rain, noise generation
- **Integration:** Used by UnifiedAudioPlaybackService

---

## 🔄 Service Interactions

### Background Playback Flow
```
User Action (Play Sound)
    │
    └─> UnifiedAudioPlaybackService.playSound()
        │
        ├─> Generated Sound?
        │   └─> SoundGenerationService
        │       └─> TrackPlayer.play() (background automatic)
        │
        ├─> Local File?
        │   └─> SupabaseAudioLibraryManager
        │       └─> TrackPlayer.play() (background automatic)
        │
        └─> Streaming?
            └─> TrackPlayer.play() (background automatic)
                │
                └─> TrackPlayerService (remote events)
                    └─> Lock Screen Controls
                    └─> Media Notifications
                    └─> Remote Controls
```

### Multi-Track Background Flow
```
User Action (Play Multi-Track)
    │
    └─> NativeMultiTrackAudioService.playAll()
        │
        └─> NativeAudioBridge
            └─> AWAVEAudioModule (iOS)
                └─> AVAudioSession (background configured)
                    └─> Background playback
```

### Background Download Flow
```
App Startup / User Action
    │
    └─> BackgroundDownloadService.downloadFavorites()
        │
        └─> SupabaseAudioLibraryManager.downloadFile()
            └─> Background download (doesn't interfere with playback)
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- State management
- Queue management
- Download logic

### Integration Tests
- Track Player integration
- Native module integration
- Background playback continuation
- Lock screen control functionality
- Download management

### Mocking
- Track Player library
- Native audio modules
- File system operations
- Network requests

---

## 📊 Service Metrics

### Performance
- **Track Player Initialization:** < 500ms
- **Playback Start:** < 1 second
- **Background Transition:** < 100ms
- **Control Response:** < 500ms
- **Download Speed:** Varies by network

### Reliability
- **Background Playback Success Rate:** > 99%
- **Lock Screen Control Response Rate:** > 99%
- **Remote Control Response Rate:** > 95%
- **Download Success Rate:** > 90%

### Error Rates
- **Playback Errors:** < 1%
- **Control Errors:** < 1%
- **Download Errors:** < 10%
- **Network Errors:** < 5%

---

## 🔐 Security Considerations

### Audio File Access
- Local files stored securely
- Streaming URLs use authentication
- Generated files in app sandbox
- No sensitive data in audio files

### Background Permissions
- iOS: `UIBackgroundModes: audio` in Info.plist
- Android: Foreground service permission
- No user data transmitted in background

### Network Security
- All streaming uses HTTPS
- Authentication tokens for Supabase
- Secure file downloads
- No credentials in logs

---

## 🐛 Error Handling

### Service-Level Errors
- Try-catch blocks around all operations
- Error logging for debugging
- User-friendly error messages
- Automatic retry for transient failures
- Graceful degradation

### Error Types
- **Playback Errors:** Track Player errors, file errors
- **Control Errors:** Remote control failures
- **Download Errors:** Network errors, file system errors
- **Native Errors:** Audio session errors, module errors

### Error Recovery
- Automatic retry for network errors
- Fallback to alternative audio sources
- State preservation on errors
- User notification for critical errors

---

## 📝 Service Configuration

### Environment Variables
```typescript
// No environment variables required
// Configuration via Info.plist (iOS) and AndroidManifest.xml (Android)
```

### Service Initialization
```typescript
// App startup
TrackPlayerService registered in index.js

// Before first use
await UnifiedAudioPlaybackService.getInstance().initialize();
await NativeMultiTrackAudioService.getInstance().initialize();
```

### Service Cleanup
```typescript
// App shutdown
await NativeMultiTrackAudioService.getInstance().cleanup();
// Track Player cleanup handled automatically
```

---

## 🔄 Service Updates

### Future Enhancements
- Enhanced error recovery
- Offline playback improvements
- Download queue prioritization
- Background download scheduling
- Multi-device sync

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
