# Library System - User Flows

## 🔄 Primary User Flows

### 1. Browse Library Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Library Screen
   └─> Display Loading State
       └─> Load Sound Metadata
           ├─> Error → Show Error Message with Retry
           └─> Success → Continue
               └─> Load Subscription Tier
                   └─> Load Favorites
                       └─> Process & Display Sounds
                           └─> Show Library Interface

2. View Sound Catalog
   └─> Display Sound Cards
       ├─> Show Title & Description
       ├─> Show Category Label & Icon
       ├─> Show Duration
       ├─> Show Favorite Status
       └─> Show Lock Status (if locked)

3. Scroll Through Sounds
   └─> Load More Sounds (if paginated)
       └─> Display Additional Sounds
```

**Success Path:**
- Library loads successfully
- All sounds display correctly
- Statistics show accurate counts

**Error Paths:**
- Network error → Show error message with retry
- Empty library → Show empty state
- Load timeout → Show timeout message

---

### 2. Search Sounds Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Enter Search Query
   └─> Real-time Filter
       └─> Search in:
           ├─> Title
           ├─> Description
           ├─> Tags
           └─> Keywords
               └─> Update Results Immediately

2. View Search Results
   └─> Display Filtered Sounds
       ├─> Show Matching Sounds
       └─> Show Results Count

3. Clear Search
   └─> Clear Search Input
       └─> Reset to All Sounds
           └─> Display Full Catalog
```

**Success Path:**
- Search results update in real-time
- Matching sounds display correctly
- Clear search resets to full catalog

**Error Paths:**
- No results → Show empty state
- Search too slow → Show loading indicator

---

### 3. Filter by Category Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Select Category
   └─> Highlight Selected Category
       └─> Filter Sounds by Category
           └─> Update Sound List
               └─> Show Category-Specific Sounds

2. Select "All" Category
   └─> Remove Category Filter
       └─> Display All Sounds
           └─> Reset Category Highlight

3. Combine Category + Search
   └─> Apply Both Filters
       └─> Show Sounds Matching:
           ├─> Selected Category
           └─> Search Query
```

**Success Path:**
- Category filter applies immediately
- Sound list updates correctly
- Combined filters work together

**Error Paths:**
- No sounds in category → Show empty state
- Category filter fails → Show error

---

### 4. Add Favorite Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click Heart Icon (Empty)
   └─> Check Authentication
       ├─> Not Authenticated → Show Login Prompt
       └─> Authenticated → Continue
           └─> Check if Locked
               ├─> Locked → Show Paywall
               └─> Not Locked → Continue
                   └─> Optimistic UI Update
                       └─> Fill Heart Icon
                           └─> Call addFavorite API
                               ├─> Error → Revert UI, Show Error
                               └─> Success → Sync with Backend
                                   └─> Update Favorite Status
```

**Success Path:**
- Heart icon fills immediately
- Favorite syncs with backend
- Status persists across sessions

**Error Paths:**
- Not authenticated → Login prompt
- Locked content → Paywall prompt
- API error → Revert UI, show error message
- Network error → Show connectivity error

---

### 5. Remove Favorite Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click Heart Icon (Filled)
   └─> Check Authentication
       ├─> Not Authenticated → Show Login Prompt
       └─> Authenticated → Continue
           └─> Optimistic UI Update
               └─> Empty Heart Icon
                   └─> Call removeFavorite API
                       ├─> Error → Revert UI, Show Error
                       └─> Success → Sync with Backend
                           └─> Update Favorite Status
