# Visual Effects System - Components Inventory

## 📱 Visual Effect Components

### GlassMorphism
**File:** `src/components/visual-effects/VisualEffects.tsx`  
**Type:** Visual Effect Component  
**Purpose:** Platform-specific glass morphism effect with blur

**Props:**
```typescript
interface GlassMorphismProps {
  children: React.ReactNode;
  intensity?: 'light' | 'medium' | 'heavy' | 'ultra';
  variant?: 'default' | 'card' | 'navigation' | 'modal';
  style?: StyleProp<ViewStyle>;
  borderRadius?: number;
  enableBlur?: boolean;
}
```

**State:** None (stateless)

**Components Used:**
- `BlurView` - Platform blur implementation
- `View` - Fallback container

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Platform-specific blur (iOS/Android)
- Multiple intensity levels
- Variant styles with shadows
- Customizable border radius
- Fallback for unsupported platforms

**Platform Implementation:**
- **iOS:** BlurView with native blur types
- **Android:** BlurView with Material Design blur
- **Fallback:** Semi-transparent overlay

**User Interactions:**
- None (visual effect only)

---

### GradientOverlay
**File:** `src/components/visual-effects/VisualEffects.tsx`  
**Type:** Visual Effect Component  
**Purpose:** Multi-directional gradient overlay

**Props:**
```typescript
interface GradientOverlayProps {
  children: React.ReactNode;
  colors?: string[];
  direction?: 'horizontal' | 'vertical' | 'diagonal';
  intensity?: number;
  style?: StyleProp<ViewStyle>;
}
```

**State:** None (stateless)

**Components Used:**
- `LinearGradient` - Gradient rendering

**Hooks Used:**
- `useTheme` - Theme colors

**Features:**
- Custom color support
- Theme color integration
- Multiple directions
- Intensity/opacity control

**User Interactions:**
- None (visual effect only)

---

### GlowEffect
**File:** `src/components/visual-effects/VisualEffects.tsx`  
**Type:** Visual Effect Wrapper  
**Purpose:** Shadow-based glow effect

**Props:**
```typescript
interface GlowEffectProps {
  children: React.ReactNode;
  color?: string;
  intensity?: number;
  radius?: number;
  style?: StyleProp<ViewStyle>;
}
```

**State:** None (stateless)

**Components Used:**
- `View` - Container with shadow styles

**Hooks Used:**
- `useTheme` - Theme colors

**Features:**
- Customizable intensity and radius
- Theme color integration
- Shadow-based implementation
- Elevation support for Android

**User Interactions:**
- None (visual effect only)

---

### WaveAnimation
**File:** `src/components/visual-effects/VisualEffects.tsx`  
**Type:** Animated Component  
**Purpose:** Smooth wave animation

**Props:**
```typescript
interface WaveAnimationProps {
  width?: number;
  height?: number;
  color?: string;
  speed?: number;
  amplitude?: number;
  style?: StyleProp<ViewStyle>;
}
```

**State:**
- `animatedValue: Animated.Value` - Animation value

**Components Used:**
- `LinearGradient` - Gradient wave
- `Animated.View` - Animated container

**Hooks Used:**
- `useTheme` - Theme colors
- `useRef` - Animation value
- `useEffect` - Animation lifecycle

**Features:**
- Continuous loop animation
- Customizable speed and amplitude
- Gradient wave support
- Transform-based animation

**User Interactions:**
- None (automatic animation)

---

### ParticleEffect
**File:** `src/components/visual-effects/VisualEffects.tsx`  
**Type:** Animated Component  
**Purpose:** Animated particle system

**Props:**
```typescript
interface ParticleEffectProps {
  particleCount?: number;
  color?: string;
  size?: number;
  speed?: number;
  style?: StyleProp<ViewStyle>;
}
```

**State:**
- `animatedValues: Animated.Value[]` - Array of animation values

**Components Used:**
- `Animated.View` - Individual particles

**Hooks Used:**
- `useTheme` - Theme colors
- `useRef` - Animation values
- `useEffect` - Animation lifecycle

**Features:**
- Configurable particle count
- Customizable size, speed, and color
- Staggered animation delays
- Opacity and scale transitions

**User Interactions:**
- None (automatic animation)

---

### BlurEffect
**File:** `src/components/visual-effects/VisualEffects.tsx`  
**Type:** Visual Effect Component  
**Purpose:** Blur effect overlay

**Props:**
```typescript
interface BlurEffectProps {
  children: React.ReactNode;
  intensity?: number;
  style?: StyleProp<ViewStyle>;
}
```

**State:** None (stateless)

**Components Used:**
- `View` - Container with blur overlay

**Hooks Used:**
- `useTheme` - Theme styling

**Features:**
- Customizable intensity
- Semi-transparent overlay
- Platform-agnostic implementation

**User Interactions:**
- None (visual effect only)

---

## 🎬 Animation Components

### AnimatedView
**File:** `src/components/animations/AnimatedView.tsx`  
**Type:** Animation Wrapper Component  
**Purpose:** Reusable animated wrapper

