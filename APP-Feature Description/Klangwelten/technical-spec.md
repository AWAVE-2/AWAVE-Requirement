# Klangwelten System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Audio Engine
- **NativeMultiTrackAudioService** - Native audio service for multi-track playback (multiplayer setup)
  - Uses native AWAVEAudioModule (iOS/Android)
  - AVAudioEngine-based (iOS)
  - Superior performance vs. Expo AV
  - Exactly 3 simultaneous tracks support (chosen from carousel)
  - Individual volume and pan control
  - Audio effects support (reverb, delay, EQ)
  - **Play button controls the complete sound system** (starts/stops all 3 sounds)
  - **Journey freezes where stopped (gets stored) and continues when started again**
  - **Time control calculated by total length of loaded sounds, dynamically based on longest sound file**

#### State Management
- **React Hooks** - `useMultiTrackMixer` for mixer state
- **React Context** - Theme and navigation context
- **AsyncStorage** - Local state persistence
- **React State** - Component-level state management

#### UI Components
- **React Native** - Core UI components
- **React Navigation** - Screen navigation
- **Theme System** - Consistent styling
- **Bottom Sheet** - Mixer interface

---

## 📁 File Structure

```
src/
├── screens/
│   └── KlangweltenScreen.tsx              # Main sound world screen
├── components/
│   ├── klangwelten/
│   │   └── SoundCarousel.tsx              # Sound selection carousel
│   └── audio-player/
│       └── AudioPlayerMixerSheet.tsx      # Mixer bottom sheet
├── hooks/
│   └── useMultiTrackMixer.ts              # Multi-track mixing hook
├── services/
│   └── NativeMultiTrackAudioService.ts    # Native audio service
└── native-modules/
    └── NativeAudioBridge.ts               # Native module bridge
```

---

## 🔧 Components

### KlangweltenScreen
**Location:** `src/screens/KlangweltenScreen.tsx`

**Purpose:** Main screen for sound world creation and mixing

**Props:**
```typescript
// Route params
interface KlangweltenRouteParams {
  categoryId: string;
  categoryTitle?: string;
}
```

**State:**
- `availableSounds: Sound[]` - Sounds available for selection
- `selectedSoundIds: string[]` - Currently selected sound IDs
- `isMixerOpen: boolean` - Mixer sheet visibility

**Features:**
- Sound carousel display
- Playback controls (play, pause, stop)
- Mixer access button
- Category information display
- Error handling
- Loading states

**Dependencies:**
- `useMultiTrackMixer` hook
- `SoundCarousel` component
- `AudioPlayerMixerSheet` component
- `useTheme` hook
- `useNavigation` hook

---

### SoundCarousel Component
**Location:** `src/components/klangwelten/SoundCarousel.tsx`

**Purpose:** Horizontal scrollable carousel for sound selection

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

**Features:**
- Horizontal FlatList with snap scrolling
- Sound card rendering with image, title, description
- Selection indicators (checkmark badges)
- Selection counter display
- Pagination dots
- Disabled state when max reached
- Tap-to-toggle selection behavior

**State:**
- `currentIndex: number` - Current visible card index

**Dependencies:**
- `useTheme` hook
- Sound data structure
- React Native FlatList

---

### AudioPlayerMixerSheet Component
**Location:** `src/components/audio-player/AudioPlayerMixerSheet.tsx`

**Purpose:** Bottom sheet mixer interface for track control

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

**Features:**
- Bottom sheet presentation
- Track cards with name and category
- Volume sliders per track
- Track on/off switches
- Empty state when no active tracks
- Volume percentage display

**Dependencies:**
- `BottomSheet` component
- `Slider` component
- `Switch` component
- `useTheme` hook

---

## 🔌 Services

### NativeMultiTrackAudioService
**Location:** `src/services/NativeMultiTrackAudioService.ts`

**Class:** Singleton service

**Methods:**
- `getInstance()` - Get singleton instance
- `initialize()` - Initialize audio engine
- `addTrack(trackId, soundUri, volume)` - Add track to mixer
- `removeTrack(trackId)` - Remove track from mixer
- `playTrack(trackId)` - Play specific track
- `pauseTrack(trackId)` - Pause specific track
- `stopTrack(trackId)` - Stop specific track
- `playAll()` - Play all tracks
- `pauseAll()` - Pause all tracks
- `stopAll()` - Stop all tracks
- `setTrackVolume(trackId, volume)` - Set track volume (0-1)
- `setTrackPan(trackId, pan)` - Set track pan (-1 to 1)
- `getTracks()` - Get all tracks
- `getTrack(trackId)` - Get specific track
- `getTrackCount()` - Get number of tracks
- `cleanup()` - Cleanup resources

**Configuration:**
- Singleton pattern for single instance
- Map-based track storage
- Native module bridge integration

**Storage:**
- In-memory track map
- No persistent storage (handled by hook)

---

### useMultiTrackMixer Hook
**Location:** `src/hooks/useMultiTrackMixer.ts`

**Purpose:** React hook for multi-track mixer state management

**Returns:**
```typescript
{
  // State
  tracks: MixerTrack[];
  masterVolume: number;
  isPlaying: boolean;
  isLoading: boolean;
  error: string | null;

  // Track Management
  setTrackSound: (trackId: string, sound: Sound) => Promise<void>;
  setTrackVolume: (trackId: string, volume: number) => Promise<void>;
  toggleTrack: (trackId: string) => Promise<void>;
  clearTrack: (trackId: string) => Promise<void>;

  // Playback Control
  playAll: () => Promise<void>;
  pauseAll: () => Promise<void>;
  stopAll: () => Promise<void>;
  setMasterVolume: (volume: number) => void;

  // State Management
  saveMixerState: () => Promise<void>;
  loadMixerState: () => Promise<void>;
  resetMixer: () => void;
}
```

