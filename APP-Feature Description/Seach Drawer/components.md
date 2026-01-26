# Search Drawer - Components Inventory

## 📱 Components

### SearchDrawer
**File:** `src/components/SearchDrawer.tsx`  
**Type:** Main Feature Component  
**Purpose:** Search interface with bottom sheet presentation

**Props:**
```typescript
interface SearchDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onSoundSelect: (sound: Sound) => void | Promise<void>;
  onSOSTriggered?: (config: SOSConfig) => void;
  onCloseToLastTab?: () => void;
}
```

**State:**
- `searchQuery: string` - Current search input value
- `debouncedQuery: string` - Debounced query (300ms delay)

**Components Used:**
- `BottomSheet` - Container component
- `SearchResults` - Results display
- `AnimatedButton` - Interactive buttons
- `Icon` - Icons (search, X)
- `LinearGradient` - Header icon background
- `TextInput` - Search input field
- `KeyboardAvoidingView` - Keyboard handling

**Hooks Used:**
- `useIntelligentSearch` - Search logic and SOS detection
- `useTheme` - Theme styling
- `useDebounce` - Query debouncing (inline hook)
- `useCallback` - Memoized callbacks
- `useEffect` - Side effects (search execution, SOS trigger)

**Features:**
- Bottom sheet presentation
- Search input with auto-focus
- Real-time search with debouncing
- SOS trigger detection
- Responsive height (tablet/phone)
- Keyboard-aware layout
- Header with title and close button
- Search results display
- Clear button for input

**User Interactions:**
- Type search query
- Clear search query
- Select sound from results
- Close drawer (swipe, backdrop, X button)
- Return to last tab (X button)

**Layout Structure:**
```
SearchDrawer
├── BottomSheet
│   └── View (container)
│       └── KeyboardAvoidingView
│           └── View (sheetContent)
│               ├── View (header)
│               │   ├── View (iconContainer)
│               │   │   └── LinearGradient
│               │   │       └── Icon (search)
│               │   ├── View (headerText)
│               │   │   ├── Text (title: "Sound-Suche")
│               │   │   └── Text (subtitle)
│               │   └── AnimatedButton (close)
│               │       └── Icon (X)
│               ├── View (searchTipsContainer) - conditional
│               ├── View (resultsContainer)
│               │   └── SearchResults
│               └── View (searchInputContainer)
│                   └── View (inputWrapper)
│                       ├── Icon (search) - absolute
│                       ├── TextInput
│                       └── AnimatedButton (clear) - conditional, absolute
```

**Styling:**
- Header: Fixed top, border-bottom separator
- Results: Flex-1, scrollable, minHeight 200px
- Input: Fixed bottom, border-top separator
- Responsive padding and spacing

---

### SearchResults
**File:** `src/components/SearchResults.tsx`  
**Type:** Display Component  
**Purpose:** Display search results with loading and empty states

**Props:**
```typescript
interface SearchResultsProps {
  results: SearchResultItem[];
  onPlaySound: (sound: Sound) => void;
  isLoading: boolean;
}
```

**State:** None (stateless component)

**Components Used:**
- `FlatList` - Results list
- `AnimatedButton` - Result cards
- `Icon` - Icons (volume-2, music, play)
- `SkeletonLoader` - Loading skeletons
- `View` - Containers
- `Text` - Text elements

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Loading skeleton loaders (3 cards)
- Empty state with icon and suggestions
- Results list with count header
- Result cards with sound info
- Play button on each result
- Scrollable list

**User Interactions:**
- Tap result card to select sound
- Scroll through results

