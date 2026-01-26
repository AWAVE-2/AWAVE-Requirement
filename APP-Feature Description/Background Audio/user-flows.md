# Background Audio System - User Flows

## 🔄 Primary User Flows

### 1. Background Playback Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Start Playback
   └─> AudioPlayerEnhanced.play()
       └─> UnifiedAudioPlaybackService.playSound()
           └─> Route to Track Player
               └─> TrackPlayer.add(track)
                   └─> TrackPlayer.play()
                       └─> Playback starts

2. Background App
   └─> AppState changes to 'background'
       └─> Track Player continues playback
           └─> Audio session remains active
               └─> Lock screen controls appear
                   └─> Media notification appears
                       └─> Playback continues

3. Lock Device
   └─> Device locks
       └─> Track Player continues playback
           └─> Lock screen controls remain active
               └─> Track information displayed
                   └─> Progress bar updates
                       └─> Playback continues

4. Use Lock Screen Controls
   └─> User taps Play/Pause
       └─> TrackPlayerService handles RemotePlay/RemotePause
           └─> TrackPlayer.play() / TrackPlayer.pause()
               └─> Playback state updates
                   └─> Lock screen controls update
                       └─> Media notification updates
                           └─> Playback responds
```

**Success Path:**
- Playback starts
- App backgrounds
- Playback continues
- Lock screen controls work
- Playback responds to controls

**Error Paths:**
- Playback fails → Error shown, playback stops
- Background mode not configured → Playback may stop
- Audio session error → Playback stops with error

---

### 2. Lock Screen Control Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Playback Active
   └─> Track Player playing
       └─> Lock screen controls appear
           └─> Track information displayed
               └─> Progress bar visible
                   └─> Controls active

2. User Taps Play/Pause
   └─> System sends RemotePlay/RemotePause event
       └─> TrackPlayerService handles event
           └─> TrackPlayer.play() / TrackPlayer.pause()
               └─> Playback state changes
                   └─> Lock screen controls update
                       └─> Media notification updates
                           └─> Playback responds

3. User Taps Stop
   └─> System sends RemoteStop event
       └─> TrackPlayerService handles event
           └─> TrackPlayer.stop()
               └─> Playback stops
                   └─> Lock screen controls disappear
                       └─> Media notification dismisses
                           └─> Playback ends

4. User Seeks (if supported)
   └─> System sends RemoteSeek event
       └─> TrackPlayerService handles event
           └─> TrackPlayer.seekTo(position)
               └─> Playback position changes
                   └─> Lock screen progress updates
                       └─> Playback seeks
```

**Success Path:**
- Controls appear
- User interacts
- Playback responds
- Controls update

**Error Paths:**
- Control not responsive → Retry or error shown
- Event not received → Control may not work
- Playback error → Error shown, playback may stop

---

### 3. Media Notification Control Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Playback Starts
   └─> Track Player playing
       └─> Media notification appears
           └─> Track information displayed
               └─> Artwork displayed
                   └─> Controls visible

2. User Pulls Down Notification
   └─> Notification expanded
       └─> Full controls visible
           └─> Track information visible
               └─> Artwork visible
                   └─> Controls active

3. User Taps Play/Pause in Notification
   └─> System sends RemotePlay/RemotePause event
       └─> TrackPlayerService handles event
           └─> TrackPlayer.play() / TrackPlayer.pause()
               └─> Playback state changes
                   └─> Notification controls update
                       └─> Lock screen controls update
                           └─> Playback responds

4. User Taps Stop in Notification
   └─> System sends RemoteStop event
       └─> TrackPlayerService handles event
           └─> TrackPlayer.stop()
               └─> Playback stops
                   └─> Notification dismisses
                       └─> Lock screen controls disappear
                           └─> Playback ends
