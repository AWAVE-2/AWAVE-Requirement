# Klangwelten System - Functional Requirements

## 📋 Core Requirements

### 1. Sound Selection & Browsing

#### Sound Carousel
- [x] Horizontal scrollable carousel displays available sounds
- [x] Sound cards show image, title, and description
- [x] Snap-to-interval scrolling for smooth navigation
- [x] Pagination dots indicate current position
- [x] Selection counter shows "X / 3 ausgewählt"
- [x] Maximum 3 selections enforced
- [x] Visual feedback for selected sounds (checkmark, highlight)
- [x] Disabled state when maximum reached

#### Sound Toggle Behavior
- [x] Tap sound to select (if not selected and under limit)
- [x] Tap selected sound to deselect
- [x] Visual indicator updates immediately
- [x] Selection state synced with mixer tracks
- [x] Empty track assignment (finds first available track)

#### Category Filtering
- [x] Category ID passed from navigation
- [x] Category title displayed in header
- [x] Sounds loaded from data structure
- [ ] Filter sounds by category (TODO: currently loads all sounds)
- [x] Custom sounds excluded from selection
- [x] Limited to 12 sounds for performance (configurable)

### 2. Multi-Track Audio Playback

#### Track Management
- [x] Support for up to 3 simultaneous tracks
- [x] Each track has independent sound assignment
- [x] Track state: sound, volume, isActive, isPlaying
- [x] Default 3 empty tracks initialized
- [x] Track IDs: 'track-1', 'track-2', 'track-3'
- [x] Default volume: 80% per track

#### Playback Controls
- [x] Play all active tracks simultaneously
- [x] Pause all tracks
- [x] Stop all tracks
- [x] Play button shows play/pause icon
- [x] Loading state during audio initialization
- [x] Error handling for playback failures
- [x] Alert when no sounds selected before play

#### Track Toggle
- [x] Toggle individual tracks on/off
- [x] Toggle without stopping other tracks
- [x] Visual feedback for active/inactive tracks
- [x] Volume controls disabled for inactive tracks

### 3. Volume Control

#### Individual Track Volume
- [x] Volume slider per track (0-100%)
- [x] Real-time volume adjustment
- [x] Volume persists across playback
- [x] Volume displayed as percentage
- [x] Volume updates in native audio service
- [x] Volume clamped to 0-100 range

#### Mixer Interface
- [x] Bottom sheet mixer opens from button
- [x] Each track shows name and category
- [x] Volume slider per track
- [x] Track on/off switch
- [x] Empty state when no active tracks
- [x] Close button to dismiss mixer

### 4. State Persistence

#### Mixer State Saving
- [x] Auto-save mixer state on changes
- [x] 1-second debounce to prevent excessive saves
- [x] State includes: tracks, masterVolume, isPlaying
- [x] Sound data serialized for storage
- [x] AsyncStorage key: 'awaveMixerState'

#### Mixer State Loading
- [x] Load saved state on component mount
- [x] Restore track assignments
- [x] Restore volume levels
- [x] Restore active/inactive states
- [x] Error handling for corrupted state

### 5. Navigation & Integration

#### Category Screen Integration
- [x] "Eigene Klangwelt" button in category screens
- [x] Navigation with categoryId parameter
- [x] Navigation with categoryTitle parameter
- [x] Back navigation support
- [x] Route parameter handling

#### Screen Layout
- [x] Header with back button and title
- [x] Category info section (if categoryTitle provided)
- [x] Sound carousel section
- [x] Info section with instructions
- [x] Bottom controls (when sounds selected)
- [x] Error display section

### 6. User Experience

#### Visual Feedback
- [x] Selected sound cards highlighted
- [x] Checkmark badge on selected sounds
- [x] Selection status text ("Ausgewählt" / "Tippen zum Auswählen")
- [x] Disabled state styling when max reached
- [x] Loading indicators during operations
- [x] Playback state indicators

#### Error Handling
- [x] Network/loading errors displayed
- [x] Playback errors shown to user
- [x] No sounds selected alert
- [x] Audio service initialization errors
- [x] State loading errors handled gracefully

#### Accessibility
- [x] Touch targets meet minimum size (44x44)
- [x] Clear visual indicators
- [x] Descriptive button labels
- [x] Error messages in user-friendly language

---

## 🎯 User Stories

