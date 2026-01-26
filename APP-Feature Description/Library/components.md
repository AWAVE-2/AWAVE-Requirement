# Library System - Components Inventory

## 📱 Screens

### LibraryScreen
**File:** `src/screens/LibraryScreen.tsx`  
**Route:** `/library`  
**Purpose:** Main library interface with browsing, search, filtering, and mix creation

**Props:**
```typescript
interface LibraryScreenProps {
  onClose?: () => void; // Optional close callback for modal context
}
```

**State:**
- `subscriptionTier: SubscriptionTier` - User subscription tier
- `libraryStats: { total: number; accessible: number }` - Library statistics
- `rawMetadata: SoundMetadata[]` - Raw sound metadata
- `tracks: LibraryTrack[]` - Processed track data
- `selectedCategory: string` - Selected category filter
- `searchQuery: string` - Search query
- `isLoading: boolean` - Loading state
- `selectedSounds: Set<string>` - Selected sound IDs for mix
- `isSelectMode: boolean` - Mix creation mode

**Components Used:**
- `AnimatedButton` - Interactive buttons
- `Icon` - Icons (heart, close)
- `SafeAreaView` - Safe area handling
- `FlatList` - Sound list rendering
- `TextInput` - Search input
- `ActivityIndicator` - Loading spinner
- `FadeIn` - Animation wrapper

**Hooks Used:**
- `useUnifiedTheme` - Theme styling
- `useTranslation` - Internationalization
- `useProductionAuth` - Authentication
- `useFavoritesManagement` - Favorites management

**Features:**
- Sound catalog display
- Real-time search
- Category filtering
- Favorites toggle
- Subscription-based filtering
- Mix creation mode
- Library statistics
- Error handling
- Loading states
- Empty states

**User Interactions:**
- Search sounds
- Filter by category
- Toggle favorites
- Select sounds for mix
- Create mix
- Navigate to sound details (future)

---

## 🧩 Components

### SoundLibraryPicker
**File:** `src/components/SoundLibraryPicker.tsx`  
**Type:** Reusable Selection Component

**Props:**
```typescript
interface SoundLibraryPickerProps {
  categoryId: string;
  onSoundSelect: (sound: Sound) => void;
  selectedSoundId?: string;
}
```

**State:**
- `librarySounds: Sound[]` - All sounds in library
- `filteredSounds: Sound[]` - Filtered sounds
- `searchQuery: string` - Search query
- `isLoading: boolean` - Loading state

**Components Used:**
- `AnimatedButton` - Sound selection buttons
- `GlassMorphism` - Search container styling
- `TextInput` - Search input
- `FlatList` - Sound list
- `ActivityIndicator` - Loading spinner

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Category-based sound filtering
- Search functionality
- Sound selection with visual feedback
- Radio button selection indicator
- Loading states
- Empty states

**User Interactions:**
- Search sounds
- Select sound
- Clear search

---

## 🔗 Component Relationships

### LibraryScreen Component Tree
```
LibraryScreen
├── SafeAreaView
│   ├── FadeIn (Header)
│   │   └── View (Header)
│   │       ├── View (Header Top)
│   │       │   ├── Text (Title)
│   │       │   └── View (Actions)
│   │       │       ├── View (Selection Counter) - conditional
│   │       │       ├── AnimatedButton (Select Mode Toggle)
│   │       │       └── AnimatedButton (Close) - conditional
│   │       ├── Text (Subtitle)
│   │       └── Text (Stats)
│   ├── FadeIn (Search & Filters)
│   │   ├── View (Search Row)
│   │   │   └── TextInput (Search)
│   │   └── View (Category Row)
│   │       └── AnimatedButton[] (Category Buttons)
│   └── FadeIn (Content)
│       ├── ActivityIndicator (Loading) - conditional
│       └── FlatList (Sound List)
│           ├── AnimatedButton (Track Card)
│           │   └── View (Track Card)
│           │       ├── View (Track Header)
│           │       │   ├── View (Selection Indicator) - conditional
│           │       │   ├── Text (Track Title)
│           │       │   └── AnimatedButton (Favorite Toggle)
│           │       ├── Text (Track Description)
│           │       ├── View (Track Meta)
│           │       │   ├── Text (Category Pill)
│           │       │   └── Text (Duration)
│           │       └── View (Lock Badge) - conditional
│           └── View (Empty State) - conditional
└── FadeIn (Mix Creation Bar) - conditional
    └── View (Mix Creation Bar)
        ├── Text (Selection Count)
        └── AnimatedButton (Create Mix)
```

