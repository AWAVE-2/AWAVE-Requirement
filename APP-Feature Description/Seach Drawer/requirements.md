# Search Drawer - Functional Requirements

## 📋 Core Requirements

### 1. Search Drawer Interface

#### Drawer Opening
- [x] Search drawer opens from bottom when search button is pressed
- [x] Drawer slides up with smooth animation (280ms duration)
- [x] Backdrop overlay appears with 60% opacity
- [x] Drawer height is responsive (85% phones, 60% tablets)
- [x] Maximum height capped at 95% to avoid full screen
- [x] Search input auto-focuses when drawer opens
- [x] Keyboard appears automatically on open

#### Drawer Closing
- [x] Drawer closes with swipe-down gesture
- [x] Drawer closes when backdrop is tapped
- [x] Drawer closes when X button is pressed
- [x] Drawer closes when sound is selected
- [x] Close animation is smooth (220ms duration)
- [x] Search query is cleared on close
- [x] Search results are cleared on close

#### Header Section
- [x] Header displays search icon with gradient background
- [x] Header shows "Sound-Suche" title
- [x] Header shows subtitle when no query ("Entdecke deine perfekten Klänge")
- [x] Header has close button (X icon) in top right
- [x] Header has border-bottom separator
- [x] Header is fixed at top of drawer

### 2. Search Input

#### Input Field
- [x] Search input field with icon on left
- [x] Placeholder text: "Suche nach Sounds... z.B. 'schlafen', 'fokus', 'regen'"
- [x] Clear button (X) appears when text is entered
- [x] Clear button removes all text when pressed
- [x] Input is positioned at bottom of drawer
- [x] Input has border-top separator
- [x] Input styling matches theme (bg-white/5, border-white/20)
- [x] Input supports keyboard return key ("search" type)

#### Input Behavior
- [x] Text input is editable
- [x] Input value is controlled (SwiftUI state)
- [x] Input supports auto-focus
- [x] Keyboard-aware layout (SwiftUI)
- [x] Keyboard offset for iOS

### 3. Search Functionality

#### Query Processing
- [x] Search query is debounced (300ms delay)
- [x] Search triggers automatically after debounce
- [x] Empty queries clear results immediately
- [x] Search is case-insensitive
- [x] Search trims whitespace
- [x] Search normalizes query (lowercase)

#### Search Execution
- [x] Search uses FirestoreSoundRepository (client-side filtering)
- [x] Search queries multiple fields (title, keywords, tags) (FirestoreSoundRepository.searchSounds - client-side)
- [ ] Search uses ILIKE for case-insensitive matching (Not applicable - uses client-side filtering)
- [ ] Search uses array contains (cs) for keywords/tags (Not applicable - uses client-side filtering)
- [ ] Search results are ordered by search_weight (Not implemented)
- [x] Search handles network errors gracefully (Implemented)
- [x] Search shows loading state during execution (Implemented)

#### Result Processing
- [x] Results are scored for relevance (client-side) (Implemented)
- [ ] Title matches score 10 points (Not implemented - basic filtering only)
- [ ] Keyword matches score 5 points each (Not implemented)
- [ ] Tag matches score 3 points each (Not implemented)
- [ ] Description matches score 2 points (Not implemented)
- [ ] Search weight multiplies final score (Not implemented)
- [ ] Results are sorted by score (descending) (Not implemented)
- [ ] Results are limited to top 6 (Not implemented)
- [x] Results are filtered (score > 0) (Implemented - basic filtering)

### 4. Search Results Display

#### Loading State
- [x] Skeleton loaders shown during search
- [x] Three skeleton cards displayed
- [x] Skeleton matches result card layout
- [x] Loading state clears when results arrive

#### Empty State
- [x] Empty state shown when no results found
- [x] Empty state displays music icon
- [x] Empty state shows "Keine passenden Sounds gefunden"
- [x] Empty state shows suggestions text
- [x] Suggestions: "Versuche andere Begriffe wie 'regen', 'fokus' oder 'meditation'"

#### Results List
- [x] Results displayed in scrollable list
- [x] Results header shows count ("X passende Sounds gefunden")
- [x] Results header includes volume icon
- [x] Each result is a clickable card
- [x] Result cards show sound icon, title, description
- [x] Result cards show play button
- [x] Result title is truncated (1 line)
- [x] Result description is truncated (2 lines)
- [x] Results are scrollable (FlatList)

#### Result Selection
- [x] Tapping result card selects sound
- [x] Sound selection triggers onSoundSelect callback
- [x] Drawer closes after sound selection
- [x] Sound data is transformed to Sound format
- [x] Sound is passed to audio player

### 5. SOS Trigger Detection

#### SOS Detection
- [ ] SOS config loaded from database on mount (Not implemented)
- [ ] SOS keywords checked before search execution (Not implemented)
- [ ] Query is checked against SOS keywords (case-insensitive) (Not implemented)
- [ ] Keyword matching uses includes() method (Not implemented)
- [ ] SOS trigger sets showSOSScreen state (Not implemented)
- [ ] SOS trigger prevents normal search execution (Not implemented)
- [ ] SOS trigger logs search analytics (0 results, sosTriggered: true) (Not implemented)

#### SOS Navigation
- [ ] SOS trigger calls onSOSTriggered callback (Not implemented)
- [ ] SOS config is passed to parent (TabNavigator) (Not implemented)
- [ ] Search drawer closes when SOS opens (Not implemented)
- [ ] SOS drawer opens with higher z-index (300) (Not implemented)
- [ ] Search drawer reopens when SOS closes (100ms delay) (Not implemented)
- [ ] SOS state is cleared after trigger (Not implemented)

### 6. Search Analytics

