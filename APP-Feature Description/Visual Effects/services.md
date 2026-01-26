# Visual Effects System - Services & Utilities Documentation

## 🔧 Service Layer Overview

The visual effects system uses a utility-oriented architecture with configuration files, animation presets, and platform-specific optimizations. All services are stateless and provide reusable configurations and utilities.

---

## 📦 Services & Utilities

### visual-effects.ts
**File:** `src/design-system/visual-effects.ts`  
**Type:** Configuration Service  
**Purpose:** Visual effects configuration and presets

#### Exports

**Gradients**
```typescript
export const gradients = {
  primary: { colors, start, end, angle },
  secondary: { colors, start, end, angle },
  background: { colors, start, end, angle },
  text: { colors, start, end, angle },
  glass: { colors, start, end, angle },
  card: { colors, start, end, angle },
  button: { primary, secondary },
  glow: { colors, start, end, angle },
  overlay: { dark, light },
}
```

**Glass Morphism**
```typescript
export const glassMorphism = {
  basic: { backgroundColor, borderWidth, borderColor, borderRadius },
  enhanced: { backgroundColor, borderWidth, borderColor, borderRadius },
  active: { backgroundColor, borderWidth, borderColor, borderRadius },
  glow: { backgroundColor, borderWidth, borderColor, borderRadius, shadow },
}
```

**Shadows**
```typescript
export const shadows = {
  none: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  sm: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  md: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  lg: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  glow: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  glowSecondary: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  card: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
  cardHover: { shadowColor, shadowOffset, shadowOpacity, shadowRadius, elevation },
}
```

**Animations**
```typescript
export const animations = {
  duration: { fast, normal, slow, verySlow },
  easing: { ease, easeIn, easeOut, easeInOut },
  fadeIn: { duration, easing },
  slideUp: { duration, easing },
  scale: { duration, easing },
  glow: { duration, easing },
}
```

**Visual Effects**
```typescript
export const visualEffects = {
  ripple: { color, duration, scale },
  glow: { color, intensity, radius, duration },
  pulse: { scale, duration, easing },
  shake: { translateX, duration, iterations },
}
```

**Platform Configuration**
```typescript
export const platformConfig = {
  ios: { blurType, blurAmount, reducedTransparencyFallbackColor },
  android: { blurType, blurAmount, reducedTransparencyFallbackColor },
}
```

#### Usage
```typescript
import { gradients, glassMorphism, shadows } from '@/design-system/visual-effects';

// Use gradient
<LinearGradient {...gradients.primary} />

// Use glass effect
<View style={glassMorphism.enhanced} />

// Use shadow
<View style={shadows.glow} />
```

---

### animations.ts
**File:** `src/design-system/animations.ts`  
**Type:** Animation Configuration Service  
**Purpose:** Unified animation system with presets

#### Exports

**Durations**
```typescript
export const durations = {
  fast: 200,        // Fast interactions
  normal: 300,      // Standard transitions
  slow: 500,        // Slow transitions
  verySlow: 800,    // Very slow transitions
  wave: 2000,       // Wave animation
  float: 4000,      // Float animation
  pulseGlow: 3000,  // Pulse glow animation
  pulseSlow: 3000,  // Pulse slow animation
  shimmer: 3000,    // Shimmer animation
}
```

**Easing**
```typescript
export const easing = {
  linear: ReanimatedEasing.linear,
  easeIn: ReanimatedEasing.in(ReanimatedEasing.ease),
  easeOut: ReanimatedEasing.out(ReanimatedEasing.ease),
  easeInOut: ReanimatedEasing.inOut(ReanimatedEasing.ease),
  ease: ReanimatedEasing.ease,
}
```

**Page Transitions**
```typescript
export const pageTransitions = {
  enter: {
    from: { opacity: 0, translateY: 10 },
    to: { opacity: 1, translateY: 0 },
    duration: 300,
    easing: easing.easeOut,
  },
  exit: {
    from: { opacity: 1, translateY: 0 },
    to: { opacity: 0, translateY: -10 },
    duration: 300,
    easing: easing.easeOut,
  },
}
```

**Tap Feedback**
```typescript
export const tapFeedback = {
  standard: { scale: 0.95, duration: 200 },
  subtle: { scale: 0.98, duration: 200 },
}
```

**Presets**
```typescript
export const presets = {
  fadeIn: { from: { opacity: 0 }, to: { opacity: 1 }, duration: 300, easing: easing.easeOut },
  slideUp: { from: { translateY: 50, opacity: 0 }, to: { translateY: 0, opacity: 1 }, duration: 400, easing: easing.easeOut },
  slideDown: { from: { translateY: -50, opacity: 0 }, to: { translateY: 0, opacity: 1 }, duration: 400, easing: easing.easeOut },
  scaleIn: { from: { scale: 0.8, opacity: 0 }, to: { scale: 1, opacity: 1 }, duration: 300, easing: easing.easeOut },
}
```

