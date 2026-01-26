# MiniPlayer Strip - Components Inventory

## 📱 Main Component

### MiniPlayerStrip
**File:** `src/components/MiniPlayerStrip.tsx`  
**Type:** Presentational Component  
**Purpose:** Compact audio player strip for quick playback access

**Props:**
```typescript
interface MiniPlayerStripProps {
  sound: Sound | null;
  onExpand: () => void;
  onPlayPress?: () => void | Promise<void>;
  onClose?: () => void | Promise<void>;
}
```

**State:** None (stateless component)

**Components Used:**
- `AnimatedButton` - Touch feedback and interactions
- `View` - Layout container
- `Text` - Title and description display
- `Image` - Artwork display
- `Lucide Icons` - Music, PlayCircle, X icons

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Conditional rendering (null if no sound)
- Artwork with placeholder fallback
- Sound metadata display
- Play button with dual behavior
- Optional close button
- Theme-aware styling
- Accessibility support

**User Interactions:**
- Tap content area → Expand to full player
- Tap play button → Resume playback or expand
- Tap close button → Stop and clear

**Styling:**
- Card-based design
- Rounded corners
- Theme colors
- Responsive layout

---

## 🧩 Sub-Components

### Artwork Display
**Type:** Image/Placeholder Component  
**Location:** Within MiniPlayerStrip

**Structure:**
```typescript
<View style={styles.artworkWrapper}>
  {sound.imageUrl ? (
    <Image source={{ uri: sound.imageUrl }} />
  ) : (
    <View style={styles.placeholder}>
      <Music icon />
    </View>
  )}
</View>
```

**Features:**
- 44x44px size
- 12px border radius
- Placeholder icon fallback
- Cover resize mode

**Styling:**
- `artworkWrapper`: Container with fixed size
- `artwork`: Full size image
- `placeholder`: Centered icon container

---

### Metadata Display
**Type:** Text Components  
**Location:** Within MiniPlayerStrip

**Structure:**
```typescript
<View style={styles.meta}>
  <Text style={styles.title}>{sound.title}</Text>
  {!!sound.description && (
    <Text style={styles.subtitle}>{sound.description}</Text>
  )}
</View>
```

**Features:**
- Title (required, single line)
- Description (optional, single line)
- Text truncation (numberOfLines={1})
- Theme-aware colors

**Styling:**
- `meta`: Flex container with left margin
- `title`: 14px, fontWeight: '600'
- `subtitle`: 12px, fontWeight: '400'

---

### Play Button
**Type:** AnimatedButton Component  
**Location:** Within MiniPlayerStrip

**Structure:**
```typescript
<AnimatedButton
  style={styles.control}
  onPress={handlePrimaryPress}
  accessibilityRole='button'
  accessibilityLabel='Wiedergabe fortsetzen'
>
  <PlayCircle icon />
</AnimatedButton>
```

**Features:**
- 36x36px circular button
- Primary color background
- Play icon (18px)
- Dual behavior (play or expand)
- Accessibility support

**Behavior:**
- If `onPlayPress` provided → Execute callback
- Otherwise → Expand to full player

**Styling:**
- Primary background color
- Primary foreground icon color
- Centered content
- Left margin spacing

---

### Close Button
**Type:** AnimatedButton Component (Optional)  
**Location:** Within MiniPlayerStrip

**Structure:**
```typescript
{onClose && (
  <AnimatedButton
    style={styles.closeButton}
    onPress={handleClose}
    accessibilityRole='button'
    accessibilityLabel='Player schließen'
  >
    <X icon />
  </AnimatedButton>
)}
```

**Features:**
- 36x36px circular button
- Card background color
- Close icon (X, 18px)
- Border styling
- Optional rendering
- Accessibility support

**Styling:**
- Card background
- Border with theme color
- Secondary text icon color
- Left margin spacing

---

## 🔗 Component Relationships

### MiniPlayerStrip Component Tree
```
MiniPlayerStrip
├── View (Container)
│   ├── AnimatedButton (Content Area)
│   │   ├── View (Artwork Wrapper)
│   │   │   ├── Image (Artwork) - conditional
│   │   │   └── View (Placeholder) - conditional
│   │   │       └── Music Icon
│   │   └── View (Metadata)
│   │       ├── Text (Title)
│   │       └── Text (Description) - conditional
│   ├── AnimatedButton (Play Button)
│   │   └── PlayCircle Icon
│   └── AnimatedButton (Close Button) - conditional
│       └── X Icon
```