**Layout Structure:**
```
SearchResults
├── View (container)
│   ├── View (loadingContainer) - if isLoading
│   │   └── [3x] View (skeletonCard)
│   │       └── View (skeletonContent)
│   │           ├── SkeletonLoader (icon)
│   │           └── View (skeletonText)
│   │               ├── SkeletonLoader (title)
│   │               └── SkeletonLoader (description)
│   │
│   ├── View (emptyState) - if !isLoading && results.length === 0
│   │   ├── Icon (music)
│   │   ├── Text ("Keine passenden Sounds gefunden")
│   │   └── Text (suggestions)
│   │
│   └── View (container) - if !isLoading && results.length > 0
│       ├── View (resultsHeader)
│       │   ├── Icon (volume-2)
│       │   └── Text (results count)
│       └── FlatList
│           └── [results] AnimatedButton (resultRow)
│               └── View (resultCard)
│                   ├── View (resultIconContainer)
│                   │   └── Icon (music)
│                   ├── View (resultInfo)
│                   │   ├── Text (title)
│                   │   └── Text (description) - optional
│                   └── View (playButton)
│                       └── Icon (play)
```

**Styling:**
- Result cards: Padding 16px, border radius 14px, border
- Icon container: 40x40px, circular, primary color background
- Play button: 40x40px, circular, primary color background
- Gap between cards: 16px
- List padding: 20px bottom

---

### BottomSheet
**File:** `src/components/BottomSheet.tsx`  
**Type:** Reusable Container Component  
**Purpose:** Bottom sheet container with animations and gestures

**Props:**
```typescript
interface BottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  children: ReactNode;
  maxHeightRatio?: number; // default 0.85
  zIndex?: number; // default 200
}
```

**State:**
- `mounted: boolean` - Component mount state
- `translateY: SharedValue<number>` - Animation value
- `backdropOpacity: SharedValue<number>` - Backdrop opacity

**Components Used:**
- `GestureDetector` - Gesture handling
- `Animated.View` - Animated containers
- `View` - Static containers

**Hooks Used:**
- `useSharedValue` - Animation values
- `useAnimatedStyle` - Animated styles
- `useSafeAreaInsets` - Safe area handling
- `useEffect` - Animation triggers

**Features:**
- Slide-up animation (280ms)
- Slide-down animation (220ms)
- Swipe-down gesture to close
- Backdrop overlay (60% opacity)
- Spring animations for gestures
- Safe area insets support
- Configurable z-index
- Handle bar at top

**User Interactions:**
- Swipe down to close
- Tap backdrop to close
- Pan gesture for dragging

**Layout Structure:**
```
BottomSheet
└── View (wrapper) - absolute fill, z-index
    ├── Animated.View (backdrop)
    │   └── [tappable overlay]
    └── GestureDetector
        └── Animated.View (sheet)
            ├── View (handle)
            └── {children}
```

**Styling:**
- Backdrop: rgba(5, 5, 5, 0.6)
- Sheet background: #050505
- Handle: 48x6px, rounded, rgba(255, 255, 255, 0.16)
- Border radius: 32px top corners
- Padding: 24px horizontal, 12px top
- Safe area bottom padding

**Animation Configuration:**
- Open: translateY from screenHeight to screenHeight - maxHeight
- Close: translateY from current to screenHeight
- Spring: damping 18, mass 0.6, stiffness 160
- Close threshold: 20% of screen height
- Easing: cubic (out for open, in for close)

---

## 🔗 Component Relationships

### SearchDrawer Component Tree
```
SearchDrawer
├── BottomSheet
│   └── View (container)
│       └── KeyboardAvoidingView
│           └── View (sheetContent)
│               ├── View (header)
│               │   ├── LinearGradient (iconContainer)
│               │   │   └── Icon (search)
│               │   ├── View (headerText)
│               │   │   ├── Text (title)
│               │   │   └── Text (subtitle)
│               │   └── AnimatedButton (close)
│               │       └── Icon (X)
│               ├── View (searchTipsContainer) - conditional
│               ├── View (resultsContainer)
│               │   └── SearchResults
│               │       ├── View (loadingContainer) - if loading
│               │       ├── View (emptyState) - if no results
│               │       └── View (container) - if results
│               │           ├── View (resultsHeader)
│               │           └── FlatList (results)
│               └── View (searchInputContainer)
│                   └── View (inputWrapper)
│                       ├── Icon (search) - absolute
│                       ├── TextInput
│                       └── AnimatedButton (clear) - conditional
```

