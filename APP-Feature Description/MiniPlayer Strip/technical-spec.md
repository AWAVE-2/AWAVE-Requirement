# MiniPlayer Strip - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Core Framework
- **React Native** - Component framework
- **TypeScript** - Type safety
- **React Native Reanimated** - Animations (via NavBar integration)

#### UI Components
- **AnimatedButton** - Touch feedback and interactions
- **Lucide Icons** - Icon library (Music, PlayCircle, X)
- **Image** - Artwork display
- **View, Text** - Layout components

#### State Management
- **useSoundPlayer Hook** - Audio state and playback control
- **useTheme Hook** - Theme system integration
- **React Context** - Global state (AuthContext, CategoryContext)

#### Services
- **SupabasePlaybackService** - Backend sync and session tracking
- **onboardingStorage** - Local AsyncStorage persistence
- **useSupabaseAudio** - Audio playback service

---

## 📁 File Structure

```
src/
├── components/
│   └── MiniPlayerStrip.tsx          # Main component
├── hooks/
│   ├── useSoundPlayer.ts            # Audio player hook
│   └── useOnboardingStorage.ts      # Local storage
├── screens/
│   ├── SchlafScreen.tsx             # Sleep category (integration)
│   ├── RuheScreen.tsx               # Rest category (integration)
│   └── ImFlussScreen.tsx            # Flow category (integration)
├── services/
│   ├── SupabasePlaybackService.ts   # Backend sync
│   └── SupabaseAudioLibraryManager.ts # Audio management
└── utils/
    └── solidBackgrounds.ts          # Theme utilities
```

---

## 🔧 Component Specification

### MiniPlayerStrip Component
**Location:** `src/components/MiniPlayerStrip.tsx`

**Purpose:** Compact audio player strip for quick playback access

**Props:**
```typescript
interface MiniPlayerStripProps {
  sound: Sound | null;                    // Sound to display
  onExpand: () => void;                   // Expand to full player
  onPlayPress?: () => void | Promise<void>; // Optional play callback
  onClose?: () => void | Promise<void>;    // Optional close callback
}
```

**Features:**
- Conditional rendering (null if no sound)
- Artwork display with placeholder fallback
- Sound metadata (title, description)
- Play button with dual behavior
- Optional close button
- Theme-aware styling
- Accessibility support

**State:**
- No internal state (stateless component)
- Props-driven rendering
- Theme from context

**Dependencies:**
- `AnimatedButton` component
- `useTheme` hook
- `getSolidBackground` utility
- `Sound` type from data structures
- Lucide icons

---

## 🎨 Styling Specification

### Layout Styles

**Container:**
```typescript
{
  flexDirection: 'row',
  alignItems: 'center',
  paddingHorizontal: 16,
  paddingVertical: 12,
  marginHorizontal: 16,
  marginBottom: 12,
  borderWidth: 1,
  borderRadius: 10,
}
```

**Content Area:**
```typescript
{
  flex: 1,
  flexDirection: 'row',
  alignItems: 'center',
}
```

**Artwork Wrapper:**
```typescript
{
  width: 44,
  height: 44,
  borderRadius: 12,
  overflow: 'hidden',
  alignItems: 'center',
  justifyContent: 'center',
}
```

**Control Buttons:**
```typescript
{
  width: 36,
  height: 36,
  borderRadius: 18,
  alignItems: 'center',
  justifyContent: 'center',
  marginLeft: 12,
}
```

### Theme Integration

**Colors:**
- Background: `theme.colors.card` (via `getSolidBackground`)
- Border: `theme.colors.border`
- Text Primary: `theme.colors.text.primary`
- Text Secondary: `theme.colors.text.secondary`
- Primary: `theme.colors.primary`
- Primary Foreground: `theme.colors.primaryForeground`

**Typography:**
- Title: 14px, fontWeight: '600'
- Subtitle: 12px, fontWeight: '400'

---

## 🔌 Integration Points

### useSoundPlayer Hook
**Location:** `src/hooks/useSoundPlayer.ts`

**Returns:**
```typescript
{
  lastPlayedSound: Sound | null;
  currentFavoriteId: string | null;
  selectedSound: Sound | null;
  handleCloseMiniPlayer: () => Promise<void>;
  handleExpandPlayer: () => void;
  // ... audio state
}
```

**Usage:**
```typescript
const {
  lastPlayedSound,
  currentFavoriteId,
  handleCloseMiniPlayer,
  handleExpandPlayer,
} = useSoundPlayer({ registration });
```

**State Flow:**
1. User selects sound → `handleSoundSelect` called
2. `lastPlayedSound` updated
3. Mini player receives new sound prop
4. Component re-renders with new data

---

### Category Screen Integration

**Pattern:**
```typescript
{lastPlayedSound && (
  <FadeIn delay={300}>
    <View style={styles.miniPlayerContainer}>
      <MiniPlayerStrip
        sound={lastPlayedSound}
        onExpand={handleExpandPlayer}
        onPlayPress={handleMiniPlayerPlay}
        onClose={handleCloseMiniPlayer}
      />
    </View>
  </FadeIn>
)}
```

**Positioning:**
```typescript
miniPlayerContainer: {
  position: 'absolute',
  bottom: 20,
  left: 0,
  right: 0,
  zIndex: 50,
}
```

---

## 🔄 State Management Flow

