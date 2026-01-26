# Search Drawer - User Flows

## 🔄 Primary User Flows

### 1. Basic Search Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User taps search button in navbar
   └─> TabNavigator.handleSearchPress()
       └─> Save current active tab
           └─> setSearchDrawerOpen(true)
               └─> SearchDrawer renders
                   └─> BottomSheet animates up (280ms)
                       └─> Search input auto-focuses
                           └─> Keyboard appears

2. User types search query
   └─> setSearchQuery(value)
       └─> Input displays typed text
           └─> Clear button appears (if text > 0)
               └─> useDebounce starts 300ms timer

3. User stops typing (300ms)
   └─> debouncedQuery updates
       └─> useEffect triggers
           └─> useIntelligentSearch.search(query)
               └─> setIsLoading(true)
                   └─> Check for SOS trigger
                       ├─> SOS triggered → Show SOS
                       └─> No SOS → Continue
                           └─> ProductionBackendService.searchSounds(query)
                               └─> Supabase query executes
                                   └─> Results returned
                                       └─> Client-side scoring
                                           └─> Top 6 results selected
                                               └─> setSearchResults(results)
                                                   └─> setIsLoading(false)
                                                       └─> Results displayed
                                                           └─> logSearchAnalytics(...)

4. User views results
   └─> SearchResults component renders
       └─> Results count displayed
           └─> Result cards shown
               └─> Each card shows: icon, title, description, play button

5. User taps a result card
   └─> handlePlaySound(sound)
       └─> Transform SearchResult to Sound format
           └─> onSoundSelect(sound)
               └─> TabNavigator.handleSoundSelect()
                   └─> Audio player starts sound
                       └─> SearchDrawer closes
                           └─> BottomSheet animates down (220ms)
```

**Success Path:**
- User finds desired sound
- Sound plays immediately
- Drawer closes smoothly

**Error Paths:**
- No results → Empty state shown
- Network error → Error handling
- Invalid query → Results filtered out

---

### 2. SOS Trigger Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens search drawer
   └─> SearchDrawer renders
       └─> useIntelligentSearch initializes
           └─> loadSOSConfig() called
               └─> ProductionBackendService.getActiveSOSConfig()
                   └─> Supabase: sos_config table
                       └─> Active config loaded
                           └─> setSOSConfig(config)

2. User types crisis-related query
   └─> setSearchQuery("suizid" or "selbstmord" etc.)
       └─> useDebounce triggers after 300ms
           └─> useIntelligentSearch.search(query)
               └─> checkForSOSTrigger(query)
                   └─> Normalize query (lowercase, trim)
                       └─> Check against SOS keywords
                           ├─> No match → Continue normal search
                           └─> Match found → Continue
                               └─> setShowSOSScreen(true)
                                   └─> logSearchAnalytics(query, 0, true)
                                       └─> setIsLoading(false)
                                           └─> Return empty results

3. SOS trigger detected
   └─> useEffect detects showSOSScreen === true
       └─> onSOSTriggered(sosConfig) called
           └─> TabNavigator.handleSOSTriggered(config)
               └─> setSOSConfig(config)
                   └─> setSearchDrawerOpen(false)
                       └─> setSOSDrawerOpen(true)
                           └─> SearchDrawer closes (220ms)
                               └─> SOSDrawer opens (280ms, z-index 300)

4. User views SOS drawer
   └─> SOSDrawer displays crisis resources
       └─> User can call hotline, access chat, view resources

5. User closes SOS drawer
   └─> TabNavigator.handleSOSClose()
       └─> setSOSDrawerOpen(false)
           └─> setSOSConfig(null)
               └─> setTimeout(() => setSearchDrawerOpen(true), 100)
                   └─> SOSDrawer closes
                       └─> SearchDrawer reopens
                           └─> Search query preserved (if any)
```

**Success Path:**
- SOS detected immediately
- SOS drawer opens smoothly
- User accesses crisis resources
- Search drawer reopens when SOS closes

**Error Paths:**
- SOS config not loaded → Normal search continues
- No SOS keywords → Normal search continues
- Network error → Normal search continues

---

### 3. Empty Results Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User types search query
   └─> Search executes
       └─> ProductionBackendService.searchSounds(query)
           └─> Supabase returns empty array
               └─> setSearchResults([])
                   └─> setIsLoading(false)

2. Empty state displayed
   └─> SearchResults component renders empty state
       └─> Icon displayed (music icon)
           └─> Text: "Keine passenden Sounds gefunden"
               └─> Suggestions text displayed
                   └─> "Versuche andere Begriffe wie 'regen', 'fokus' oder 'meditation'"

