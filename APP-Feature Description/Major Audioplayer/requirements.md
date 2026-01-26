# Major Audioplayer System - Functional Requirements

## 📋 Core Requirements

### 1. Multiplayer Architecture (Multi-Sound System Only)

#### Track Mixer System
- [x] **Multiplayer setup only** - All playback is multi-sound based
- [x] Up to 7 track mixers OR one track mixer per sound journey
- [x] Track mixer tiles always based on multi-sound playing system
- [x] Dynamic track management (add, remove, toggle/mute)
- [x] Individual volume control per track
- [x] **Time control calculated by total length of loaded sounds**
- [x] **Dynamically calculated based on longest sound file integrated into the mix**
- [x] Automatic track loading from same category
- [x] Session tracking integration
- [x] Background audio support
- [x] Media controls (lock screen, control center)
- [x] **Play button controls the complete sound system** (starts/stops all sounds)
- [x] **Journey freezes where stopped (gets stored) and continues when started again**

### 2. Audio Playback Controls

#### Basic Playback
- [x] Play audio from sound selection
- [x] Pause playback
- [x] Resume playback
- [x] Stop playback
- [x] Seek to position
- [x] Volume control (master)
- [x] Loading state indication
- [x] Error handling and display

#### Advanced Playback
- [x] Individual track volume control
- [x] Track activation/deactivation
- [x] Track replacement during playback
- [x] Pan control for spatial positioning
- [x] Audio effects application
- [x] Playtime calculation and display
- [x] Progress tracking

### 3. Dynamic Track Management

#### Track Management
- [x] Create up to 7 track mixers OR one track mixer
- [x] Track mixer tiles always based on multi-sound playing system
- [x] Load related sounds from same category
- [x] Activate/deactivate tracks dynamically (mute/unmute)
- [x] Add sounds to empty tracks dynamically
- [x] Remove sounds from tracks dynamically
- [x] Replace sounds in tracks dynamically
- [x] Track state persistence

#### Playback Behavior
- [x] Multi-sound playback system (all active tracks play simultaneously)
- [x] **Time control calculated by total length of loaded sounds**
- [x] **Dynamically calculated based on longest sound file integrated into the mix**
- [x] Progress tracking for complete mix
- [x] Current mix indication
- [x] **Play button controls complete sound system** (starts/stops all sounds)
- [x] **Journey freezes where stopped (gets stored) and continues when started again**

### 4. Play Control System

#### Track Management
- [x] Add unlimited tracks to mixer
- [x] Remove tracks from mixer
- [x] Toggle tracks on/off
- [x] Clear track (remove sound)
- [x] Track state persistence in AsyncStorage
- [x] Auto-save mixer state (1s debounce)

#### Play Control Rules (Applies to All Player Integrations)
- [x] **Play button always controls the complete sound system**
- [x] Starts all active sounds simultaneously
- [x] Stops all sounds when paused
- [x] **Journey freezes where stopped (gets stored)**
- [x] **Journey continues when started again from stored position**
- [x] Applies to: Klangwelten, Background play, Phone Saving Screen, Miniplayer Stip and Klangwelten
- [x] Independent volume per track
- [x] Master volume control is handled by iOS native sound volume (all mixed sounds get louder or less loudy, based on users phone volume control)

### 5. Audio Waveform Visualization

#### Visualization Display
- [x] Animated waveform bars (7 bars)
- [x] Purple gradient background
- [x] Floating orbs animation (3 orbs)
- [x] Gradient overlay sweep animation
- [x] Title and description display when paused
- [x] Toggle between visualization modes
- [x] Real-time animation updates

#### Animation Behavior
- [x] Waveform bars animate during playback
- [x] Random height variations for bars
- [x] Smooth transitions between states
- [x] Orb floating animations (continuous)
- [x] Gradient sweep animation
- [x] Performance optimization for animations

### 6. Procedural Sound Generation

#### Wave Sound Generation
- [x] Generate ocean wave sounds
- [x] Generate lake wave sounds
- [x] Generate river wave sounds
- [x] Configurable duration (default 300s)
- [x] Native module integration
- [x] File caching and storage

