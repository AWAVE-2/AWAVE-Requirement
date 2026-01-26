# Favorite Functionality - Components Inventory

## 📱 Screens

### LibraryScreen
**File:** `src/screens/LibraryScreen.tsx`  
**Route:** `/library`  
**Purpose:** Main library screen with favorites display and management

**Props:**
```typescript
interface LibraryScreenProps {
  onClose?: () => void;
}
```

**State:**
- `favorites: FavoriteItem[]` - Current favorites list
- `favoriteIds: Set<string>` - Set of favorited sound IDs
- `tracks: LibraryTrack[]` - Library tracks with favorite status
- `selectedCategory: string` - Currently selected category filter
- `searchQuery: string` - Current search query
- `isLoading: boolean` - Loading state

**Components Used:**
- `AnimatedButton` - Interactive buttons
- `Icon` - Heart icon for favorites
- `FlatList` - List rendering
- `TextInput` - Search input
- `ActivityIndicator` - Loading spinner

**Hooks Used:**
- `useFavoritesManagement` - Favorites management
- `useProductionAuth` - Authentication
- `useUnifiedTheme` - Theme styling
- `useTranslation` - Internationalization

**Features:**
- Display all sounds with favorite indicators
- Toggle favorites from list items
- Filter favorites by category
- Search within favorites
- View favorite status on each sound
- Handle locked/premium content
- Select mode for mix creation

**User Interactions:**
- Tap heart icon to toggle favorite
- Filter by category
- Search favorites
- View favorite details
- Navigate to audio player

**Favorite Integration:**
- Uses `useFavoritesManagement()` hook
- Displays `isFavorite` status on each track
- Calls `addFavorite()` or `removeFavorite()` on toggle
- Refreshes favorites list after operations
- Updates UI optimistically

---

### AudioPlayerScreen
**File:** `src/components/AudioPlayerScreen.tsx`  
**Route:** `/player`  
**Purpose:** Audio player screen with favorite button

**Props:**
```typescript
interface AudioPlayerScreenProps {
  sound: Sound;
  favoriteId?: string;
  isFavorite: boolean;
  onToggleFavorite: () => void;
  // ... other props
}
```

**State:**
- Inherits favorite state from parent
- Manages player state (playing, progress, etc.)

**Components Used:**
- `AudioPlayerFavoriteButton` - Favorite toggle button
- `AudioPlayerHeader` - Player header
- `AudioPlayerMixer` - Mixer controls
- `AudioPlayerProgress` - Progress bar
- `AudioPlayerControls` - Playback controls

**Hooks Used:**
- `useFavoritesManagement` - Favorites management (via parent)
- `useTheme` - Theme styling

**Features:**
- Display favorite button in player controls
- Toggle favorite status
- Visual feedback on favorite state
- Integrate with audio playback

**User Interactions:**
- Tap favorite button to toggle
- See favorite status in button
- Get visual confirmation

---

### AudioPlayerEnhanced
**File:** `src/components/AudioPlayerEnhanced.tsx`  
**Route:** `/player-enhanced`  
**Purpose:** Enhanced audio player with favorites

**Props:**
```typescript
interface AudioPlayerEnhancedProps {
  sound: Sound;
  favoriteId?: string;
  onClose: () => void;
}
```

**State:**
- `isFavorite: boolean` - Local favorite state
- `favoriteId: string | undefined` - Current favorite ID

**Components Used:**
- `AudioPlayerFavoriteButton` - Favorite button
- Other audio player components

**Hooks Used:**
- `useFavoritesManagement` - Favorites management
- `useProductionAuth` - Authentication

**Features:**
- Manage favorite state locally
- Handle favorite toggle
- Sync with backend
- Error handling with rollback

**Favorite Logic:**
```typescript
const handleToggleFavorite = async () => {
  if (isFavorite) {
    await removeFavorite(favoriteId || sound.id);
    setIsFavorite(false);
  } else {
    await addFavorite(userId, {
      soundId: sound.id,
      title: sound.title,
      description: sound.description,
      categoryId: sound.categoryId,
      imageUrl: sound.imageUrl,
    });
    setIsFavorite(true);
  }
};
```

---

