# SOS Screen - User Flows

## 🔄 Primary User Flows

### 1. SOS Trigger Flow (Search → SOS)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User opens Search Drawer
   └─> SearchDrawer opens
       └─> useIntelligentSearch hook initializes
           └─> loadSOSConfig() called
               └─> ProductionBackendService.getActiveSOSConfig()
                   └─> Config loaded and cached

2. User types search query
   └─> Search input updates
       └─> Debounced query triggers search()

3. Search query contains SOS keyword
   └─> useIntelligentSearch.search() called
       └─> checkForSOSTrigger(query) executed
           ├─> Keyword match found → Continue
           └─> No match → Normal search results

4. SOS keyword detected
   └─> setShowSOSScreen(true)
       └─> Search results bypassed
           └─> logSearch(query, 0, true) called
               └─> Analytics logged with SOS flag

5. SearchDrawer detects SOS trigger
   └─> useEffect detects showSOSScreen === true
       └─> onSOSTriggered(sosConfig) called
           └─> dismissSOS() clears hook state

6. TabNavigator receives SOS trigger
   └─> handleSOSTriggered(config) called
       ├─> setSOSConfig(config)
       ├─> setSearchDrawerOpen(false)
       └─> setSOSDrawerOpen(true)

7. SOSDrawer opens
   └─> Full-height drawer slides up
       └─> SOSScreenDrawer displays
           └─> SOS content visible to user
```

**Success Path:**
- Keyword detected
- SOS screen opens immediately
- User sees crisis resources

**Error Paths:**
- Config not loaded → Attempt reload, use defaults
- No keywords match → Normal search continues
- Network error → Use cached config or defaults

---

### 2. Phone Call Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User views SOS Screen
   └─> SOSScreenDrawer displays
       └─> "Sofort anrufen" button visible
           └─> Phone number displayed

2. User clicks "Sofort anrufen"
   └─> handleCall() called
       └─> Phone number formatted
           └─> Spaces and hyphens removed
               └─> URL created: tel:+498001110111

3. System checks phone availability
   └─> Linking.canOpenURL(tel:...) called
       ├─> Available → Continue
       └─> Not available → Show error alert

4. Phone dialer opens
   └─> Linking.openURL(tel:...) called
       └─> Native phone app opens
           └─> Number pre-filled
               └─> User can initiate call
```

**Success Path:**
- Button clicked
- Phone dialer opens
- Number pre-filled

**Error Paths:**
- Phone unavailable → Error alert shown
- Invalid number → Error alert shown
- No phone app → Error alert shown

---

### 3. Chat Link Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User views SOS Screen
   └─> SOSScreenDrawer displays
       └─> Chat link configured?
           ├─> Yes → "Online-Chat starten" button visible
           └─> No → Button hidden

2. User clicks "Online-Chat starten"
   └─> handleChat() called
       └─> Chat link URL available?
           ├─> Yes → Continue
           └─> No → Return (should not happen)

3. System checks link availability
   └─> Linking.canOpenURL(chatLink) called
       ├─> Available → Continue
       └─> Not available → Show error alert

4. Chat service opens
   └─> Linking.openURL(chatLink) called
       └─> External browser/app opens
           └─> Chat service loads
               └─> User can start chat
```

**Success Path:**
- Button clicked
- Chat service opens
- User can chat

**Error Paths:**
- Link unavailable → Error alert shown
- Invalid URL → Error alert shown
- Network error → Error alert shown

---

### 4. Resource Phone Call Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User views SOS Screen
   └─> SOSScreenDrawer displays
       └─> Resources list visible
           └─> Resources with phone numbers shown

2. User views resource item
   └─> Resource text displayed
       └─> extractPhoneNumber(resource) called
           ├─> Phone found → Phone icon shown, item clickable
           └─> No phone → Item display-only

3. User clicks resource with phone
   └─> handleCall(extractedPhone) called
       └─> Phone number formatted
           └─> URL created: tel:...

4. Phone dialer opens
   └─> Linking.openURL(tel:...) called
       └─> Native phone app opens
           └─> Resource phone number pre-filled
```

**Success Path:**
- Resource clicked
- Phone extracted
- Phone dialer opens