**Props:**
```typescript
interface AnimatedViewProps {
  children: React.ReactNode;
  animation?: 'fade' | 'slide-up' | 'slide-down' | 'scale' | 'none';
  duration?: number;
  delay?: number;
  style?: ViewStyle;
  testID?: string;
}
```

**State:**
- `opacity: SharedValue` - Opacity animation
- `translateY: SharedValue` - Y translation
- `scale: SharedValue` - Scale animation

**Components Used:**
- `Animated.View` - Reanimated animated view

**Hooks Used:**
- `useSharedValue` - Animation values
- `useAnimatedStyle` - Animated styles
- `useEffect` - Animation lifecycle

**Features:**
- Multiple animation types
- Customizable duration and delay
- Uses React Native Reanimated
- Native driver support

**Animation Types:**
- `fade` - Opacity transition
- `slide-up` - Translate Y from bottom
- `slide-down` - Translate Y from top
- `scale` - Scale animation with spring
- `none` - No animation

**User Interactions:**
- None (mount animation)

---

### AnimatedScreenTransition
**File:** `src/components/AnimatedScreenTransition.tsx`  
**Type:** Screen Transition Component  
**Purpose:** Screen transition animations

**Props:**
```typescript
interface AnimatedScreenTransitionProps {
  children: React.ReactNode;
  direction: 'left' | 'right' | 'none';
  duration?: number;
}
```

**State:**
- `translateX: SharedValue` - X translation
- `opacity: SharedValue` - Opacity animation

**Components Used:**
- `Animated.View` - Reanimated animated view

**Hooks Used:**
- `useSharedValue` - Animation values
- `useAnimatedStyle` - Animated styles
- `useEffect` - Animation lifecycle

**Features:**
- Left/right slide transitions
- Fade transitions
- Customizable duration
- Cubic easing

**User Interactions:**
- None (automatic on mount)

---

### Ripple
**File:** `src/components/visual-effects/AnimationComponents.tsx`  
**Type:** Interactive Animation Component  
**Purpose:** Ripple effect on press

**Props:**
```typescript
interface RippleProps {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
}
```

**State:**
- `scaleAnim: Animated.Value` - Scale animation

**Components Used:**
- `TouchableOpacity` - Touchable container
- `Animated.View` - Animated wrapper

**Hooks Used:**
- `useRef` - Animation value
- `Animated.spring` - Spring animation

**Features:**
- Scale animation on press
- Spring-based animation
- Optional onPress handler

**User Interactions:**
- Press in/out triggers animation

---

### Scale
**File:** `src/components/visual-effects/AnimationComponents.tsx`  
**Type:** Looping Animation Component  
**Purpose:** Continuous scale animation

**Props:**
```typescript
interface ScaleProps {
  children: React.ReactNode;
  style?: ViewStyle;
}
```

**State:**
- `scaleAnim: Animated.Value` - Scale animation

**Components Used:**
- `Animated.View` - Animated wrapper

**Hooks Used:**
- `useRef` - Animation value
- `useEffect` - Animation lifecycle

**Features:**
- Continuous loop animation
- Scale 1 → 1.02 → 1
- 2s duration per cycle

**User Interactions:**
- None (automatic animation)

---

## 🎨 Audio Visualization Components

### AudioPlayerVisualization
**File:** `src/components/audio-player/AudioPlayerVisualization.tsx`  
**Type:** Audio Visualization Component  
**Purpose:** Real-time audio visualization

**Props:**
```typescript
interface AudioPlayerVisualizationProps {
  title: string;
  description?: string;
  imageUrl?: string;
  showVisualization: boolean;
  isPlaying: boolean;
  onToggleVisualization: () => void;
  onToggleFavorite?: () => void;
  isFavorite?: boolean;
}
```

**State:**
- `orb1X, orb1Y, orb1Scale: SharedValue` - Orb 1 animations
- `orb2X, orb2Y, orb2Scale: SharedValue` - Orb 2 animations
- `orb3X, orb3Y, orb3Scale: SharedValue` - Orb 3 animations
- `gradientX: SharedValue` - Gradient sweep
- `barHeights: SharedValue[]` - Waveform bar heights

**Components Used:**
- `LinearGradient` - Gradient backgrounds
- `Animated.View` - Animated orbs and bars
- `TouchableOpacity` - Toggle interaction

**Hooks Used:**
- `useSharedValue` - Animation values
- `useAnimatedStyle` - Animated styles
- `useEffect` - Animation lifecycle

**Features:**
- Real-time waveform bars (7 bars)
- Three floating orbs
- Gradient overlay sweep
- Toggle between visualization and text
- Purple gradient background

**User Interactions:**
- Tap to toggle visualization mode

---

### AudioPlayerBackground
**File:** `src/components/audio-player/AudioPlayerBackground.tsx`  
**Type:** Animated Background Component  
**Purpose:** Animated mesh gradient background

**Props:**
```typescript
interface AudioPlayerBackgroundProps {
  opacity?: number;
}
```

