# Index & Landing Screen - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Core Framework
- **React Native** - Mobile app framework
- **TypeScript** - Type safety and development experience

#### Animation Libraries
- **React Native Reanimated** - High-performance animations (favicon, logo, tagline)
- **React Native Animated** - Standard animations (fade-out, ripple circles)

#### Navigation
- **React Navigation** - Stack navigator for routing
- **@react-navigation/native** - Core navigation library

#### State & Storage
- **AsyncStorage** - Local storage via `storageBridge`
- **onboardingStorage** - Custom storage service

#### Theming & Localization
- **useUnifiedTheme** - Unified theme hook
- **LanguageContext** - Translation context

---

## 📁 File Structure

```
src/
├── screens/
│   └── IndexScreen.tsx              # Main Index screen component
├── hooks/
│   ├── useOnboardingStorage.ts      # Onboarding state storage
│   └── useUnifiedTheme.ts           # Theme hook
├── contexts/
│   └── LanguageContext.tsx          # Translation context
└── navigation/
    └── index.tsx                     # Navigation configuration
```

---

## 🔧 Components

### IndexScreen
**Location:** `src/screens/IndexScreen.tsx`

**Purpose:** Main entry point screen with preloader and routing logic

**Props:** None (root screen)

**State:**
```typescript
const [showPreloader, setShowPreloader] = useState(true);
```

**Features:**
- Renders Preloader component
- Handles routing logic after preloader
- Manages loading state during navigation
- Error handling for storage and navigation

**Dependencies:**
- `Preloader` component (internal)
- `onboardingStorage` service
- `useNavigation` hook
- `useUnifiedTheme` hook

**Navigation Logic:**
```typescript
const handlePreloaderComplete = async () => {
  const { completed, profile } = await onboardingStorage.loadOnboardingState();
  
  if (completed) {
    navigation.navigate('MainTabs');
  } else if (profile) {
    navigation.navigate('OnboardingSlides', { startAtSlide: 4 });
  } else {
    navigation.navigate('OnboardingSlides');
  }
};
```

---

### Preloader Component
**Location:** `src/screens/IndexScreen.tsx` (internal component)

**Purpose:** Animated preloader with branding

**Props:**
```typescript
interface PreloaderProps {
  onComplete: () => void;
}
```

**State:**
```typescript
const [isVisible, setIsVisible] = useState(true);
const fadeAnim = useState(new Animated.Value(1))[0];
const scaleAnim1 = useState(new Animated.Value(1))[0];
const scaleAnim2 = useState(new Animated.Value(1))[0];
const scaleAnim3 = useState(new Animated.Value(1))[0];
const opacityAnim1 = useState(new Animated.Value(0.3))[0];
const opacityAnim2 = useState(new Animated.Value(0.4))[0];
const opacityAnim3 = useState(new Animated.Value(0.5))[0];

// Reanimated values
const faviconScale = useSharedValue(0.8);
const faviconOpacity = useSharedValue(0);
const logoOpacity = useSharedValue(0);
const logoTranslateY = useSharedValue(20);
const taglineOpacity = useSharedValue(0);
const taglineTranslateY = useSharedValue(20);
```

**Features:**
- Favicon pulsation animation
- Logo fade-in with translate
- Tagline fade-in with translate
- Three ripple circle animations
- Fade-out transition
- 3-second display duration

**Animation Timeline:**
```
0ms:    Favicon fades in (800ms)
300ms:  Logo starts fade-in (800ms)
500ms:  Tagline starts fade-in (800ms)
3000ms: Fade-out starts (500ms)
3500ms: onComplete callback
```

---

## 🔌 Services

### onboardingStorage
**Location:** `src/hooks/useOnboardingStorage.ts`

**Type:** Static Service Object

**Purpose:** Manage onboarding state in local storage

**Methods:**

**`loadOnboardingState(): Promise<{completed: boolean, profile: string | null}>`**
- Reads completion flag and profile from storage
- Returns parsed state object
- Handles null/undefined values

**Storage Keys:**
- `awaveOnboardingCompleted` - String 'true' or null
- `awaveOnboardingProfile` - JSON string or null