### As a user, I want to:
- Create my own sound mix by selecting multiple sounds so I can personalize my audio experience
- Adjust the volume of each sound independently so I can balance the mix to my preference
- Turn individual sounds on/off during playback so I can experiment with different combinations
- Access sound world creation from category screens so I can quickly start mixing sounds
- Have my sound selections saved so I can resume my mix later
- See clear visual feedback when selecting sounds so I know what's active
- Be prevented from selecting too many sounds so the app doesn't become overwhelming

### As a user experiencing issues, I want to:
- See clear error messages when audio fails to load
- Be alerted when I try to play without selecting sounds
- Have the app handle network issues gracefully
- Recover from state corruption without losing all my settings

---

## ✅ Acceptance Criteria

### Sound Selection
- [x] User can select up to 3 sounds from carousel
- [x] Selection limit enforced visually and functionally
- [x] Selected sounds clearly indicated
- [x] Deselection works by tapping selected sound
- [x] Carousel scrolls smoothly with snap behavior

### Multi-Track Playback
- [x] All selected tracks play simultaneously
- [x] Playback starts within 2 seconds of pressing play
- [x] Individual tracks can be paused/stopped independently
- [x] Volume changes apply immediately
- [x] No audio glitches or dropouts

### Mixer Interface
- [x] Mixer opens from bottom sheet
- [x] All active tracks visible in mixer
- [x] Volume sliders work smoothly
- [x] Track toggles work instantly
- [x] Mixer closes properly

### State Persistence
- [x] Mixer state saves automatically
- [x] State loads on app restart
- [x] All track assignments restored
- [x] Volume levels restored
- [x] Active states restored

### Navigation
- [x] Navigation from category screens works
- [x] Category context displayed correctly
- [x] Back navigation returns to previous screen
- [x] Route parameters handled correctly

---

## 🚫 Non-Functional Requirements

### Performance
- [x] Sound carousel scrolls at 60fps
- [x] Audio playback starts within 2 seconds
- [x] Volume adjustments respond within 100ms
- [x] State saves don't block UI
- [x] No memory leaks during extended use

### Reliability
- [x] Audio playback continues in background
- [x] State persists across app restarts
- [x] Error recovery without crashes
- [x] Graceful degradation when audio service unavailable

### Usability
- [x] Clear visual feedback for all actions
- [x] Intuitive selection behavior
- [x] Helpful error messages
- [x] Consistent with app design language

### Security
- [x] No sensitive data in persisted state
- [x] Audio files loaded securely
- [x] No unauthorized audio access

---

## 🔄 Edge Cases

### Selection Edge Cases
- [x] Maximum selections reached - prevent further selection
- [x] Deselecting when only one track active
- [x] Rapid selection/deselection
- [x] Selecting same sound multiple times (prevented)

### Playback Edge Cases
- [x] Play pressed with no sounds selected - show alert
- [x] Play pressed during loading - show loading state
- [x] Audio file missing - show error
- [x] All tracks toggled off - show empty state
- [x] App backgrounded during playback - continue playback

### State Edge Cases
- [x] Corrupted state file - reset to defaults
- [x] State from older app version - handle migration
- [x] State save fails - retry silently
- [x] State load fails - use defaults

### Navigation Edge Cases
- [x] Navigate without categoryId - use default
- [x] Navigate with invalid categoryId - handle gracefully
- [x] Back navigation during playback - continue playback
- [x] Multiple rapid navigations - prevent duplicate screens

---

## 📊 Success Metrics

- Sound selection completion rate > 90%
- Average time to create mix < 30 seconds
- Mixer usage rate > 60% of category screen visits
- State persistence success rate > 99%
- Audio playback success rate > 95%
- User satisfaction with sound mixing > 4/5

---

## 🔮 Future Enhancements

### Planned Features
- [ ] Category-based sound filtering
- [ ] Save named sound worlds
- [ ] Share sound worlds with other users
- [ ] Preset sound world templates
- [ ] More than 3 tracks support
- [ ] Pan control (left/right positioning)
- [ ] Audio effects (reverb, delay, EQ)
- [ ] Fade in/out controls
- [ ] Crossfade between sound worlds
- [ ] Session tracking integration

### Technical Improvements
- [ ] Optimize sound loading performance
- [ ] Implement sound preloading
- [ ] Add audio visualization
- [ ] Improve state migration handling
- [ ] Add analytics tracking