**Features:**
- Default 3-track initialization
- Auto-save state on changes (1s debounce)
- Auto-load state on mount
- Track management (add, remove, toggle)
- Playback control (play, pause, stop)
- Volume control per track
- Error handling
- State persistence

**Storage:**
- AsyncStorage key: `awaveMixerState`
- Serialized JSON format
- Auto-save on state changes

---

## 🪝 Hooks

### useMultiTrackMixer
**Location:** `src/hooks/useMultiTrackMixer.ts`

**Purpose:** Multi-track mixer state and playback management

**State Management:**
- Tracks array with sound, volume, isActive, isPlaying
- Master volume (0-100)
- Playback state (isPlaying)
- Loading state (isLoading)
- Error state (error)

**Lifecycle:**
- Initializes audio service on mount
- Loads saved state on mount
- Auto-saves state on changes (debounced)
- Cleans up on unmount

**Track Operations:**
- `setTrackSound` - Assign sound to track
- `setTrackVolume` - Set track volume (0-100)
- `toggleTrack` - Toggle track active state
- `clearTrack` - Remove sound from track

**Playback Operations:**
- `playAll` - Play all active tracks
- `pauseAll` - Pause all tracks
- `stopAll` - Stop all tracks
- `setMasterVolume` - Set master volume

**State Persistence:**
- `saveMixerState` - Save to AsyncStorage
- `loadMixerState` - Load from AsyncStorage
- `resetMixer` - Reset to defaults

---

## 🔐 Data Structures

### MixerTrack Interface
```typescript
interface MixerTrack {
  id: string;
  sound: Sound | null;
  volume: number; // 0-100
  isActive: boolean;
  isPlaying: boolean;
}
```

### MixerState Interface
```typescript
interface MixerState {
  tracks: MixerTrack[];
  masterVolume: number;
  isPlaying: boolean;
}
```

### Sound Interface
```typescript
interface Sound {
  id: string;
  title: string;
  description?: string;
  categoryId: string;
  imageUrl?: string;
  audioFile?: string;
  isCustom?: boolean;
}
```

---

## 🔄 State Management

### Component State (KlangweltenScreen)
```typescript
{
  availableSounds: Sound[];
  selectedSoundIds: string[];
  isMixerOpen: boolean;
}
```

### Hook State (useMultiTrackMixer)
```typescript
{
  mixerState: MixerState;
  isLoading: boolean;
  error: string | null;
}
```

### Persisted State (AsyncStorage)
```typescript
{
  tracks: Array<{
    id: string;
    sound: {
      id: string;
      title: string;
      description?: string;
      categoryId: string;
      imageUrl?: string;
      audioFile?: string;
    } | null;
    volume: number;
    isActive: boolean;
    isPlaying: boolean;
  }>;
  masterVolume: number;
  isPlaying: boolean;
}
```

---

## 🌐 API Integration

### Native Module Bridge
- **NativeAudioBridge** - Bridge to native audio module
- Methods: `loadTrack`, `playTrack`, `pauseTrack`, `stopTrack`, `setVolume`, `setPan`
- Error handling and logging
- Platform-specific implementations

### AsyncStorage API
- `setItem('awaveMixerState', JSON.stringify(state))` - Save state
- `getItem('awaveMixerState')` - Load state
- Error handling for storage failures

---

## 📱 Platform-Specific Notes

### iOS
- Native AVAudioEngine for multi-track playback
- Superior audio performance
- Background audio support
- Lock screen controls (via audio session)

### Android
- Native audio engine implementation
- Background audio support
- Media session integration

### Common
- React Native bridge for native modules
- Consistent API across platforms
- Error handling for platform differences

---

## 🧪 Testing Strategy

### Unit Tests
- Hook state management
- Track operations (add, remove, toggle)
- Volume control
- State persistence (save/load)
- Error handling

### Integration Tests
- Audio service initialization
- Multi-track playback
- Volume adjustment during playback
- State persistence across restarts
- Navigation flow

### E2E Tests
- Complete sound world creation flow
- Volume adjustment in mixer
- Track toggle during playback
- State persistence verification
- Error recovery

---

## 🐛 Error Handling

### Error Types
- Audio service initialization failures
- Track loading failures
- Playback errors
- State persistence errors
- Navigation errors

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

---

## 📊 Performance Considerations

### Optimization
- Debounced state saves (1 second)
- Lazy sound loading
- Efficient track management
- Native audio engine for performance
- Memoized callbacks

### Monitoring
- Audio playback success rate
- State persistence success rate
- Average time to create mix
- Error rates

---

## 🔄 State Flow

### Sound Selection Flow
```
User taps sound
  → handleSoundToggle()
  → Check if selected
  → If selected: clearTrack()
  → If not selected: setTrackSound()
  → Update selectedSoundIds
  → Sync with tracks
```

### Playback Flow
```
User presses play
  → handlePlayPause()
  → Check active tracks
  → If none: show alert
  → If active: playAll()
  → Update isPlaying state
  → Update track isPlaying states
```

### Volume Adjustment Flow
```
User adjusts slider
  → handleVolumeChange()
  → setTrackVolume()
  → Update track volume in state
  → Update volume in audio service
  → Update UI
```

### State Persistence Flow
```
State changes
  → useEffect detects change
  → Debounce 1 second
  → saveMixerState()
  → Serialize state
  → Save to AsyncStorage
```

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
