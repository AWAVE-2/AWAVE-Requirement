# Category Screens - User Flows

## 🔄 Primary User Flows

### 1. Category Screen Display Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. App Starts / Navigate to Category Tab
   └─> TabNavigator renders category screen
       └─> CategoryScreenBase mounts
           ├─> CategoryContext loads categories
           │   └─> CategoryService.fetchPrimaryCategories()
           │       ├─> Fetch from Supabase
           │       │   ├─> audio_categories table
           │       │   └─> sound_metadata table
           │       └─> Fallback to majorCategories if needed
           ├─> Load selected category from onboarding storage
           └─> Display category screen
               ├─> CategoryHeroHeader
               │   ├─> Display category icon with gradient
               │   ├─> Display category headline
               │   └─> Display category description
               └─> SoundGrid
                   ├─> Display category sounds
                   ├─> Display custom sounds
                   ├─> Display favorites
                   ├─> Display "Weitere Sessions" button
                   └─> Display "Eigene Klangwelt" section
```

**Success Path:**
- Categories load successfully
- Category screen displays with all content
- User can interact with sounds

**Error Paths:**
- Network error → Fallback to local categories
- Invalid data → Use default category structure
- Empty data → Display empty state

---

### 2. Category Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Tap Category Tab in Bottom Navigation
   └─> TabNavigator.handleTabPress(categoryId)
       ├─> Update activeTab state
       ├─> CategoryContext.handleCategorySelect(categoryId)
       │   └─> Save to onboarding storage
       └─> Render category screen
           └─> CategoryScreenBase displays content
               ├─> CategoryHeroHeader (category-specific)
               └─> SoundGrid (category-specific sounds)
```

**Success Path:**
- Tab press updates active tab
- Category screen displays
- Category selection persisted

**Alternative Paths:**
- Same category selected → No change
- Invalid category → Default to first category

---

### 3. Sound Selection Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Tap Sound Card in SoundGrid
   └─> SoundGrid.onSoundSelect(sound)
       └─> CategoryScreenBase passes to screen
           └─> Screen.handleSoundSelect(sound)
               └─> useSoundPlayer.handleSoundSelect(sound)
                   ├─> Check registration status
                   │   ├─> Not registered → Cache selection
                   │   │   └─> Navigate to auth
                   │   └─> Registered → Continue
                   ├─> Open AudioPlayerEnhanced
                   │   └─> Start playback
                   └─> Show mini player strip (if minimized)
```

**Success Path:**
- Sound selected
- Audio player opens
- Playback starts

**Error Paths:**
- Not registered → Navigate to auth (with cached selection)
- Playback error → Show error message
- Network error → Show connectivity error

---

### 4. Add to Mix Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Long Press / Add to Mix Action on Sound
   └─> SoundGrid.onAddToMix(sound)
       └─> CategoryScreenBase passes to screen
           └─> Screen.handleAddToMix(sound)
               └─> useSoundPlayer.handleAddToMix(sound)
                   └─> Add sound to multi-track mixer
                       └─> Update mixer state
                           └─> Show mixer UI (if not visible)
```

**Success Path:**
- Sound added to mix
- Mixer updated
- Multi-track playback available

**Error Paths:**
- Mixer full → Show error message
- Playback error → Show error message

---

### 5. Favorite Selection Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Tap Favorite Sound in SoundGrid
   └─> SoundGrid.onFavoriteSelect(favorite)
       └─> CategoryScreenBase passes to screen
           └─> Screen.handleFavoriteSelect(favorite)
               ├─> useSoundPlayer.handleSoundSelect(favorite.sound)
               │   └─> Open AudioPlayerEnhanced
               └─> useFavoritesManagement.markFavoritePlayed(favoriteId)
                   └─> Update favorite played status
```

**Success Path:**
- Favorite selected
- Audio player opens
- Favorite played status updated

**Error Paths:**
- Favorite not found → Show error message
- Playback error → Show error message

---

### 6. Klangwelten Navigation Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Tap "Eigene Klangwelt erstellen" Button
   └─> SoundGrid.onRequestKlangwelten()
       └─> CategoryScreenBase passes to screen
           └─> Screen.handleKlangweltenPress()
               └─> Navigation.navigate('Klangwelten', {
                     categoryId: categoryId,
                     categoryTitle: category.title
                   })
                   └─> KlangweltenScreen opens
                       └─> Display sound world creation
```

**Success Path:**
- Navigation to Klangwelten screen
- Category context passed
- Sound world creation available

**Error Paths:**
- Navigation error → Show error message
- Missing category → Use default category

---

### 7. Add Sound Drawer Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Tap "Weitere Sessions" Button
   └─> SoundGrid.onRequestAddSound()
       └─> CategoryScreenBase passes to screen
           └─> Screen.setState({ isAddSoundOpen: true })
               └─> AddNewSoundDrawer opens
                   ├─> Display sound library
                   ├─> Display search
                   └─> Display add sound options
                       └─> User selects sound
                           └─> Screen.handleSoundAdded(sound)
                               └─> useCustomSounds.handleSoundAdded(sound)
                                   └─> Add custom sound to category
                                       └─> Update SoundGrid