```

**Success Path:**
- Notification appears
- User interacts
- Playback responds
- Notification updates

**Error Paths:**
- Notification not appearing → Check Track Player configuration
- Controls not working → Check service registration
- Notification not updating → Check event handling

---

### 4. Remote Control Flow (Bluetooth/Headphones)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Connect Bluetooth Device
   └─> Device connected
       └─> Audio routes to Bluetooth device
           └─> Track Player continues playback
               └─> Remote controls available
                   └─> Playback continues

2. User Presses Play Button on Device
   └─> Device sends play command
       └─> System sends RemotePlay event
           └─> TrackPlayerService handles event
               └─> TrackPlayer.play()
                   └─> Playback resumes
                       └─> All controls update
                           └─> Playback responds

3. User Presses Pause Button on Device
   └─> Device sends pause command
       └─> System sends RemotePause event
           └─> TrackPlayerService handles event
               └─> TrackPlayer.pause()
                   └─> Playback pauses
                       └─> All controls update
                           └─> Playback responds

4. User Presses Stop Button on Device
   └─> Device sends stop command
       └─> System sends RemoteStop event
           └─> TrackPlayerService handles event
               └─> TrackPlayer.stop()
                   └─> Playback stops
                       └─> All controls update
                           └─> Playback ends
```

**Success Path:**
- Device connected
- User interacts
- Playback responds
- Controls update

**Error Paths:**
- Device not connected → Controls not available
- Event not received → Control may not work
- Bluetooth disconnects → Playback continues on device speaker

---

### 5. App State Transition Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App Goes to Background
   └─> AppState changes to 'background'
       └─> Track Player continues playback
           └─> Audio session remains active
               └─> Lock screen controls appear
                   └─> Media notification appears
                       └─> Playback continues

2. App Returns to Foreground
   └─> AppState changes to 'foreground'
       └─> Track Player state synchronized
           └─> UI updates to reflect playback state
               └─> Controls re-enabled if needed
                   └─> Playback continues
                       └─> Lock screen controls remain

3. App is Killed
   └─> App process terminated
       └─> Track Player stops
           └─> Playback ends
               └─> State not preserved (expected)
                   └─> User must restart playback

4. App is Restarted
   └─> App launches
       └─> Track Player initializes
           └─> Previous state not restored (expected)
               └─> User must start playback again
```

**Success Path:**
- Background transition smooth
- Playback continues
- Foreground restoration works
- State synchronized

**Error Paths:**
- Background mode not configured → Playback may stop
- State synchronization fails → UI may be out of sync
- App killed → Playback stops (expected)

---

### 6. Interruption Handling Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. Phone Call Received
   └─> Audio session interrupted
       └─> Track Player pauses automatically
           └─> Playback state preserved
               └─> Controls show paused state
                   └─> Playback paused

2. Phone Call Ends
   └─> Audio session interruption ends
       └─> Track Player can resume
           └─> User can resume playback
               └─> Playback resumes
                   └─> Controls update

3. Alarm Goes Off
   └─> Audio session interrupted
       └─> Track Player pauses automatically
           └─> Playback state preserved
               └─> Controls show paused state
                   └─> Playback paused

4. Alarm Ends
   └─> Audio session interruption ends
       └─> Track Player can resume
           └─> User can resume playback
               └─> Playback resumes
                   └─> Controls update
```

**Success Path:**
- Interruption detected
- Playback pauses
- State preserved
- Resume available

**Error Paths:**
- Interruption not detected → Playback may continue
- Resume fails → User must manually resume
- State lost → Playback position may be lost

---

## 🔀 Alternative Flows

### Multi-Track Background Playback Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Start Multi-Track Playback
   └─> NativeMultiTrackAudioService.playAll()
       └─> NativeAudioBridge
           └─> AWAVEAudioModule (iOS)
               └─> AVAudioSession (background configured)
                   └─> All tracks play simultaneously
                       └─> Background playback active

2. Background App
   └─> AppState changes to 'background'
       └─> AVAudioSession remains active
           └─> All tracks continue playing
               └─> Background playback continues

