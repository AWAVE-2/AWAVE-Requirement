# MiniPlayer Strip - User Flows

## 🔄 Primary User Flows

### 1. Sound Selection & Mini Player Appearance Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User browses category screen
   └─> Category screen displays sounds

2. User taps on a sound
   └─> handleSoundSelect(sound, favoriteId) called
       ├─> setSelectedSound(sound)
       ├─> setLastPlayedSound(sound)
       ├─> onboardingStorage.saveLastPlaybackState()
       └─> SupabasePlaybackService.createPlaybackSession()
           └─> MiniPlayerStrip receives sound prop
               └─> Component renders at bottom of screen
                   └─> FadeIn animation (300ms delay)
```

**Success Path:**
- Sound selected
- Mini player appears
- State saved locally
- Session created (if authenticated)

**Error Paths:**
- Storage failure → Continue without persistence
- Backend sync failure → Continue with local state
- Invalid sound data → Component returns null

---

### 2. Expand to Full Player Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Mini player is visible
   └─> User taps on content area (artwork/title)
       └─> onExpand() callback triggered
           └─> handleExpandPlayer() called
               └─> Navigation to AudioPlayerEnhanced
                   └─> Full player opens with sound
                       └─> Mini player remains in background
```

**Success Path:**
- Tap on content area
- Full player opens
- Sound loaded in full player
- Smooth navigation transition

**Alternative Path:**
- If `onPlayPress` not provided, play button also expands

---

### 3. Resume Playback Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Mini player is visible
   └─> User taps play button
       └─> handlePrimaryPress() called
           ├─> If onPlayPress provided:
           │   └─> onPlayPress() executed
           │       └─> handleMiniPlayerPlay() called
           │           └─> handleSoundSelect(lastPlayedSound)
           │               └─> AudioPlayerEnhanced opens
           │                   └─> Playback resumes
           └─> If onPlayPress not provided:
               └─> onExpand() called
                   └─> Expand to full player
```

**Success Path:**
- Play button tapped
- Playback resumes or player expands
- Audio starts playing

**Error Paths:**
- Audio service error → Show error state
- Network error → Show connectivity message

---

### 4. Close Mini Player Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Mini player is visible
   └─> User taps close button (X)
       └─> handleClose() called
           └─> onClose() callback triggered
               └─> handleCloseMiniPlayer() called
                   ├─> useSupabaseAudio.stop()
                   ├─> setLastPlayedSound(null)
                   ├─> onboardingStorage.clearPlaybackState()
                   ├─> SupabasePlaybackService.completePlaybackSession()
                   └─> SupabasePlaybackService.clearCachedPlayback()
                       └─> MiniPlayerStrip receives null sound
                           └─> Component returns null (hidden)
```

**Success Path:**
- Close button tapped
- Audio stops
- State cleared
- Mini player disappears

**Error Paths:**
- Stop failure → Continue with state clear
- Storage clear failure → Log warning, continue
- Backend sync failure → Continue with local clear

---

## 🔀 Alternative Flows

### 5. Navigation Persistence Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Mini player visible on SchlafScreen
   └─> User navigates to RuheScreen
       └─> Mini player persists (same sound)
           └─> Component remains visible
               └─> State maintained across navigation
```

**Use Cases:**
- Navigating between category screens
- Mini player remains visible
- State persists across navigation

---

### 6. App Restart & State Restoration Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App starts
   └─> useSoundPlayer.loadState() called
       ├─> onboardingStorage.loadLastPlaybackState()
       │   └─> Load sound from AsyncStorage
       └─> SupabasePlaybackService.fetchCachedPlayback() (if authenticated)
           └─> Load sound from Supabase
               └─> setLastPlayedSound(sound)
                   └─> MiniPlayerStrip receives sound prop
                       └─> Component renders with last played sound
```

**Success Path:**
- App restarts
- Last played sound restored
- Mini player appears automatically

**Error Paths:**
- Storage read failure → No mini player
- Invalid data → No mini player
- Backend sync failure → Use local storage

---

### 7. Multiple Sound Selection Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Sound A is playing (mini player visible)
   └─> User selects Sound B
       └─> handleSoundSelect(Sound B) called
           ├─> setLastPlayedSound(Sound B)
           ├─> Stop Sound A playback
           └─> MiniPlayerStrip updates with Sound B
               └─> Component re-renders with new sound
```

**Behavior:**
- New sound replaces previous
- Previous playback stops
- Mini player updates immediately

---

## 🚨 Error Flows

### 8. Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User selects sound (offline)
   └─> handleSoundSelect() called
       ├─> Local state updated (success)
       ├─> onboardingStorage.saveLastPlaybackState() (success)
       └─> SupabasePlaybackService.createPlaybackSession() (fails)
           └─> Error logged, but continues
               └─> Mini player appears with local state
                   └─> Sync queued for when online
```

**Error Handling:**
- Local state always succeeds
- Backend sync fails gracefully
- State syncs when network available

---

### 9. Audio Service Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User taps play button
   └─> Audio service attempts playback
       └─> Audio service error occurs
           └─> Error state set in useSoundPlayer
               └─> Error displayed in UI (if visible)
                   └─> User can retry or expand to full player
