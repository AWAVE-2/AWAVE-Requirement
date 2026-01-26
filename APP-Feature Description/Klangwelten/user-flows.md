# Klangwelten System - User Flows

## 🔄 Primary User Flows

### 1. Create Sound World Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Category Screen
   └─> Display category content
       └─> Show "Eigene Klangwelt" button

2. Tap "Eigene Klangwelt erstellen"
   └─> Navigate to KlangweltenScreen
       └─> Pass categoryId and categoryTitle
           └─> Display KlangweltenScreen
               ├─> Show header with back button
               ├─> Show category info (if provided)
               └─> Load available sounds

3. Browse Sound Carousel
   └─> Display horizontal scrollable carousel
       └─> Show sound cards with images
           └─> Display selection counter "0 / 3 ausgewählt"

4. Select First Sound
   └─> Tap sound card
       └─> Check if selection allowed
           └─> Assign sound to track-1
               ├─> Update visual indicator (checkmark)
               ├─> Highlight card
               └─> Update counter "1 / 3 ausgewählt"
                   └─> Load sound into audio service

5. Select Second Sound
   └─> Tap another sound card
       └─> Assign sound to track-2
           ├─> Update visual indicator
           ├─> Highlight card
           └─> Update counter "2 / 3 ausgewählt"
               └─> Load sound into audio service

6. Select Third Sound (Optional)
   └─> Tap another sound card
       └─> Assign sound to track-3
           ├─> Update visual indicator
           ├─> Highlight card
           └─> Update counter "3 / 3 ausgewählt"
               └─> Load sound into audio service
                   └─> Disable remaining sounds

7. Press Play Button
   └─> Check if any tracks active
       └─> If active tracks exist:
           ├─> Show loading state
           ├─> Start playback of all active tracks
           └─> Update UI to playing state
               └─> Show pause button
```

**Success Path:**
- User selects sounds
- Sounds load successfully
- Playback starts
- All tracks play simultaneously

**Error Paths:**
- No sounds selected → Show alert
- Audio loading fails → Show error
- Playback fails → Show error message

---

### 2. Adjust Volume in Mixer Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Sounds are playing
   └─> Display bottom controls
       └─> Show "🎚️ Mixer" button

2. Tap Mixer Button
   └─> Open AudioPlayerMixerSheet
       └─> Display bottom sheet
           └─> Show all active tracks
               ├─> Track name and category
               ├─> Volume slider (current volume)
               ├─> Volume percentage
               └─> Track on/off switch

3. Adjust Volume Slider
   └─> Drag slider for track-1
       └─> Update volume in real-time
           ├─> Update volume in state
           ├─> Update volume in audio service
           └─> Update percentage display
               └─> Audio volume changes immediately

4. Adjust Another Track Volume
   └─> Drag slider for track-2
       └─> Update volume in real-time
           └─> Audio volume changes immediately

5. Close Mixer
   └─> Tap outside or close button
       └─> Dismiss bottom sheet
           └─> Return to main screen
               └─> Playback continues
```

**Success Path:**
- Mixer opens
- Volume adjustments work
- Changes apply immediately
- Playback continues smoothly

**Error Paths:**
- Volume adjustment fails → Show error
- Audio service unavailable → Show error

---

### 3. Toggle Tracks During Playback Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Sounds are playing
   └─> All 3 tracks active and playing

2. Open Mixer
   └─> Display mixer with all tracks

3. Toggle Track Off
   └─> Switch track-2 to off
       └─> Pause track-2 in audio service
           ├─> Update track state (inactive)
           ├─> Disable volume slider
           └─> Track-2 stops playing
               └─> Track-1 and track-3 continue

4. Toggle Track On
   └─> Switch track-2 to on
       └─> Play track-2 in audio service
           ├─> Update track state (active)
           ├─> Enable volume slider
           └─> Track-2 resumes playing
               └─> All tracks playing again
```

**Success Path:**
- Track toggles work instantly
- Other tracks continue playing
- State updates correctly

**Error Paths:**
- Toggle fails → Show error
- Audio service unavailable → Show error

---

### 4. Modify Existing Mix Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Open KlangweltenScreen
   └─> Load saved mixer state
       └─> Restore previous selections
           ├─> Load sounds into tracks
           ├─> Restore volume levels
           └─> Display carousel with selections

2. Deselect Sound
   └─> Tap selected sound card
       └─> Clear track assignment
           ├─> Remove visual indicator
           ├─> Unhighlight card
           └─> Update counter
               └─> Remove track from audio service

3. Select New Sound
   └─> Tap different sound card
       └─> Assign to empty track
           ├─> Update visual indicator
           ├─> Highlight card
           └─> Update counter
               └─> Load sound into audio service

4. Adjust Volumes
   └─> Open mixer and adjust sliders
       └─> Update volumes in real-time

5. Play Updated Mix
   └─> Press play button
       └─> Start playback with new mix
```

**Success Path:**
- State loads correctly
- Modifications work
- New mix plays successfully

**Error Paths:**
- State load fails → Use defaults
- Sound loading fails → Show error

---

### 5. Quick Mix Flow (Minimal Interaction)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to KlangweltenScreen
   └─> Display screen with carousel

2. Select Sound
   └─> Tap sound card
       └─> Assign to track-1

3. Select Another Sound
   └─> Tap another sound card
       └─> Assign to track-2

4. Press Play Immediately
   └─> Start playback
       └─> Both tracks play simultaneously
           └─> User can adjust later if needed
```

**Success Path:**
- Quick selection
- Immediate playback
- Minimal interaction required

---

## 🔀 Alternative Flows

### Resume Previous Mix Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Open KlangweltenScreen
   └─> Load saved mixer state
       └─> Restore previous mix
           ├─> Load sounds into tracks
           ├─> Restore volumes
           └─> Display selections in carousel

2. Press Play
   └─> Start playback with saved mix
       └─> All tracks play with saved volumes
```