3. User can:
   ├─> Clear search and try different query
   │   └─> Tap clear button
   │       └─> setSearchQuery('')
   │           └─> Results cleared
   │               └─> Empty state hidden
   │
   ├─> Type new query
   │   └─> New search executes
   │       └─> Results displayed (if found)
   │
   └─> Close drawer
       └─> Drawer closes
           └─> Return to previous screen
```

**User Experience:**
- Clear feedback that no results found
- Helpful suggestions for alternative queries
- Easy to try again or close

---

### 4. Loading State Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User types search query
   └─> Debounce triggers
       └─> setIsLoading(true)
           └─> SearchResults component renders loading state
               └─> Three skeleton loaders displayed
                   └─> Each skeleton shows:
                       ├─> Icon placeholder (40x40px)
                       ├─> Title placeholder (75% width)
                       └─> Description placeholder (50% width)

2. Search executes
   └─> ProductionBackendService.searchSounds(query)
       └─> Network request in progress
           └─> Skeleton loaders animate

3. Results received
   └─> setSearchResults(results)
       └─> setIsLoading(false)
           └─> Skeleton loaders disappear
               └─> Results displayed
                   └─> Smooth transition
```

**User Experience:**
- Clear visual feedback during search
- Skeleton loaders match result card layout
- Smooth transition to results

---

### 5. Navigation Flow (X Button)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens search drawer
   └─> TabNavigator saves current tab
       └─> setLastActiveTabBeforeSearch(activeTab)
           └─> Search drawer opens

2. User taps X button
   └─> handleClose(true) called
       └─> setSearchQuery('')
           └─> clearSearch()
               └─> onCloseToLastTab() called
                   └─> TabNavigator.handleReturnToLastTab()
                       └─> if (lastActiveTabBeforeSearch)
                           └─> setActiveTab(lastActiveTabBeforeSearch)
                               └─> setLastActiveTabBeforeSearch(null)
                                   └─> setSearchDrawerOpen(false)
                                       └─> Drawer closes
                                           └─> User returns to previous tab
```

**Use Case:**
- User wants to return to previous tab
- X button provides quick navigation
- Tab state is preserved correctly

---

### 6. Navigation Flow (Normal Close)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens search drawer
   └─> Search drawer opens
       └─> Current tab remains active

2. User closes drawer (swipe, backdrop, or after sound selection)
   └─> handleClose(false) called
       └─> setSearchQuery('')
           └─> clearSearch()
               └─> onClose() called
                   └─> TabNavigator.handleSearchClose()
                       └─> setSearchDrawerOpen(false)
                           └─> Drawer closes
                               └─> User remains on current tab
```

**Use Case:**
- User closes drawer without selecting sound
- User remains on current tab
- Normal navigation behavior

---

## 🔀 Alternative Flows

### Quick Search Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens search
   └─> Drawer opens, input focused

2. User types "regen" quickly
   └─> Debounce waits 300ms
       └─> Search executes
           └─> Results appear
               └─> User taps first result
                   └─> Sound plays, drawer closes

Total time: < 5 seconds
```

**Optimization:**
- Fast typing doesn't trigger multiple searches
- Debounce prevents unnecessary API calls
- Quick selection minimizes interaction time

---

### Refined Search Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User types "schlaf"
   └─> Results displayed (e.g., 4 results)

2. User wants different results
   └─> Taps clear button
       └─> setSearchQuery('')
           └─> Results cleared
               └─> Input ready for new query

3. User types "meditation"
   └─> New search executes
       └─> New results displayed
```

**Use Case:**
- User refines search query
- Clear button provides quick reset
- New search executes immediately

---

### SOS Return Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User triggers SOS from search
   └─> SOS drawer opens
       └─> Search drawer closes

2. User views SOS resources
   └─> SOS drawer displays resources

3. User closes SOS drawer
   └─> TabNavigator.handleSOSClose()
       └─> setSOSDrawerOpen(false)
           └─> setTimeout(() => setSearchDrawerOpen(true), 100)
               └─> Search drawer reopens
                   └─> Search query preserved (if any)
                       └─> User can continue searching
```

**Use Case:**
- User accesses SOS resources
- Returns to search after viewing resources
- Seamless transition between drawers

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User types search query
   └─> Search executes
       └─> Network request fails
           └─> ProductionBackendService.searchSounds() throws error
               └─> Error caught in useIntelligentSearch
                   └─> setIsLoading(false)
                       └─> setSearchResults([])
                           └─> Empty state displayed
                               └─> User can retry
```