```

**Error Recovery:**
- Error state available
- User can retry
- Fallback to full player

---

### 10. Storage Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User selects sound
   └─> onboardingStorage.saveLastPlaybackState() called
       └─> AsyncStorage write fails
           └─> Error logged
               └─> Continue without persistence
                   └─> Mini player still appears
                       └─> State lost on app restart
```

**Error Handling:**
- Graceful degradation
- Component still works
- State not persisted

---

## 🔄 State Transitions

### Mini Player Visibility States

```
No Sound → Sound Selected → Mini Player Visible
    │            │                    │
    │            │                    ├─> User Taps Close
    │            │                    │   └─> No Sound
    │            │                    │
    │            │                    └─> User Navigates Away
    │            │                        └─> Mini Player Visible (persists)
    │            │
    │            └─> App Restart
    │                └─> State Restored → Mini Player Visible
    │
    └─> Invalid Sound Data
        └─> No Sound (component returns null)
```

### Playback States

```
No Playback → Sound Selected → Ready to Play
    │              │                  │
    │              │                  ├─> User Taps Play
    │              │                  │   └─> Playing
    │              │                  │
    │              │                  └─> User Taps Content
    │              │                      └─> Full Player Opens
    │              │
    │              └─> User Taps Close
    │                  └─> No Playback
    │
    └─> App Restart
        └─> State Restored → Ready to Play
```

---

## 📊 Flow Diagrams

### Complete User Journey

```
Category Screen
    │
    ├─> User Browses Sounds
    │   └─> Sounds Displayed
    │
    ├─> User Selects Sound
    │   └─> handleSoundSelect()
    │       ├─> State Updated
    │       ├─> Local Storage Saved
    │       ├─> Backend Sync (if authenticated)
    │       └─> Mini Player Appears
    │           │
    │           ├─> User Taps Content Area
    │           │   └─> Full Player Opens
    │           │
    │           ├─> User Taps Play Button
    │           │   └─> Playback Resumes / Full Player Opens
    │           │
    │           └─> User Taps Close
    │               └─> Audio Stops
    │                   └─> State Cleared
    │                       └─> Mini Player Disappears
    │
    └─> User Navigates to Another Category
        └─> Mini Player Persists
            └─> Same Sound Displayed
```

---

### State Persistence Flow

```
App Session
    │
    ├─> Sound Selected
    │   └─> State Saved
    │       ├─> AsyncStorage (local)
    │       └─> Supabase (cloud, if authenticated)
    │
    ├─> App Backgrounded
    │   └─> State Persists
    │
    ├─> App Terminated
    │   └─> State Persists
    │
    └─> App Restarts
        └─> State Restored
            ├─> Load from AsyncStorage
            └─> Load from Supabase (if authenticated)
                └─> Mini Player Appears
```

---

## 🎯 User Goals

### Goal: Quick Playback Access
- **Path:** Select sound → Mini player appears → Tap play
- **Time:** < 2 seconds
- **Steps:** 2 taps

### Goal: Resume Playback
- **Path:** App restart → Mini player appears → Tap play
- **Time:** < 3 seconds
- **Steps:** 1 tap (after app loads)

### Goal: Full Player Access
- **Path:** Mini player visible → Tap content → Full player
- **Time:** < 500ms
- **Steps:** 1 tap

### Goal: Stop Playback
- **Path:** Mini player visible → Tap close → Audio stops
- **Time:** < 1 second
- **Steps:** 1 tap

---

## 🔄 Interaction Patterns

### Tap Patterns

**Content Area Tap:**
- Always expands to full player
- Smooth navigation transition
- Visual feedback (activeOpacity)

**Play Button Tap:**
- If `onPlayPress` provided → Direct playback
- Otherwise → Expand to full player
- Immediate response

**Close Button Tap:**
- Stops playback
- Clears state
- Hides mini player
- Immediate response

---

## 📱 Screen Integration Patterns

### Category Screen Pattern
```typescript
// Mini player positioned at bottom
{lastPlayedSound && (
  <View style={styles.miniPlayerContainer}>
    <MiniPlayerStrip
      sound={lastPlayedSound}
      onExpand={handleExpandPlayer}
      onPlayPress={handleMiniPlayerPlay}
      onClose={handleCloseMiniPlayer}
    />
  </View>
)}
```

### Navigation Pattern
- Mini player persists across category navigation
- State maintained in useSoundPlayer hook
- Component re-renders with same sound

---

## 🎨 Animation Flows

### Appearance Animation
```
Sound Selected
  └─> FadeIn animation starts (delay: 300ms)
      └─> Opacity: 0 → 1
      └─> TranslateY: 20 → 0
          └─> Mini player visible
```

### Disappearance Animation
```
Close Button Tapped
  └─> State cleared
      └─> Component receives null sound
          └─> Component returns null
              └─> Component unmounts
                  └─> (Animation handled by parent)
```

---

## 🔐 Authentication Flow

### Authenticated User Flow
```
Sound Selected
  └─> Local state saved
  └─> Supabase session created
  └─> Cached playback saved to Supabase
      └─> State synced across devices
```

### Unauthenticated User Flow
```
Sound Selected
  └─> Local state saved
  └─> No Supabase sync
      └─> State only on current device
```

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*  
*For requirements, see `requirements.md`*
