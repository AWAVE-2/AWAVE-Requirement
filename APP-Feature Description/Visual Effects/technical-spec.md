# Visual Effects System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Animation Libraries
- **React Native Reanimated** (v3) - Primary animation library
  - Worklet-based animations
  - Native driver support
  - 60fps performance
  - Shared values and animated styles

- **React Native Animated** (Legacy) - Fallback for some components
  - Used in older components
  - Compatible with Reanimated

#### Visual Effect Libraries
- **react-native-linear-gradient** - Gradient rendering
  - LinearGradient component
  - Multi-color gradients
  - Custom start/end points

- **@react-native-community/blur** - Blur effects
  - BlurView component
  - Platform-specific blur
  - iOS and Android support

#### State Management
- **React Hooks** - Component state
  - useState for local state
  - useEffect for animations
  - useRef for animation values
  - useSharedValue for Reanimated

#### Platform APIs
- **Native Driver** - Performance optimization
- **Platform API** - Platform detection
- **Dimensions API** - Screen size calculations

---

## 📁 File Structure

```
src/
├── components/
│   ├── visual-effects/
│   │   ├── VisualEffects.tsx              # Main visual effects components
│   │   ├── AnimationComponents.tsx        # Animation wrapper components
│   │   ├── MicroInteractions.tsx          # Micro-interaction components
│   │   ├── PlatformOptimizations.tsx     # Platform-specific optimizations
│   │   ├── EnhancedHapticFeedback.tsx    # Haptic feedback system
│   │   ├── FocusStates.tsx               # Focus state management
│   │   ├── Accessibility.tsx             # Accessibility features
│   │   ├── PerformanceOptimization.ts    # Performance utilities
│   │   └── index.ts                      # Exports
│   ├── animations/
│   │   └── AnimatedView.tsx              # Reusable animated wrapper
│   └── AnimatedScreenTransition.tsx      # Screen transition component
├── design-system/
│   ├── visual-effects.ts                 # Visual effects configuration
│   ├── animations.ts                     # Animation presets and configs
│   └── theme.ts                          # Theme with visual effects
└── components/
    └── audio-player/
        ├── AudioPlayerVisualization.tsx   # Audio visualization
        └── AudioPlayerBackground.tsx      # Animated background
```

---

## 🔧 Components

### GlassMorphism
**Location:** `src/components/visual-effects/VisualEffects.tsx`

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

**Features:**
- Platform-specific blur implementation
- Multiple intensity levels
- Variant styles with shadows
- Customizable border radius
- Fallback for unsupported platforms

**Platform Implementation:**
- **iOS:** BlurView with native blur types (light, regular, prominent)
- **Android:** BlurView with Material Design blur
- **Fallback:** Semi-transparent overlay

**Dependencies:**
- `@react-native-community/blur`
- `useTheme` hook
- Platform API

---

### GradientOverlay
**Location:** `src/components/visual-effects/VisualEffects.tsx`

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

**Features:**
- Custom color support
- Theme color integration
- Multiple directions
- Intensity/opacity control

**Dependencies:**
- `react-native-linear-gradient`
- `useTheme` hook

---

### GlowEffect
**Location:** `src/components/visual-effects/VisualEffects.tsx`

**Purpose:** Shadow-based glow effect wrapper

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

**Features:**
- Customizable intensity and radius
- Theme color integration
- Shadow-based implementation
- Elevation support for Android

**Dependencies:**
- `useTheme` hook

---

### WaveAnimation
**Location:** `src/components/visual-effects/VisualEffects.tsx`

**Purpose:** Smooth wave animation component

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

**Features:**
- Continuous loop animation
- Customizable speed and amplitude
- Gradient wave support
- Transform-based animation

**Implementation:**
- Uses React Native Animated (legacy)
- Interpolated translateX animation
- Linear gradient overlay

**Dependencies:**
- `react-native-linear-gradient`
- `useTheme` hook

---

### ParticleEffect
**Location:** `src/components/visual-effects/VisualEffects.tsx`

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

**Features:**
- Configurable particle count
- Customizable size, speed, and color
- Staggered animation delays
- Opacity and scale transitions