**Use Cases:**
- User returns to app
- User wants to continue previous session
- Quick access to favorite mix

---

### Maximum Selection Reached Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User has selected 3 sounds
   └─> Counter shows "3 / 3 ausgewählt"
       └─> All other sounds disabled

2. User tries to select another sound
   └─> Tap disabled sound card
       └─> No action (card disabled)
           └─> User must deselect first

3. User deselects a sound
   └─> Tap selected sound
       └─> Clear selection
           ├─> Remove visual indicator
           └─> Update counter "2 / 3 ausgewählt"
               └─> Enable other sounds

4. User can now select new sound
   └─> Tap any available sound
       └─> Assign to empty track
```

**User Experience:**
- Clear visual feedback
- Intuitive selection limit
- Easy to modify selections

---

### Error Recovery Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Audio loading fails
   └─> Show error message
       └─> Display error container
           └─> User can retry or select different sound

2. Playback fails
   └─> Show error message
       └─> Display error container
           └─> User can try again

3. State load fails
   └─> Use default state
       └─> Start with empty tracks
           └─> User can create new mix

4. Network error (if applicable)
   └─> Show connectivity error
       └─> User can retry when connected
```

**Error Handling:**
- User-friendly messages
- Clear recovery options
- Graceful degradation

---

## 🚨 Error Flows

### No Sounds Selected Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens KlangweltenScreen
   └─> No sounds selected yet

2. User presses Play
   └─> Check active tracks
       └─> No active tracks found
           └─> Show Alert
               ├─> Title: "Keine Sounds ausgewählt"
               ├─> Message: "Bitte wähle mindestens einen Sound aus dem Karussell."
               └─> User dismisses alert
                   └─> Returns to selection
```

**User Experience:**
- Clear guidance
- Helpful error message
- Easy to correct

---

### Audio Loading Failure Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User selects sound
   └─> Attempt to load sound
       └─> Audio file not found or corrupted
           └─> Show error in error container
               └─> Display: "⚠️ Failed to load sound"
                   └─> User can select different sound
```

**Error Handling:**
- Non-blocking error
- Clear indication
- Recovery option

---

### State Corruption Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App opens KlangweltenScreen
   └─> Attempt to load saved state
       └─> State file corrupted or invalid
           └─> Catch error
               └─> Use default state
                   └─> Start with empty tracks
                       └─> User can create new mix
```

**Recovery:**
- Silent error handling
- Graceful fallback
- No user disruption

---

## 🔄 State Transitions

### Selection States

```
No Selection → 1 Selected → 2 Selected → 3 Selected
     │              │             │             │
     │              │             │             └─> Max Reached
     │              │             │                 (Disable others)
     │              │             │
     │              │             └─> Can deselect
     │              │
     │              └─> Can add more
     │
     └─> Can select
```

### Playback States

```
Stopped → Loading → Playing → Paused
   │         │          │         │
   │         │          │         └─> Can resume
   │         │          │
   │         │          └─> Can pause
   │         │
   │         └─> Can cancel
   │
   └─> Can start
```

### Track States

```
Empty → Sound Assigned → Active → Playing
  │           │             │         │
  │           │             │         └─> Can pause
  │           │             │
  │           │             └─> Can toggle off
  │           │
  │           └─> Can clear
  │
  └─> Can assign
```

---

## 📊 Flow Diagrams

### Complete Sound World Creation Journey

```
Category Screen (Schlaf/Ruhe/Im Fluss)
    │
    ├─> User taps "Eigene Klangwelt erstellen"
    │   └─> Navigate to KlangweltenScreen
    │       ├─> Load available sounds
    │       ├─> Display sound carousel
    │       └─> Show selection counter
    │
    ├─> User selects sound 1
    │   └─> Assign to track-1
    │       └─> Update UI
    │
    ├─> User selects sound 2
    │   └─> Assign to track-2
    │       └─> Update UI
    │
    ├─> User selects sound 3 (optional)
    │   └─> Assign to track-3
    │       └─> Update UI
    │           └─> Disable remaining sounds
    │
    ├─> User presses Play
    │   └─> Start playback
    │       └─> All tracks play simultaneously
    │
    ├─> User opens Mixer
    │   └─> Adjust volumes
    │       └─> Real-time updates
    │
    └─> User toggles tracks
        └─> Individual control
            └─> Playback continues
```

---

## 🎯 User Goals

### Goal: Quick Sound Mix
- **Path:** Select 2-3 sounds → Play
- **Time:** < 20 seconds
- **Steps:** 3-4 taps

### Goal: Fine-Tuned Mix
- **Path:** Select sounds → Open mixer → Adjust volumes → Play
- **Time:** ~1 minute
- **Steps:** 6-8 taps

### Goal: Resume Previous Mix
- **Path:** Open Klangwelten → Play
- **Time:** < 5 seconds
- **Steps:** 1-2 taps

---

## 🔄 Interaction Patterns

### Selection Pattern
- **Tap to select** - First tap selects sound
- **Tap to deselect** - Second tap removes selection
- **Visual feedback** - Immediate visual update
- **Counter update** - Real-time selection count

### Playback Pattern
- **Play all** - All active tracks play simultaneously
- **Independent control** - Each track can be toggled
- **Volume control** - Per-track volume adjustment
- **State persistence** - Mix saved automatically

### Mixer Pattern
- **Bottom sheet** - Slide up from bottom
- **Per-track controls** - Individual sliders and switches
- **Real-time updates** - Changes apply immediately
- **Easy dismissal** - Tap outside or close button

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