**Implementation:**
```typescript
async loadOnboardingState(): Promise<{
  completed: boolean;
  profile: string | null;
}> {
  const [completed, profile] = await Promise.all([
    storageBridge.getItem(ONBOARDING_COMPLETED_KEY),
    storageBridge.getItem(ONBOARDING_PROFILE_KEY),
  ]);

  return {
    completed: completed === 'true',
    profile,
  };
}
```

**Dependencies:**
- `storageBridge` - AsyncStorage wrapper

---

## 🎨 Animation Details

### Favicon Animation
**Library:** React Native Reanimated

**Properties:**
- Scale: 0.8 → 1.2 → 0.8 (continuous loop)
- Opacity: 0 → 1 (initial fade-in)
- Duration: 1500ms per cycle
- Easing: Easing.ease

**Implementation:**
```typescript
faviconOpacity.value = withTiming(1, { duration: 800, easing: Easing.ease });
faviconScale.value = withRepeat(
  withSequence(
    withTiming(1.2, { duration: 1500, easing: Easing.ease }),
    withTiming(0.8, { duration: 1500, easing: Easing.ease }),
  ),
  -1, // Infinite loop
  false,
);
```

### Logo Animation
**Library:** React Native Reanimated

**Properties:**
- Opacity: 0 → 1
- TranslateY: 20 → 0
- Delay: 300ms
- Duration: 800ms
- Easing: Easing.ease

**Implementation:**
```typescript
setTimeout(() => {
  logoOpacity.value = withTiming(1, { duration: 800, easing: Easing.ease });
  logoTranslateY.value = withTiming(0, { duration: 800, easing: Easing.ease });
}, 300);
```

### Tagline Animation
**Library:** React Native Reanimated

**Properties:**
- Opacity: 0 → 1
- TranslateY: 20 → 0
- Delay: 500ms
- Duration: 800ms
- Easing: Easing.ease

### Ripple Circle Animations
**Library:** React Native Animated

**Circle 1 (Outer):**
- Scale: 1 → 1.4 → 1
- Opacity: 0.3 → 0 → 0.3
- Duration: 3000ms (1500ms each direction)
- Loop: Infinite

**Circle 2 (Middle):**
- Scale: 1 → 1.3 → 1
- Opacity: 0.4 → 0 → 0.4
- Duration: 2500ms (1250ms each direction)
- Delay: 500ms
- Loop: Infinite

**Circle 3 (Inner):**
- Scale: 1 → 1.2 → 1
- Opacity: 0.5 → 0 → 0.5
- Duration: 2000ms (1000ms each direction)
- Delay: 1000ms
- Loop: Infinite

**Implementation:**
```typescript
const animation1 = Animated.loop(
  Animated.sequence([
    Animated.parallel([
      Animated.timing(scaleAnim1, {
        toValue: 1.4,
        duration: 1500,
        useNativeDriver: true,
      }),
      Animated.timing(opacityAnim1, {
        toValue: 0,
        duration: 1500,
        useNativeDriver: true,
      }),
    ]),
    Animated.parallel([
      Animated.timing(scaleAnim1, {
        toValue: 1,
        duration: 1500,
        useNativeDriver: true,
      }),
      Animated.timing(opacityAnim1, {
        toValue: 0.3,
        duration: 1500,
        useNativeDriver: true,
      }),
    ]),
  ]),
);
```

### Fade-Out Animation
**Library:** React Native Animated

**Properties:**
- Opacity: 1 → 0
- Duration: 500ms
- Trigger: After 3000ms
- Callback: onComplete after additional 500ms

**Implementation:**
```typescript
setTimeout(() => {
  Animated.timing(fadeAnim, {
    toValue: 0,
    duration: 500,
    useNativeDriver: true,
  }).start(() => {
    setIsVisible(false);
    setTimeout(onComplete, 500);
  });
}, 3000);
```

---

## 🎨 Styling

### Theme Integration
**Hook:** `useUnifiedTheme()`

**Properties Used:**
- `theme.colors.background` - Background color
- `theme.colors.textPrimary` - Primary text color
- `theme.colors.textSecondary` - Secondary text color
- `theme.typography.fontSize.base` - Base font size
- `theme.typography.fontFamily.light` - Light font family
- `theme.typography.fontWeight.light` - Light font weight