**Implementation:**
- Array of Animated.Value instances
- Loop animations with delays
- Random positioning
- Interpolated transforms

**Dependencies:**
- `useTheme` hook

---

### AnimatedView
**Location:** `src/components/animations/AnimatedView.tsx`

**Purpose:** Reusable animated wrapper component

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

**Dependencies:**
- `react-native-reanimated`
- `animations.ts` presets

---

### AnimatedScreenTransition
**Location:** `src/components/AnimatedScreenTransition.tsx`

**Purpose:** Screen transition animations

**Props:**
```typescript
interface AnimatedScreenTransitionProps {
  children: React.ReactNode;
  direction: 'left' | 'right' | 'none';
  duration?: number;
}
```

**Features:**
- Left/right slide transitions
- Fade transitions
- Customizable duration
- Cubic easing

**Implementation:**
- Uses React Native Reanimated
- Screen width-based calculations
- Opacity and translateX animations

**Dependencies:**
- `react-native-reanimated`
- Dimensions API

---

### AudioPlayerVisualization
**Location:** `src/components/audio-player/AudioPlayerVisualization.tsx`

**Purpose:** Real-time audio visualization with animations

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

**Features:**
- Real-time waveform bars (7 bars)
- Three floating orbs with independent animations
- Gradient overlay sweep
- Toggle between visualization and text
- Purple gradient background

**Animations:**
- Waveform bars: Random height animations (20-60px)
- Orb 1: 8s duration, X/Y/scale animations
- Orb 2: 6s duration, X/Y/scale animations
- Orb 3: 10s duration, X/Y/scale animations
- Gradient sweep: 4s linear horizontal movement

**Dependencies:**
- `react-native-reanimated`
- `react-native-linear-gradient`
- `useTheme` hook

---

### AudioPlayerBackground
**Location:** `src/components/audio-player/AudioPlayerBackground.tsx`

**Purpose:** Animated mesh gradient background

**Props:**
```typescript
interface AudioPlayerBackgroundProps {
  opacity?: number;
}
```

**Features:**
- Three rotating mesh gradients
- Six floating blob animations
- Central ambient glow
- Long-duration animations (40s-140s)

**Animations:**
- Primary mesh: 80s rotation, 25s scale
- Secondary mesh: 65s rotation (reverse), 20s scale
- Tertiary mesh: 100s rotation, 30s scale
- Floating blobs: 40s-140s independent movements
- Central glow: 15s scale and opacity pulse

**Dependencies:**
- `react-native-reanimated`
- `react-native-linear-gradient`
- `useTheme` hook

---

## 🔌 Services & Utilities

### visual-effects.ts
**Location:** `src/design-system/visual-effects.ts`

**Purpose:** Visual effects configuration and presets

**Exports:**
- `gradients` - Gradient configurations
- `glassMorphism` - Glass effect styles
- `shadows` - Shadow presets
- `animations` - Animation configurations
- `visualEffects` - Visual effect utilities
- `platformConfig` - Platform-specific configs

**Gradient Types:**
- Primary, secondary, background, text
- Glass, card, button gradients
- Glow and overlay gradients

**Shadow Presets:**
- sm, md, lg (standard sizes)
- glow, glowSecondary (AWAVE-specific)
- card, cardHover (card variants)

---

### animations.ts
**Location:** `src/design-system/animations.ts`

**Purpose:** Unified animation system with presets

**Exports:**
- `durations` - Animation duration constants
- `easing` - Easing functions
- `pageTransitions` - Page transition presets
- `tapFeedback` - Tap feedback configs
- `presets` - Common animation presets
- `looping` - Looping animation configs
- `accordion` - Accordion animation configs

**Durations:**
- fast: 200ms
- normal: 300ms
- slow: 500ms
- verySlow: 800ms
- wave: 2000ms
- float: 4000ms
- pulseGlow: 3000ms
- pulseSlow: 3000ms
- shimmer: 3000ms

**Easing Functions:**
- linear, easeIn, easeOut, easeInOut, ease
- React Native Reanimated compatible