### AudioPlayerLayout
**File:** `src/components/AudioPlayerLayout.tsx`  
**Route:** `/player-layout`  
**Purpose:** Layout component with favorites integration

**Props:**
```typescript
interface AudioPlayerLayoutProps {
  sound: Sound;
  favoriteId?: string;
  isFavorite: boolean;
  onToggleFavorite: () => void;
  // ... other props
}
```

**Components Used:**
- `AudioPlayerHeader` - Header with favorite info
- `AudioPlayerMixer` - Mixer with favorite button

**Features:**
- Pass favorite props to child components
- Coordinate favorite state across layout
- Maintain consistent favorite UI

---

## 🧩 Components

### AudioPlayerFavoriteButton
**File:** `src/components/audio-player/AudioPlayerFavoriteButton.tsx`  
**Type:** Reusable Button Component

**Props:**
```typescript
interface AudioPlayerFavoriteButtonProps {
  isFavorite: boolean;
  onToggleFavorite: () => void;
}
```

**State:** None (stateless, controlled component)

**Components Used:**
- `Icon` - Heart icon
- `TouchableOpacity` - Button wrapper

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Visual favorite status indicator
- Toggle favorite on press
- Theme-aware styling
- Heart icon with text label
- Active/inactive states
- Touch feedback

**Styling:**
- **Active State:**
  - Background: Primary color (`theme.colors.awave.primary`)
  - Text: White (`#FFFFFF`)
  - Icon: White
  
- **Inactive State:**
  - Background: Transparent with opacity (`rgba(255, 255, 255, 0.1)`)
  - Text: Secondary text color
  - Icon: Secondary text color

**Layout:**
- Horizontal layout (row)
- Icon on left, text on right
- Rounded button (borderRadius: 24)
- Padding: 12px vertical, 24px horizontal
- Margin top: 16px

**Text Labels:**
- Active: "Zu Favoriten hinzugefügt"
- Inactive: "Zu Favoriten hinzufügen"

**User Interactions:**
- Tap button to toggle favorite
- Visual feedback on press (activeOpacity: 0.8)
- Immediate state update

---

### AudioPlayerMixer
**File:** `src/components/audio-player/AudioPlayerMixer.tsx`  
**Type:** Audio Mixer Component

**Props:**
```typescript
interface AudioPlayerMixerProps {
  tracks: Track[];
  isFavorite?: boolean;
  onToggleFavorite?: () => void;
  // ... other props
}
```

**Components Used:**
- `AudioPlayerFavoriteButton` - Favorite button (conditional)

**Features:**
- Conditionally render favorite button
- Pass favorite props to button
- Integrate with mixer controls

**Favorite Integration:**
- Only shows favorite button if `onToggleFavorite` is provided
- Passes `isFavorite` and `onToggleFavorite` to button
- Positioned below playback controls

---

### AudioPlayerHeader
**File:** `src/components/audio-player/AudioPlayerHeader.tsx`  
**Type:** Player Header Component

**Props:**
```typescript
interface AudioPlayerHeaderProps {
  sound: Sound;
  favoriteId?: string;
  onClose: () => void;
}
```

**Features:**
- Display sound information
- Close button
- May display favorite status (future enhancement)

---

## 🔗 Component Relationships

### AudioPlayerScreen Component Tree
```
AudioPlayerScreen
├── ScrollView
│   ├── AudioPlayerHeader
│   │   └── Sound info
│   ├── AudioPlayerMixer
│   │   ├── Track cards
│   │   └── Controls
│   │       ├── AudioPlayerProgress
│   │       ├── AudioPlayerControls
│   │       └── AudioPlayerFavoriteButton
│   │           ├── Icon (heart)
│   │           └── Text
│   └── Timer Section
└── Sound Selection Drawer
```

### LibraryScreen Component Tree
```
LibraryScreen
├── SafeAreaView
│   ├── Header
│   │   ├── Title
│   │   └── Actions
│   ├── Search Input
│   ├── Category Filters
│   └── FlatList
│       └── Track Cards
│           ├── Track Info
│           ├── Category Badge
│           └── Favorite Icon (heart)
│               └── AnimatedButton
└── Mix Creation Bar (conditional)
```