**Error Paths:**
- No phone in resource → Item not clickable
- Invalid phone format → Error alert shown
- Phone unavailable → Error alert shown

---

### 5. Close/Dismiss Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User views SOS Screen
   └─> SOSScreenDrawer displays
       └─> Close button visible in header

2. User clicks close button
   └─> onDismiss() called
       └─> SOSDrawer.handleClose() called
           ├─> onDismiss() called (clear state)
           └─> onClose() called (close drawer)

3. TabNavigator handles close
   └─> handleSOSClose() called
       ├─> setSOSDrawerOpen(false)
       ├─> setSOSConfig(null)
       └─> setTimeout(() => setSearchDrawerOpen(true), 100)

4. Search Drawer reopens
   └─> SearchDrawer opens
       └─> User returns to search interface
           └─> Search query preserved (if applicable)
```

**Alternative: Swipe Down**
- User swipes down on SOS drawer
- Same close flow as button click
- Smooth transition back to search

**Success Path:**
- Close button clicked or swipe down
- SOS drawer closes
- Search drawer reopens
- User returns to search

---

## 🔀 Alternative Flows

### Normal Search Flow (No SOS Trigger)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User types search query
   └─> Search input updates
       └─> Debounced query triggers search()

2. Search query does NOT contain SOS keyword
   └─> useIntelligentSearch.search() called
       └─> checkForSOSTrigger(query) executed
           └─> No keyword match → Continue normal search

3. Normal search performed
   └─> ProductionBackendService.searchSounds(query)
       └─> Results returned
           └─> Results displayed in SearchDrawer

4. Search results shown
   └─> User can select sounds
       └─> No SOS screen displayed
```

**Use Cases:**
- Regular sound searches
- Category searches
- Non-crisis queries

---

### Configuration Load Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App starts / Component mounts
   └─> useIntelligentSearch hook initializes
       └─> useEffect triggers loadSOSConfig()

2. Configuration loading
   └─> ProductionBackendService.getActiveSOSConfig()
       └─> Supabase query executed
           ├─> Success → Config loaded
           └─> Error → Null returned

3. Configuration transformation
   └─> Database format transformed to component format
       └─> sosConfig state updated
           └─> Config ready for keyword checking

4. Cache management (SearchService alternative)
   └─> Check cache validity
       ├─> Valid → Return cached config
       └─> Expired → Reload from database
           └─> Update cache
```

**Cache Behavior:**
- Cache duration: 1 hour
- Cache hit: Return immediately
- Cache miss: Load from database
- Cache update: On successful load

---

### Error Recovery Flow

```
Error Event                    System Response
─────────────────────────────────────────────────────────
1. Configuration load fails
   └─> ProductionBackendService.getActiveSOSConfig()
       └─> Error returned
           └─> Null returned
               └─> Default values used
                   └─> SOS still functional

2. Phone call fails
   └─> Linking.canOpenURL() returns false
       └─> Alert.alert('Fehler', 'Telefonfunktion ist nicht verfügbar')
           └─> User informed
               └─> SOS screen remains open

3. Chat link fails
   └─> Linking.canOpenURL() returns false
       └─> Alert.alert('Fehler', 'Chat-Link konnte nicht geöffnet werden')
           └─> User informed
               └─> SOS screen remains open

4. Network error during search
   └─> Search fails
       └─> Error logged
           └─> Empty results shown
               └─> SOS check still performed (if config cached)
```

**Error Handling:**
- Graceful degradation
- User-friendly messages
- Non-blocking errors
- Default fallbacks

---

## 🚨 Error Flows

### Configuration Load Error

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App starts
   └─> loadSOSConfig() called
       └─> Database query fails
           └─> Error caught
               └─> Null returned

2. Default values used
   └─> Default title: "Du bist nicht ALLEIN"
       └─> Default message: "Wenn du in einer Krise bist..."
           └─> Default phone: "0800 111 0 111"
               └─> Empty resources array

3. SOS still functional
   └─> Keyword detection disabled (no keywords)
       └─> SOS screen can be opened manually (if needed)
           └─> Default resources displayed
```