**Page Transitions:**
- enter: opacity 0→1, translateY 10→0
- exit: opacity 1→0, translateY 0→-10
- Duration: 300ms, easing: easeOut

**Tap Feedback:**
- standard: scale 0.95, 200ms
- subtle: scale 0.98, 200ms

**Looping Animations:**
- wave: translateY 0→-15→0, 2000ms
- float: translateY 0→-10→0, 4000ms
- pulseGlow: shadowOpacity 0.4→0.8→0.4, 3000ms
- pulseSlow: opacity 1→0.5→1, 3000ms
- bounceSubtle: translateY 0→-5→0, 2000ms

---

## 🪝 Hooks & Utilities

### useTheme
**Location:** `src/design-system/ThemeProvider.tsx`

**Purpose:** Access theme including visual effects

**Returns:**
```typescript
{
  colors: ColorSystem;
  visualEffects: VisualEffectsSystem;
  animations: AnimationSystem;
  // ... other theme properties
}
```

**Usage:**
- Access brand colors for effects
- Get visual effect presets
- Access animation configurations

---

## 🔐 Performance Implementation

### Native Driver
- All animations use `useNativeDriver: true`
- React Native Reanimated uses worklets
- Animations run on UI thread
- 60fps performance guaranteed

### Optimization Strategies
- **Particle Limits:** Configurable particle counts
- **Animation Cleanup:** Proper cleanup in useEffect
- **Memoization:** React.memo for expensive components
- **Efficient Re-renders:** Shared values in Reanimated
- **Platform Optimizations:** Platform-specific implementations

### Performance Monitoring
- Frame rate monitoring (target: 60fps)
- CPU usage tracking (target: < 5%)
- Memory usage optimization
- Animation cancellation on unmount

---

## 🔄 State Management

### Animation State
- **Shared Values:** React Native Reanimated shared values
- **Animated Values:** React Native Animated values (legacy)
- **Local State:** useState for component state
- **Refs:** useRef for animation instances

### State Patterns
- **Mount Animations:** useEffect on mount
- **Prop-based Animations:** useEffect with prop dependencies
- **Continuous Animations:** Loop animations with withRepeat
- **Cleanup:** Animation stop on unmount

---

## 🌐 Platform-Specific Notes

### iOS
- Native blur support via BlurView
- Blur types: light, regular, prominent
- Reduced transparency fallback
- Native shadow rendering
- Smooth animations with Core Animation

### Android
- Material Design blur
- Elevation-based shadows
- Optimized opacity values
- Native driver support
- Hardware acceleration

### Cross-Platform
- Consistent color usage
- Platform detection for optimizations
- Graceful degradation
- Fallback implementations

---

## 🧪 Testing Strategy

### Unit Tests
- Component rendering
- Animation value calculations
- Platform-specific logic
- Configuration validation

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

## 🐛 Error Handling

### Error Types
- Platform unsupported errors
- Animation initialization errors
- Performance degradation warnings
- Memory leak detection

### Error Handling Strategies
- Graceful fallbacks
- Platform detection
- Performance monitoring
- Error logging

---

## 📊 Performance Considerations

### Optimization Techniques
- Native driver usage
- Efficient re-renders
- Animation cleanup
- Memory management
- Platform-specific optimizations

### Performance Metrics
- Frame rate: 60fps target
- CPU usage: < 5% target
- Memory usage: Optimized
- Animation smoothness: < 300ms transitions

---

## 🔄 Animation Lifecycle

### Mount Phase
1. Component mounts
2. Animation values initialized
3. useEffect triggers animation
4. Animation starts

### Update Phase
1. Props change
2. useEffect dependencies trigger
3. Animation updates or resets
4. Smooth transition

### Unmount Phase
1. Component unmounts
2. useEffect cleanup runs
3. Animations stopped
4. Resources released

---

## 📝 Configuration

### Theme Integration
- All effects use theme colors
- Brand colors: `colors.awave`
- Spacing: `spacing` system
- Border radius: `borderRadius` system

### Animation Configuration
- Durations: `animations.durations`
- Easing: `animations.easing`
- Presets: `animations.presets`
- Platform: `platformConfig`

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