### AudioPlayerEnhanced Component Tree
```
AudioPlayerEnhanced
├── Animated View
│   ├── AudioPlayerHeader
│   ├── AudioPlayerMixer
│   │   └── AudioPlayerFavoriteButton
│   └── Other player components
└── Backdrop
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` or `useUnifiedTheme`:
- Colors: `theme.colors.primary`, `theme.colors.textPrimary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Favorite Button Styling
- **Active State:**
  ```typescript
  backgroundColor: theme.colors.awave.primary
  color: '#FFFFFF'
  ```
  
- **Inactive State:**
  ```typescript
  backgroundColor: 'rgba(255, 255, 255, 0.1)'
  color: theme.colors.text.secondary
  ```

### Heart Icon Styling
- Size: 18-20px
- Color: White (active) or secondary text (inactive)
- Margin right: 8px

### Responsive Design
- Adapts to screen sizes
- Touch targets minimum 44x44px
- Accessible contrast ratios

---

## 🔄 State Management

### Component State
- Local state for immediate UI updates
- Optimistic updates before API calls
- Rollback on error

### Hook State
- `useFavoritesManagement` manages favorites list
- Automatic refresh after operations
- Loading states for async operations

### Props Flow
```
Parent Component
    │
    ├─> useFavoritesManagement()
    │   └─> Returns: favorites, addFavorite, removeFavorite
    │
    └─> Pass to Child Components
        ├─> isFavorite (derived from favorites)
        └─> onToggleFavorite (wraps addFavorite/removeFavorite)
```

---

## 🧪 Testing Considerations

### Component Tests
- Button rendering (active/inactive states)
- Icon display
- Text label changes
- Touch interactions
- Theme integration
- Error states

### Integration Tests
- Favorite toggle flow
- State updates
- API calls
- Error handling
- Optimistic updates

### E2E Tests
- Complete add favorite flow
- Complete remove favorite flow
- Favorite persistence
- Cross-screen consistency

---

## 📊 Component Metrics

### Complexity
- **AudioPlayerFavoriteButton:** Low (simple button)
- **LibraryScreen:** High (complex list with filters)
- **AudioPlayerScreen:** Medium (player with favorites)
- **AudioPlayerEnhanced:** Medium (enhanced player)

### Reusability
- **AudioPlayerFavoriteButton:** High (used in multiple players)
- **LibraryScreen:** Low (specific to library)
- **AudioPlayerScreen:** Medium (reusable player)

### Dependencies
- All components depend on theme system
- All components depend on favorites hook
- All components depend on authentication

---

## 🔄 Component Lifecycle

### Mount
1. Component mounts
2. Hook initializes
3. Load favorites from backend/storage
4. Update component state
5. Render with favorite status

### Update
1. User toggles favorite
2. Optimistic UI update
3. API call to backend
4. Refresh favorites list
5. Update component state
6. Re-render with new status

### Unmount
1. Component unmounts
2. Cleanup subscriptions (if any)
3. State persists in hook

---

## 🎯 Usage Examples

### Basic Favorite Button
```typescript
import { AudioPlayerFavoriteButton } from './components/audio-player/AudioPlayerFavoriteButton';

function MyComponent() {
  const [isFavorite, setIsFavorite] = useState(false);
  
  const handleToggle = () => {
    setIsFavorite(!isFavorite);
    // Call API here
  };
  
  return (
    <AudioPlayerFavoriteButton
      isFavorite={isFavorite}
      onToggleFavorite={handleToggle}
    />
  );
}
```

### With Favorites Hook
```typescript
import { useFavoritesManagement } from './hooks/useFavoritesManagement';

function MyComponent({ sound }) {
  const { userId } = useProductionAuth();
  const { addFavorite, removeFavorite, favorites } = useFavoritesManagement();
  
  const isFavorite = favorites.some(f => f.metadata.soundId === sound.id);
  
  const handleToggle = async () => {
    if (isFavorite) {
      await removeFavorite(sound.id);
    } else {
      await addFavorite(userId, {
        soundId: sound.id,
        title: sound.title,
        categoryId: sound.categoryId,
      });
    }
  };
  
  return (
    <AudioPlayerFavoriteButton
      isFavorite={isFavorite}
      onToggleFavorite={handleToggle}
    />
  );
}
```

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