### SoundLibraryPicker Component Tree
```
SoundLibraryPicker
├── View (Container)
│   ├── View (Header)
│   │   ├── Text (Title)
│   │   └── Text (Subtitle)
│   ├── GlassMorphism (Search Container)
│   │   ├── Text (Search Icon)
│   │   ├── TextInput (Search Input)
│   │   └── AnimatedButton (Clear) - conditional
│   ├── Text (Results Count) - conditional
│   ├── ActivityIndicator (Loading) - conditional
│   ├── FlatList (Sound List)
│   │   └── AnimatedButton (Sound Item)
│   │       ├── View (Radio Button)
│   │       ├── View (Sound Info)
│   │       │   ├── Text (Sound Title)
│   │       │   └── Text (Sound Description) - conditional
│   │       └── Text (Sound Icon)
│   └── View (Empty State) - conditional
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, `theme.colors.background`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Visual States

**Track Card States:**
- Default: Normal border, full opacity
- Selected: Purple border (#7D5BA6), highlighted
- Locked: Reduced opacity (0.6), lock badge
- Favorite: Filled heart icon

**Category Button States:**
- Default: Transparent background, normal border
- Active: Primary color background, white text

**Search States:**
- Default: Normal input
- Active: Focused input
- With Query: Clear button visible

---

## 🔄 State Management

### Local State
- Component-specific UI state (loading, selections, filters)
- Search query
- Category selection
- Select mode toggle

### Context State
- `AuthContext` - User authentication
- `ThemeContext` - Theme preferences
- `LanguageContext` - Translations

### Service State
- `useFavoritesManagement` - Favorites state
- `SupabaseAudioLibraryManager` - Audio file cache
- `ProductionBackendService` - Backend data

### Persistent State
- `AsyncStorage` - Local favorites cache
- `RNFS` - Downloaded audio files
- Supabase - Remote favorites and metadata

---

## 🧪 Testing Considerations

### Component Tests
- Render with different props
- State updates (search, filter, selection)
- User interactions (clicks, input)
- Loading states
- Error states
- Empty states

### Integration Tests
- API calls (getSoundMetadata, addFavorite, removeFavorite)
- Favorites sync
- Subscription tier filtering
- Search functionality
- Category filtering

### E2E Tests
- Complete library browsing flow
- Search and filter flow
- Favorite add/remove flow
- Mix creation flow
- Error recovery

---

## 📊 Component Metrics

### Complexity
- **LibraryScreen:** High (multiple features, complex state)
- **SoundLibraryPicker:** Medium (search, filter, selection)

### Reusability
- **LibraryScreen:** Low (specific to library feature)
- **SoundLibraryPicker:** High (used in multiple contexts)

### Dependencies
- All components depend on theme system
- All components depend on translation system
- LibraryScreen depends on multiple services
- SoundLibraryPicker depends on data structures

---

## 🎯 Component Responsibilities

### LibraryScreen
- **Data Loading:** Fetch sound metadata from backend
- **State Management:** Manage filters, search, selections
- **UI Rendering:** Display sounds, filters, search
- **User Interactions:** Handle search, filter, favorite, selection
- **Error Handling:** Display errors and retry options

### SoundLibraryPicker
- **Sound Selection:** Allow user to select sounds
- **Search:** Filter sounds by query
- **Category Filtering:** Filter by category
- **Visual Feedback:** Show selection state

---

## 🔄 Component Lifecycle

### LibraryScreen Lifecycle
```
Mount
  ├─> Load Tracks
  ├─> Load Subscription Tier
  └─> Load Favorites
      │
      └─> Process & Display
          │
          └─> User Interactions
              ├─> Search
              ├─> Filter
              ├─> Favorite
              └─> Select
                  │
                  └─> Update State
                      └─> Re-render
```

### SoundLibraryPicker Lifecycle
```
Mount
  ├─> Load Library Sounds
  └─> Filter by Category
      │
      └─> User Interactions
          ├─> Search
          └─> Select
              │
              └─> Callback
```

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