### Component Dependencies
```
SearchDrawer
├── BottomSheet (container)
├── SearchResults (results display)
├── useIntelligentSearch (search logic)
├── AnimatedButton (interactions)
├── Icon (icons)
├── LinearGradient (header icon)
└── useTheme (styling)

SearchResults
├── FlatList (list)
├── AnimatedButton (result cards)
├── Icon (icons)
├── SkeletonLoader (loading)
└── useTheme (styling)

BottomSheet
├── GestureDetector (gestures)
├── Animated.View (animations)
└── useSafeAreaInsets (safe areas)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.primary`, `theme.colors.text.primary`, `theme.colors.border`, etc.
- Typography: `theme.fonts.raleway`
- Spacing: Consistent padding and margins
- Backgrounds: `getSolidBackground(theme, 'card')`

### Responsive Design
- Tablet detection: `screenWidth >= 768`
- Phone height: 85% + ~100px
- Tablet height: 60% + ~100px
- Maximum height: 95%
- Dynamic padding based on screen size

### Color Scheme
- Background: Theme background colors
- Primary: Theme primary color
- Text: Theme text colors (primary, muted)
- Border: Theme border color
- Overlay: rgba(5, 5, 5, 0.6)
- Input background: rgba(255, 255, 255, 0.05)
- Input border: rgba(255, 255, 255, 0.2)

### Typography
- Title: 18px, font-weight 600
- Subtitle: 14px
- Input: 16px, font-weight 500
- Result title: 16px, font-weight 600
- Result description: 14px
- Results count: 14px, font-weight 600

---

## 🔄 State Management

### Local State
- Search query (SearchDrawer)
- Debounced query (SearchDrawer)
- Component mount state (BottomSheet)
- Animation values (BottomSheet)

### Hook State
- Search results (useIntelligentSearch)
- Loading state (useIntelligentSearch)
- SOS config (useIntelligentSearch)
- SOS trigger state (useIntelligentSearch)

### Props State
- Drawer open/close (TabNavigator)
- Active tab (TabNavigator)
- SOS config (TabNavigator)

---

## 🧪 Testing Considerations

### Component Tests
- SearchDrawer rendering
- SearchResults display (loading, empty, results)
- BottomSheet animations
- Input interactions
- Button interactions
- Gesture handling

### Integration Tests
- Search flow (type → results → select)
- SOS trigger flow
- Navigation flows
- Drawer open/close
- Keyboard interactions

### E2E Tests
- Complete search journey
- SOS trigger journey
- Navigation flows
- Error scenarios
- Edge cases

---

## 📊 Component Metrics

### Complexity
- **SearchDrawer:** Medium (search logic + UI)
- **SearchResults:** Low (display only)
- **BottomSheet:** Medium (animations + gestures)

### Reusability
- **SearchDrawer:** Low (feature-specific)
- **SearchResults:** Medium (could be reused)
- **BottomSheet:** High (reusable container)

### Dependencies
- All components depend on theme system
- SearchDrawer depends on navigation context
- BottomSheet depends on gesture/animation libraries
- SearchResults depends on data structures

---

## 🔄 Component Lifecycle

### SearchDrawer Lifecycle
1. **Mount:** Component renders, hooks initialize
2. **Open:** BottomSheet animates up, input focuses
3. **Search:** User types, debounce triggers, search executes
4. **Results:** Results displayed, user can select
5. **Close:** Drawer animates down, state cleared

### SearchResults Lifecycle
1. **Render:** Component receives props
2. **Loading:** Skeleton loaders displayed
3. **Results:** Results list displayed
4. **Empty:** Empty state displayed
5. **Update:** Props change, component re-renders

### BottomSheet Lifecycle
1. **Mount:** Component initializes, animations set up
2. **Open:** Animation triggers, sheet slides up
3. **Interactive:** User can interact, gestures active
4. **Close:** Animation triggers, sheet slides down
5. **Unmount:** Component unmounts after animation

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