```

**Success Path:**
- Heart icon empties immediately
- Favorite removed from backend
- Status updates across app

**Error Paths:**
- Not authenticated → Login prompt
- API error → Revert UI, show error message
- Network error → Show connectivity error

---

### 6. Create Mix Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Click "Mix erstellen" Button
   └─> Enable Select Mode
       └─> Show Selection Indicators
           └─> Display Selection Counter
               └─> Show "Abbrechen" Button

2. Select Sound
   └─> Check Selection Count
       ├─> < 4 → Add to Selection
       │   └─> Show Selection Indicator
       │       └─> Update Counter
       └─> = 4 → Show Alert
           └─> "Maximum 4 Sounds Reached"

3. Deselect Sound
   └─> Remove from Selection
       └─> Hide Selection Indicator
           └─> Update Counter

4. Click "Mix erstellen" (with selections)
   └─> Validate Selection
       ├─> No Selection → Show Alert
       └─> Has Selection → Continue
           └─> Navigate to Mixer Screen
               └─> Pass Selected Sounds
```

**Success Path:**
- Select mode enables correctly
- Up to 4 sounds can be selected
- Mix creation navigates to mixer

**Error Paths:**
- Maximum reached → Alert shown
- No selection → Alert shown
- Navigation fails → Error message

---

### 7. Access Locked Content Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Locked Sound
   └─> Display Lock Indicator
       └─> Show Premium Badge
           └─> Reduce Opacity

2. Click Locked Sound
   └─> Check Subscription Tier
       ├─> Premium → Allow Access
       └─> Not Premium → Continue
           └─> Track Paywall Event
               └─> Show Paywall Alert
                   └─> "Upgrade erforderlich"
                       └─> Offer Upgrade Option

3. Try to Favorite Locked Sound
   └─> Check Lock Status
       └─> Show Paywall Alert
           └─> Prevent Favorite Addition
```

**Success Path:**
- Lock indicators display correctly
- Paywall shows for locked content
- Premium users access all content

**Error Paths:**
- Tier check fails → Default to locked
- Paywall fails → Show error message

---

## 🔀 Alternative Flows

### Offline Download Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Select Sound for Download
   └─> Check if Already Downloaded
       ├─> Downloaded → Use Local File
       └─> Not Downloaded → Continue
           └─> Start Download
               └─> Show Progress Indicator
                   └─> Download with Progress Updates
                       ├─> Error → Show Error Message
                       └─> Success → Save to Local Storage
                           └─> Update Cache
                               └─> Mark as Downloaded
```

**Use Cases:**
- User wants offline access
- User has limited data plan
- User wants faster playback

---

### Subscription Tier Change Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User Subscription Changes
   └─> Detect Tier Change
       └─> Reload Subscription Tier
           └─> Re-filter Content
               ├─> Unlock Previously Locked Content
               └─> Update Statistics
                   └─> Refresh Library Display
```

**Automatic Behavior:**
- Runs when subscription changes
- Updates accessible sounds count
- Unlocks premium content
- Updates lock indicators

---

### Favorites Sync Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App Startup / Favorites Load
   └─> Load Favorites from Supabase
       ├─> Success → Display Favorites
       └─> Failure → Load from Local Storage
           └─> Sync with Backend When Online

2. Favorite Added/Removed
   └─> Update Local State
       └─> Sync with Backend
           ├─> Success → Confirm Sync
           └─> Failure → Queue for Retry
               └─> Retry on Next Action
```

**Automatic Behavior:**
- Syncs on app startup
- Syncs on favorite changes
- Retries failed syncs
- Falls back to local storage

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Library Load
   └─> Network Request Fails
       └─> Detect Network Error
           └─> Show Error Message
               └─> "Verbindungsfehler"
                   └─> Offer Retry Option
                       └─> Retry on User Action
```

**Error Messages:**
- "Die Audiobibliothek konnte nicht geladen werden"
- "Bitte überprüfe deine Internetverbindung"
- Retry button available

---

### Empty Results Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Search/Filter Returns No Results
   └─> Display Empty State
       ├─> Show Empty Icon
       ├─> Show Message
       │   └─> "Keine Ergebnisse gefunden"
       └─> Show Suggestion
           └─> "Passe deine Filter oder Suchbegriffe an"
```

