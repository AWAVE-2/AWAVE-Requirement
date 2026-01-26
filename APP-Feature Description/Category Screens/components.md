# Category Screens - Components Inventory

## 📱 Screens

### SchlafScreen
**File:** `src/screens/SchlafScreen.tsx`  
**Route:** `/schlafen` (via TabNavigator)  
**Purpose:** Sleep category screen with meditation, dream journeys, theta waves, white noise

**Props:** None (screen component)

**State:**
- `isAddSoundOpen: boolean` - Add sound drawer open state

**Components Used:**
- `CategoryScreenBase` - Main content container
- `MiniPlayerStrip` - Floating mini player
- `AddNewSoundDrawer` - Add sound drawer
- `AudioPlayerEnhanced` - Full audio player
- `SafeAreaView` - Safe area handling
- `FadeIn` - Animation wrapper

**Hooks Used:**
- `useCategoryContext` - Category data and state
- `useSoundPlayer` - Audio playback management
- `useCustomSounds` - Custom sounds management
- `useFavoritesManagement` - Favorites management
- `useRegistrationFlow` - Registration handling
- `useTheme` - Theme styling
- `useNavigation` - Navigation
- `useSafeAreaInsets` - Safe area insets

**Features:**
- Category content display (sleep-specific)
- Sound selection and playback
- Mini player strip when audio playing
- Add sound drawer for custom sounds
- Klangwelten navigation
- Audio player full screen

**User Interactions:**
- Select sound from grid
- Add sound to mix
- Select favorite sound
- Open add sound drawer
- Navigate to Klangwelten
- Expand mini player to full player
- Close audio player

**Category ID:** `schlafen`

---

### RuheScreen
**File:** `src/screens/RuheScreen.tsx`  
**Route:** `/stress` (via TabNavigator)  
**Purpose:** Stress/rest category screen with relaxation exercises, breathing techniques, calming sounds

**Props:** None (screen component)

**State:**
- `isAddSoundOpen: boolean` - Add sound drawer open state

**Components Used:**
- `CategoryScreenBase` - Main content container
- `MiniPlayerStrip` - Floating mini player
- `AddNewSoundDrawer` - Add sound drawer
- `AudioPlayerEnhanced` - Full audio player
- `SafeAreaView` - Safe area handling
- `FadeIn` - Animation wrapper

**Hooks Used:**
- `useCategoryContext` - Category data and state
- `useSoundPlayer` - Audio playback management
- `useCustomSounds` - Custom sounds management
- `useFavoritesManagement` - Favorites management
- `useRegistrationFlow` - Registration handling
- `useTheme` - Theme styling
- `useNavigation` - Navigation

**Features:**
- Category content display (stress-specific)
- Sound selection and playback
- Mini player strip when audio playing
- Add sound drawer for custom sounds
- Klangwelten navigation
- Audio player full screen

**User Interactions:**
- Select sound from grid
- Add sound to mix
- Select favorite sound
- Open add sound drawer
- Navigate to Klangwelten
- Expand mini player to full player
- Close audio player

**Category ID:** `stress`

---

### ImFlussScreen
**File:** `src/screens/ImFlussScreen.tsx`  
**Route:** `/leichtigkeit` (via TabNavigator)  
**Purpose:** Flow/lightness category screen with motivating sounds, energy sounds, focus audio

**Props:** None (screen component)

**State:**
- `isAddSoundOpen: boolean` - Add sound drawer open state

**Components Used:**
- `CategoryScreenBase` - Main content container
- `MiniPlayerStrip` - Floating mini player
- `AddNewSoundDrawer` - Add sound drawer
- `AudioPlayerEnhanced` - Full audio player
- `SafeAreaView` - Safe area handling
- `FadeIn` - Animation wrapper

**Hooks Used:**
- `useCategoryContext` - Category data and state
- `useSoundPlayer` - Audio playback management
- `useCustomSounds` - Custom sounds management
- `useFavoritesManagement` - Favorites management
- `useRegistrationFlow` - Registration handling
- `useTheme` - Theme styling
- `useNavigation` - Navigation

**Features:**
- Category content display (flow-specific)
- Sound selection and playback
- Mini player strip when audio playing
- Add sound drawer for custom sounds
- Klangwelten navigation
- Audio player full screen

**User Interactions:**
- Select sound from grid
- Add sound to mix
- Select favorite sound
- Open add sound drawer
- Navigate to Klangwelten
- Expand mini player to full player
- Close audio player

**Category ID:** `leichtigkeit`

---

## 🧩 Components

### CategoryScreenBase
**File:** `src/components/screens/CategoryScreenBase.tsx`  
**Type:** Reusable Base Component