### StyleSheet Structure
```typescript
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  backgroundCircle: {
    position: 'absolute',
    borderRadius: 150,
    borderWidth: 1,
    backgroundColor: 'transparent',
  },
  favicon: {
    width: 80,
    height: 80,
    marginBottom: 32,
  },
  logo: {
    width: 200,
    height: 60,
  },
  tagline: {
    fontSize: theme.typography.fontSize.base,
    fontFamily: theme.typography.fontFamily.light,
    fontWeight: theme.typography.fontWeight.light,
    color: theme.colors.textSecondary,
    textAlign: 'center',
  },
});
```

### Ripple Circle Positioning
**Circle 1 (Outer):**
- Size: 200x200px
- Position: left: -90px, top: -90px
- Border color: rgba(255, 255, 255, 0.2)

**Circle 2 (Middle):**
- Size: 160x160px
- Position: left: -70px, top: -70px
- Border color: rgba(255, 255, 255, 0.3)

**Circle 3 (Inner):**
- Size: 120x120px
- Position: left: -50px, top: -50px
- Border color: rgba(255, 255, 255, 0.4)

---

## 🌐 External Resources

### CDN Images
**Favicon:**
- URL: `https://cdn.prod.website-files.com/660563701250a201ebbf40c1/660c33c36a776793b1a4c0c9_favicon.ico`
- Size: 80x80px
- Format: ICO

**Logo:**
- URL: `https://cdn.prod.website-files.com/660563701250a201ebbf40c1/66891047763b9604604c0a86_Awave.png`
- Size: 200x60px
- Format: PNG

**Loading:**
- Images loaded via React Native `Image` component
- `resizeMode: 'contain'` to maintain aspect ratio
- No local caching (loaded fresh each time)

---

## 🔄 State Management

### Local State
```typescript
// IndexScreen
const [showPreloader, setShowPreloader] = useState(true);

// Preloader
const [isVisible, setIsVisible] = useState(true);
```

### Storage State
```typescript
// Read from AsyncStorage
const { completed, profile } = await onboardingStorage.loadOnboardingState();
```

### Navigation State
- Managed by React Navigation
- Stack navigator maintains route history
- Navigation params passed programmatically

---

## 🧪 Performance Considerations

### Animation Performance
- **Reanimated** used for 60fps animations (favicon, logo, tagline)
- **Animated API** used for ripple circles (acceptable performance)
- All animations use `useNativeDriver: true` where possible
- Animations run on UI thread (smooth even with JS thread busy)

### Image Loading
- Images loaded from CDN (no local bundle size impact)
- Progressive loading (images appear when ready)
- No blocking (app continues if images fail)

### Storage Performance
- Parallel reads using `Promise.all`
- Async operations don't block UI
- Fast reads (< 100ms typical)

### Memory Management
- Animations cleaned up on unmount
- Timers cleared in useEffect cleanup
- No memory leaks from event listeners

---

## 🐛 Error Handling

### Storage Errors
```typescript
try {
  const { completed, profile } = await onboardingStorage.loadOnboardingState();
  // ... routing logic
} catch (error) {
  console.error('[IndexScreen] Failed to process onboarding state', error);
  // Fallback to full onboarding
  navigation.navigate('OnboardingSlides');
}
```

### Navigation Errors
- Navigation failures are caught by React Navigation
- Fallback navigation always provided
- No app crashes on navigation errors

### Image Loading Errors
- Images fail silently (no error shown to user)
- App continues without images
- No blocking on image load failures

---

## 📱 Platform-Specific Notes

### iOS
- Animations run smoothly on iOS
- Native driver support excellent
- Image loading works reliably

### Android
- Animations perform well on Android
- Some older devices may have reduced performance
- Image loading works reliably

### Common
- Both platforms use same code
- No platform-specific implementations
- Consistent behavior across platforms

---

## 🔐 Security Considerations

### Storage
- Local storage only (no sensitive data)
- Onboarding state is non-sensitive
- No encryption needed

### Network
- CDN images loaded over HTTPS
- No authentication required
- Public resources only

---

## 📊 Performance Metrics

### Target Metrics
- Preloader display: 3000ms
- Storage read: < 100ms
- Navigation transition: < 1000ms
- Total time to next screen: < 5000ms
- Animation frame rate: > 55fps

### Optimization
- Parallel storage reads
- Native driver animations
- Efficient re-renders (minimal state updates)
- Cleanup on unmount

---

*For component structure, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