**User Experience:**
- App continues to function
- Default resources available
- No error shown to user
- Logged for debugging

---

### Phone Unavailable Error

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User clicks "Sofort anrufen"
   └─> handleCall() called
       └─> Linking.canOpenURL(tel:...) called
           └─> Returns false (phone unavailable)

2. Error alert shown
   └─> Alert.alert('Fehler', 'Telefonfunktion ist nicht verfügbar')
       └─> User sees error message
           └─> SOS screen remains open
               └─> User can try other actions
```

**User Actions:**
- Read error message
- Try chat link (if available)
- View resources
- Close SOS screen

---

### Invalid Phone Number Error

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User clicks resource with phone
   └─> extractPhoneNumber() called
       └─> Phone extracted from text
           └─> handleCall(phone) called

2. Phone number invalid
   └─> Linking.openURL() fails
       └─> catch block executed
           └─> Alert.alert('Fehler', 'Anruf konnte nicht gestartet werden')
               └─> User informed
                   └─> SOS screen remains open
```

**Error Handling:**
- Error caught gracefully
- User-friendly message
- App continues functioning
- No crash

---

## 🔄 State Transitions

### SOS Trigger States

```
No Trigger → Keyword Detected → SOS Screen Open
     │              │                  │
     │              │                  └─> Close → Search Drawer
     │              │
     │              └─> No Match → Normal Search
     │
     └─> Normal Search → Results Displayed
```

### Configuration States

```
No Config → Loading → Loaded
    │          │          │
    │          │          └─> Cached → Used
    │          │
    │          └─> Error → Defaults Used
    │
    └─> Defaults → Used
```

### Drawer States

```
Search Drawer Open → SOS Triggered → SOS Drawer Open
        │                                    │
        │                                    └─> Close → Search Drawer Open
        │
        └─> Close → Main App
```

---

## 📊 Flow Diagrams

### Complete SOS Journey

```
User Opens App
    │
    ├─> Opens Search Drawer
    │   └─> Types search query
    │       ├─> Contains SOS keyword
    │       │   └─> SOS Screen Opens
    │       │       ├─> Clicks "Sofort anrufen"
    │       │       │   └─> Phone Dialer Opens
    │       │       ├─> Clicks "Online-Chat starten"
    │       │       │   └─> Chat Service Opens
    │       │       ├─> Clicks Resource
    │       │       │   └─> Resource Phone Called
    │       │       └─> Closes SOS Screen
    │       │           └─> Returns to Search
    │       │
    │       └─> No SOS keyword
    │           └─> Normal Search Results
    │               └─> User Selects Sound
    │
    └─> Uses Main App
        └─> (No SOS interaction)
```

---

### Configuration Loading Journey

```
App Startup
    │
    └─> useIntelligentSearch Mounts
        └─> useEffect Triggers
            └─> loadSOSConfig() Called
                │
                ├─> Cache Hit?
                │   ├─> Yes → Use Cached Config
                │   └─> No → Continue
                │
                └─> Database Query
                    ├─> Success
                    │   └─> Transform Config
                    │       └─> Update Cache
                    │           └─> Set State
                    │
                    └─> Error
                        └─> Use Defaults
                            └─> Set State
```

---

## 🎯 User Goals

### Goal: Get Immediate Help
- **Path:** Search → SOS Keyword → SOS Screen → Call/Chat
- **Time:** < 5 seconds
- **Steps:** 3-4 taps

### Goal: Find Support Resources
- **Path:** Search → SOS Keyword → SOS Screen → View Resources
- **Time:** < 3 seconds
- **Steps:** 2-3 taps

### Goal: Access Chat Support
- **Path:** Search → SOS Keyword → SOS Screen → Chat Button
- **Time:** < 4 seconds
- **Steps:** 3 taps

---

## 📱 Platform-Specific Flows

### iOS Flow
- Phone dialer opens via `tel:` URL scheme
- Chat links open in Safari or app
- Bottom sheet uses native iOS gestures
- Smooth animations

### Android Flow
- Phone dialer opens via `tel:` intent
- Chat links open in browser or app
- Bottom sheet uses native Android gestures
- Material design animations

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