#### Rain Sound Generation
- [x] Generate light rain sounds
- [x] Generate medium rain sounds
- [x] Generate heavy rain sounds
- [x] Configurable duration
- [x] Native module integration
- [x] File caching and storage

#### Noise Sound Generation
- [x] Generate white noise
- [x] Generate pink noise
- [x] Generate brown noise
- [x] Configurable duration
- [x] Native module integration
- [x] File caching and storage

#### Cache Management
- [x] Check for existing generated files
- [x] Cache files for 7 days
- [x] Automatic cleanup of old files
- [x] Regenerate if cache expired
- [x] Directory structure management

### 7. Session Tracking

#### Session Creation
- [x] Automatic session creation on playback start
- [x] Session ID generation
- [x] User ID association
- [x] Sound ID association
- [x] Favorite ID association (if applicable)
- [x] Start timestamp recording

#### Session Updates
- [x] Progress updates every 30 seconds
- [x] Current time tracking
- [x] Total duration tracking
- [x] Progress percentage calculation
- [x] Active tracks consideration

#### Session Completion
- [x] Automatic completion on stop
- [x] Automatic completion on player close
- [x] Duration calculation (seconds)
- [x] Session status update
- [x] Error handling for completion

### 8. Background Audio Support

#### Background Playback
- [x] Continue playback when app backgrounds
- [x] Media controls in lock screen
- [x] Media controls in control center
- [x] Notification controls
- [x] App state change handling
- [x] Automatic pause on app background (optional)

#### Media Controls
- [x] Play button
- [x] Pause button
- [x] Stop button
- [x] Seek controls
- [x] Track information display
- [x] Artwork display

### 9. Audio Source Management

#### Source Priority
- [x] Generated sounds (highest priority)
- [x] Local files (downloaded)
- [x] Server streaming (Supabase)
- [x] Automatic source selection
- [x] Fallback mechanism

#### Audio Loading
- [x] Load from Supabase storage
- [x] Load from local file system
- [x] Generate procedural sounds
- [x] Download management
- [x] Error handling for failed loads

### 10. User Interface

#### Player Layout
- [x] Full-screen player view
- [x] Bottom sheet player view
- [x] Close button with animation
- [x] Gesture-based closing (swipe down)
- [x] Safe area handling
- [x] Responsive layout

#### Controls Display
- [x] Play/Pause button
- [x] Progress bar with seek
- [x] Volume control
- [x] Timer display
- [x] Track information
- [x] Favorite button
- [x] Mixer controls (multi-track)

#### Track Management UI
- [x] Track list display
- [x] Track toggle controls
- [x] Volume sliders per track
- [x] Track replacement interface
- [x] Active track indication
- [x] Empty track placeholders

---

## 🎯 User Stories

### As a user, I want to:
- Play individual sounds so I can listen to meditations
- Create custom sound journeys with multiple tracks so I can personalize my experience
- Mix multiple sounds simultaneously so I can create my own sound world
- See visual feedback during playback so I feel engaged
- Control playback from the lock screen so I don't need to unlock my phone
- Generate sounds on my device so I can use them offline
- Adjust individual track volumes so I can balance the mix
- Toggle tracks on/off so I can customize my journey in real-time
- See my listening progress so I know how much time I've spent
- Resume interrupted sessions so I don't lose my progress

### As a user experiencing issues, I want to:
- See clear error messages when playback fails
- Have playback automatically resume after network issues
- Get feedback when tracks are loading
- Know when sounds are being generated
- Understand why certain features aren't available

---

## ✅ Acceptance Criteria

### Playback
- [x] Audio starts playing within 2 seconds of selection
- [x] Playback continues smoothly without interruptions
- [x] Volume changes take effect immediately
- [x] Seek operations complete within 500ms
- [x] Error messages are user-friendly and actionable

### Multi-Track Mixer System
- [x] Up to 7 track mixers OR one track mixer can be loaded per journey
- [x] Track mixer tiles always based on multi-sound playing system
- [x] All active tracks play simultaneously (multiplayer setup)
- [x] Time control calculated by total length of loaded sounds
- [x] Dynamically calculated based on longest sound file in mix
- [x] Volume changes apply immediately
- [x] Track toggling (mute/unmute) doesn't interrupt playback
- [x] Playtime updates when tracks are added/removed/toggled
- [x] Mixer state and journey freeze state persist across app sessions