**User Actions:**
- Clear search
- Change category filter
- Try different search terms

---

### Authentication Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Try to Add Favorite (Not Authenticated)
   └─> Check Authentication Status
       └─> Not Authenticated → Show Alert
           └─> "Anmeldung erforderlich"
               └─> "Bitte melde dich an, um Favoriten zu verwalten"
                   └─> Offer Navigation to Auth
```

**User Actions:**
- Navigate to authentication
- Sign in and return to library
- Retry favorite action

---

## 🔄 State Transitions

### Library Loading States

```
Initial → Loading → Loaded
    │        │         │
    │        │         └─> Error → Retry → Loading
    │        │
    │        └─> Error → Retry → Loading
    │
    └─> Empty → Loaded
```

### Search States

```
No Query → Query Entered → Results
    │            │            │
    │            │            └─> No Results → Empty State
    │            │
    │            └─> Clear → No Query
    │
    └─> Clear → No Query
```

### Favorite States

```
Not Favorite → Adding → Favorite
    │             │         │
    │             │         └─> Removing → Not Favorite
    │             │
    │             └─> Error → Not Favorite
    │
    └─> Error → Not Favorite
```

### Select Mode States

```
Normal → Select Mode → Selection
    │         │            │
    │         │            └─> Create Mix → Normal
    │         │
    │         └─> Cancel → Normal
    │
    └─> Cancel → Normal
```

---

## 📊 Flow Diagrams

### Complete Library Browsing Journey

```
App Launch
    │
    └─> Navigate to Library
        └─> LibraryScreen Mount
            ├─> Load Sound Metadata
            ├─> Load Subscription Tier
            └─> Load Favorites
                │
                └─> Display Library
                    │
                    ├─> User Searches
                    │   └─> Filter Results
                    │       └─> Select Sound
                    │
                    ├─> User Filters by Category
                    │   └─> Display Category Sounds
                    │       └─> Select Sound
                    │
                    ├─> User Adds Favorite
                    │   └─> Sync with Backend
                    │       └─> Update UI
                    │
                    └─> User Creates Mix
                        └─> Select 4 Sounds
                            └─> Navigate to Mixer
```

---

### Favorites Management Journey

```
Library Screen
    │
    ├─> User Clicks Heart (Empty)
    │   └─> Check Authentication
    │       ├─> Authenticated → Add Favorite
    │       │   └─> Sync with Backend
    │       │       └─> Update UI
    │       └─> Not Authenticated → Show Login
    │
    └─> User Clicks Heart (Filled)
        └─> Remove Favorite
            └─> Sync with Backend
                └─> Update UI
```

---

### Mix Creation Journey

```
Library Screen
    │
    └─> User Clicks "Mix erstellen"
        └─> Enable Select Mode
            │
            ├─> User Selects Sound 1
            │   └─> Update Counter (1/4)
            │
            ├─> User Selects Sound 2
            │   └─> Update Counter (2/4)
            │
            ├─> User Selects Sound 3
            │   └─> Update Counter (3/4)
            │
            ├─> User Selects Sound 4
            │   └─> Update Counter (4/4)
            │       └─> Show "Mix erstellen" Button
            │
            └─> User Clicks "Mix erstellen"
                └─> Navigate to Mixer
                    └─> Pass Selected Sounds
```

---

## 🎯 User Goals

### Goal: Find Specific Sound
- **Path:** Search or Filter by Category
- **Time:** < 10 seconds
- **Steps:** 2-3 actions

### Goal: Save Favorite Sound
- **Path:** Browse → Click Heart
- **Time:** < 2 seconds
- **Steps:** 1-2 actions

### Goal: Create Custom Mix
- **Path:** Select Mode → Select 4 Sounds → Create
- **Time:** < 30 seconds
- **Steps:** 6-7 actions

### Goal: Browse All Sounds
- **Path:** Open Library → Scroll
- **Time:** Immediate
- **Steps:** 1 action

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