**Error Handling:**
- Network errors don't crash app
- Empty state shown as fallback
- User can retry search
- Error logged for debugging

---

### SOS Config Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Search drawer opens
   └─> useIntelligentSearch initializes
       └─> loadSOSConfig() called
           └─> ProductionBackendService.getActiveSOSConfig()
               └─> Database error or no config
                   └─> Returns null
                       └─> setSOSConfig(null)
                           └─> Search continues normally
                               └─> SOS detection disabled
                                   └─> Normal search works
```

**Error Handling:**
- SOS config errors don't block search
- Search continues without SOS detection
- Error logged for debugging
- App remains functional

---

### Analytics Logging Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Search executes successfully
   └─> Results displayed
       └─> logSearchAnalytics() called
           └─> ProductionBackendService.logSearchAnalytics()
               └─> Database error
                   └─> Error caught
                       └─> Error logged (non-blocking)
                           └─> Search continues normally
                               └─> User experience unaffected
```

**Error Handling:**
- Analytics errors don't block search
- Non-blocking error handling
- User experience unaffected
- Error logged for debugging

---

## 🔄 State Transitions

### Search State Machine

```
No Query
    │
    ├─> User types → Query Entered
    │       │
    │       ├─> Debounce → Searching
    │       │       │
    │       │       ├─> Success → Results Displayed
    │       │       │       │
    │       │       │       ├─> User selects → Sound Playing
    │       │       │       │
    │       │       │       └─> User clears → No Query
    │       │       │
    │       │       ├─> SOS Triggered → SOS Drawer Open
    │       │       │
    │       │       └─> Error → Empty State
    │       │
    │       └─> User clears → No Query
    │
    └─> User closes → Drawer Closed
```

### Drawer State Machine

```
Closed
    │
    ├─> User opens → Opening
    │       │
    │       └─> Animation complete → Open
    │               │
    │               ├─> User closes → Closing
    │               │       │
    │               │       └─> Animation complete → Closed
    │               │
    │               └─> SOS triggered → Closing
    │                       │
    │                       └─> SOS opens → SOS Open
    │                               │
    │                               └─> SOS closes → Opening
    │                                       │
    │                                       └─> Animation complete → Open
```

---

## 📊 Flow Diagrams

### Complete Search Journey

```
Main App Screen
    │
    ├─> User taps search button
    │   └─> Search Drawer Opens
    │       │
    │       ├─> User types query
    │       │   └─> Search Executes
    │       │       │
    │       │       ├─> Results Found
    │       │       │   └─> Results Displayed
    │       │       │       │
    │       │       │       ├─> User selects sound
    │       │       │       │   └─> Sound Plays
    │       │       │       │       └─> Drawer Closes
    │       │       │       │
    │       │       │       └─> User closes drawer
    │       │       │           └─> Return to Main App
    │       │       │
    │       │       ├─> No Results
    │       │       │   └─> Empty State Shown
    │       │       │       │
    │       │       │       └─> User can retry or close
    │       │       │
    │       │       └─> SOS Triggered
    │       │           └─> SOS Drawer Opens
    │       │               │
    │       │               └─> User closes SOS
    │       │                   └─> Search Drawer Reopens
    │       │
    │       └─> User closes without searching
    │           └─> Drawer Closes
    │               └─> Return to Main App
    │
    └─> User continues browsing
        └─> No search interaction
```

---

## 🎯 User Goals

### Goal: Find Sound Quickly
- **Path:** Open Search → Type Query → Select Result
- **Time:** < 10 seconds
- **Steps:** 3-4 interactions

### Goal: Discover New Sounds
- **Path:** Open Search → Type Generic Query → Browse Results
- **Time:** < 30 seconds
- **Steps:** 5-6 interactions

### Goal: Access Crisis Support
- **Path:** Open Search → Type Crisis Query → SOS Opens
- **Time:** < 5 seconds
- **Steps:** 2-3 interactions

---

## 📈 Performance Metrics

### Search Flow Performance
- Drawer open: < 300ms
- Search execution: < 2 seconds
- Results display: < 500ms
- Sound selection: < 200ms
- Total flow: < 3 seconds

### SOS Flow Performance
- SOS detection: < 500ms
- SOS drawer open: < 300ms
- Total SOS flow: < 1 second

### Navigation Performance
- Tab switch: < 200ms
- Drawer close: < 220ms
- Return to tab: < 200ms

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