### Visualization
- [x] Waveform bars animate during playback
- [x] Animations are smooth (60fps)
- [x] Visualization toggles without lag
- [x] Title/description displays when paused
- [x] Gradient animations are continuous

### Sound Generation
- [x] Generated sounds are created within 5 seconds
- [x] Cached sounds load instantly
- [x] Old cache files are cleaned up automatically
- [x] Generation errors are handled gracefully
- [x] Generated files are stored correctly

### Session Tracking
- [x] Sessions are created on playback start
- [x] Progress updates every 30 seconds
- [x] Sessions complete on stop/close
- [x] Duration is calculated accurately
- [x] Errors don't prevent playback

### Background Audio
- [x] Playback continues in background
- [x] Media controls appear in lock screen
- [x] Controls respond to user actions
- [x] Track information displays correctly
- [x] App state changes are handled

---

## 🚫 Non-Functional Requirements

### Performance
- Audio playback starts within 2 seconds
- Track switching completes within 500ms
- Visualization animations run at 60fps
- Sound generation completes within 5 seconds
- UI remains responsive during playback

### Reliability
- Playback continues without interruptions
- Network errors don't crash the app
- File errors are handled gracefully
- Session tracking doesn't block playback
- Background playback is stable

### Usability
- Controls are intuitive and discoverable
- Error messages are clear and actionable
- Loading states provide feedback
- Animations enhance rather than distract
- Gestures work smoothly

### Accessibility
- Media controls are accessible
- Screen reader support for controls
- High contrast mode support
- Touch target sizes meet guidelines
- Audio feedback for actions

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before playback
- [x] Fallback to local files when available
- [x] Error messages for network failures
- [x] Retry mechanism for failed loads
- [x] Graceful degradation

### File Issues
- [x] Missing file handling
- [x] Corrupted file detection
- [x] Invalid format handling
- [x] File permission errors
- [x] Storage space warnings

### Playback Issues
- [x] Interrupted playback recovery
- [x] Multiple playback attempts
- [x] Track switching during playback
- [x] Volume changes during playback
- [x] App backgrounding during playback

### State Management
- [x] Mixer state corruption recovery
- [x] Session state persistence
- [x] Track state synchronization
- [x] Volume state persistence
- [x] Playback state recovery

### Generation Issues
- [x] Generation failure handling
- [x] Cache corruption recovery
- [x] Storage space management
- [x] Native module unavailability
- [x] Generation timeout handling

---

## 📊 Success Metrics

- Playback start time < 2 seconds
- Track switching time < 500ms
- Sound generation time < 5 seconds
- Session tracking accuracy > 99%
- Background playback stability > 99%
- User satisfaction with controls > 4.5/5
- Error rate < 1%
- Cache hit rate > 80%

---

## 🔐 Security & Privacy

### Audio File Security
- [x] Secure file storage
- [x] Access control for audio files
- [x] Encryption for sensitive data
- [x] Secure deletion of cached files

### Session Data Privacy
- [x] User consent for tracking
- [x] Anonymized session data
- [x] Secure transmission of analytics
- [x] Data retention policies

---

## 📱 Platform-Specific Requirements

### iOS
- [x] AVAudioEngine integration
- [x] Background audio configuration
- [x] Media controls support
- [x] Audio session management
- [x] Interruption handling

### Android
- [x] AudioTrack integration
- [x] MediaPlayer integration
- [x] Background audio service
- [x] Media controls support
- [x] Audio focus management

---

## 🔄 Integration Requirements

### Required Services
- [x] SupabaseAudioLibraryManager
- [x] SessionTrackingService
- [x] SoundGenerationService
- [x] NativeAudioBridge
- [x] TrackPlayerService

### Required Hooks
- [x] useAudioPlayer
- [x] useMultiTrackMixer
- [x] useSupabaseAudio
- [x] useFavoritesManagement

### Required Components
- [x] AudioPlayerEnhanced
- [x] AudioPlayerLayout
- [x] AudioPlayerVisualization
- [x] AudioPlayerControls
- [x] AudioPlayerMixerSheet

---

*For technical implementation details, see `technical-spec.md`*  
*For component specifications, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flow diagrams, see `user-flows.md`*