#### Analytics Logging
- [ ] All search queries are logged (Not implemented)
- [ ] Logging includes user ID (if authenticated) (Not implemented)
- [ ] Logging includes query text (Not implemented)
- [x] Logging includes results count
- [x] Logging includes SOS trigger status
- [x] Logging is asynchronous (non-blocking)
- [x] Logging errors are handled gracefully
- [x] Analytics stored in search_analytics table

#### Analytics Data
- [x] User ID (nullable for anonymous)
- [x] Search query text
- [x] Results count (number)
- [x] SOS triggered (boolean)
- [x] Created timestamp

### 7. Navigation Integration

#### Tab Navigation
- [x] Active tab is saved before opening search
- [x] X button returns to last active tab
- [x] Normal close returns to current tab
- [x] Tab state is preserved during search
- [x] Navigation stacking is handled correctly

#### Drawer Coordination
- [x] Search drawer z-index is 200
- [x] SOS drawer z-index is 300 (overlays search)
- [x] Library modal uses formSheet presentation
- [x] Drawers don't interfere with each other
- [x] Smooth transitions between drawers

---

## 🎯 User Stories

### As a user, I want to:
- Search for sounds quickly so I can find what I need
- See search results in real-time as I type
- Get relevant results based on my search query
- Access crisis support if I search for help
- Clear my search easily to start over
- Close the search drawer quickly when done
- Return to my previous screen after closing search

### As a user experiencing issues, I want to:
- See helpful suggestions when no results are found
- Know when search is loading (loading indicators)
- Get clear feedback when search fails
- Access SOS support if I search for crisis-related terms

---

## ✅ Acceptance Criteria

### Search Drawer Opening
- [x] Drawer opens in < 300ms
- [x] Animation is smooth and responsive
- [x] Search input is focused automatically
- [x] Keyboard appears without delay

### Search Execution
- [x] Search triggers after 300ms of no typing
- [x] Search completes in < 2 seconds
- [x] Results appear within 500ms of search completion
- [x] Loading state is visible during search

### Search Results
- [x] Results are relevant to query
- [x] Results are sorted by relevance
- [x] Maximum 6 results displayed
- [x] Results are clickable and responsive

### SOS Detection
- [x] SOS triggers within 500ms of keyword match
- [x] SOS drawer opens immediately
- [x] Search drawer closes smoothly
- [x] Search drawer reopens when SOS closes

### Navigation
- [x] Tab state is preserved correctly
- [x] Return to last tab works via X button
- [x] Drawer closes smoothly on all actions
- [x] No navigation stack issues

---

## 🚫 Non-Functional Requirements

### Performance
- Search debounce: 300ms
- Search execution: < 2 seconds
- Results rendering: < 500ms
- Drawer animation: < 300ms
- Smooth 60fps animations

### Usability
- Clear visual feedback for all states
- Intuitive search input placement
- Helpful empty state messages
- Accessible touch targets (min 44x44)
- Keyboard-friendly layout

### Reliability
- Network errors handled gracefully
- Empty states handled correctly
- SOS config loading failures handled
- Analytics logging failures don't block search
- No crashes on invalid input

### Accessibility
- Screen reader support
- Keyboard navigation support
- Clear visual hierarchy
- Sufficient color contrast
- Semantic labels

---

## 🔄 Edge Cases

### Network Issues
- [x] Offline detection before search
- [x] Network error messages displayed
- [x] Search retry capability
- [x] Graceful degradation

### Invalid Input
- [x] Empty queries handled
- [x] Very long queries handled
- [x] Special characters handled
- [x] Whitespace trimmed

### SOS Edge Cases
- [x] SOS config not loaded (graceful fallback)
- [x] No SOS keywords configured
- [x] SOS config loading failure
- [x] Multiple SOS triggers in sequence

### Navigation Edge Cases
- [x] Search opened from different tabs
- [x] Tab changed while search open
- [x] Multiple drawer interactions
- [x] Rapid open/close actions

### Result Edge Cases
- [x] No results found
- [x] Single result found
- [x] Exactly 6 results found
- [x] More than 6 results (limited)
- [x] Results with missing data

---

## 📊 Success Metrics

- Search drawer open time < 300ms
- Search execution time < 2 seconds
- Search success rate > 95%
- SOS detection accuracy > 99%
- User satisfaction with search > 80%
- Average searches per session > 3
- Search-to-play conversion > 60%

---

## 🔐 Security & Privacy

### Data Privacy
- [x] Search queries logged securely
- [x] User ID only logged if authenticated
- [x] Anonymous searches supported
- [x] No sensitive data in search results
- [x] Analytics comply with privacy regulations

### Security
- [x] Input sanitization (trim, normalize) (Implemented)
- [x] Injection prevention (Firestore – no SQL; client-side filtering)
- [x] XSS prevention (SwiftUI safe rendering) (Implemented)
- [x] Rate limiting (via debounce) (Implemented)
- [x] Error messages don't expose system details (Implemented)

---

## 🧪 Testing Requirements

### Unit Tests
- [x] Search query debouncing
- [x] Result scoring algorithm
- [x] SOS keyword matching
- [x] Query normalization
- [x] Result limiting

### Integration Tests
- [x] Search integration (FirestoreSoundRepository, client-side)
- [ ] SOS config loading (Not implemented)
- [ ] Analytics logging (Not implemented)
- [x] Navigation flows (Implemented)
- [x] Drawer animations (Implemented)

### E2E Tests
- [x] Complete search flow
- [x] SOS trigger flow
- [x] Navigation flows
- [x] Error scenarios
- [x] Edge cases

---

*For technical implementation details, see `technical-spec.md`*  
*For component specifications, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flow diagrams, see `user-flows.md`*