### State Initialization
```
App Start
  └─> useSoundPlayer loads state
      ├─> onboardingStorage.loadLastPlaybackState()
      └─> SupabasePlaybackService.fetchCachedPlayback() (if authenticated)
          └─> setLastPlayedSound(sound)
              └─> MiniPlayerStrip receives sound prop
```

### Sound Selection Flow
```
User Selects Sound
  └─> handleSoundSelect(sound, favoriteId)
      ├─> setSelectedSound(sound)
      ├─> setLastPlayedSound(sound)
      ├─> onboardingStorage.saveLastPlaybackState()
      └─> SupabasePlaybackService.createPlaybackSession()
          └─> MiniPlayerStrip updates with new sound
```

### Close Flow
```
User Taps Close
  └─> handleCloseMiniPlayer()
      ├─> audio.stop()
      ├─> setLastPlayedSound(null)
      ├─> onboardingStorage.clearPlaybackState()
      ├─> SupabasePlaybackService.completePlaybackSession()
      └─> SupabasePlaybackService.clearCachedPlayback()
          └─> MiniPlayerStrip receives null sound
              └─> Component returns null (hidden)
```

---

## 🎯 Component Behavior

### Conditional Rendering
```typescript
if (!sound) {
  return null;
}
```
- Component only renders when sound is available
- Prevents empty/minimal UI display

### Play Button Logic
```typescript
const handlePrimaryPress = () => {
  if (onPlayPress) {
    void onPlayPress();
    return;
  }
  onExpand();
};
```
- Priority: `onPlayPress` > `onExpand`
- Supports both direct playback and expansion
- **Play button controls the complete sound system** (starts/stops all sounds)
- **Journey freezes where stopped (gets stored) and continues when started again**

### Close Button Logic
```typescript
{onClose && (
  <AnimatedButton onPress={handleClose}>
    {/* Close button */}
  </AnimatedButton>
)}
```
- Only renders if `onClose` prop provided
- Allows flexible usage patterns

---

## 🔐 Data Types

### Sound Type
```typescript
interface Sound {
  id: string;
  title: string;
  description?: string;
  imageUrl?: string;
  categoryId?: string;
  // ... other fields
}
```

### Component Props
```typescript
interface MiniPlayerStripProps {
  sound: Sound | null;
  onExpand: () => void;
  onPlayPress?: () => void | Promise<void>;
  onClose?: () => void | Promise<void>;
}
```

---

## 🌐 Service Integration

### SupabasePlaybackService
**Methods Used:**
- `fetchCachedPlayback(userId)` - Restore last played sound
- `createPlaybackSession(userId, payload)` - Track playback
- `completePlaybackSession(sessionId, data)` - End session
- `clearCachedPlayback(userId)` - Clear state

**Data Flow:**
```
MiniPlayerStrip (display)
  └─> useSoundPlayer (state)
      └─> SupabasePlaybackService (sync)
          └─> Supabase Database
```

### onboardingStorage
**Methods Used:**
- `loadLastPlaybackState()` - Restore from local storage
- `saveLastPlaybackState(sound, favoriteId)` - Save state
- `clearPlaybackState()` - Clear state

**Storage Keys:**
- `last_played_sound` - Sound JSON string
- `last_played_favorite_id` - Favorite ID

---

## 📱 Platform Considerations

### iOS
- Safe area insets handled by parent screens
- Native image loading for artwork
- Smooth animations via Reanimated

### Android
- Elevation for shadow effects
- Touch feedback via AnimatedButton
- Image caching handled by React Native

### Cross-Platform
- Consistent styling across platforms
- Platform-specific optimizations handled internally
- Theme system ensures visual consistency

---

## 🧪 Testing Strategy

### Unit Tests
- Component rendering with/without sound
- Button press handlers
- Conditional rendering logic
- Prop validation

### Integration Tests
- useSoundPlayer hook integration
- Category screen integration
- State persistence
- Audio playback integration

### E2E Tests
- Complete user flow
- State restoration
- Navigation persistence
- Error handling

---

## 🐛 Error Handling

### Missing Artwork
```typescript
{sound.imageUrl ? (
  <Image source={{ uri: sound.imageUrl }} />
) : (
  <View style={styles.placeholder}>
    <Music icon />
  </View>
)}
```
- Graceful fallback to placeholder icon

### Missing Description
```typescript
{!!sound.description && (
  <Text>{sound.description}</Text>
)}
```
- Optional rendering prevents empty space

### Async Callbacks
```typescript
const handleClose = () => {
  if (onClose) {
    void onClose(); // Handle promise
  }
};
```
- Proper async handling with void operator

---

## 📊 Performance Considerations

### Optimization
- Conditional rendering prevents unnecessary renders
- Memoized props in parent components
- Efficient image loading
- Minimal re-renders (props-driven)

### Memory Management
- No event listeners to clean up
- Stateless component (no cleanup needed)
- Image caching handled by React Native

### Rendering Performance
- Simple component tree
- No complex calculations
- Efficient style application
- Theme values cached

---

## 🔄 Future Enhancements

### Potential Improvements
- Progress indicator for playback position
- Waveform visualization
- Swipe gestures for dismissal
- Haptic feedback on interactions
- Background blur effect
- Animation improvements

### Technical Debt
- Consider extracting to separate package
- Add unit test coverage
- Improve TypeScript types
- Add Storybook stories

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For requirements, see `requirements.md`*
