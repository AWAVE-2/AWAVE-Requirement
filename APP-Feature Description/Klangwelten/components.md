# Klangwelten System - Components Inventory

## 📱 Screens

### KlangweltenScreen
**File:** `src/screens/KlangweltenScreen.tsx`  
**Route:** `/Klangwelten`  
**Purpose:** Main screen for sound world creation and mixing

**Props:**
```typescript
// Route params via React Navigation
interface KlangweltenRouteParams {
  categoryId: string;
  categoryTitle?: string;
}
```

**State:**
- `availableSounds: Sound[]` - Sounds loaded for selection
- `selectedSoundIds: string[]` - Currently selected sound IDs
- `isMixerOpen: boolean` - Mixer sheet visibility state

**Components Used:**
- `SoundCarousel` - Sound selection carousel
- `AudioPlayerMixerSheet` - Mixer bottom sheet
- `FadeIn` - Animation wrapper
- `SafeAreaView` - Safe area handling
- `ScrollView` - Content scrolling
- `TouchableOpacity` - Interactive buttons
- `Text` - Text display
- `View` - Container components

**Hooks Used:**
- `useMultiTrackMixer` - Multi-track mixer functionality
- `useTheme` - Theme styling
- `useNavigation` - Navigation control
- `useRoute` - Route parameters

**Features:**
- Category information display
- Sound carousel with selection
- Playback controls (play, pause, stop)
- Mixer access button
- Selected sounds counter
- Error display
- Loading states
- Info section with instructions

**User Interactions:**
- Navigate back
- Select/deselect sounds in carousel
- Press play/pause/stop
- Open/close mixer
- Adjust volumes in mixer
- Toggle tracks in mixer

**Lifecycle:**
- Loads sounds on mount
- Syncs selectedSoundIds with tracks
- Handles route parameters
- Manages mixer sheet visibility

---

## 🧩 Components

### SoundCarousel
**File:** `src/components/klangwelten/SoundCarousel.tsx`  
**Type:** Selection Component

**Props:**
```typescript
interface SoundCarouselProps {
  sounds: Sound[];
  selectedSoundIds: string[];
  onSoundToggle: (sound: Sound) => void;
  maxSelections?: number; // Default: 3
  title?: string;
  description?: string;
}
```

**State:**
- `currentIndex: number` - Current visible card index

**Components Used:**
- `FlatList` - Horizontal scrollable list
- `TouchableOpacity` - Sound card buttons
- `Image` - Sound images
- `Text` - Titles and descriptions
- `View` - Container components

**Features:**
- Horizontal scrolling with snap behavior
- Sound card rendering
- Selection indicators (checkmark badges)
- Selection counter ("X / 3 ausgewählt")
- Pagination dots
- Disabled state when max reached
- Visual feedback for selections

**Card Structure:**
- Sound image or placeholder
- Selection badge (checkmark)
- Sound title
- Sound description
- Selection status badge

**User Interactions:**
- Scroll horizontally
- Tap sound to select/deselect
- View pagination dots

**Styling:**
- Card width: 70% of screen width
- Card spacing: 16px
- Border radius: 20px
- Selection highlight: Primary color with opacity
- Disabled opacity: 0.5

---

### AudioPlayerMixerSheet
**File:** `src/components/audio-player/AudioPlayerMixerSheet.tsx`  
**Type:** Bottom Sheet Component

**Props:**
```typescript
interface AudioPlayerMixerSheetProps {
  isOpen: boolean;
  onClose: () => void;
  tracks: MixerTrack[];
  onVolumeChange: (trackId: string, volume: number) => void;
  onToggleTrack: (trackId: string) => void;
}
```

**State:** None (controlled component)

**Components Used:**
- `BottomSheet` - Bottom sheet container
- `Slider` - Volume sliders
- `Switch` - Track on/off switches
- `Text` - Labels and values
- `View` - Container components

**Features:**
- Bottom sheet presentation
- Track cards with name and category
- Volume slider per track (0-100%)
- Track on/off switch
- Volume percentage display
- Empty state when no active tracks
- Disabled controls for inactive tracks

**Track Card Structure:**
- Track header (name, category, switch)
- Volume slider
- Volume metadata (label, percentage)

**User Interactions:**
- Open/close bottom sheet
- Adjust volume sliders
- Toggle track switches
- View track information

**Styling:**
- Track cards with border and padding
- Slider styling with theme colors
- Switch with theme colors
- Empty state centered text

---

## 🔗 Component Relationships