**Looping Animations**
```typescript
export const looping = {
  wave: { keyframes: [{ translateY: 0 }, { translateY: -15 }, { translateY: 0 }], duration: 2000, loop: true, easing: easing.easeInOut },
  float: { keyframes: [{ translateY: 0 }, { translateY: -10 }, { translateY: 0 }], duration: 4000, loop: true, easing: easing.easeInOut },
  pulseGlow: { keyframes: [{ shadowOpacity: 0.4 }, { shadowOpacity: 0.8 }, { shadowOpacity: 0.4 }], duration: 3000, loop: true, easing: easing.easeInOut },
  pulseSlow: { keyframes: [{ opacity: 1 }, { opacity: 0.5 }, { opacity: 1 }], duration: 3000, loop: true, easing: easing.easeInOut },
  bounceSubtle: { keyframes: [{ translateY: 0 }, { translateY: -5 }, { translateY: 0 }], duration: 2000, loop: true, easing: easing.easeInOut },
}
```

**Accordion**
```typescript
export const accordion = {
  down: { from: { height: 0, opacity: 0 }, to: { height: 'auto', opacity: 1 }, duration: 200, easing: easing.easeOut },
  up: { from: { height: 'auto', opacity: 1 }, to: { height: 0, opacity: 0 }, duration: 200, easing: easing.easeOut },
}
```

#### Usage
```typescript
import { animations } from '@/design-system/animations';

// Use duration
const duration = animations.durations.normal;

// Use easing
const easing = animations.easing.easeOut;

// Use preset
const fadeIn = animations.presets.fadeIn;
```

---

### theme.ts (Visual Effects Integration)
**File:** `src/design-system/theme.ts`  
**Type:** Theme Service  
**Purpose:** Theme with integrated visual effects

#### Visual Effects Export
```typescript
export const visualEffects = {
  glass: { light, medium, heavy, tap },
  gradients: { primary, secondary, background, text, glow, card },
  shadows: { glass, glow },
  glow: { primary, secondary, accent },
  animations: { fadeIn, slideUp, slideDown, scaleIn, pulse },
}
```

#### Theme Integration
```typescript
export const theme = {
  colors,
  spacing,
  borderRadius,
  typography,
  shadows,
  animations,
  layout,
  components,
  visualEffects, // Integrated visual effects
}
```

#### Usage
```typescript
import { useTheme } from '@/design-system/ThemeProvider';

const theme = useTheme();
const glassEffect = theme.visualEffects.glass.medium;
const gradient = theme.visualEffects.gradients.primary;
```

---

## 🔗 Service Dependencies

### Dependency Graph
```
Visual Effects Components
├── visual-effects.ts
│   └── Theme colors
├── animations.ts
│   └── React Native Reanimated
└── theme.ts
    ├── visual-effects.ts
    └── animations.ts

Animation Components
├── animations.ts
│   └── React Native Reanimated
└── theme.ts
    └── animations.ts
```

### External Dependencies

#### React Native Reanimated
- **Purpose:** Animation library
- **Usage:** Shared values, animated styles, worklets
- **Version:** v3

#### React Native Linear Gradient
- **Purpose:** Gradient rendering
- **Usage:** LinearGradient component
- **Version:** Latest

#### React Native Blur
- **Purpose:** Blur effects
- **Usage:** BlurView component
- **Version:** @react-native-community/blur

#### Theme System
- **Purpose:** Colors and styling
- **Usage:** Brand colors, spacing, typography
- **Location:** `src/design-system/theme.ts`

---

## 🔄 Service Interactions

### Visual Effects Flow
```
Component
    │
    ├─> visual-effects.ts
    │   └─> Get gradient/glass/shadow config
    │       └─> Apply to component
    │
    ├─> animations.ts
    │   └─> Get animation preset
    │       └─> Apply with Reanimated
    │
    └─> theme.ts
        └─> Get integrated visual effects
            └─> Apply to component
```

### Animation Flow
```
Component
    │
    └─> animations.ts
        ├─> Get duration
        ├─> Get easing
        └─> Get preset
            └─> Apply with Reanimated
                └─> Native driver
                    └─> 60fps animation
```

---

## 🧪 Service Testing

### Unit Tests
- Configuration validation
- Preset accuracy
- Type safety
- Default values

### Integration Tests
- Theme integration
- Component usage
- Animation application
- Platform compatibility

### Mocking
- Theme provider
- Animation libraries
- Platform APIs

---

## 📊 Service Metrics

### Performance
- **Configuration Access:** < 1ms
- **Preset Application:** < 5ms
- **Theme Integration:** < 10ms

### Code Quality
- **Type Safety:** 100% TypeScript
- **Reusability:** High (stateless)
- **Maintainability:** High (centralized)

---

## 🔐 Configuration Management

### Environment Variables
- None required (all configs in code)

### Theme Integration
- All effects use theme colors
- Brand colors from `colors.awave`
- Spacing from `spacing` system
- Border radius from `borderRadius` system

### Animation Configuration
- Durations from `animations.durations`
- Easing from `animations.easing`
- Presets from `animations.presets`
- Platform configs from `visual-effects.platformConfig`

---

## 🔄 Service Updates

### Future Enhancements
- Custom animation builder
- Dynamic effect generation
- Performance monitoring
- Animation analytics
- A/B testing support

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