---

## 🎨 Styling Details

### Container Styles
```typescript
container: {
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

### Content Styles
```typescript
content: {
  flex: 1,
  flexDirection: 'row',
  alignItems: 'center',
}
```

### Artwork Styles
```typescript
artworkWrapper: {
  width: 44,
  height: 44,
  borderRadius: 12,
  overflow: 'hidden',
  alignItems: 'center',
  justifyContent: 'center',
}

artwork: {
  width: '100%',
  height: '100%',
}

placeholder: {
  width: '100%',
  height: '100%',
  alignItems: 'center',
  justifyContent: 'center',
}
```

### Metadata Styles
```typescript
meta: {
  flex: 1,
  marginLeft: 12,
}

title: {
  fontSize: 14,
  fontWeight: '600',
}

subtitle: {
  fontSize: 12,
  fontWeight: '400',
}
```

### Control Button Styles
```typescript
control: {
  width: 36,
  height: 36,
  borderRadius: 18,
  alignItems: 'center',
  justifyContent: 'center',
  marginLeft: 12,
}

closeButton: {
  width: 36,
  height: 36,
  borderRadius: 18,
  alignItems: 'center',
  justifyContent: 'center',
  marginLeft: 12,
  borderWidth: 1,
}
```

---

## 🎯 Integration Components

### Category Screen Integration
**Files:**
- `src/screens/SchlafScreen.tsx`
- `src/screens/RuheScreen.tsx`
- `src/screens/ImFlussScreen.tsx`

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

**Container Styles:**
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

## 🔄 State Management

### Local State
- None (stateless component)
- Props-driven rendering

### Context State
- `useTheme` - Theme values
- `useSoundPlayer` - Audio state (via props)

### Props Flow
```
useSoundPlayer Hook
  └─> lastPlayedSound (state)
      └─> MiniPlayerStrip (prop)
          └─> Component renders/updates
```

---

## 🧪 Testing Considerations

### Component Tests
- Rendering with sound
- Rendering without sound (null)
- Artwork display
- Placeholder fallback
- Title/description truncation
- Button interactions
- Optional close button

### Integration Tests
- useSoundPlayer integration
- Category screen integration
- AudioPlayer expansion
- State persistence

### E2E Tests
- Complete user flow
- Navigation persistence
- State restoration
- Error handling

---

## 📊 Component Metrics

### Complexity
- **MiniPlayerStrip:** Low (simple presentational component)
- **Sub-components:** Very Low (basic UI elements)

### Reusability
- **MiniPlayerStrip:** High (used in 3+ screens)
- **Sub-components:** Medium (internal to MiniPlayerStrip)

### Dependencies
- Theme system (required)
- Sound type (required)
- AnimatedButton (required)
- Lucide icons (required)

---

## 🎨 Theme Integration

### Colors Used
- `theme.colors.card` - Background
- `theme.colors.border` - Border
- `theme.colors.text.primary` - Title text
- `theme.colors.text.secondary` - Subtitle text, icons
- `theme.colors.primary` - Play button background
- `theme.colors.primaryForeground` - Play button icon

### Utilities Used
- `getSolidBackground(theme, 'card')` - Background styling

---

## 🔧 Component Props Details

### sound: Sound | null
- **Required:** Yes
- **Type:** Sound object or null
- **Purpose:** Sound data to display
- **Behavior:** Component returns null if sound is null

### onExpand: () => void
- **Required:** Yes
- **Type:** Function
- **Purpose:** Expand to full AudioPlayer
- **Usage:** Called when content area is tapped

### onPlayPress?: () => void | Promise<void>
- **Required:** No
- **Type:** Optional function (sync or async)
- **Purpose:** Direct playback control
- **Behavior:** If provided, used instead of onExpand for play button

### onClose?: () => void | Promise<void>
- **Required:** No
- **Type:** Optional function (sync or async)
- **Purpose:** Close and clear mini player
- **Behavior:** If provided, close button is rendered

---

## 📝 Component Notes

- Component is fully stateless (no internal state)
- All behavior controlled via props
- Conditional rendering prevents empty UI
- Theme integration ensures consistency
- Accessibility labels for screen readers
- Touch feedback via AnimatedButton

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*  
*For requirements, see `requirements.md`*