**Props:**
```typescript
interface CategoryScreenBaseProps {
  categoryId: 'schlafen' | 'stress' | 'leichtigkeit';
  category: {
    id: string;
    sounds: Sound[];
    title?: string;
  };
  customSounds: Sound[];
  favoriteSounds: FavoriteSound[];
  onSoundSelect: (sound: Sound) => void;
  onAddToMix: (sound: Sound) => void;
  onFavoriteSelect: (favorite: FavoriteSound) => void;
  onRequestAddSound: () => void;
  onRequestKlangwelten?: () => void;
}
```

**State:** None (stateless)

**Components Used:**
- `CategoryHeroHeader` - Category header with branding
- `SoundGrid` - Sound grid layout
- `ScrollView` - Scrollable container
- `View` - Layout container

**Hooks Used:**
- `useTheme` - Theme styling
- `getCategoryContent` - Category content utility

**Features:**
- Category hero header display
- Sound grid with category sounds
- Custom sounds integration
- Favorites filtering by category
- Scrollable content container
- Bottom padding for mini player

**User Interactions:**
- Scroll through content
- Interact with sound grid (via SoundGrid component)
- View category header information

**Styling:**
- Horizontal padding: 24px (APP_PADDING_X)
- Bottom padding: 150px (for mini player space)
- Scrollable with automatic content inset adjustment

---

### CategoryHeroHeader
**File:** `src/components/screens/CategoryHeroHeader.tsx`  
**Type:** Category Header Component

**Props:**
```typescript
interface CategoryHeroHeaderProps {
  content: CategoryContent;
  categoryId: string;
  panelWidth?: number; // Not used but kept for compatibility
}
```

**State:** None (stateless)

**Components Used:**
- `LinearGradient` - Gradient backgrounds
- `Icon` - Icon component (for Activity icon)
- `Sparkles` - Lucide icon (direct import)
- `View` - Layout containers
- `Text` - Text display

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Category-specific icon with gradient background
- Headline text display
- Description text display
- Gradient divider
- Category-specific theming

**Category Themes:**
- **Schlafen (Sleep):**
  - Icon: Sparkles (purple)
  - Gradient: `['rgba(168, 85, 247, 0.2)', 'rgba(99, 102, 241, 0.2)']`
  - Icon Color: `#A78BFA` (purple-400)

- **Stress (Rest):**
  - Icon: Activity (blue)
  - Gradient: `['rgba(59, 130, 246, 0.2)', 'rgba(6, 182, 212, 0.2)']`
  - Icon Color: `#60A5FA` (blue-400)

- **Leichtigkeit (Flow):**
  - Icon: Sparkles (emerald)
  - Gradient: `['rgba(16, 185, 129, 0.2)', 'rgba(20, 184, 166, 0.2)']`
  - Icon Color: `#34D399` (emerald-400)

**User Interactions:**
- Visual display only (no direct interaction)

**Styling:**
- Icon badge: 48x48px with gradient background
- Headline: 20px font size, bold
- Description: 18px font size, regular
- Divider: 4px height with category gradient
- Margin bottom: 32px

---

### SoundGrid
**File:** `src/components/SoundGrid.tsx`  
**Type:** Sound Grid Layout Component

**Props:**
```typescript
interface SoundGridProps {
  sounds: Sound[];
  customSounds: Sound[];
  favoriteSounds: FavoriteSound[];
  onSoundSelect: (sound: Sound) => void;
  onAddToMix: (sound: Sound) => void;
  onFavoriteSelect: (favorite: FavoriteSound) => void;
  onRequestAddSound: () => void;
  onRequestKlangwelten?: () => void;
  categoryId?: string;
}
```

**State:** None (stateless)

**Components Used:**
- `EnhancedCard` - Card component with gradient
- `AnimatedButton` - Animated button wrapper
- `LinearGradient` - Gradient backgrounds
- `Image` - Sound image display
- `View` - Layout containers
- `Text` - Text display

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Sound cards with airplane window design
- Sound title and description
- Sound image in airplane window frame
- "Weitere Sessions" (More Sessions) button
- "Eigene Klangwelt" (Own Sound World) section
- "Eigene Klangwelt erstellen" (Create Own Sound World) button
- Gradient button styling

**Sound Card Design:**
- Airplane window frame with image
- Window shade effect (top 30%)
- Shade handle at bottom
- Sound title (purple, 20px, bold)
- Sound description (white 70% opacity, 14px)
- Card padding: 16px
- Border radius: 16px
- Border: 1px rgba(255, 255, 255, 0.1)

**User Interactions:**
- Tap sound card → Select sound
- Tap "Weitere Sessions" → Open add sound drawer
- Tap "Eigene Klangwelt erstellen" → Navigate to Klangwelten

