# MiniPlayer Strip - Functional Requirements

## 📋 Core Requirements

### 1. Display & Rendering

#### Sound Information Display
- [x] Display sound artwork (44x44px) or placeholder icon
- [x] Display sound title (truncated to single line)
- [x] Display sound description (truncated to single line, optional)
- [x] Render only when sound is available (null check)
- [x] Apply theme-aware styling
- [x] Use card-based design with rounded corners

#### Visual Layout
- [x] Fixed position at bottom of screen
- [x] Horizontal margins (16px)
- [x] Bottom margin (12px)
- [x] Flex layout (row direction)
- [x] Proper spacing between elements
- [x] Border and background styling

### 2. Playback Controls

#### Play Button
- [x] Circular button (36x36px) with primary color background
- [x] Play icon (18px) in primary foreground color
- [x] Accessibility label: "Wiedergabe fortsetzen"
- [x] Support `onPlayPress` callback (if provided)
- [x] Fallback to `onExpand` if `onPlayPress` not provided
- [x] Touch feedback (activeOpacity)

#### Close Button
- [x] Optional close button (controlled by `onClose` prop)
- [x] Circular button (36x36px) with card background
- [x] Close icon (X, 18px) in secondary text color
- [x] Border styling
- [x] Accessibility label: "Player schließen"
- [x] Touch feedback

### 3. User Interactions

#### Content Area Tap
- [x] Entire content area is tappable
- [x] Expands to full AudioPlayer on tap
- [x] Visual feedback (activeOpacity: 0.85)
- [x] Smooth navigation transition

#### Play Button Tap
- [x] If `onPlayPress` provided: execute callback
- [x] If `onPlayPress` not provided: expand to full player
- [x] Handle async callbacks properly
- [x] Prevent multiple rapid taps

#### Close Button Tap
- [x] Execute `onClose` callback (if provided)
- [x] Handle async close operations
- [x] Stop audio playback
- [x] Clear state

### 4. State Management

#### Sound State
- [ ] Track `lastPlayedSound` from `useSoundPlayer` (Not applicable - React hook, not in Swift)
- [x] Display sound information when available (Implemented)
- [x] Hide component when sound is null (Implemented)
- [x] Update when sound changes (Implemented)

#### Playback State
- [x] Integrate with audio playback service
- [x] Reflect current playback status
- [x] Handle play/pause state transitions

#### Persistence
- [ ] Save last played sound to local storage (Not implemented)
- [ ] Restore last played sound on app restart (Not implemented)
- [ ] Sync with Supabase for authenticated users (Not applicable - app uses Firebase)
- [x] Clear state on explicit close (Implemented)

### 5. Integration

#### Category Screen Integration
- [x] Render in SchlafScreen
- [x] Render in RuheScreen
- [x] Render in ImFlussScreen
- [x] Position at bottom of screen
- [x] Do not block content scrolling
- [x] Maintain z-index above content

#### Audio Player Integration
- [x] Expand to AudioPlayerEnhanced on tap
- [x] Pass sound and favoriteId to full player
- [x] Handle player close and return to mini player
- [x] Sync state between mini and full player

#### Navigation Integration
- [x] Persist across category screen navigation
- [x] Maintain state when navigating between categories
- [x] Clear on explicit user action (close button)

---

## 🎯 User Stories

### As a user, I want to:
- See what sound is currently playing while browsing other sounds
- Quickly resume playback without opening the full player
- Expand to the full player when I want more control
- Close the mini player when I'm done listening
- Have my last played sound remembered when I return to the app

### As a user browsing sounds, I want to:
- Continue browsing while a sound is playing
- See the mini player without it blocking my view
- Easily access playback controls without leaving my current screen

### As a user returning to the app, I want to:
- See my last played sound in the mini player
- Resume playback from where I left off
- Have my playback state synced across devices (if authenticated)

---

## ✅ Acceptance Criteria

### Display
- [x] Mini player appears within 300ms after sound selection
- [x] Artwork loads and displays correctly
- [x] Title and description truncate properly
- [x] Component hides when no sound is selected
- [x] Styling matches design system

### Interactions
- [x] Tap on content expands to full player in < 200ms
- [x] Play button responds to taps immediately
- [x] Close button stops playback and clears state
- [x] No visual glitches during state transitions

### State Management
- [x] Last played sound persists across app restarts
- [ ] State syncs with Supabase for authenticated users (Not applicable - app uses Firebase)
- [x] State clears on explicit close action
- [x] State updates correctly when new sound is selected

### Performance
- [x] Component renders without lag
- [x] Animations are smooth (60fps)
- [x] No memory leaks from event listeners
- [x] Efficient re-renders (only when state changes)

---

## 🚫 Non-Functional Requirements

### Performance
- Component should render in < 16ms (60fps)
- State updates should complete in < 100ms
- Image loading should not block UI
- Smooth animations during state transitions

### Accessibility
- All interactive elements have accessibility labels
- Touch targets meet minimum size (44x44px)
- Color contrast meets WCAG AA standards
- Screen reader support

### Usability
- Clear visual hierarchy
- Intuitive interaction patterns
- Consistent with app design language
- Responsive to user actions

### Reliability
- Graceful handling of missing artwork
- Error handling for failed state operations
- Network failure handling for Supabase sync
- State recovery after app crashes

---

## 🔄 Edge Cases

### Missing Data
- [x] Handle null/undefined sound gracefully
- [x] Display placeholder when artwork missing
- [x] Handle missing description (optional field)
- [x] Handle invalid sound data

### Network Issues
- [x] Continue working offline (local state)
- [ ] Queue Supabase sync for when online (Not applicable - app uses Firebase)
- [x] Handle sync failures gracefully
- [x] Show appropriate error states

### Audio Playback
- [x] Handle audio service errors
- [x] Handle playback state inconsistencies
- [x] Handle rapid play/pause toggles
- [x] Handle audio loading failures

### Navigation
- [x] Persist across screen navigation
- [x] Handle deep linking while mini player active
- [x] Handle app backgrounding/foregrounding
- [x] Handle navigation stack changes

### State Edge Cases
- [x] Handle multiple rapid sound selections
- [x] Handle state updates during navigation
- [x] Handle concurrent state modifications
- [x] Handle storage quota exceeded

---

## 📊 Success Metrics

- Mini player appears > 95% of the time after sound selection
- User interaction success rate > 98%
- State persistence success rate > 99%
- Average render time < 16ms
- User satisfaction with quick access > 4.5/5

---

## 🔐 Security & Privacy

### Data Storage
- Sound data stored locally (AsyncStorage)
- Supabase sync only for authenticated users
- No sensitive data in component state
- Proper cleanup on component unmount

### User Privacy
- Playback state only synced with user consent
- No tracking of user interactions with mini player
- Session data anonymized where possible

---

## 🧪 Testing Requirements

### Unit Tests
- Component rendering with/without sound
- Button interactions
- State updates
- Prop handling

### Integration Tests
- useSoundPlayer hook integration
- Category screen integration
- AudioPlayer expansion
- State persistence

### E2E Tests
- Complete user flow: select sound → mini player → expand → close
- State persistence across app restart
- Navigation with mini player active
- Multiple sound selections

---

## 📝 Implementation Notes

- Component uses `AnimatedButton` for consistent touch feedback
- Theme integration via `useTheme` hook
- Sound type from `exactDataStructures`
- Optional props allow flexible usage
- Null rendering prevents empty component display

---

*For technical implementation details, see `technical-spec.md`*  
*For component structure, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