```

**Success Path:**
- Add sound drawer opens
- Sound selected
- Custom sound added to category

**Error Paths:**
- Drawer open error → Show error message
- Sound addition error → Show error message

---

## 🔀 Alternative Flows

### Category Persistence Flow

```
App Restart
    │
    └─> CategoryProvider.initialize()
        └─> loadInitialCategories()
            ├─> CategoryService.fetchPrimaryCategories()
            ├─> onboardingStorage.getSelectedCategory()
            └─> Set selectedCategory
                └─> TabNavigator renders category screen
                    └─> Display saved category
```

**Use Cases:**
- App restart with saved category
- Category selection persistence
- Initial category from onboarding

---

### Category Refresh Flow

```
User Action / System Event
    │
    └─> CategoryContext.refreshCategories()
        └─> loadInitialCategories()
            └─> CategoryService.fetchPrimaryCategories()
                ├─> Fetch from Supabase
                └─> Update orderedCategories
                    └─> Category screens update
```

**Use Cases:**
- Manual category refresh
- Background category update
- Category data synchronization

---

### Mini Player Flow

```
Audio Playing
    │
    └─> MiniPlayerStrip appears
        ├─> Display last played sound
        ├─> Play/Pause button
        ├─> Expand button
        └─> Close button
            │
            ├─> Tap Expand
            │   └─> AudioPlayerEnhanced opens (full screen)
            │
            ├─> Tap Play
            │   └─> Resume playback
            │
            └─> Tap Close
                └─> Stop playback
                    └─> MiniPlayerStrip hides
```

**Use Cases:**
- Audio playback while browsing
- Quick playback control
- Full player access

---

## 🚨 Error Flows

### Network Error Flow

```
Category Data Fetch
    │
    └─> CategoryService.fetchPrimaryCategories()
        └─> Supabase request fails
            └─> Catch error
                └─> Use fallback categories
                    └─> Display local category data
                        └─> Show warning (optional)
```

**Error Messages:**
- "Keine Internetverbindung" (No internet connection)
- "Lade lokale Daten" (Loading local data)

---

### Invalid Category Flow

```
Category Selection
    │
    └─> Invalid category ID
        └─> CategoryContext validation
            └─> Use fallback category
                └─> Display first category
                    └─> Log warning
```

**Error Handling:**
- Invalid category ID → Use first category
- Missing category → Use default category
- Category not found → Show error message

---

### Empty Data Flow

```
Category Display
    │
    └─> No sounds in category
        └─> SoundGrid displays empty state
            ├─> Show "Weitere Sessions" button
            └─> Show "Eigene Klangwelt" section
                └─> User can add sounds
```

**Empty State:**
- No sounds → Show add sound options
- No favorites → Show regular sounds only
- No custom sounds → Show library sounds only

---

## 🔄 State Transitions

### Category Selection States

```
No Selection → Category Selected → Category Displayed
     │                │                    │
     │                │                    └─> Navigation
     │                └─> Persisted
     └─> Default Category
```

### Audio Player States

```
No Audio → Sound Selected → Audio Playing
   │            │                │
   │            │                └─> Mini Player
   │            └─> Player Open
   └─> Player Closed
```

### Category Data States

```
Loading → Loaded → Displayed
   │         │          │
   │         │          └─> Error
   │         └─> Refresh
   └─> Fallback
```

---

## 📊 Flow Diagrams

### Complete Category Browsing Journey

```
App Start
    │
    ├─> Onboarding (if new user)
    │   └─> Category Selection
    │       └─> Save to storage
    │
    └─> Main App
        └─> TabNavigator
            └─> Load saved category
                └─> Category Screen
                    ├─> Browse Sounds
                    │   └─> Select Sound
                    │       └─> Audio Player
                    ├─> Add Sound
                    │   └─> Add Sound Drawer
                    └─> Create Klangwelt
                        └─> Klangwelten Screen
```

---

### Category Navigation Journey

```
Bottom Navigation
    │
    ├─> Tap Schlafen Tab
    │   └─> SchlafScreen
    │       └─> Sleep category content
    │
    ├─> Tap Stress Tab
    │   └─> RuheScreen
    │       └─> Stress category content
    │
    └─> Tap Im Fluss Tab
        └─> ImFlussScreen
            └─> Flow category content
```

---

## 🎯 User Goals

### Goal: Browse Category Content
- **Path:** Category Tab → Category Screen → Browse Sounds
- **Time:** < 2 seconds
- **Steps:** 1 tap

### Goal: Play Sound from Category
- **Path:** Category Screen → Sound Card → Audio Player
- **Time:** < 1 second
- **Steps:** 1 tap

### Goal: Create Custom Sound World
- **Path:** Category Screen → Eigene Klangwelt → Klangwelten Screen
- **Time:** < 3 seconds
- **Steps:** 1 tap

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