**Styling:**
- Sound cards: Full width, 12px margin bottom
- Airplane window: 80x96px
- Window frame: 4px border, 35px border radius
- Buttons: 24px padding, 12px border radius
- Gradient: Purple to blue (`#7D5BA6` to `#4A7A8A`)

---

### CategoryCard
**File:** `src/components/ui/CategoryCard.tsx`  
**Type:** Category Card Component (used in other contexts)

**Props:**
```typescript
interface CategoryCardProps {
  category: Category;
  isActive: boolean;
  onPress: () => void;
  variant?: 'default' | 'compact' | 'featured';
  style?: ViewStyle;
  hapticFeedback?: boolean;
}
```

**Features:**
- Category card display
- Active/inactive states
- Variant support (default, compact, featured)
- Haptic feedback support
- Glass morphism effects (featured variant)
- Glow effects (active featured variant)

**Note:** This component is used in other contexts (not directly in category screens), but is related to category display.

---

## 🔗 Component Relationships

### SchlafScreen Component Tree
```
SchlafScreen
├── SafeAreaView
│   └── FadeIn
│       └── CategoryScreenBase
│           ├── ScrollView
│           │   └── View (Content)
│           │       ├── CategoryHeroHeader
│           │       │   ├── View (Header Row)
│           │       │   │   ├── View (Icon Badge)
│           │       │   │   │   └── LinearGradient
│           │       │   │   │       └── Sparkles Icon
│           │       │   │   └── View (Headline)
│           │       │   │       └── Text (Headline)
│           │       │   ├── LinearGradient (Divider)
│           │       │   └── Text (Description)
│           │       └── SoundGrid
│           │           ├── AnimatedButton (Sound Cards)
│           │           │   └── EnhancedCard
│           │           │       └── View (Sound Card Content)
│           │           │           ├── View (Sound Info)
│           │           │           │   ├── Text (Title)
│           │           │           │   └── Text (Description)
│           │           │           └── View (Airplane Window)
│           │           │               └── View (Window Frame)
│           │           │                   ├── Image
│           │           │                   └── View (Window Shade)
│           │           ├── AnimatedButton (Weitere Sessions)
│           │           │   └── LinearGradient
│           │           │       └── View (Content)
│           │           ├── View (Eigene Klangwelt Section)
│           │           └── AnimatedButton (Eigene Klangwelt Button)
│           │               └── LinearGradient
│           │                   └── View (Content)
│       ├── MiniPlayerStrip (conditional)
│       └── AddNewSoundDrawer (conditional)
└── AudioPlayerEnhanced (conditional, full screen)
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.awave.background`, `theme.colors.text.primary`, etc.
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Category-Specific Theming
- **Schlafen:** Purple gradients and Sparkles icon
- **Stress:** Blue gradients and Activity icon
- **Leichtigkeit:** Emerald gradients and Sparkles icon

### Responsive Design
- ScrollView for content overflow
- SafeAreaView for status bar handling
- Flexible layouts for different screen sizes
- Touch target sizes (min 44x44)

### Accessibility
- Semantic labels
- Touch target sizes (min 44x44)
- Color contrast compliance
- Screen reader support

---

## 🔄 State Management

### Local State
- Screen-level state (isAddSoundOpen)
- Component-level state (none in base components)

### Context State
- `CategoryContext` - Global category state
- Category selection
- Category data

### Props Flow
- Category data flows from CategoryContext → CategoryScreenBase → SoundGrid
- Sound selection flows from SoundGrid → Screen → useSoundPlayer
- Favorites flow from useFavoritesManagement → CategoryScreenBase → SoundGrid

---

## 🧪 Testing Considerations

### Component Tests
- Category screen rendering
- Category hero header display
- Sound grid layout
- Sound card interactions
- Button interactions
- Navigation handling

### Integration Tests
- Category data flow
- Sound selection flow
- Favorites integration
- Custom sounds integration
- Navigation flows

### E2E Tests
- Complete category browsing flow
- Sound playback from category
- Navigation between categories
- Custom sound creation
- Klangwelten navigation

---

## 📊 Component Metrics

### Complexity
- **SchlafScreen/RuheScreen/ImFlussScreen:** Low (wrapper components)
- **CategoryScreenBase:** Medium (base logic)
- **CategoryHeroHeader:** Low (display component)
- **SoundGrid:** High (complex layout and interactions)

### Reusability
- **CategoryScreenBase:** High (used by all category screens)
- **CategoryHeroHeader:** High (used by CategoryScreenBase)
- **SoundGrid:** High (used by CategoryScreenBase)

### Dependencies
- All screens depend on theme system
- All screens depend on CategoryContext
- All screens depend on audio player hooks
- Sound grid depends on sound data structure

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