**State:**
- `primaryRotation, primaryScale: SharedValue` - Primary mesh
- `secondaryRotation, secondaryScale: SharedValue` - Secondary mesh
- `tertiaryRotation, tertiaryScale: SharedValue` - Tertiary mesh
- `glowScale, glowOpacity: SharedValue` - Central glow

**Components Used:**
- `LinearGradient` - Mesh gradients
- `Animated.View` - Animated layers
- `FloatingBlob` - Individual blob component

**Hooks Used:**
- `useSharedValue` - Animation values
- `useAnimatedStyle` - Animated styles
- `useEffect` - Animation lifecycle

**Features:**
- Three rotating mesh gradients
- Six floating blob animations
- Central ambient glow
- Long-duration animations

**User Interactions:**
- None (automatic background animation)

---

## 🔗 Component Relationships

### Visual Effects Component Tree
```
GlassMorphism
├── BlurView (iOS/Android)
│   └── children
└── View (Fallback)
    └── children

GradientOverlay
└── LinearGradient
    └── children

GlowEffect
└── View (with shadow styles)
    └── children

WaveAnimation
├── LinearGradient
│   └── Animated.View
│       └── Wave transform
└── View (Container)

ParticleEffect
└── View (Container)
    └── Animated.View[] (Particles)
        └── Individual particles
```

### Animation Component Tree
```
AnimatedView
└── Animated.View (Reanimated)
    └── children

AnimatedScreenTransition
└── Animated.View (Reanimated)
    └── children

Ripple
└── TouchableOpacity
    └── Animated.View
        └── children

Scale
└── Animated.View
    └── children
```

### Audio Visualization Component Tree
```
AudioPlayerVisualization
├── LinearGradient (Background)
├── Animated.View (Orb 1)
│   └── LinearGradient
├── Animated.View (Orb 2)
│   └── LinearGradient
├── Animated.View (Orb 3)
│   └── LinearGradient
├── Animated.View (Gradient Overlay)
│   └── LinearGradient
└── View (Content Container)
    ├── View (Waveform) - conditional
    │   └── Animated.View[] (Bars)
    └── View (Text) - conditional
        ├── Icon
        ├── Text (Title)
        └── Text (Description)

AudioPlayerBackground
├── View (Base Background)
├── Animated.View (Primary Mesh)
│   └── LinearGradient
├── Animated.View (Secondary Mesh)
│   └── LinearGradient
├── Animated.View (Tertiary Mesh)
│   └── LinearGradient
├── FloatingBlob[] (6 blobs)
└── Animated.View (Central Glow)
    └── LinearGradient
```

---

## 🎨 Styling

### Theme Integration
All components use the theme system via `useTheme` hook:
- Colors: `theme.colors.awave.primary`, `theme.colors.awave.secondary`, etc.
- Spacing: `theme.spacing`
- Border radius: `theme.borderRadius`
- Visual effects: `theme.visualEffects`

### Platform-Specific Styling
- **iOS:** Native blur, reduced transparency fallback
- **Android:** Material Design blur, elevation support
- **Cross-platform:** Consistent colors and spacing

### Performance Optimizations
- Native driver for all animations
- Efficient re-renders with React.memo
- Optimized particle counts
- Platform-specific implementations

---

## 🔄 State Management

### Local State
- Animation values (SharedValue, Animated.Value)
- Component visibility states
- Interaction states (pressed, focused)

### Animation State
- **Reanimated:** Shared values for 60fps animations
- **Animated API:** Animated values for legacy components
- **Lifecycle:** useEffect for animation setup/cleanup

### Persistent State
- None (all animations are ephemeral)

---

## 🧪 Testing Considerations

### Component Tests
- Component rendering
- Animation value initialization
- Platform-specific logic
- Prop validation

### Integration Tests
- Animation sequences
- Component interactions
- Performance benchmarks
- Platform compatibility

### Visual Tests
- Screenshot comparisons
- Animation smoothness
- Color accuracy
- Layout consistency

---

## 📊 Component Metrics

### Complexity
- **GlassMorphism:** Low (stateless wrapper)
- **GradientOverlay:** Low (stateless wrapper)
- **GlowEffect:** Low (stateless wrapper)
- **WaveAnimation:** Medium (animation logic)
- **ParticleEffect:** High (multiple animations)
- **AnimatedView:** Medium (animation wrapper)
- **AudioPlayerVisualization:** High (complex animations)
- **AudioPlayerBackground:** High (multiple layers)

### Reusability
- **GlassMorphism:** High (used throughout app)
- **GradientOverlay:** High (used in backgrounds)
- **GlowEffect:** Medium (used in cards/buttons)
- **AnimatedView:** High (used for all mount animations)
- **AudioPlayerVisualization:** Low (audio player specific)

### Dependencies
- All components depend on theme system
- Animation components depend on Reanimated/Animated
- Visual effects depend on blur/gradient libraries
- Platform-specific components depend on Platform API

---

*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