3. Lock Device
   └─> Device locks
       └─> AVAudioSession remains active
           └─> All tracks continue playing
               └─> Background playback continues
```

**Use Cases:**
- Sound World (Klangwelten) playback
- Multi-track mixing
- Simultaneous sound playback

---

### Background Download Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App in Background
   └─> BackgroundDownloadService active
       └─> Download queue processing
           └─> Downloads continue
               └─> Doesn't interfere with playback
                   └─> Downloads progress

2. Download Completes
   └─> File saved locally
       └─> Available for offline playback
           └─> Next download starts
               └─> Queue continues processing
```

**Use Cases:**
- Favorites download
- Category download
- Priority category download

---

## 🚨 Error Flows

### Playback Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Playback Starts
   └─> Track Player playing
       └─> Error occurs (network, file, etc.)
           └─> TrackPlayer fires PlaybackError event
               └─> useAudioPlayer catches error
                   └─> Error state set
                       └─> User notified
                           └─> Playback stops
                               └─> Controls show error state
```

**Error Messages:**
- Network error → "Network connection lost"
- File error → "Audio file not available"
- Playback error → "Playback error occurred"

**User Actions:**
- Retry playback
- Check network connection
- Try different audio source

---

### Background Mode Not Configured Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Start Playback
   └─> Track Player playing
       └─> App backgrounds
           └─> Background mode not configured
               └─> Playback stops
                   └─> User must keep app in foreground
                       └─> Playback limited
```

**Solution:**
- Configure `UIBackgroundModes: audio` in Info.plist (iOS)
- Configure foreground service (Android)
- Restart app after configuration

---

### Control Not Responsive Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Taps Control
   └─> Control pressed
       └─> Event sent
           └─> Event not received
               └─> Control not responsive
                   └─> User retries
                       └─> Control works (retry success)
                           └─> Playback responds
```

**Possible Causes:**
- Service not registered
- Event handler not set up
- Track Player not initialized
- System delay

**Solutions:**
- Check service registration
- Verify Track Player initialization
- Retry control action
- Restart app if persistent

---

## 🔄 State Transitions

### Playback State Transitions

```
None → Loading → Ready → Playing
                          ↓
                      Paused
                          ↓
                      Playing
                          ↓
                      Stopped → None
                          ↓
                      Error → None
```

### Background State Transitions

```
Foreground → Background → Foreground
     │            │              │
     │            └─> Playback continues
     │                 Lock screen controls
     │                 Media notification
     │
     └─> Playback active
         UI controls active
```

### Interruption State Transitions

```
Playing → Interrupted → Paused
    │          │            │
    │          └─> Auto pause
    │              State preserved
    │
    └─> Resume available
        User can resume
```

---

## 📊 Flow Diagrams

### Complete Background Playback Journey

```
User starts playback
    │
    ├─> Track Player initialized
    │   └─> Playback starts
    │       └─> App backgrounds
    │           └─> Playback continues
    │               └─> Lock screen controls appear
    │                   └─> Media notification appears
    │                       └─> User locks device
    │                           └─> Playback continues
    │                               └─> User uses controls
    │                                   └─> Playback responds
    │
    └─> Multi-track playback
        └─> Native audio session
            └─> Background configured
                └─> All tracks play
                    └─> Background playback continues
```

---

## 🎯 User Goals

### Goal: Listen While Using Other Apps
- **Path:** Start playback → Background app → Playback continues
- **Time:** Immediate
- **Steps:** 1 tap to background

### Goal: Control from Lock Screen
- **Path:** Lock device → Use controls → Playback responds
- **Time:** < 1 second
- **Steps:** 1 tap on control

### Goal: Control from Bluetooth Device
- **Path:** Connect device → Use device controls → Playback responds
- **Time:** < 1 second
- **Steps:** 1 press on device button

### Goal: Continue After Interruption
- **Path:** Interruption → Auto pause → Resume → Playback continues
- **Time:** < 5 seconds
- **Steps:** 1 tap to resume

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