### KlangweltenScreen Component Tree
```
KlangweltenScreen
├── SafeAreaView
│   └── FadeIn
│       ├── View (Header)
│       │   ├── TouchableOpacity (Back)
│       │   ├── Text (Title)
│       │   └── View (Spacer)
│       ├── View (Category Info) - conditional
│       │   ├── Text (Category Title)
│       │   └── Text (Subtitle)
│       ├── View (Error Container) - conditional
│       │   └── Text (Error)
│       ├── ScrollView (Content)
│       │   ├── SoundCarousel
│       │   │   ├── View (Header)
│       │   │   ├── View (Counter)
│       │   │   ├── FlatList (Sounds)
│       │   │   │   └── TouchableOpacity (Sound Card)
│       │   │   │       ├── Image/View (Image)
│       │   │   │       ├── View (Selection Badge) - conditional
│       │   │   │       ├── View (Content)
│       │   │   │       │   ├── Text (Title)
│       │   │   │       │   └── Text (Description)
│       │   │   │       └── View (Footer)
│       │   │   │           └── View (Status Badge)
│       │   │   └── View (Pagination)
│       │   └── View (Info Section)
│       │       ├── Text (Title)
│       │       └── Text (Instructions)
│       ├── View (Bottom Controls) - conditional
│       │   ├── View (Controls Header)
│       │   │   ├── Text (Counter)
│       │   │   └── TouchableOpacity (Mixer Button)
│       │   └── View (Playback Controls)
│       │       ├── TouchableOpacity (Stop)
│       │       ├── TouchableOpacity (Play/Pause)
│       │       └── TouchableOpacity (Volume)
│       └── AudioPlayerMixerSheet
│           └── BottomSheet
│               └── View (Container)
│                   ├── Text (Title)
│                   ├── Text (Subtitle)
│                   ├── View (Track Cards)
│                   │   └── View (Track Card)
│                   │       ├── View (Track Header)
│                   │       │   ├── View (Track Info)
│                   │       │   │   ├── Text (Track Name)
│                   │       │   │   └── Text (Category) - conditional
│                   │       │   └── Switch (Toggle)
│                   │       ├── Slider (Volume)
│                   │       └── View (Volume Meta)
│                   │           ├── Text (Label)
│                   │           └── Text (Percentage)
│                   └── View (Empty State) - conditional
│                       ├── Text (Title)
│                       └── Text (Description)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.awave.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins
- Borders: Theme border colors and widths

### Responsive Design
- Sound carousel adapts to screen width (70% card width)
- Bottom sheet adapts to content height
- ScrollView for content overflow
- SafeAreaView for status bar handling

### Visual States
- **Selected:** Primary color highlight, checkmark badge
- **Unselected:** Default background, tap prompt
- **Disabled:** Reduced opacity, "Max. erreicht" text
- **Active Track:** Full opacity, enabled controls
- **Inactive Track:** Reduced opacity, disabled controls
- **Loading:** Loading indicators, disabled buttons
- **Error:** Error container with warning icon

---

## 🔄 State Management

### Local State (KlangweltenScreen)
- `availableSounds` - Loaded from data structure
- `selectedSoundIds` - Synced with mixer tracks
- `isMixerOpen` - Controlled by user interaction

### Hook State (useMultiTrackMixer)
- `tracks` - Track array with sound assignments
- `isPlaying` - Playback state
- `isLoading` - Loading state
- `error` - Error state

### Persistent State (AsyncStorage)
- Mixer state (tracks, volumes, active states)
- Auto-saved on changes
- Auto-loaded on mount

---

## 🧪 Testing Considerations

### Component Tests
- Sound card rendering
- Selection behavior
- Carousel scrolling
- Mixer sheet open/close
- Volume slider interaction
- Track toggle interaction
- Empty state display

### Integration Tests
- Sound selection → track assignment
- Volume adjustment → audio service
- Track toggle → playback state
- State persistence → AsyncStorage
- Navigation flow

### E2E Tests
- Complete sound world creation
- Volume adjustment workflow
- Track management workflow
- State persistence verification
- Error recovery

---

## 📊 Component Metrics

### Complexity
- **KlangweltenScreen:** High (orchestrates multiple components)
- **SoundCarousel:** Medium (complex scrolling and selection logic)
- **AudioPlayerMixerSheet:** Low (simple bottom sheet with controls)

### Reusability
- **SoundCarousel:** High (can be used in other contexts)
- **AudioPlayerMixerSheet:** Medium (specific to mixer use case)
- **KlangweltenScreen:** Low (specific to sound world feature)

### Dependencies
- All components depend on theme system
- SoundCarousel depends on sound data structure
- AudioPlayerMixerSheet depends on track data structure
- All components depend on React Navigation for navigation

---

## 🔄 Component Lifecycle

### KlangweltenScreen
1. **Mount:** Load sounds, initialize mixer, load saved state
2. **Update:** Sync selectedSoundIds with tracks
3. **Unmount:** Cleanup (handled by hook)

### SoundCarousel
1. **Mount:** Initialize FlatList ref, set currentIndex
2. **Update:** Re-render on sounds/selection changes
3. **Unmount:** Cleanup refs

### AudioPlayerMixerSheet
1. **Mount:** None (controlled component)
2. **Update:** Re-render on tracks/isOpen changes
3. **Unmount:** None

---

## 🎯 Component Responsibilities

### KlangweltenScreen
- Screen-level orchestration
- Navigation handling
- Error display
- Loading state management
- User interaction coordination

### SoundCarousel
- Sound display and selection
- Carousel scrolling behavior
- Selection state visualization
- Maximum selection enforcement

### AudioPlayerMixerSheet
- Track control interface
- Volume adjustment UI
- Track toggle UI
- Empty state display

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
